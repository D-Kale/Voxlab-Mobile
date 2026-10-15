import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../game_content.dart';
import '../widgets/game_kit.dart';

class _Token {
  const _Token.word(this.text) : pause = 0;
  const _Token.pause(this.pause) : text = '';

  final String text;

  /// Seconds of silence; 0 for a word.
  final double pause;

  bool get isPause => pause > 0;
}

/// Karaoke text: hold the button through each pause, release on the mark.
class PausePerfectGame extends StatefulWidget {
  const PausePerfectGame({
    super.key,
    required this.onFinish,
    required this.onClose,
  });

  final OnGameFinish onFinish;
  final VoidCallback onClose;

  @override
  State<PausePerfectGame> createState() => _PausePerfectGameState();
}

class _PausePerfectGameState extends State<PausePerfectGame> {
  static const _tick = Duration(milliseconds: 50);
  static const _wordEvery = 0.32;
  static const _pressWindow = 2.5;

  late final List<List<_Token>> _texts;
  Timer? _timer;

  int _textIndex = 0;
  int _revealed = 0;
  double _clock = 0;

  bool _waiting = false;
  double _waitTime = 0;
  bool _holding = false;
  double _held = 0;
  double _target = 0;

  int _pausesTotal = 0;
  int _pausesDone = 0;
  double _accuracy = 0;
  int _points = 0;
  int _streak = 0;
  int _perfects = 0;
  String? _verdict;
  bool _verdictGood = true;

  @override
  void initState() {
    super.initState();
    final picked = ([...pauseTexts]..shuffle(Random())).take(3);
    _texts = [for (final text in picked) _parse(text)];
    _pausesTotal = _texts.fold(
      0,
      (sum, t) => sum + t.where((x) => x.isPause).length,
    );
    _timer = Timer.periodic(_tick, (_) => _onTick());
  }

