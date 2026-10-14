import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/media/speech_recorder.dart';
import '../../../shared/widgets/chunky.dart';
import '../../../shared/widgets/voxi_mood.dart';
import '../game_content.dart';
import '../widgets/game_kit.dart';
import '../widgets/voice_helpers.dart';

enum _Phase { ready, recording, analyzing, verdict, error }

/// Say the tongue twister clearly within the time of each gear: slow,
/// normal and turbo.
class TongueTwisterGame extends ConsumerStatefulWidget {
  const TongueTwisterGame({
    super.key,
    required this.onFinish,
    required this.onClose,
  });

  final OnGameFinish onFinish;
  final VoidCallback onClose;

  @override
  ConsumerState<TongueTwisterGame> createState() => _TongueTwisterGameState();
}

class _TongueTwisterGameState extends ConsumerState<TongueTwisterGame> {
  static const _gears = ['🐢 Lento', '🚲 Normal', '🚀 Turbo'];
  static const _passSimilarity = 0.78;

  /// Reaction time before speaking, not counted against the limit.
  static const _grace = 0.8;

  late final TongueTwister _twister;
  _Phase _phase = _Phase.ready;
  int _gear = 0;
  int _lives = 2;
  final List<double> _similarities = [];
  int _gearsPassed = 0;

  SpeechRecorder? _recorder;
  StreamSubscription<double>? _levelSub;
  Timer? _timer;
  double _elapsed = 0;
  double _level = 0;

