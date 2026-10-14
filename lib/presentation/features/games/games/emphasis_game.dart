import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/chunky.dart';
import '../game_content.dart';
import '../widgets/game_kit.dart';

/// Pick the word to stress so the sentence means what is asked.
class EmphasisGame extends StatefulWidget {
  const EmphasisGame({
    super.key,
    required this.onFinish,
    required this.onClose,
  });

  final OnGameFinish onFinish;
  final VoidCallback onClose;

  @override
  State<EmphasisGame> createState() => _EmphasisGameState();
}

class _EmphasisGameState extends State<EmphasisGame> {
  static const _rounds = 8;
  static const _secondsPerRound = 8.0;

  late final List<EmphasisRound> _deck;
  Timer? _timer;
  int _index = 0;
  double _left = _secondsPerRound;
  int? _picked;
  int _correct = 0;
  int _points = 0;
  int _streak = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _deck = ([...emphasisRounds]..shuffle(Random())).take(_rounds).toList();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _picked != null) return;
      setState(() {
        _left -= 0.1;
        if (_left <= 0) _answer(-1);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  EmphasisRound get _round => _deck[_index];

  void _answer(int word) {
    if (_picked != null) return;
    final right = word == _round.answer;
    _picked = word;
    if (right) {
      _correct++;
      _streak++;
      _points += (10 + _left.round()) * comboMultiplier(_streak);
    } else {
      _streak = 0;
    }
    playSfx(context, right ? Sfx.correct : Sfx.wrong);
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      if (_index + 1 >= _deck.length) {
        _end();
      } else {
        setState(() {
          _index++;
          _picked = null;
          _left = _secondsPerRound;
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
        headline: '$_correct de ${_deck.length} frases con el énfasis justo',
        notes: const [
          'El énfasis es subrayar con la voz: más fuerza o un tono más alto '
              'en la palabra clave.',
          'Probá decir cada frase en voz alta cambiando la palabra '
              'enfatizada.',
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = _round.sentence.split(' ');
    return Column(
      children: [
        GameHud(
          onClose: widget.onClose,
          timeLeft: _left / _secondsPerRound,
          points: _points,
          streak: _streak,
          progressColor: AppColors.primary,
        ),
        const SizedBox(height: 4),
        Text(
          'Ronda ${_index + 1} de ${_deck.length}',
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
                Text(
                  'Querés decir…',
                  style: gameText(16, color: AppColors.darkBrownLight),
                ),
                const SizedBox(height: 6),
                Text(
                  '"${_round.meaning}"',
                  textAlign: TextAlign.center,
                  style: gameText(24, color: AppColors.accentRed),
                ),
                const SizedBox(height: 28),
                Text('¿Qué palabra enfatizás?', style: gameText(16)),
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 10,
                  children: [
                    for (var i = 0; i < words.length; i++) _word(words[i], i),
                  ],
                ),
                const SizedBox(height: 24),
                if (_picked != null)
                  VerdictBadge(
                    text: _picked == _round.answer
                        ? '¡Exacto!'
                        : 'Era "${words[_round.answer].toUpperCase()}"',
                    good: _picked == _round.answer,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _word(String word, int i) {
    var colors = ChunkyColors.white;
    if (_picked != null) {
      if (i == _round.answer) {
        colors = ChunkyColors.green;
      } else if (i == _picked) {
        colors = ChunkyColors.red;
      }
    }
    final stressed = _picked != null && i == _round.answer;
    return ChunkyCard(
      colors: colors,
      radius: 14,
      depth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: _picked == null ? () => setState(() => _answer(i)) : null,
      semanticsLabel: word,
      child: Text(
        stressed ? word.toUpperCase() : word,
        style: gameText(stressed ? 22 : 20, color: colors.content),
      ),
    );
  }
}