  static List<_Token> _parse(String text) => [
    for (final raw in text.split(' '))
      if (raw == '||')
        const _Token.pause(2)
      else if (raw == '|')
        const _Token.pause(1)
      else if (raw.isNotEmpty)
        _Token.word(raw),
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<_Token> get _tokens => _texts[_textIndex];

  void _onTick() {
    if (!mounted) return;
    setState(() {
      const dt = 0.05;
      if (_waiting) {
        if (_holding) {
          _held += dt;
          // Holding far past the mark counts as released.
          if (_held > _target + 1.5) _release();
        } else {
          _waitTime += dt;
          if (_waitTime > _pressWindow) {
            _score(0, 'Te la salteaste');
          }
        }
        return;
      }
      _clock += dt;
      if (_clock < _wordEvery) return;
      _clock = 0;
      if (_revealed >= _tokens.length) {
        _nextText();
        return;
      }
      final token = _tokens[_revealed];
      if (token.isPause) {
        _waiting = true;
        _waitTime = 0;
        _held = 0;
        _target = token.pause;
      } else {
        _revealed++;
      }
    });
  }

  void _nextText() {
    if (_textIndex + 1 >= _texts.length) {
      _end();
      return;
    }
    _textIndex++;
    _revealed = 0;
    _clock = -0.6;
  }

  void _press() {
    if (!_waiting) {
      setState(() {
        _streak = 0;
        _verdict = 'Todavía no: esperá la pausa';
        _verdictGood = false;
      });
      return;
    }
    setState(() {
      _holding = true;
      _held = 0;
    });
  }

  void _release() {
    if (!_holding) return;
    _holding = false;
    final error = (_held - _target).abs();
    if (error <= 0.3) {
      _score(1, '¡Perfecta!');
    } else if (error <= 0.7) {
      _score(
        0.6,
        _held < _target ? 'Bien, un poco corta' : 'Bien, un poco larga',
      );
    } else {
      _score(0, _held < _target ? 'Apurado' : 'Demasiado larga');
    }
  }

  void _score(double value, String verdict) {
    _pausesDone++;
    _accuracy += value;
    if (value >= 1) {
      _perfects++;
      _streak++;
    } else if (value == 0) {
      _streak = 0;
    }
    _points += (value * 20).round() * comboMultiplier(_streak);
    _verdict = verdict;
    _verdictGood = value > 0;
    playSfx(context, value > 0 ? Sfx.correct : Sfx.wrong);
    _waiting = false;
    _holding = false;
    _revealed++;
    _clock = 0;
  }

  void _end() {
    if (_timer == null) return;
    _timer?.cancel();
    _timer = null;
    widget.onFinish(
      GameScore(
        points: _points,
        ratio: _pausesTotal == 0 ? 0 : _accuracy / _pausesTotal,
        headline: '$_perfects pausas perfectas de $_pausesTotal',
        notes: const [
          'Pausá antes de una idea importante para generar expectativa, y '
              'después, para que se asiente.',
          'Lo que a vos te parece eterno, para el público dura un instante.',
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ring = _target == 0 ? 0.0 : (_held / _target);
    return Column(
      children: [
        GameHud(
          onClose: widget.onClose,
          timeLeft: _pausesTotal == 0 ? 0 : 1 - _pausesDone / _pausesTotal,
          points: _points,
          streak: _streak,
          progressColor: AppColors.primary,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  for (var i = 0; i < _tokens.length; i++)
                    if (_tokens[i].isPause)
                      _pauseMark(i)
                    else
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 180),
                        opacity: i < _revealed ? 1 : 0.18,
                        child: Text(
                          _tokens[i].text,
                          style: gameText(24, height: 1.3),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 56,
          child: _verdict == null
              ? null
              : Center(
                  child: VerdictBadge(text: _verdict!, good: _verdictGood),
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24, top: 8),
          child: Listener(
            onPointerDown: (_) => _press(),
            onPointerUp: (_) => setState(_release),
            onPointerCancel: (_) => setState(_release),
            child: SizedBox(
              width: 150,
              height: 150,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: _waiting ? ring : 0,
                  active: _waiting,
                ),
                child: Center(
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 120),
                    scale: _holding ? 0.92 : 1,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _waiting
                            ? AppColors.accentRed
                            : AppColors.idleFace,
                        boxShadow: [
                          BoxShadow(
                            color: _waiting
                                ? AppColors.accentRedDark
                                : AppColors.idleLip,
                            offset: Offset(0, _holding ? 2 : 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.pause_rounded,
                            size: 44,
                            color: _waiting
                                ? Colors.white
                                : AppColors.darkBrownLight,
                          ),
                          Text(
                            _waiting
                                ? '${_target.toStringAsFixed(0)} s'
                                : 'MANTENÉ',
                            style: gameText(
                              13,
                              color: _waiting
                                  ? Colors.white
                                  : AppColors.darkBrownLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _pauseMark(int index) {
    final current = _waiting && index == _revealed;
    final done = index < _revealed;
    final long = _tokens[index].pause >= 2;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: current
            ? AppColors.accentRed
            : (done ? AppColors.successContainer : AppColors.idleFace),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        long ? '⏸⏸' : '⏸',
        style: gameText(
          16,
          color: current ? Colors.white : AppColors.darkBrownLight,
        ),
      ),
    );
  }
}

/// Ring that fills while holding; the tick at the top is the target.
class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.active});

  final double progress;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = AppColors.idleLip.withValues(alpha: 0.5);
    canvas.drawCircle(center, radius, base);
    if (!active) return;
    final over = progress > 1;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = over ? AppColors.accentRed : AppColors.success;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      arc,
    );
    // Target mark at 12 o'clock.
    final mark = Paint()
      ..color = AppColors.darkBrown
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center + Offset(0, -radius - 9),
      center + Offset(0, -radius + 9),
      mark,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.active != active;
}