  double _lastSimilarity = 0;
  bool _lastInTime = true;
  List<String> _lastMissing = const [];
  String _lastHeard = '';
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _twister = tongueTwisters[Random().nextInt(tongueTwisters.length)];
  }

  @override
  void dispose() {
    _timer?.cancel();
    _levelSub?.cancel();
    _recorder?.dispose();
    super.dispose();
  }

  double get _limit => _twister.limits[_gear];

  Future<void> _start() async {
    if (!await ensureMicrophone(context, ref) || !mounted) return;
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
    _elapsed = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() => _elapsed += 0.1);
      if (_elapsed >= _limit + _grace + 1.5) _stop();
    });
    setState(() => _phase = _Phase.recording);
  }

  Future<void> _stop() async {
    final recorder = _recorder;
    if (recorder == null) return;
    _recorder = null;
    _timer?.cancel();
    await _levelSub?.cancel();
    final elapsed = _elapsed;
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
        targetSeconds: _limit.ceil(),
      );
      if (!mounted) return;
      _judge(analysis.transcript, elapsed);
    } catch (_) {
      if (mounted) setState(() => _phase = _Phase.error);
    }
  }

  void _judge(String heard, double elapsed) {
    final similarity = speechSimilarity(_twister.text, heard);
    final inTime = elapsed <= _limit + _grace;
    final passed = similarity >= _passSimilarity && inTime;
    _similarities.add(similarity);
    playSfx(context, passed ? Sfx.correct : Sfx.wrong);
    setState(() {
      _lastSimilarity = similarity;
      _lastInTime = inTime;
      _lastHeard = heard;
      _lastMissing = missingWords(_twister.text, heard);
      if (passed) {
        _gearsPassed++;
      } else {
        _lives--;
      }
      _phase = _Phase.verdict;
    });
  }

  bool get _lastPassed => _lastSimilarity >= _passSimilarity && _lastInTime;

  void _continue() {
    if (_lastPassed && _gear < _gears.length - 1) {
      setState(() {
        _gear++;
        _phase = _Phase.ready;
      });
    } else if (!_lastPassed && _lives > 0) {
      setState(() => _phase = _Phase.ready);
    } else {
      _end();
    }
  }

  void _end() {
    if (_finished) return;
    _finished = true;
    final avg = _similarities.isEmpty
        ? 0.0
        : _similarities.reduce((a, b) => a + b) / _similarities.length;
    widget.onFinish(
      GameScore(
        points: _gearsPassed * 100 + (avg * 100).round(),
        ratio: _gearsPassed / 3 * 0.75 + avg * 0.25,
        headline: _gearsPassed == 3
            ? '¡Llegaste a turbo! Claridad: ${(avg * 100).round()} %'
            : 'Llegaste a ${_gears[_gearsPassed.clamp(0, 2)]} · claridad '
                  '${(avg * 100).round()} %',
        notes: [
          'La claridad va antes que la velocidad: subí de marcha solo cuando '
              'te salga perfecto.',
          if (_lastMissing.isNotEmpty)
            'Practicá estas palabras despacio: ${_lastMissing.take(5).join(', ')}.',
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GameHud(
          onClose: widget.onClose,
          timeLeft: _phase == _Phase.recording
              ? 1 - _elapsed / (_limit + _grace)
              : null,
          lives: _lives,
          maxLives: 2,
          points: _gearsPassed * 100,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _gears.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChunkyTag(
                    label: _gears[i],
                    color: i < _gearsPassed
                        ? AppColors.successDark
                        : (i == _gear
                              ? AppColors.accentRed
                              : AppColors.darkBrownLight),
                    filled: i == _gear,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            children: [
              ChunkyCard(
                radius: 24,
                padding: const EdgeInsets.all(20),
                child: Text(
                  _twister.text,
                  textAlign: TextAlign.center,
                  style: gameText(22, height: 1.3),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Tiempo: ${_limit.toStringAsFixed(_limit % 1 == 0 ? 0 : 1)} s',
                  style: gameText(
                    16,
                    color: AppColors.darkBrownLight,
                    weight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ..._phaseBody(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _phaseBody() {
    switch (_phase) {
      case _Phase.ready:
        return [
          Center(
            child: MicButton(
              recording: false,
              onPressed: _start,
              label: 'Tocá y decilo',
            ),
          ),
        ];
      case _Phase.recording:
        return [
          Center(
            child: MicButton(
              recording: true,
              level: _level,
              onPressed: _stop,
              label: '${_elapsed.toStringAsFixed(1)} s · tocá al terminar',
            ),
          ),
        ];
      case _Phase.analyzing:
        return [
          Center(
            child: Image.asset(VoxiMood.thinking.asset, width: 96, height: 96),
          ),
          const SizedBox(height: 10),
          Center(child: Text('Voxi está escuchando…', style: gameText(18))),
          const SizedBox(height: 14),
          const Center(
            child: CircularProgressIndicator(color: AppColors.accentRed),
          ),
        ];
      case _Phase.error:
        return [
          Center(child: Image.asset(VoxiMood.shy.asset, width: 96, height: 96)),
          const SizedBox(height: 10),
          Text(
            'No pudimos analizar tu voz. Revisá tu conexión e intentá de nuevo.',
            textAlign: TextAlign.center,
            style: gameText(16, weight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ChunkyButton(
            label: 'REINTENTAR',
            icon: Icons.replay_rounded,
            onPressed: () => setState(() => _phase = _Phase.ready),
          ),
        ];
      case _Phase.verdict:
        final passed = _lastPassed;
        return [
          Center(
            child: VerdictBadge(
              text: passed
                  ? (_gear == _gears.length - 1
                        ? '¡TURBO superado!'
                        : '¡Pasaste de marcha!')
                  : (_lastInTime
                        ? 'No se entendió del todo'
                        : '¡Te pasaste de tiempo!'),
              good: passed,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Claridad: ${(_lastSimilarity * 100).round()} %',
              style: gameText(18),
            ),
          ),
          if (_lastHeard.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Voxi escuchó: "$_lastHeard"',
              textAlign: TextAlign.center,
              style: gameText(
                14,
                color: AppColors.darkBrownLight,
                weight: FontWeight.w600,
              ),
            ),
          ],
          if (_lastMissing.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final word in _lastMissing.take(6))
                  ChunkyTag(label: word, color: AppColors.accentRed),
              ],
            ),
          ],
          const SizedBox(height: 20),
          ChunkyButton(
            label: passed
                ? (_gear < _gears.length - 1
                      ? 'SIGUIENTE MARCHA'
                      : 'VER RESULTADO')
                : (_lives > 0 ? 'OTRA VEZ' : 'VER RESULTADO'),
            colors: ChunkyColors.green,
            onPressed: _continue,
          ),
        ];
    }
  }
}
