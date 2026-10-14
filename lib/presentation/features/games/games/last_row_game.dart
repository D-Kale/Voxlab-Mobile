import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/chunky.dart';
import '../game_content.dart';
import '../widgets/game_kit.dart';
import '../widgets/voice_helpers.dart';

/// Raw microphone level in dBFS, without auto gain (the speech recorder
/// normalizes volume, which would defeat a volume game).
class _LevelMeter {
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _sub;
  String? _path;
  final _controller = StreamController<double>.broadcast();

  Stream<double> get dbfs => _controller.stream;

  Future<void> start() async {
    _path = kIsWeb
        ? 'level.wav'
        : '${(await getTemporaryDirectory()).path}/voxlab_level_${DateTime.now().millisecondsSinceEpoch}.wav';
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
        autoGain: false,
        noiseSuppress: false,
        echoCancel: false,
      ),
      path: _path!,
    );
    _sub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 80))
        .listen((a) => _controller.add(a.current.isFinite ? a.current : -160));
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    await _recorder.stop();
    final path = _path;
    if (!kIsWeb && path != null) {
      File(path).delete().then((_) {}, onError: (_) {});
    }
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
    await _recorder.dispose();
  }
}

enum _Phase { ready, listening, flying, verdict }

/// Say each phrase with the right volume so the paper plane lands on the
/// target row. Shouting crashes it into the back wall.
class LastRowGame extends ConsumerStatefulWidget {
  const LastRowGame({super.key, required this.onFinish, required this.onClose});

  final OnGameFinish onFinish;
  final VoidCallback onClose;

  @override
  ConsumerState<LastRowGame> createState() => _LastRowGameState();
}

class _LastRowGameState extends ConsumerState<LastRowGame> {
  /// Upper dBFS bound of rows 1..5; louder than the last one is a shout.
  /// Tuned for a phone held at arm's length.
  static const _rowCeilings = [-38.0, -31.0, -25.0, -19.0, -9.0];
  static const _listenSeconds = 4.0;

  _LevelMeter? _meter;
  StreamSubscription<double>? _sub;
  Timer? _timer;
  final List<double> _samples = [];
  double _live = -160;
  double _elapsed = 0;

  _Phase _phase = _Phase.ready;
  int _round = 0;
  int _landed = 0;
  bool _shout = false;
  double _accuracy = 0;
  int _points = 0;
  int _streak = 0;
  int _exact = 0;
  bool _finished = false;

  @override
  void dispose() {
    _timer?.cancel();
    _sub?.cancel();
    _meter?.dispose();
    super.dispose();
  }

  VolumeRound get _target => volumeRounds[_round];

  static int _rowFor(double db) {
    for (var i = 0; i < _rowCeilings.length; i++) {
      if (db <= _rowCeilings[i]) return i + 1;
    }
    return 6;
  }

