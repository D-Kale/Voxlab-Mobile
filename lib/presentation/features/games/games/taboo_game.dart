import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/chunky.dart';
import '../game_content.dart';
import '../widgets/game_kit.dart';

/// Pick the description that explains the word without the banned words.
class TabooGame extends StatefulWidget {
  const TabooGame({super.key, required this.onFinish, required this.onClose});

  final OnGameFinish onFinish;
  final VoidCallback onClose;

  @override
  State<TabooGame> createState() => _TabooGameState();
}

class _TabooGameState extends State<TabooGame> {
  static const _rounds = 5;
  static const _seconds = 15.0;

  final _random = Random();
  late final List<TabooRound> _deck;
  late List<String> _options;
  Timer? _timer;
  int _index = 0;
  double _left = _seconds;
  String? _picked;
  int _correct = 0;
  int _points = 0;
  int _streak = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _deck = ([...tabooRounds]..shuffle(_random)).take(_rounds).toList();
    _shuffleOptions();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _picked != null) return;
      setState(() {
        _left -= 0.1;
        if (_left <= 0) _answer('');
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  TabooRound get _round => _deck[_index];

  void _shuffleOptions() {
    _options = [_round.correct, ..._round.wrong]..shuffle(_random);
  }

  /// The banned word an option uses, if any.
  String? _bannedIn(String option) {
    final lower = option.toLowerCase();
    for (final word in _round.banned) {
      if (RegExp('\\b${RegExp.escape(word)}', unicode: true).hasMatch(lower)) {
        return word;
      }
    }
    return null;
  }

  void _answer(String option) {
    if (_picked != null) return;
    _picked = option;
    final ok = option == _round.correct;
    playSfx(context, ok ? Sfx.correct : Sfx.wrong);
    if (ok) {
      _correct++;
      _streak++;
      _points += (10 + _left.round()) * comboMultiplier(_streak);
    } else {
      _streak = 0;
    }
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted || _finished) return;
      if (_index + 1 >= _deck.length) {
        _end();
      } else {
        setState(() {
          _index++;
          _picked = null;
          _left = _seconds;
          _shuffleOptions();
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
        headline: '$_correct de ${_deck.length} palabras bien explicadas',
        notes: const [
          'Buscar otras palabras te da fluidez: si una se te escapa en una '
              'charla, vas a tener alternativas.',
          'Una buena explicación piensa en quién escucha: es concreta y usa '
              'ejemplos.',
        ],
      ),
    );
  }

  String _verdict() {
    if (_picked == _round.correct) return '¡Bien explicada!';
    if (_picked == '') return 'Se acabó el tiempo';
    final banned = _bannedIn(_picked!);
    return banned != null ? '¡Buzz! Usó "$banned"' : 'Muy vaga: no se entiende';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GameHud(
          onClose: widget.onClose,
          timeLeft: _left / _seconds,
          points: _points,
          streak: _streak,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              Center(
                child: Text(
                  'Palabra ${_index + 1} de ${_deck.length}',
                  style: gameText(
                    14,
                    color: AppColors.darkBrownLight,
                    weight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ChunkyCard(
                colors: ChunkyColors.brown,
                radius: 24,
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      _round.target.toUpperCase(),
                      style: gameText(30, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final word in _round.banned)
                          ChunkyTag(
                            label: word,
                            icon: Icons.block_rounded,
                            color: AppColors.accentRed,
                            filled: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '¿Cuál la explica sin decir lo prohibido?',
                style: gameText(17),
              ),
              const SizedBox(height: 10),
              for (final option in _options) _option(option),
              const SizedBox(height: 6),
              if (_picked != null)
                Center(
                  child: VerdictBadge(
                    text: _verdict(),
                    good: _picked == _round.correct,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _option(String option) {
    var colors = ChunkyColors.white;
    if (_picked != null) {
      if (option == _round.correct) {
        colors = ChunkyColors.green;
      } else if (option == _picked) {
        colors = ChunkyColors.red;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ChunkyCard(
        colors: colors,
        depth: 4,
        radius: 16,
        padding: const EdgeInsets.all(14),
        onTap: _picked == null ? () => setState(() => _answer(option)) : null,
        semanticsLabel: option,
        child: Text(
          option,
          style: gameText(15.5, color: colors.content, weight: FontWeight.w700),
        ),
      ),
    );
  }
}
