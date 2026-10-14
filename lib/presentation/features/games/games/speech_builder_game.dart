import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/chunky.dart';
import '../game_content.dart';
import '../widgets/game_kit.dart';

/// Tap the shuffled blocks in order to build the speech before time runs
/// out. Some puzzles hide an intruder that must stay out.
class SpeechBuilderGame extends StatefulWidget {
  const SpeechBuilderGame({
    super.key,
    required this.onFinish,
    required this.onClose,
  });

  final OnGameFinish onFinish;
  final VoidCallback onClose;

  @override
  State<SpeechBuilderGame> createState() => _SpeechBuilderGameState();
}

class _SpeechBuilderGameState extends State<SpeechBuilderGame> {
  static const _puzzles = 4;

  final _random = Random();
  late final List<SpeechPuzzle> _deck;
  Timer? _timer;

  int _index = 0;
  late double _limit;
  late double _left;
  late List<String> _pool;
  late List<String?> _slots;
  Set<int> _wrongSlots = {};
  int _mistakes = 0;
  bool _locked = false;
  bool _revealed = false;

  double _accuracy = 0;
  int _solved = 0;
  int _points = 0;
  int _streak = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _deck = ([...speechPuzzles]..shuffle(_random)).take(_puzzles).toList();
    _load();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted || _locked) return;
      setState(() {
        _left -= 0.1;
        if (_left <= 0) _timeUp();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  SpeechPuzzle get _puzzle => _deck[_index];

  void _load() {
    final p = _puzzle;
    _limit = 10.0 + p.slots.length * 5;
    _left = _limit;
    _pool = [...p.blocks, ?p.intruder]..shuffle(_random);
    _slots = List.filled(p.slots.length, null);
    _wrongSlots = {};
    _mistakes = 0;
    _locked = false;
    _revealed = false;
  }

  void _place(String block) {
    if (_locked) return;
    final free = _slots.indexOf(null);
    if (free < 0) return;
    playSfx(context, Sfx.tap);
    setState(() {
      _slots[free] = block;
      _pool.remove(block);
      if (!_slots.contains(null)) _check();
    });
  }

  void _unplace(int slot) {
    final block = _slots[slot];
    if (_locked || block == null) return;
    setState(() {
      _slots[slot] = null;
      _pool.add(block);
    });
  }

  void _check() {
    final wrong = {
      for (var i = 0; i < _slots.length; i++)
        if (_slots[i] != _puzzle.blocks[i]) i,
    };
    if (wrong.isEmpty) {
      playSfx(context, Sfx.correct);
      _solved++;
      _streak = _mistakes == 0 ? _streak + 1 : 0;
      _accuracy += _mistakes == 0 ? 1 : 0.7;
      _points += (20 + _left.round()) * comboMultiplier(_streak);
      _locked = true;
      _advanceAfter(const Duration(milliseconds: 1300));
      return;
    }
    playSfx(context, Sfx.wrong);
    _mistakes++;
    _streak = 0;
    _left = max(0.5, _left - 4);
    _wrongSlots = wrong;
    _locked = true;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        for (final i in wrong) {
          _pool.add(_slots[i]!);
          _slots[i] = null;
        }
        _wrongSlots = {};
        _locked = false;
      });
    });
  }

  void _timeUp() {
    _locked = true;
    _revealed = true;
    _streak = 0;
    playSfx(context, Sfx.wrong);
    _advanceAfter(const Duration(milliseconds: 2200));
  }

  void _advanceAfter(Duration delay) {
    Future.delayed(delay, () {
      if (!mounted || _finished) return;
      if (_index + 1 >= _deck.length) {
        _end();
      } else {
        setState(() {
          _index++;
          _load();
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
        ratio: _accuracy / _deck.length,
        headline: 'Armaste $_solved de ${_deck.length} discursos',
        notes: const [
          'Estructura base: gancho, tres ideas y un cierre con llamado a la '
              'acción.',
          'PREP para opinar: Punto, Razón, Ejemplo y otra vez el Punto.',
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final solvedNow =
        _locked && !_revealed && _wrongSlots.isEmpty && !_slots.contains(null);
    return Column(
      children: [
        GameHud(
          onClose: widget.onClose,
          timeLeft: _left / _limit,
          points: _points,
          streak: _streak,
          progressColor: AppColors.success,
        ),
        Text(
          'Discurso ${_index + 1} de ${_deck.length} · ${_puzzle.title}',
          style: gameText(
            15,
            color: AppColors.darkBrownLight,
            weight: FontWeight.w800,
          ),
        ),
        if (_puzzle.intruder != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '¡Hay un intruso! Dejalo afuera.',
              style: gameText(
                13,
                color: AppColors.accentRed,
                weight: FontWeight.w800,
              ),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            children: [
              for (var i = 0; i < _slots.length; i++) _slot(i),
              const SizedBox(height: 14),
              if (solvedNow)
                const Center(
                  child: VerdictBadge(text: '¡Discurso armado!', good: true),
                )
              else if (_revealed)
                const Center(
                  child: VerdictBadge(text: 'Se acabó el tiempo', good: false),
                )
              else ...[
                Text('Tocá el bloque que sigue:', style: gameText(15)),
                const SizedBox(height: 10),
                for (final block in _pool)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ChunkyCard(
                      depth: 4,
                      radius: 16,
                      padding: const EdgeInsets.all(14),
                      onTap: () => _place(block),
                      semanticsLabel: block,
                      child: Text(
                        block,
                        style: gameText(16, weight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _slot(int i) {
    final block = _revealed ? _puzzle.blocks[i] : _slots[i];
    final wrong = _wrongSlots.contains(i);
    final colors = wrong
        ? ChunkyColors.red
        : (block == null ? ChunkyColors.idle : ChunkyColors.green);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ChunkyCard(
        colors: colors,
        depth: 3,
        radius: 14,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        onTap: block == null || _revealed ? null : () => _unplace(i),
        child: Row(
          children: [
            SizedBox(
              width: 74,
              child: Text(
                _puzzle.slots[i].toUpperCase(),
                style: gameText(
                  11,
                  color: colors.content,
                  weight: FontWeight.w900,
                ),
              ),
            ),
            Expanded(
              child: Text(
                block ?? '…',
                style: gameText(
                  14.5,
                  color: colors.content,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
