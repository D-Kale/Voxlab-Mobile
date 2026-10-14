import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/media/media_permissions.dart';
import '../../../../data/media/speech_recorder.dart';
import '../../../../data/remote/services/analyzer_service.dart';
import '../../../../domain/models/exercise_outcome.dart';
import '../../../../domain/models/session_result.dart';
import '../../../../domain/models/speech_metrics.dart';
import '../../../shared/widgets/chunky.dart';
import '../../../shared/widgets/lesson_widgets.dart';
import '../../../shared/widgets/motion.dart';
import '../../../shared/widgets/stat_tile.dart';

/// Oratory exercise: records the user's voice while a timer runs, then
/// analyzes the take. The backend speech AI (Whisper) adds the transcript,
/// pace and filler words; on-device timing metrics (pauses, speaking time)
/// are the fallback when it is unreachable or on the web. Users who deny
/// the microphone can still practice with the timer alone.
class OratoryWidget extends ConsumerStatefulWidget {
  const OratoryWidget({
    super.key,
    required this.prompt,
    required this.topic,
    required this.durationSeconds,
    required this.minDurationSeconds,
    required this.requirements,
    required this.points,
    this.onCompleted,
  });

  final String prompt;
  final String topic;
  final int durationSeconds;
  final int minDurationSeconds;
  final List<String> requirements;
  final int points;
  final void Function(ExerciseOutcome outcome)? onCompleted;

  @override
  ConsumerState<OratoryWidget> createState() => _OratoryWidgetState();
}

enum _Phase { preparation, permission, active, analyzing, summary }

class _OratoryWidgetState extends ConsumerState<OratoryWidget> {
  static const _meterBars = 28;

  _Phase _phase = _Phase.preparation;
  MediaAccess _access = MediaAccess.denied;
  int _remainingSeconds = 0;
  int _elapsedSeconds = 0;
  Timer? _timer;

  SpeechRecorder? _recorder;
  StreamSubscription<double>? _levelSub;
  final List<double> _levels = List.filled(_meterBars, 0.0, growable: true);
  bool _recording = false;

  SessionResult? _result;
  SpeechMetrics? _metrics;
  bool _analyzedByAi = false;

  @override
  void dispose() {
    _timer?.cancel();
    _levelSub?.cancel();
    _recorder?.dispose();
    super.dispose();
  }

  Future<void> _requestAndStart() async {
    MediaAccess access;
    try {
      access = await ref.read(mediaPermissionsProvider).requestMicrophone();
    } catch (_) {
      access = MediaAccess.denied;
    }
    if (!mounted) return;
    if (access != MediaAccess.granted) {
      setState(() {
        _access = access;
        _phase = _Phase.permission;
      });
      return;
    }
    await _startTake(record: true);
  }

