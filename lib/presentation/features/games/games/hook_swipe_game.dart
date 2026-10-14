import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/voxi_mood.dart';
import '../game_content.dart';
import '../widgets/game_kit.dart';
import '../widgets/swipe_card.dart';

/// Swipe openings and closings: hook (right) or yawn (left). The audience's
/// attention rises and falls; at zero they fall asleep.
class HookSwipeGame extends StatefulWidget {
  const HookSwipeGame({
    super.key,
    required this.onFinish,
    required this.onClose,
  });

  final OnGameFinish onFinish;
  final VoidCallback onClose;

  @override
  State<HookSwipeGame> createState() => _HookSwipeGameState();
}

class _HookSwipeGameState extends State<HookSwipeGame> {
  static const _secondsPerCard = 5.0;

  late final List<(SwipeCard, bool)> _deck;
  Timer? _timer;
  int _index = 0;
  double _left = _secondsPerCard;
  double _attention = 0.5;
  int _correct = 0;
  int _points = 0;
  int _streak = 0;
  bool? _lastRight;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final random = Random();
    final openings = ([...hookOpenings]..shuffle(random)).take(7);
    final closings = ([...hookClosings]..shuffle(random)).take(3);
    _deck = [
      for (final c in openings) (c, false),
      for (final c in closings) (c, true),
    ]..shuffle(random);
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _lastRight != null) return;
      setState(() {
        _left -= 0.1;
        if (_left <= 0) _resolve(null);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// [right] is null when the time ran out.
  void _resolve(bool? right) {
    final card = _deck[_index].$1;
    final ok = right != null && right == card.isGood;
    playSfx(context, ok ? Sfx.correct : Sfx.wrong);
    _lastRight = ok;
    if (ok) {
      _correct++;
      _streak++;
      _points += (10 + _left.round() * 2) * comboMultiplier(_streak);
      _attention = min(1, _attention + 0.12);
    } else {
      _streak = 0;
      _attention = max(0, _attention - 0.22);
    }
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted || _finished) return;
      if (_attention <= 0 || _index + 1 >= _deck.length) {
        _end();
      } else {
        setState(() {
          _index++;
          _lastRight = null;
          _left = _secondsPerCard;
        });
      }
    });
  }

  void _end() {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    final asleep = _attention <= 0;
    widget.onFinish(
      GameScore(
        points: _points,
        ratio: asleep
            ? min(0.45, _correct / _deck.length)
            : _correct / _deck.length,
        headline: asleep
            ? 'El público se durmió 😴 · $_correct aciertos'
            : '$_correct de ${_deck.length} bien elegidas',
        notes: const [
          'Abrí con una pregunta, una historia breve o una imagen. Dejá los '
              'agradecimientos para después.',
          'Cerrá con un resumen y un llamado a la acción concreto, o '
              'retomando la apertura.',
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (card, isClosing) = _deck[_index];
    final mood = _attention > 0.66
        ? VoxiMood.love
        : (_attention > 0.33 ? VoxiMood.happy : VoxiMood.sleepy);
    return Column(
      children: [
        GameHud(
          onClose: widget.onClose,
          timeLeft: _left / _secondsPerCard,
          points: _points,
          streak: _streak,
          progressColor: AppColors.success,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Image.asset(mood.asset, width: 44, height: 44),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atención del público',
                      style: gameText(
                        12,
                        color: AppColors.darkBrownLight,
                        weight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: _attention),
                        duration: const Duration(milliseconds: 350),
                        builder: (context, v, _) => LinearProgressIndicator(
                          value: v,
                          minHeight: 12,
                          backgroundColor: AppColors.idleLip.withValues(
                            alpha: 0.5,
                          ),
                          color: v > 0.33
                              ? AppColors.success
                              : AppColors.accentRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          isClosing ? '¿Este CIERRE engancha?' : '¿Esta APERTURA engancha?',
          style: gameText(18),
        ),
        Expanded(
          child: SwipeDecider(
            enabled: _lastRight == null,
            leftLabel: 'BOSTEZO',
            rightLabel: 'GANCHO',
            leftIcon: Icons.bedtime_rounded,
            rightIcon: Icons.phishing_rounded,
            onDecide: (right) => setState(() => _resolve(right)),
            child: DeckCard(
              key: ValueKey(_index),
              text: card.text,
              emoji: isClosing ? '🎬' : '🎤',
              caption: _lastRight == null ? null : card.why,
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: _lastRight == null
              ? null
              : Center(
                  child: VerdictBadge(
                    text: _lastRight!
                        ? '¡Bien!'
                        : (card.isGood ? 'Era un gancho' : 'Era un bostezo'),
                    good: _lastRight!,
                  ),
                ),
        ),
      ],
    );
  }
}