  Future<void> _listen() async {
    if (!await ensureMicrophone(context, ref) || !mounted) return;
    final meter = _LevelMeter();
    try {
      await meter.start();
    } catch (_) {
      await meter.dispose();
      return;
    }
    if (!mounted) {
      await meter.dispose();
      return;
    }
    playSfx(context, Sfx.recordStart);
    _meter = meter;
    _samples.clear();
    _elapsed = 0;
    _sub = meter.dbfs.listen((db) {
      _live = db;
      _samples.add(db);
    });
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() => _elapsed += 0.1);
      if (_elapsed >= _listenSeconds) _evaluate();
    });
    setState(() => _phase = _Phase.listening);
  }

  /// Loudness of the take: mean of the loudest 40% of samples (the voiced
  /// part), so pauses between words do not drag it down.
  double get _takeLevel {
    if (_samples.isEmpty) return -160;
    final sorted = [..._samples]..sort((a, b) => b.compareTo(a));
    final top = sorted.take(max(1, (sorted.length * 0.4).round()));
    return top.reduce((a, b) => a + b) / top.length;
  }

  Future<void> _evaluate() async {
    final meter = _meter;
    if (meter == null) return;
    _meter = null;
    _timer?.cancel();
    await _sub?.cancel();
    final peak = _samples.isEmpty ? -160.0 : _samples.reduce(max);
    final level = _takeLevel;
    await meter.stop();
    await meter.dispose();
    if (!mounted) return;
    final row = _rowFor(level);
    final shout = row == 6 || peak > -2;
    final landed = shout ? 6 : row;
    final off = (landed - _target.targetRow).abs();
    final value = shout ? 0.0 : (off == 0 ? 1.0 : (off == 1 ? 0.5 : 0.0));
    setState(() {
      _landed = landed;
      _shout = shout;
      _accuracy += value;
      if (value == 1) {
        _exact++;
        _streak++;
      } else {
        _streak = 0;
      }
      _points += (value * 30).round() * comboMultiplier(_streak);
      _phase = _Phase.flying;
    });
    playSfx(
      context,
      value == 1 ? Sfx.correct : (value > 0 ? Sfx.pop : Sfx.wrong),
    );
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _phase = _Phase.verdict);
    });
  }

  void _next() {
    if (_round + 1 >= volumeRounds.length) {
      _end();
      return;
    }
    setState(() {
      _round++;
      _phase = _Phase.ready;
    });
  }

  void _end() {
    if (_finished) return;
    _finished = true;
    widget.onFinish(
      GameScore(
        points: _points,
        ratio: _accuracy / volumeRounds.length,
        headline: '$_exact de ${volumeRounds.length} aterrizajes exactos',
        notes: const [
          'Proyectar no es gritar: apoyá el aire con el abdomen y abrí bien '
              'la boca.',
          'Bajar la voz en un momento clave también atrae la atención.',
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liveRow = _phase == _Phase.listening ? _rowFor(_live) : null;
    return Column(
      children: [
        GameHud(
          onClose: widget.onClose,
          timeLeft: 1 - _round / volumeRounds.length,
          points: _points,
          streak: _streak,
          progressColor: AppColors.darkBrown,
        ),
        Text(
          'Ronda ${_round + 1} de ${volumeRounds.length}',
          style: gameText(
            14,
            color: AppColors.darkBrownLight,
            weight: FontWeight.w800,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: ChunkyCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Text(
                  _target.targetRow == 1
                      ? 'Susurro dramático: llegá solo a la FILA 1'
                      : 'Hacé llegar el avión a la FILA ${_target.targetRow}',
                  textAlign: TextAlign.center,
                  style: gameText(15, color: AppColors.accentRed),
                ),
                const SizedBox(height: 6),
                Text(
                  '"${_target.phrase}"',
                  textAlign: TextAlign.center,
                  style: gameText(19),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: LayoutBuilder(
              builder: (context, box) => _Auditorium(
                size: box.biggest,
                target: _target.targetRow,
                live: liveRow,
                landed: _phase == _Phase.flying || _phase == _Phase.verdict
                    ? _landed
                    : null,
              ),
            ),
          ),
        ),
        SizedBox(height: 178, child: Center(child: _controls())),
      ],
    );
  }

  Widget _controls() {
    switch (_phase) {
      case _Phase.ready:
        return MicButton(
          recording: false,
          onPressed: _listen,
          label: 'Tocá y decí la frase',
        );
      case _Phase.listening:
        return MicButton(
          recording: true,
          level: ((_live + 60) / 60).clamp(0.0, 1.0),
          onPressed: _evaluate,
          label:
              '${(_listenSeconds - _elapsed).clamp(0, _listenSeconds).toStringAsFixed(1)} s',
        );
      case _Phase.flying:
        return const SizedBox.shrink();
      case _Phase.verdict:
        final exact = _landed == _target.targetRow;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              VerdictBadge(
                text: _shout
                    ? '¡Eso es gritar!'
                    : exact
                    ? '¡Aterrizaje perfecto!'
                    : (_landed < _target.targetRow
                          ? 'Te quedaste corto'
                          : 'Te pasaste'),
                good: exact,
              ),
              const SizedBox(height: 14),
              ChunkyButton(
                label: _round + 1 >= volumeRounds.length
                    ? 'VER RESULTADO'
                    : 'SIGUIENTE',
                colors: ChunkyColors.green,
                onPressed: _next,
              ),
            ],
          ),
        );
    }
  }
}

/// Rows of seats seen from the stage (row 5 at the top), the back wall and
/// the paper plane.
class _Auditorium extends StatelessWidget {
  const _Auditorium({
    required this.size,
    required this.target,
    this.live,
    this.landed,
  });

  final Size size;
  final int target;
  final int? live;

  /// Row the plane landed on; 6 is the back wall (shout).
  final int? landed;

  @override
  Widget build(BuildContext context) {
    final rowHeight = size.height / 6.5;
    double yOfRow(int row) => size.height - rowHeight * (row + 0.5);
    final planeY = landed == null
        ? size.height - 24
        : yOfRow(landed!.clamp(1, 6));
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Back wall.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: rowHeight * 0.8,
          child: Container(
            decoration: BoxDecoration(
              color: landed == 6
                  ? AppColors.accentRedContainer
                  : AppColors.idleFace,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: landed == 6 ? AppColors.accentRed : AppColors.idleLip,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'PARED',
              style: gameText(12, color: AppColors.darkBrownLight),
            ),
          ),
        ),
        for (var row = 1; row <= 5; row++)
          Positioned(
            top: yOfRow(row) - rowHeight * 0.35,
            left: 0,
            right: 0,
            height: rowHeight * 0.7,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              decoration: BoxDecoration(
                color: row == live
                    ? AppColors.successContainer
                    : (row == target
                          ? AppColors.primaryContainer
                          : AppColors.surface),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: row == target
                      ? AppColors.primaryDark
                      : AppColors.cardBorder,
                  width: row == target ? 3 : 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    'FILA $row',
                    style: gameText(12, color: AppColors.darkBrownLight),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (var s = 0; s < 6; s++)
                          const Icon(
                            Icons.event_seat_rounded,
                            size: 18,
                            color: AppColors.idleLip,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 850),
          curve: Curves.easeOutCubic,
          top: planeY - 18,
          left: size.width / 2 - 18,
          child: Transform.rotate(
            angle: -pi / 2,
            child: Icon(
              Icons.send_rounded,
              size: 36,
              color: landed == 6 ? AppColors.accentRed : AppColors.darkBrown,
            ),
          ),
        ),
      ],
    );
  }
}
