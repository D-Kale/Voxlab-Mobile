import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import 'chunky.dart';
import 'motion.dart';

/// Lesson screens use a calm cream background (focus mode), while the tabs
/// use the brand orange.
const lessonBackground = AppColors.surfaceContainer;

/// Voxi with a speech bubble, the Duolingo way of presenting a prompt.
class VoxiSays extends StatelessWidget {
  const VoxiSays({super.key, required this.text, this.mascotSize = 76});

  final String text;
  final double mascotSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Bob(
          amplitude: 3,
          child: Image.asset(
            'assets/images/voxi_awake.png',
            width: mascotSize,
            height: mascotSize,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: mascotSize * 0.25),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomPaint(size: const Size(12, 18), painter: _TailPainter()),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder, width: 2),
                    ),
                    child: Text(
                      text,
                      style: GoogleFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBrown,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Tail pointing left at the mascot; drawn under the bubble border.
    final path = Path()
      ..moveTo(size.width + 2, 0)
      ..lineTo(0, size.height - 2)
      ..lineTo(size.width + 2, size.height - 8)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.surface);
    canvas.drawPath(
      Path()
        ..moveTo(size.width, 0)
        ..lineTo(0, size.height - 2)
        ..lineTo(size.width, size.height - 8),
      Paint()
        ..color = AppColors.cardBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_TailPainter old) => false;
}

/// Thick rounded progress bar with a glossy stripe, animated on change.
class LessonProgressBar extends StatelessWidget {
  const LessonProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.success,
    this.height = 16,
  });

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.idleLip.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(99),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: value.clamp(0, 1)),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: v,
          child: Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.fromLTRB(
              height / 2,
              height * 0.2,
              height / 2,
              0,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Container(
              height: height * 0.25,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom result panel after checking an answer (green or red).
class AnswerFeedbackPanel extends StatelessWidget {
  const AnswerFeedbackPanel({
    super.key,
    required this.correct,
    required this.title,
    this.detail,
    required this.onContinue,
  });

  final bool correct;
  final String title;
  final String? detail;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final ink = correct
        ? AppColors.onSuccessContainer
        : AppColors.accentRedDark;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: correct
            ? AppColors.successContainer
            : AppColors.accentRedContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EntranceAnimation(
                scaleFrom: 0.3,
                offsetY: 0,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: correct ? AppColors.success : AppColors.accentRed,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    correct ? Icons.check_rounded : Icons.close_rounded,
                    color: correct ? AppColors.success : AppColors.accentRed,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: ink,
                      ),
                    ),
                    if (detail != null && detail!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        detail!,
                        style: GoogleFonts.dmSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: ink,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ChunkyButton(
            label: 'CONTINUAR',
            colors: correct ? ChunkyColors.green : ChunkyColors.red,
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}
