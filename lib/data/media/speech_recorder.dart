import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../domain/models/speech_metrics.dart';

/// A finished take: where the audio is and its on-device metrics.
class SpeechRecording {
  const SpeechRecording({
    required this.path,
    required this.fileName,
    required this.metrics,
  });

  /// File path on mobile; a blob URL on the web.
  final String? path;
  final String fileName;
  final SpeechMetrics metrics;
}

/// Records the user's voice and samples its level for the live meter and
/// the on-device pause analysis.
abstract class SpeechRecorder {
  /// Microphone level, 0 (silence) to 1 (loud), every [sampleInterval].
  Stream<double> get levels;

  Future<void> start();

  Future<SpeechRecording> stop();

  Future<void> dispose();

  static const sampleInterval = Duration(milliseconds: 100);
}

class RecordSpeechRecorder implements SpeechRecorder {
  final AudioRecorder _recorder = AudioRecorder();
  final _levels = StreamController<double>.broadcast();
  final List<double> _dbfs = [];
  StreamSubscription<Amplitude>? _amplitude;
  String _fileName = 'take.m4a';

  @override
  Stream<double> get levels => _levels.stream;

  @override
  Future<void> start() async {
    _dbfs.clear();
    final encoder = await _pickEncoder();
    final ext = switch (encoder) {
      AudioEncoder.opus => 'webm',
      AudioEncoder.wav => 'wav',
      _ => 'm4a',
    };
    _fileName = 'voxlab_${DateTime.now().millisecondsSinceEpoch}.$ext';
    final path = kIsWeb
        ? _fileName
        : '${(await getTemporaryDirectory()).path}/$_fileName';

    await _recorder.start(
      RecordConfig(
        encoder: encoder,
        sampleRate: 44100,
        numChannels: 1,
        bitRate: 64000,
      ),
      path: path,
    );
    _amplitude = _recorder
        .onAmplitudeChanged(SpeechRecorder.sampleInterval)
        .listen((a) {
          final db = a.current.isFinite ? a.current : -160.0;
          _dbfs.add(db);
          _levels.add(((db + 60) / 60).clamp(0.0, 1.0));
        });
  }

  @override
  Future<SpeechRecording> stop() async {
    await _amplitude?.cancel();
    _amplitude = null;
    final path = await _recorder.stop();
    return SpeechRecording(
      path: path,
      fileName: _fileName,
      metrics: SpeechMetrics.fromLevels(
        List.of(_dbfs),
        SpeechRecorder.sampleInterval,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    await _amplitude?.cancel();
    await _levels.close();
    await _recorder.dispose();
  }

  /// AAC is small and widely decodable; browsers often only do Opus or WAV.
  Future<AudioEncoder> _pickEncoder() async {
    for (final encoder in [
      AudioEncoder.aacLc,
      AudioEncoder.opus,
      AudioEncoder.wav,
    ]) {
      if (await _recorder.isEncoderSupported(encoder)) return encoder;
    }
    return AudioEncoder.aacLc;
  }
}

/// A fresh recorder per take; overridden in tests.
final speechRecorderFactoryProvider = Provider<SpeechRecorder Function()>(
  (ref) => RecordSpeechRecorder.new,
);
