import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/voxi_mood.dart';
import '../widgets/game_kit.dart';

enum _Step {
  inhale('INHALÁ', 'Mantené apretado'),
  hold('SOSTENÉ', 'Seguí apretando'),
  exhale('EXHALÁ', 'Soltá y no toques'),
  wait('ESPERÁ', 'Sin tocar');

  const _Step(this.label, this.hint);

  final String label;
  final String hint;

  bool get wantsPress => this == inhale || this == hold;
}

/// Box breathing (4-4-4-4): press while inhaling and holding, release while
/// exhaling and waiting. Four cycles.
class BreathBalloonGame extends StatefulWidget {
  const BreathBalloonGame({
    super.key,
    required this.onFinish,
    required this.onClose,
  });

  final OnGameFinish onFinish;
  final VoidCallback onClose;

  @override
  State<BreathBalloonGame> createState() => _BreathBalloonGameState();
}

class _BreathBalloonGameState extends State<BreathBalloonGame> {
  static const _cycles = 4;
  static const _stepSeconds = 4.0;
  static const _cycleSeconds = _stepSeconds * 4;
  static const _lead = 2.0;

  /// Seconds around a step change where either state counts as right.
  static const _grace = 0.45;

  Timer? _timer;
  double _t = -_lead;
  bool _pressing = false;
  int _samples = 0;
  int _good = 0;
  int _cycleGood = 0;
  int _cycleSamples = 0;
  final List<double> _cycleScores = [];
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _onTick(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double get _inCycle => _t % _cycleSeconds;
  int get _cycle => (_t / _cycleSeconds).floor();
  _Step get _step =>
      _Step.values[(_inCycle / _stepSeconds).floor().clamp(0, 3)];
  double get _stepProgress => (_inCycle % _stepSeconds) / _stepSeconds;

  void _onTick() {
    if (!mounted || _finished) return;
    setState(() {
      final previousCycle = _t < 0 ? -1 : _cycle;
      _t += 0.1;
      if (_t < 0) return;
      if (_cycle != previousCycle && previousCycle >= 0) _closeCycle();
      if (_cycle >= _cycles) {
        _end();
        return;
      }
      final nearChange = _distanceToChange() < _grace;
      if (!nearChange) {
        _samples++;
        _cycleSamples++;
        if (_pressing == _step.wantsPress) {
          _good++;
          _cycleGood++;
        }
      }
    });
  }

  /// Distance in seconds to the closest press/release change (0, 8, 16).
  double _distanceToChange() {
    final x = _inCycle;
    return [x, (x - 8).abs(), (_cycleSeconds - x)].reduce(min);
  }

  void _closeCycle() {
    final score = _cycleSamples == 0 ? 0.0 : _cycleGood / _cycleSamples;
    _cycleScores.add(score);
    _cycleGood = 0;
    _cycleSamples = 0;
    playSfx(context, score >= 0.75 ? Sfx.correct : Sfx.pop);
  }

  void _end() {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    final ratio = _samples == 0 ? 0.0 : _good / _samples;
    final perfect = _cycleScores.where((s) => s >= 0.9).length;
    widget.onFinish(
      GameScore(
        points: (_good * 2.5).round(),
        ratio: ratio,
        headline: '$perfect de $_cycles ciclos impecables',
        notes: const [
          'Podés hacer esta respiración antes de cualquier charla, sin que '
              'nadie lo note.',
          'Exhalar lento es la clave: le avisa a tu cuerpo que no hay peligro.',
        ],
      ),
    );
  }

  /// Guide balloon size, 0.45 (empty) to 1 (full).
  double get _guideSize {
    if (_t < 0) return 0.45;
    return switch (_step) {
      _Step.inhale => 0.45 + 0.55 * _stepProgress,
      _Step.hold => 1,
      _Step.exhale => 1 - 0.55 * _stepProgress,
      _Step.wait => 0.45,
    };
  }

  @override
  Widget build(BuildContext context) {
    final ready = _t >= 0;
    final right =
        !ready || _pressing == _step.wantsPress || _distanceToChange() < _grace;
    final ratio = _samples == 0 ? 0.0 : _good / _samples;
    final secondsLeft = ready
        ? (_stepSeconds - _inCycle % _stepSeconds).ceil()
        : _t.abs().ceil();

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => setState(() => _pressing = true),
      onPointerUp: (_) => setState(() => _pressing = false),
      onPointerCancel: (_) => setState(() => _pressing = false),
      child: Column(
        children: [
          GameHud(
            onClose: widget.onClose,
            timeLeft: ready ? 1 - _t / (_cycleSeconds * _cycles) : 1,
            progressColor: AppColors.success,
          ),
          Text(
            ready
                ? 'Ciclo ${min(_cycle + 1, _cycles)} de $_cycles'
                : 'Preparate…',
            style: gameText(
              14,
              color: AppColors.darkBrownLight,
              weight: FontWeight.w800,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, box) {
                final balloon =
                    min(box.maxWidth, box.maxHeight) * 0.55 * _guideSize;
                // Voxi climbs as the accuracy grows.
                final lift = (box.maxHeight - 120) * ratio * 0.5;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    for (var i = 0; i < _cycleScores.length; i++)
                      Positioned(
                        top: 20.0 + i * 8,
                        left: 30.0 + i * 70,
                        child: Icon(
                          Icons.star_rounded,
                          size: 30,
                          color: _cycleScores[i] >= 0.75
                              ? AppColors.gold
                              : AppColors.idleLip,
                        ),
                      ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      bottom: 20 + lift,
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            width: balloon,
                            height: balloon * 1.15,
                            decoration: BoxDecoration(
                              color: right
                                  ? AppColors.accentRed
                                  : AppColors.idleLip,
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(balloon, balloon * 1.15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: right
                                      ? AppColors.accentRedDark
                                      : AppColors.darkBrownLight,
                                  offset: const Offset(-6, 6),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ready ? _step.label : '¡YA!',
                                  style: gameText(
                                    max(14, balloon * 0.13),
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '$secondsLeft',
                                  style: gameText(
                                    max(18, balloon * 0.2),
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 40,
                            color: AppColors.darkBrownLight,
                          ),
                          Image.asset(
                            (right ? VoxiMood.happy : VoxiMood.shy).asset,
                            width: 80,
                            height: 80,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
            child: Column(
              children: [
                Text(
                  ready ? _step.hint : 'Al empezar, mantené apretado',
                  style: gameText(18),
                ),
                const SizedBox(height: 6),
                Text(
                  _pressing ? 'Apretando' : 'Sin tocar',
                  style: gameText(
                    14,
                    color: AppColors.darkBrownLight,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
