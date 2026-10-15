import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../game_content.dart';
import '../widgets/game_kit.dart';
import '../widgets/swipe_card.dart';

/// Swipe each pose: right if it conveys confidence, left if nerves.
class BodySwipeGame extends StatefulWidget {
  const BodySwipeGame({
    super.key,
    required this.onFinish,
    required this.onClose,
  });

  final OnGameFinish onFinish;
  final VoidCallback onClose;

  @override
  State<BodySwipeGame> createState() => _BodySwipeGameState();
}

class _BodySwipeGameState extends State<BodySwipeGame> {
  static const _cards = 12;
  static const _seconds = 60.0;

  late final List<SwipeCard> _deck;
  Timer? _timer;
  double _left = _seconds;
  int _index = 0;
  int _correct = 0;
  int _points = 0;
  int _streak = 0;
  bool? _lastRight;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _deck = ([...bodyCards]..shuffle(Random())).take(_cards).toList();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() {
        _left -= 0.1;
        if (_left <= 0) _end();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _decide(bool right) {
    final card = _deck[_index];
    final ok = right == card.isGood;
    playSfx(context, ok ? Sfx.correct : Sfx.wrong);
    setState(() {
      _lastRight = ok;
      if (ok) {
        _correct++;
        _streak++;
        _points += 10 * comboMultiplier(_streak);
      } else {
        _streak = 0;
      }
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted || _finished) return;
      if (_index + 1 >= _deck.length) {
        _end();
      } else {
        setState(() {
          _index++;
          _lastRight = null;
        });
      }
    });
  }

  void _end() {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();
    final answered = _index + (_lastRight == null ? 0 : 1);
    widget.onFinish(
      GameScore(
        points: _points + (_left > 0 ? _left.round() : 0),
        ratio: _correct / _deck.length,
        headline:
            '$_correct de ${_deck.length} poses bien leídas'
            '${answered < _deck.length ? ' (se acabó el tiempo)' : ''}',
        notes: const [
          'Base firme: pies al ancho de los hombros y peso repartido.',
          'Gestos entre la cintura y los hombros, con las palmas a la vista.',
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = _deck[_index];
    return Column(
      children: [
        GameHud(
          onClose: widget.onClose,
          timeLeft: _left / _seconds,
          points: _points,
          streak: _streak,
        ),
        Text(
          'Carta ${_index + 1} de ${_deck.length}',
          style: gameText(
            14,
            color: AppColors.darkBrownLight,
            weight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text('¿Qué transmite esta pose?', style: gameText(20)),
        Expanded(
          child: SwipeDecider(
            enabled: _lastRight == null,
            overlay: _lastRight == null
                ? null
                : _Verdict(
                    good: _lastRight!,
                    text: _lastRight! ? '¡Bien leído!' : 'Era al revés',
                    why: card.why,
                  ),
            leftLabel: 'NERVIOS',
            rightLabel: 'APLOMO',
            onDecide: _decide,
            child: DeckCard(
              key: ValueKey(_index),
              text: card.text,
              emoji: card.emoji,
            ),
          ),
        ),
      ],
    );
  }
}

class _Verdict extends StatelessWidget {
  const _Verdict({required this.good, required this.text, required this.why});

  final bool good;
  final String text;
  final String why;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        VerdictBadge(text: text, good: good),
        const SizedBox(height: 14),
        Text(
          why,
          textAlign: TextAlign.center,
          style: gameText(18, height: 1.3),
        ),
      ],
    );
  }
}