  Future<void> _startTake({required bool record}) async {
    if (record) {
      final recorder = ref.read(speechRecorderFactoryProvider)();
      try {
        await recorder.start();
        _recorder = recorder;
        _recording = true;
        _levelSub = recorder.levels.listen((level) {
          if (!mounted) return;
          setState(() {
            _levels.removeAt(0);
            _levels.add(level);
          });
        });
        if (mounted) playSfx(context, Sfx.recordStart);
      } catch (e) {
        debugPrint('Oratory recording failed to start: $e');
        await recorder.dispose();
        _recording = false;
      }
    }
    if (!mounted) return;
    setState(() {
      _phase = _Phase.active;
      _remainingSeconds = widget.durationSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        setState(() => _remainingSeconds = 0);
        _finish();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  /// Stops the timer (and the recording) and shows the summary; the
  /// summary's button reports the outcome.
  Future<void> _finish() async {
    if (_phase != _Phase.active) return;
    _timer?.cancel();
    _elapsedSeconds = widget.durationSeconds - _remainingSeconds;

    final recorder = _recorder;
    if (!_recording || recorder == null) {
      setState(() => _phase = _Phase.summary);
      return;
    }

    playSfx(context, Sfx.recordStop);
    setState(() => _phase = _Phase.analyzing);
    unawaited(_levelSub?.cancel());
    _levelSub = null;
    _recording = false;

    SpeechRecording take;
    try {
      take = await recorder.stop();
    } catch (e) {
      debugPrint('Oratory recording failed to stop: $e');
      if (mounted) setState(() => _phase = _Phase.summary);
      return;
    }

    var metrics = take.metrics;
    var result = SessionResultBuilder.fromSpeech(
      metrics,
      targetSeconds: widget.durationSeconds,
      minSeconds: widget.minDurationSeconds,
    );
    var byAi = false;
    final path = take.path;
    if (!kIsWeb && path != null && metrics.hasSpeech) {
      try {
        final json = await ref
            .read(analyzerServiceProvider)
            .analyzeSpeech(
              path: path,
              fileName: take.fileName,
              minSeconds: widget.minDurationSeconds,
              targetSeconds: widget.durationSeconds,
            );
        final data = json['data'] as Map<String, dynamic>? ?? json;
        result = SessionResult.fromJson(json);
        metrics = metrics.copyWith(
          fillerWords: (data['filler_words'] as num?)?.toInt(),
          wordsPerMinute: (data['words_per_minute'] as num?)?.toInt(),
          transcript: data['transcript'] as String?,
        );
        byAi = true;
      } catch (e) {
        // Speech AI unreachable: keep the on-device analysis.
        debugPrint('Speech AI unavailable, using on-device metrics: $e');
      }
    }

    if (!mounted) return;
    setState(() {
      _metrics = metrics;
      _result = result;
      _analyzedByAi = byAi;
      _phase = _Phase.summary;
    });
  }

  double get _progress => widget.durationSeconds == 0
      ? 0
      : _remainingSeconds / widget.durationSeconds;

  @override
  Widget build(BuildContext context) {
    return switch (_phase) {
      _Phase.preparation => _buildPreparation(),
      _Phase.permission => _buildPermission(),
      _Phase.active => _buildActive(),
      _Phase.analyzing => const _Analyzing(),
      _Phase.summary => _buildSummary(),
    };
  }

  Widget _buildPreparation() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VoxiSays(text: widget.prompt),
                const SizedBox(height: 18),
                ChunkyCard(
                  colors: ChunkyColors.brown,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.record_voice_over_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TU TEMA',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            Text(
                              widget.topic,
                              style: GoogleFonts.dmSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.requirements.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Objetivos',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBrownLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final r in widget.requirements)
                        ChunkyTag(
                          label: r,
                          icon: Icons.flag_rounded,
                          color: AppColors.darkBrown,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    ChunkyTag(
                      label: '${widget.durationSeconds}s',
                      icon: Icons.timer_rounded,
                      color: AppColors.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'mínimo ${widget.minDurationSeconds}s',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBrownLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: AppColors.darkBrownLight,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vamos a grabar tu voz para analizar tu ritmo, tus '
                        'pausas y tus muletillas.',
                        style: GoogleFonts.dmSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBrownLight,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Semantics(
            label: 'Grabar ejercicio de oratoria',
            excludeSemantics: true,
            child: ChunkyButton(
              label: 'GRABAR',
              icon: Icons.mic_rounded,
              colors: ChunkyColors.green,
              onPressed: _requestAndStart,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActive() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final urgent = _progress < 0.25;
    final ringColor = urgent ? AppColors.accentRed : AppColors.success;

    return Column(
      children: [
        const Spacer(),
        Text(
          widget.topic,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.darkBrown,
          ),
        ),
        const SizedBox(height: 24),
        Semantics(
          label: 'Tiempo restante: $minutes minutos con $seconds segundos',
          excludeSemantics: true,
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PulseHalo(color: ringColor, diameter: 200, spread: 20),
                SizedBox(
                  width: 210,
                  height: 210,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: _progress),
                    duration: const Duration(milliseconds: 900),
                    builder: (context, v, _) => CircularProgressIndicator(
                      value: v,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppColors.cardBorder,
                      valueColor: AlwaysStoppedAnimation(ringColor),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic_rounded, color: ringColor, size: 34),
                    Text(
                      '$minutes:${seconds.toString().padLeft(2, '0')}',
                      style: GoogleFonts.dmSans(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        color: urgent
                            ? AppColors.accentRed
                            : AppColors.darkBrown,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '¡Hablá!',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBrownLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        if (_recording) ...[
          _LevelMeter(levels: _levels, color: ringColor),
          const SizedBox(height: 10),
          const _RecordingBadge(),
        ] else
          Text(
            'Práctica sin grabación',
            style: GoogleFonts.dmSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBrownLight,
            ),
          ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Semantics(
            label: 'Finalizar ejercicio de oratoria',
            excludeSemantics: true,
            child: ChunkyButton(
              label: 'TERMINÉ',
              icon: Icons.stop_rounded,
              colors: ChunkyColors.red,
              onPressed: _finish,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermission() {
    final blocked = _access == MediaAccess.permanentlyDenied;
    return Column(
      children: [
        const Spacer(),
        Bob(
          child: Image.asset(
            'assets/images/voxi_awake.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Necesito escucharte',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.darkBrown,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          blocked
              ? 'El micrófono está bloqueado para Voxlab. Activalo en los '
                    'ajustes para analizar tu ritmo, tus pausas y tus '
                    'muletillas.'
              : 'Permití el micrófono para que pueda analizar tu ritmo, tus '
                    'pausas y tus muletillas. La grabación solo se usa para '
                    'el análisis.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBrownLight,
            height: 1.4,
          ),
        ),
        const Spacer(),
        ChunkyButton(
          label: blocked ? 'ABRIR AJUSTES' : 'PERMITIR MICRÓFONO',
          icon: blocked ? Icons.settings_rounded : Icons.mic_rounded,
          colors: ChunkyColors.green,
          onPressed: blocked
              ? () => ref.read(mediaPermissionsProvider).openSettings()
              : _requestAndStart,
        ),
        const SizedBox(height: 12),
        ChunkyButton(
          label: 'PRACTICAR SIN GRABAR',
          colors: ChunkyColors.white,
          onPressed: () => _startTake(record: false),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSummary() {
    final result = _result;
    final metrics = _metrics;
    final metMinimum = _elapsedSeconds >= widget.minDurationSeconds;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EntranceAnimation(
                  scaleFrom: 0.4,
                  child: Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: metMinimum
                            ? AppColors.success
                            : AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: metMinimum
                                ? AppColors.successDark
                                : AppColors.primaryDark,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        metMinimum ? Icons.mic_rounded : Icons.mic_none_rounded,
                        size: 44,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  metMinimum ? '¡Muy bien hablado!' : '¡Buen intento!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metMinimum
                      ? 'Hablaste ${_elapsedSeconds}s'
                      : 'Hablaste ${_elapsedSeconds}s · la próxima, intentá '
                            'llegar a ${widget.minDurationSeconds}s',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: metMinimum
                        ? AppColors.darkBrownLight
                        : AppColors.accentRed,
                  ),
                ),
                if (metrics != null) ...[
                  const SizedBox(height: 18),
                  Center(
                    child: ChunkyTag(
                      label: _analyzedByAi
                          ? 'Analizado con IA'
                          : 'Análisis en el dispositivo',
                      icon: _analyzedByAi
                          ? Icons.auto_awesome_rounded
                          : Icons.phone_iphone_rounded,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _MetricsGrid(metrics: metrics),
                  if (result != null && result.tips.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    for (final tip in result.tips.take(2))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              tip.isPositive
                                  ? Icons.check_circle_rounded
                                  : Icons.trending_up_rounded,
                              size: 20,
                              color: tip.isPositive
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip.text,
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkBrown,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  if ((metrics.transcript ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ChunkyCard(
                      depth: 4,
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lo que dijiste',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkBrown,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            metrics.transcript!,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkBrownLight,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: ChunkyButton(
            label: 'CONTINUAR',
            colors: ChunkyColors.green,
            onPressed: () => widget.onCompleted?.call(
              ExerciseOutcome(score: widget.points, sessionResult: result),
            ),
          ),
        ),
      ],
    );
  }
}

/// Live microphone level as a row of bars (newest on the right).
class _LevelMeter extends StatelessWidget {
  const _LevelMeter({required this.levels, required this.color});

  final List<double> levels;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Nivel de tu voz',
      excludeSemantics: true,
      child: SizedBox(
        height: 48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final level in levels)
              AnimatedContainer(
                duration: const Duration(milliseconds: 90),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 5,
                height: 6 + 42 * level,
                decoration: BoxDecoration(
                  color: Color.lerp(AppColors.cardBorder, color, level),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecordingBadge extends StatelessWidget {
  const _RecordingBadge();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppColors.accentRed,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Grabando',
          style: GoogleFonts.dmSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: AppColors.accentRed,
          ),
        ),
      ],
    );
  }
}

class _Analyzing extends StatelessWidget {
  const _Analyzing();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Bob(
            amplitude: 6,
            child: Image.asset(
              'assets/images/voxi_awake.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Escuchando tu grabación...',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analizo tu ritmo, tus pausas y tus muletillas.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBrownLight,
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(
            width: 160,
            child: LinearProgressIndicator(
              minHeight: 10,
              borderRadius: BorderRadius.all(Radius.circular(99)),
              color: AppColors.success,
              backgroundColor: AppColors.cardBorder,
            ),
          ),
        ],
      ),
    );
  }
}

/// Duration, pauses, pace and filler words; AI-only values show "—" when
/// only the on-device analysis ran.
class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.metrics});

  final SpeechMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final seconds = metrics.duration.inSeconds;
    final tiles = [
      (
        Icons.timer_rounded,
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
        'Duración',
      ),
      (Icons.pause_circle_rounded, '${metrics.pauseCount}', 'Pausas'),
      (
        Icons.speed_rounded,
        metrics.wordsPerMinute?.toString() ?? '—',
        'Palabras/min',
      ),
      (
        Icons.record_voice_over_rounded,
        metrics.fillerWords?.toString() ?? '—',
        'Muletillas',
      ),
    ];
    return Column(
      children: [
        for (var row = 0; row < 2; row++) ...[
          if (row > 0) const SizedBox(height: 10),
          Row(
            children: [
              for (var col = 0; col < 2; col++) ...[
                if (col > 0) const SizedBox(width: 10),
                Expanded(
                  child: StatTile(
                    icon: tiles[row * 2 + col].$1,
                    color: AppColors.darkBrown,
                    value: tiles[row * 2 + col].$2,
                    label: tiles[row * 2 + col].$3,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
