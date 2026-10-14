import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/exercise_outcome.dart';
import '../../../shared/widgets/chunky.dart';
import '../../../shared/widgets/lesson_widgets.dart';
import '../../../shared/widgets/motion.dart';

/// Oratory exercise with an in-app timer and self-reported completion.
///
/// TODO(backend): there is no AI analysis endpoint for oratory/audio yet
/// (only POST /exercises/analyze-text for writing). When it exists, send
/// the recording transcript through the analyzer and complete with the
/// AI-scored ExerciseOutcome instead of the heuristic points.
class OratoryWidget extends StatefulWidget {
  const OratoryWidget({
    super.key,
    required this.prompt,
    required this.topic,
    required this.durationSeconds,
    required this.minDurationSeconds,
    required this.requirements,
    required this.points,
    this.onCompleted,
  });

  final String prompt;
  final String topic;
  final int durationSeconds;
  final int minDurationSeconds;
  final List<String> requirements;
  final int points;
  final void Function(ExerciseOutcome outcome)? onCompleted;

  @override
  State<OratoryWidget> createState() => _OratoryWidgetState();
}

class _OratoryWidgetState extends State<OratoryWidget> {
  bool _isStarted = false;
  bool _isFinished = false;
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _isStarted = true;
      _remainingSeconds = widget.durationSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _remainingSeconds = 0);
      } else {
        if (mounted) setState(() => _remainingSeconds--);
      }
    });
  }

  /// Stops the timer and shows the summary; the summary's button reports
  /// the outcome (it used to be reported here too, so the summary flashed
  /// and the outcome could be sent twice).
  void _finish() {
    _timer?.cancel();
    setState(() => _isFinished = true);
  }

  double get _progress => _remainingSeconds / widget.durationSeconds;

  @override
  Widget build(BuildContext context) {
    if (_isFinished) return _buildSummary();
    if (!_isStarted) return _buildPreparation();
    return _buildActive();
  }

  Widget _buildPreparation() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                VoxiSays(text: widget.prompt),
                const SizedBox(height: 18),
                ChunkyCard(
                  colors: ChunkyColors.brown,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.record_voice_over_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TU TEMA',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                            ),
                            Text(
                              widget.topic,
                              style: GoogleFonts.dmSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.requirements.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Objetivos',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBrownLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final r in widget.requirements)
                        ChunkyTag(
                          label: r,
                          icon: Icons.flag_rounded,
                          color: AppColors.darkBrown,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: [
                    ChunkyTag(
                      label: '${widget.durationSeconds}s',
                      icon: Icons.timer_rounded,
                      color: AppColors.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'mínimo ${widget.minDurationSeconds}s',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBrownLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Semantics(
            label: 'Comenzar ejercicio de oratoria',
            excludeSemantics: true,
            child: ChunkyButton(
              label: 'COMENZAR',
              icon: Icons.play_arrow_rounded,
              colors: ChunkyColors.green,
              onPressed: _start,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActive() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final urgent = _progress < 0.25;
    final ringColor = urgent ? AppColors.accentRed : AppColors.success;

    return Column(
      children: [
        const Spacer(),
        Text(
          widget.topic,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.darkBrown,
          ),
        ),
        const SizedBox(height: 24),
        Semantics(
          label: 'Tiempo restante: $minutes minutos con $seconds segundos',
          excludeSemantics: true,
          child: SizedBox(
            width: 240,
            height: 240,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PulseHalo(color: ringColor, diameter: 200, spread: 20),
                SizedBox(
                  width: 210,
                  height: 210,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: _progress),
                    duration: const Duration(milliseconds: 900),
                    builder: (context, v, _) => CircularProgressIndicator(
                      value: v,
                      strokeWidth: 14,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppColors.cardBorder,
                      valueColor: AlwaysStoppedAnimation(ringColor),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic_rounded, color: ringColor, size: 34),
                    Text(
                      '$minutes:${seconds.toString().padLeft(2, '0')}',
                      style: GoogleFonts.dmSans(
                        fontSize: 46,
                        fontWeight: FontWeight.w900,
                        color: urgent
                            ? AppColors.accentRed
                            : AppColors.darkBrown,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '¡Hablá!',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBrownLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Semantics(
            label: 'Finalizar ejercicio de oratoria',
            excludeSemantics: true,
            child: ChunkyButton(
              label: 'TERMINÉ',
              icon: Icons.stop_rounded,
              colors: ChunkyColors.red,
              onPressed: _finish,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final elapsed = widget.durationSeconds - _remainingSeconds;
    final metMinimum = elapsed >= widget.minDurationSeconds;

    return Column(
      children: [
        const Spacer(),
        EntranceAnimation(
          scaleFrom: 0.4,
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: metMinimum ? AppColors.success : AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: metMinimum
                      ? AppColors.successDark
                      : AppColors.primaryDark,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              metMinimum ? Icons.mic_rounded : Icons.mic_none_rounded,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          metMinimum ? '¡Muy bien hablado!' : '¡Buen intento!',
          style: GoogleFonts.dmSans(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.darkBrown,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Hablaste ${elapsed}s',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBrownLight,
          ),
        ),
        if (!metMinimum)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'La próxima, intentá llegar a ${widget.minDurationSeconds}s.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.accentRed,
              ),
            ),
          ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ChunkyButton(
            label: 'CONTINUAR',
            colors: ChunkyColors.green,
            onPressed: () =>
                widget.onCompleted?.call(ExerciseOutcome(score: widget.points)),
          ),
        ),
      ],
    );
  }
}
