import 'dart:math' as math;

/// Delivery metrics of a spoken take.
///
/// Timing metrics (duration, speaking time, pauses) are measured on the
/// device from the microphone level, so they work offline. Metrics that need
/// to understand the words (filler words, words per minute, transcript) come
/// from the backend speech AI and stay null until it answers.
class SpeechMetrics {
  const SpeechMetrics({
    required this.duration,
    required this.speakingTime,
    required this.pauseCount,
    required this.longestPause,
    this.fillerWords,
    this.wordsPerMinute,
    this.transcript,
  });

  /// Silence shorter than this between two stretches of speech is just the
  /// gap between words, not a pause.
  static const minPause = Duration(milliseconds: 600);

  /// Speech blips shorter than this (a cough, a click) are ignored.
  static const minSpeech = Duration(milliseconds: 200);

  final Duration duration;
  final Duration speakingTime;

  /// Pauses between stretches of speech (silence at the very start and end
  /// is not counted).
  final int pauseCount;
  final Duration longestPause;

  final int? fillerWords;
  final int? wordsPerMinute;
  final String? transcript;

  /// Share of the take spent speaking (0-1).
  double get speakingRatio => duration.inMilliseconds == 0
      ? 0
      : speakingTime.inMilliseconds / duration.inMilliseconds;

  /// Pauses per minute of the take.
  double get pausesPerMinute => duration.inMilliseconds == 0
      ? 0
      : pauseCount / (duration.inMilliseconds / 60000);

  bool get hasSpeech => speakingTime > Duration.zero;

  SpeechMetrics copyWith({
    int? fillerWords,
    int? wordsPerMinute,
    String? transcript,
  }) {
    return SpeechMetrics(
      duration: duration,
      speakingTime: speakingTime,
      pauseCount: pauseCount,
      longestPause: longestPause,
      fillerWords: fillerWords ?? this.fillerWords,
      wordsPerMinute: wordsPerMinute ?? this.wordsPerMinute,
      transcript: transcript ?? this.transcript,
    );
  }

  /// Measures a take from microphone levels in dBFS sampled every
  /// [interval]. The speech threshold adapts to the room: it sits between
  /// the quiet floor and the loud peaks of this very take.
  factory SpeechMetrics.fromLevels(List<double> levels, Duration interval) {
    final duration = interval * levels.length;
    if (levels.isEmpty) {
      return SpeechMetrics(
        duration: duration,
        speakingTime: Duration.zero,
        pauseCount: 0,
        longestPause: Duration.zero,
      );
    }

    final sorted = [...levels]..sort();
    double percentile(double p) =>
        sorted[(p * (sorted.length - 1)).round().clamp(0, sorted.length - 1)];
    final floor = percentile(0.15);
    final peak = percentile(0.95);
    // A flat take (no voice above the room noise) has no speech at all.
    if (peak - floor < 8) {
      return SpeechMetrics(
        duration: duration,
        speakingTime: Duration.zero,
        pauseCount: 0,
        longestPause: Duration.zero,
      );
    }
    final threshold = math.max(floor + (peak - floor) * 0.35, -55.0);

    final minSpeechSamples =
        (minSpeech.inMilliseconds / interval.inMilliseconds).ceil();
    final minPauseSamples = (minPause.inMilliseconds / interval.inMilliseconds)
        .ceil();

    // Runs of speech/silence, dropping speech blips.
    final speaking = [for (final l in levels) l >= threshold];
    final runs = <(bool, int)>[];
    for (final s in speaking) {
      if (runs.isNotEmpty && runs.last.$1 == s) {
        runs[runs.length - 1] = (s, runs.last.$2 + 1);
      } else {
        runs.add((s, 1));
      }
    }
    final cleaned = <(bool, int)>[];
    for (final run in runs) {
      final isSpeech = run.$1 && run.$2 >= minSpeechSamples;
      if (cleaned.isNotEmpty && cleaned.last.$1 == isSpeech) {
        cleaned[cleaned.length - 1] = (isSpeech, cleaned.last.$2 + run.$2);
      } else {
        cleaned.add((isSpeech, run.$2));
      }
    }

    var speechSamples = 0;
    var pauses = 0;
    var longest = 0;
    for (var i = 0; i < cleaned.length; i++) {
      final (isSpeech, length) = cleaned[i];
      if (isSpeech) {
        speechSamples += length;
        continue;
      }
      final internal = i > 0 && i < cleaned.length - 1;
      if (internal && length >= minPauseSamples) {
        pauses++;
        longest = math.max(longest, length);
      }
    }

    return SpeechMetrics(
      duration: duration,
      speakingTime: interval * speechSamples,
      pauseCount: pauses,
      longestPause: interval * longest,
    );
  }
}
