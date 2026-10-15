import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/media/speech_recorder.dart';
import '../../../shared/widgets/chunky.dart';
import '../../../shared/widgets/voxi_mood.dart';
import 'game_kit.dart';
import 'voice_helpers.dart';

enum _Phase { idle, prep, recording, analyzing, error }

/// "Think, then speak" panel: a prep countdown, a take between [minSeconds]
/// and [maxSeconds], then the speech AI. Reports the analysis and length.
class TimedSpeech extends ConsumerStatefulWidget {
  const TimedSpeech({
    super.key,
    required this.prepSeconds,
    required this.minSeconds,
    required this.maxSeconds,
    required this.topic,
    required this.onResult,
    this.startLabel = '¡EMPEZAR!',
  });

  final int prepSeconds;
  final int minSeconds;
  final int maxSeconds;

  /// Sent to the AI coach so its tip is about this challenge.
  final String topic;
  final void Function(SpeechAnalysis analysis, double seconds) onResult;
  final String startLabel;

  @override
  ConsumerState<TimedSpeech> createState() => _TimedSpeechState();
}

class _TimedSpeechState extends ConsumerState<TimedSpeech> {
  _Phase _phase = _Phase.idle;
  Timer? _timer;
  double _clock = 0;
  double _level = 0;
  SpeechRecorder? _recorder;
  StreamSubscription<double>? _levelSub;

  @override
  void dispose() {
    _timer?.cancel();
    _levelSub?.cancel();
    _recorder?.dispose();
    super.dispose();
  }

  Future<void> _begin() async {
    if (!await ensureMicrophone(context, ref) || !mounted) return;
    playSfx(context, Sfx.tap);
    setState(() {
      _phase = _Phase.prep;
      _clock = widget.prepSeconds.toDouble();
    });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() => _clock -= 0.1);
      if (_clock <= 0) {
        _timer?.cancel();
        _record();
      }
    });
  }

  Future<void> _record() async {
    final recorder = ref.read(speechRecorderFactoryProvider)();
    try {
      await recorder.start();
    } catch (_) {
      await recorder.dispose();
      if (mounted) setState(() => _phase = _Phase.error);
      return;
    }
    if (!mounted) {
      await recorder.dispose();
      return;
    }
    playSfx(context, Sfx.recordStart);
    _recorder = recorder;
    _levelSub = recorder.levels.listen((l) => _level = l);
    setState(() {
      _phase = _Phase.recording;
      _clock = 0;
    });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() => _clock += 0.1);
      if (_clock >= widget.maxSeconds) _stop();
    });
  }

  Future<void> _stop() async {
    final recorder = _recorder;
    if (recorder == null) return;
    _recorder = null;
    _timer?.cancel();
    await _levelSub?.cancel();
    final seconds = _clock;
    if (mounted) {
      playSfx(context, Sfx.recordStop);
      setState(() => _phase = _Phase.analyzing);
    }
    try {
      final take = await recorder.stop();
      await recorder.dispose();
      final analysis = await analyzeTake(
        ref,
        take,
        topic: widget.topic,
        minSeconds: widget.minSeconds,
        targetSeconds: widget.maxSeconds,
      );
      if (mounted) widget.onResult(analysis, seconds);
    } catch (_) {
      if (mounted) setState(() => _phase = _Phase.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_phase) {
      case _Phase.idle:
        return ChunkyButton(
          label: widget.startLabel,
          icon: Icons.mic_rounded,
          colors: ChunkyColors.green,
          onPressed: _begin,
        );
      case _Phase.prep:
        return Column(
          children: [
            Text('Pensá tu estructura…', style: gameText(18)),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              key: ValueKey(_clock.ceil()),
              tween: Tween(begin: 1.4, end: 1),
              duration: const Duration(milliseconds: 300),
              builder: (context, v, child) =>
                  Transform.scale(scale: v, child: child),
              child: Text(
                '${_clock.ceil()}',
                style: gameText(64, color: AppColors.accentRed),
              ),
            ),
          ],
        );
      case _Phase.recording:
        final canStop = _clock >= widget.minSeconds;
        return Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: (_clock / widget.maxSeconds).clamp(0.0, 1.0),
                minHeight: 12,
                backgroundColor: AppColors.idleLip.withValues(alpha: 0.5),
                color: canStop ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            MicButton(
              recording: true,
              level: _level,
              onPressed: canStop ? _stop : null,
              label: canStop
                  ? '${_clock.floor()} s · tocá para terminar'
                  : 'Hablá al menos ${widget.minSeconds} s (${_clock.floor()} s)',
            ),
          ],
        );
      case _Phase.analyzing:
        return Column(
          children: [
            Image.asset(VoxiMood.thinking.asset, width: 90, height: 90),
            const SizedBox(height: 8),
            Text('Voxi está analizando tu charla…', style: gameText(17)),
            const SizedBox(height: 12),
            const CircularProgressIndicator(color: AppColors.accentRed),
          ],
        );
      case _Phase.error:
        return Column(
          children: [
            Text(
              'No pudimos analizar tu voz. Revisá tu conexión e intentá de nuevo.',
              textAlign: TextAlign.center,
              style: gameText(16, weight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ChunkyButton(
              label: 'REINTENTAR',
              icon: Icons.replay_rounded,
              onPressed: () => setState(() => _phase = _Phase.idle),
            ),
          ],
        );
    }
  }
}
