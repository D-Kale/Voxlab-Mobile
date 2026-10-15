import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../shared/widgets/chunky.dart';
import '../game_content.dart';
import '../widgets/game_kit.dart';
import '../widgets/timed_speech.dart';
import '../widgets/voice_helpers.dart';

/// Spin a topic and a structure, think 5 seconds, speak 45.
class ImprovWheelGame extends StatefulWidget {
  const ImprovWheelGame({
    super.key,
    required this.onFinish,
    required this.onClose,
  });

  final OnGameFinish onFinish;
  final VoidCallback onClose;

  @override
  State<ImprovWheelGame> createState() => _ImprovWheelGameState();
}

class _ImprovWheelGameState extends State<ImprovWheelGame> {
  final _random = Random();
  Timer? _spin;
  bool _spinning = false;
  bool _spun = false;
  int _topic = 0;
  int _structure = 0;

  @override
  void dispose() {
    _spin?.cancel();
    super.dispose();
  }

  /// Slot-machine spin that slows down before stopping.
  void _start() {
    if (_spinning) return;
    setState(() => _spinning = true);
    var step = 0;
    void tick() {
      if (!mounted) return;
      setState(() {
        _topic = _random.nextInt(improvTopics.length);
        _structure = _random.nextInt(improvStructures.length);
      });
      playSfx(context, Sfx.tap);
      step++;
      if (step >= 18) {
        setState(() {
          _spinning = false;
          _spun = true;
        });
        playSfx(context, Sfx.unlock);
        return;
      }
      _spin = Timer(Duration(milliseconds: 50 + step * step * 2), tick);
    }

    tick();
  }

  void _onResult(SpeechAnalysis analysis, double seconds) {
    final score =
        analysis.score ?? ((seconds / 45).clamp(0.0, 1.0) * 100).round();
    final structure = improvStructures[_structure];
    widget.onFinish(
      GameScore(
        points: score * 3 + seconds.round(),
        ratio: score / 100,
        headline:
            '"${improvTopics[_topic]}" · ${seconds.round()} s · puntaje $score',
        coachTip: analysis.coachTip,
        notes: [
          'Estructura usada: ${structure.name} (${structure.steps}).',
          'Antes de improvisar, regalate dos segundos: respirá, elegí la '
              'estructura y pensá tu primera frase.',
          if (analysis.fillers > 2)
            'Se escaparon ${analysis.fillers} muletillas: hablá un poco más '
                'lento y pausá.',
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final structure = improvStructures[_structure];
    return Column(
      children: [
        GameHud(onClose: widget.onClose),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            children: [
              Text(
                'Ruleta de improvisación',
                textAlign: TextAlign.center,
                style: gameText(22),
              ),
              const SizedBox(height: 16),
              _Slot(
                label: '🎯 TEMA',
                value: _spun || _spinning ? improvTopics[_topic] : '?',
                colors: ChunkyColors.red,
                spinning: _spinning,
              ),
              const SizedBox(height: 12),
              _Slot(
                label: '🧱 ESTRUCTURA',
                value: _spun || _spinning ? structure.name : '?',
                caption: _spun ? structure.steps : null,
                colors: ChunkyColors.brown,
                spinning: _spinning,
              ),
              const SizedBox(height: 24),
              if (!_spun)
                ChunkyButton(
                  label: _spinning ? 'GIRANDO…' : 'GIRAR',
                  icon: Icons.casino_rounded,
                  colors: ChunkyColors.gold,
                  onPressed: _spinning ? null : _start,
                )
              else
                TimedSpeech(
                  prepSeconds: 5,
                  minSeconds: 20,
                  maxSeconds: 45,
                  topic:
                      'Improvisación sobre "${improvTopics[_topic]}" usando la '
                      'estructura ${structure.name}: ${structure.steps}.',
                  startLabel: '¡A HABLAR!',
                  onResult: _onResult,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({
    required this.label,
    required this.value,
    required this.colors,
    required this.spinning,
    this.caption,
  });

  final String label;
  final String value;
  final String? caption;
  final ChunkyColors colors;
  final bool spinning;

  @override
  Widget build(BuildContext context) {
    return ChunkyCard(
      colors: colors,
      radius: 22,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        children: [
          Text(
            label,
            style: gameText(13, color: colors.content.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 90),
            transitionBuilder: (child, a) => SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.6),
                end: Offset.zero,
              ).animate(a),
              child: child,
            ),
            child: Text(
              value,
              key: ValueKey(value),
              textAlign: TextAlign.center,
              style: gameText(spinning ? 20 : 23, color: colors.content),
            ),
          ),
          if (caption != null) ...[
            const SizedBox(height: 6),
            Text(
              caption!,
              textAlign: TextAlign.center,
              style: gameText(
                14,
                color: colors.content.withValues(alpha: 0.9),
                weight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
