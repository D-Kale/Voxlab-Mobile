import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/chunky.dart';
import '../game_content.dart';
import '../widgets/game_kit.dart';
import '../widgets/timed_speech.dart';
import '../widgets/voice_helpers.dart';

/// Flip a character, a place and a problem, then tell a story with
/// situation, conflict and resolution.
class StoryCardsGame extends StatefulWidget {
  const StoryCardsGame({
    super.key,
    required this.onFinish,
    required this.onClose,
  });

  final OnGameFinish onFinish;
  final VoidCallback onClose;

  @override
  State<StoryCardsGame> createState() => _StoryCardsGameState();
}

class _StoryCardsGameState extends State<StoryCardsGame> {
  static const _decks = [storyCharacters, storyPlaces, storyProblems];
  static const _labels = ['👤 Personaje', '📍 Lugar', '⚡ Problema'];
  static const _minSeconds = 20;
  static const _maxSeconds = 60;

  final _random = Random();
  late final List<String> _cards = [
    for (final deck in _decks) deck[_random.nextInt(deck.length)],
  ];
  bool _flipped = false;
  bool _swapUsed = false;
  bool _speaking = false;

  void _swap(int i) {
    if (_swapUsed || _speaking) return;
    final deck = _decks[i];
    String next;
    do {
      next = deck[_random.nextInt(deck.length)];
    } while (next == _cards[i]);
    playSfx(context, Sfx.pop);
    setState(() {
      _cards[i] = next;
      _swapUsed = true;
    });
  }

  String get _topic =>
      'Historia improvisada con: ${_cards[0]}, en ${_cards[1].toLowerCase()}, '
      'problema: ${_cards[2].toLowerCase()}. Debe tener situación, conflicto '
      'y resolución, con algún detalle concreto.';

  void _onResult(SpeechAnalysis analysis, double seconds) {
    final lengthScore = (seconds / 45).clamp(0.0, 1.0) * 100;
    final score = analysis.score ?? lengthScore.round();
    widget.onFinish(
      GameScore(
        points: score * 3 + seconds.round(),
        ratio: score / 100,
        headline: 'Hablaste ${seconds.round()} s · puntaje de oratoria $score',
        coachTip: analysis.coachTip,
        notes: [
          'Situación, conflicto y resolución: sin conflicto no hay historia.',
          'Un detalle sensorial (un sonido, un olor) mete al público en la '
              'escena.',
          if (analysis.fillers > 2)
            'Se escaparon ${analysis.fillers} muletillas: probá reemplazarlas '
                'por una pausa.',
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GameHud(onClose: widget.onClose),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            children: [
              Text(
                _flipped ? 'Tu historia tiene…' : 'Tus cartas',
                textAlign: TextAlign.center,
                style: gameText(22),
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _card(i),
                ),
              if (_flipped && !_swapUsed && !_speaking)
                Text(
                  'Podés cambiar una carta tocándola (una sola vez).',
                  textAlign: TextAlign.center,
                  style: gameText(
                    13,
                    color: AppColors.darkBrownLight,
                    weight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: 18),
              if (!_flipped)
                ChunkyButton(
                  label: 'DAR VUELTA',
                  icon: Icons.style_rounded,
                  colors: ChunkyColors.red,
                  onPressed: () {
                    playSfx(context, Sfx.unlock);
                    setState(() => _flipped = true);
                  },
                )
              else
                Listener(
                  onPointerDown: (_) => _speaking = true,
                  child: TimedSpeech(
                    prepSeconds: 10,
                    minSeconds: _minSeconds,
                    maxSeconds: _maxSeconds,
                    topic: _topic,
                    startLabel: 'PENSAR Y CONTAR',
                    onResult: _onResult,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _card(int i) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: _flipped ? 1 : 0),
      duration: Duration(milliseconds: 400 + i * 150),
      curve: Curves.easeInOut,
      builder: (context, v, _) {
        final showFront = v > 0.5;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(pi * v),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..rotateY(showFront ? pi : 0),
            child: ChunkyCard(
              colors: showFront ? ChunkyColors.white : ChunkyColors.brown,
              radius: 20,
              padding: const EdgeInsets.all(16),
              onTap: showFront ? () => _swap(i) : null,
              child: SizedBox(
                height: 64,
                child: showFront
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _labels[i],
                            style: gameText(
                              13,
                              color: AppColors.darkBrownLight,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _cards[i],
                            textAlign: TextAlign.center,
                            style: gameText(20),
                          ),
                        ],
                      )
                    : Center(
                        child: Text(
                          '?',
                          style: gameText(36, color: Colors.white),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
