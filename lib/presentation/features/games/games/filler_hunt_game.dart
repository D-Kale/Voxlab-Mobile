import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/chunky.dart';
import '../game_content.dart';
import '../widgets/game_kit.dart';

class _Word {
  _Word(this.text, this.isFiller);

  final String text;
  final bool isFiller;
  bool tapped = false;
}

/// Tap the filler words of each sentence before its time runs out.
class FillerHuntGame extends StatefulWidget {
  const FillerHuntGame({
    super.key,
    required this.onFinish,
    required this.onClose,
  });

  final OnGameFinish onFinish;
  final VoidCallback onClose;

  @override
  State<FillerHuntGame> createState() => _FillerHuntGameState();
}

class _FillerHuntGameState extends State<FillerHuntGame> {
  static const _gameSeconds = 60;
  static const _tick = Duration(milliseconds: 100);

  final _random = Random();
  late final List<String> _queue;
  Timer? _timer;

  List<_Word> _words = [];
  int _sentenceIndex = -1;
  double _sentenceTime = 0;
  double _sentenceLeft = 0;
  double _gameLeft = _gameSeconds.toDouble();

  int _lives = 3;
  int _points = 0;
  int _streak = 0;
  int _caught = 0;
  int _fillersSeen = 0;
  int _wrongTaps = 0;
  String? _verdict;
  bool _verdictGood = true;
  bool _clean = false;

  @override
  void initState() {
    super.initState();
    final l1 = [...fillerSentencesL1]..shuffle(_random);
    final l2 = [...fillerSentencesL2]..shuffle(_random);
    // Warm up with level 1, then mix in the traps.
    _queue = [
      ...l1.take(4),
      ...([...l1.skip(4), ...l2]..shuffle(_random)),
    ];
    _next();
    _timer = Timer.periodic(_tick, (_) => _onTick());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Less time per sentence as the game goes on.
  double get _timeForSentence {
    final elapsed = _gameSeconds - _gameLeft;
    return max(3.0, 6.5 - elapsed / 15);
  }

  void _next() {
    _sentenceIndex++;
    if (_sentenceIndex >= _queue.length) {
      _end();
      return;
    }
    _words = [
      for (final token in _queue[_sentenceIndex].split(' '))
        if (token.startsWith('*') && token.endsWith('*') && token.length > 2)
          _Word(token.substring(1, token.length - 1).replaceAll('_', ' '), true)
        else
          _Word(token, false),
    ];
    _sentenceTime = _timeForSentence;
    _sentenceLeft = _sentenceTime;
    _clean = false;
  }

  void _onTick() {
    if (!mounted) return;
    setState(() {
      _gameLeft -= 0.1;
      if (_clean) return;
      _sentenceLeft -= 0.1;
      if (_gameLeft <= 0) {
        _closeSentence();
        _end();
      } else if (_sentenceLeft <= 0) {
        _closeSentence();
      }
    });
  }

  /// Counts the fillers of the current sentence and shows it clean.
  void _closeSentence() {
    final fillers = _words.where((w) => w.isFiller).length;
    final missed = _words.where((w) => w.isFiller && !w.tapped).length;
    _fillersSeen += fillers;
    if (missed > 0) {
      _streak = 0;
      _flash('Se escaparon $missed', good: false);
    } else if (fillers == 0 && !_words.any((w) => w.tapped)) {
      _points += 15;
      _flash('¡Bien! No había muletillas', good: true);
    }
    _clean = true;
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || _timer == null) return;
      setState(_next);
    });
  }

  void _flash(String text, {required bool good}) {
    _verdict = text;
    _verdictGood = good;
  }

  void _tap(_Word word) {
    if (_clean || word.tapped) return;
    setState(() {
      word.tapped = true;
      if (word.isFiller) {
        _streak++;
        _caught++;
        _points += 10 * comboMultiplier(_streak);
        playSfx(context, Sfx.pop);
        _flash(_streak >= 3 ? '¡Combo $_streak!' : '¡Cazada!', good: true);
        if (_words.where((w) => w.isFiller).every((w) => w.tapped)) {
          _points += (_sentenceLeft * 2).round();
          _closeSentence();
        }
      } else {
        _streak = 0;
        _wrongTaps++;
        _lives--;
        playSfx(context, Sfx.wrong);
        _flash('"${word.text}" no es muletilla', good: false);
        if (_lives <= 0) _end();
      }
    });
  }

  void _end() {
    if (_timer == null) return;
    _timer?.cancel();
    _timer = null;
    final denominator = _fillersSeen + _wrongTaps;
    widget.onFinish(
      GameScore(
        points: _points,
        ratio: denominator == 0 ? 0 : _caught / denominator,
        headline:
            'Cazaste $_caught de $_fillersSeen muletillas'
            '${_wrongTaps > 0 ? ' · $_wrongTaps toques de más' : ''}',
        notes: const [
          'Cuando sientas que viene un "eh", cerrá la boca y respirá: la '
              'pausa reemplaza a la muletilla.',
          'Ojo con el contexto: "este libro" o "un tipo de música" no son '
              'muletillas.',
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
          timeLeft: _gameLeft / _gameSeconds,
          lives: _lives,
          points: _points,
          streak: _streak,
        ),
        const SizedBox(height: 8),
        Text('Tocá las muletillas', style: gameText(20)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: _sentenceTime == 0
                  ? 0
                  : (_sentenceLeft / _sentenceTime).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.idleLip.withValues(alpha: 0.4),
              color: AppColors.primary,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => SlideTransition(
                  position: Tween(
                    begin: const Offset(0, -0.4),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Wrap(
                  key: ValueKey('$_sentenceIndex-$_clean'),
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 12,
                  children: [
                    for (final word in _words)
                      if (!(_clean && word.isFiller)) _bubble(word),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 64,
          child: _verdict == null
              ? null
              : Center(
                  child: VerdictBadge(text: _verdict!, good: _verdictGood),
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _bubble(_Word word) {
    final colors = !word.tapped
        ? ChunkyColors.white
        : (word.isFiller ? ChunkyColors.green : ChunkyColors.red);
    return ChunkyCard(
      colors: colors,
      radius: 99,
      depth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onTap: () => _tap(word),
      semanticsLabel: word.text,
      child: Text(
        word.text,
        style: gameText(18, color: colors.content, weight: FontWeight.w800),
      ),
    );
  }
}
