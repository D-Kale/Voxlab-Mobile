import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/chunky.dart';
import '../game_content.dart';
import '../widgets/game_kit.dart';

/// Rapid fire: is each belief about nerves a myth or a fact?
class MythFactGame extends StatefulWidget {
  const MythFactGame({
    super.key,
    required this.onFinish,
    required this.onClose,
  });

  final OnGameFinish onFinish;
  final VoidCallback onClose;

  @override
  State<MythFactGame> createState() => _MythFactGameState();
}

class _MythFactGameState extends State<MythFactGame> {
  static const _rounds = 10;
  static const _seconds = 4.0;

  late final List<MythFact> _deck;
  Timer? _timer;
  int _index = 0;
  double _left = _seconds;
  bool? _picked;
  bool _timedOut = false;
  int _correct = 0;
  int _points = 0;
  int _streak = 0;
  int _bestStreak = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _deck = ([...mythFacts]..shuffle(Random())).take(_rounds).toList();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _picked != null || _timedOut) return;
      setState(() {
        _left -= 0.1;
        if (_left <= 0) {
          _timedOut = true;
          _streak = 0;
          playSfx(context, Sfx.wrong);
          _next();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  MythFact get _item => _deck[_index];

  void _answer(bool fact) {
    if (_picked != null || _timedOut) return;
    final ok = fact == _item.isFact;
    playSfx(context, ok ? Sfx.correct : Sfx.wrong);
    setState(() {
      _picked = fact;
      if (ok) {
        _correct++;
        _streak++;
        _bestStreak = max(_bestStreak, _streak);
        _points += (10 + (_left * 3).round()) * comboMultiplier(_streak);
      } else {
        _streak = 0;
      }
    });
    _next();
  }

  void _next() {
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted || _finished) return;
      if (_index + 1 >= _deck.length) {
        _end();
      } else {
        setState(() {
          _index++;
          _picked = null;
          _timedOut = false;
          _left = _seconds;
        });
      }
    });
  }

  void _end() {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    widget.onFinish(
      GameScore(
        points: _points,
        ratio: _correct / _deck.length,
        headline: '$_correct de ${_deck.length} · mejor racha: $_bestStreak',
        notes: const [
          'El público nota tus nervios mucho menos de lo que creés.',
          'No hace falta eliminar los nervios: usalos como energía.',
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final answered = _picked != null || _timedOut;
    final ok = _picked == _item.isFact;
    return Column(
      children: [
        GameHud(
          onClose: widget.onClose,
          timeLeft: _left / _seconds,
          points: _points,
          streak: _streak,
          progressColor: AppColors.success,
        ),
        Text(
          '${_index + 1} de ${_deck.length}',
          style: gameText(
            14,
            color: AppColors.darkBrownLight,
            weight: FontWeight.w800,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: ChunkyCard(
                    key: ValueKey(_index),
                    radius: 26,
                    depth: 7,
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                    child: Column(
                      children: [
                        Text(
                          _item.statement,
                          textAlign: TextAlign.center,
                          style: gameText(23, height: 1.25),
                        ),
                        if (answered) ...[
                          const SizedBox(height: 14),
                          Text(
                            _item.isFact ? 'REALIDAD' : 'MITO',
                            style: gameText(
                              16,
                              color: _item.isFact
                                  ? AppColors.successDark
                                  : AppColors.accentRed,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _item.why,
                            textAlign: TextAlign.center,
                            style: gameText(
                              15,
                              color: AppColors.darkBrownLight,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 48,
                  child: answered
                      ? VerdictBadge(
                          text: _timedOut
                              ? '¡Muy lento!'
                              : (ok ? '¡Correcto!' : 'Nop'),
                          good: !_timedOut && ok,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Row(
            children: [
              Expanded(
                child: ChunkyButton(
                  label: 'MITO',
                  icon: Icons.close_rounded,
                  height: 64,
                  colors: ChunkyColors.red,
                  onPressed: answered ? null : () => _answer(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChunkyButton(
                  label: 'REALIDAD',
                  icon: Icons.check_rounded,
                  height: 64,
                  colors: ChunkyColors.green,
                  onPressed: answered ? null : () => _answer(true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
