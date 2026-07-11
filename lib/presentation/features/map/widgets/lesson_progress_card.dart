import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/lesson.dart';
import '../../../../utils/lesson_progress_utils.dart';

class LessonProgressCard extends StatelessWidget {
  const LessonProgressCard({
    super.key,
    required this.lesson,
    required this.isLocked,
    required this.isCompleted,
    required this.completedExerciseIds,
    this.onTap,
  });

  final Lesson lesson;
  final bool isLocked;
  final bool isCompleted;
  final Set<String> completedExerciseIds;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final progress = computeLessonProgress(lesson, completedExerciseIds);
    final fraction = progress.totalExercises > 0
        ? progress.completedExercises / progress.totalExercises
        : 0.0;
    final percent = (fraction * 100).round();

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCompleted
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.onSurfaceVariant.withValues(alpha: 0.2),
        ),
      ),
      color: isLocked
          ? AppColors.surfaceContainer
          : AppColors.surface,
      child: InkWell(
        onTap: (isLocked || isCompleted) ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // Progress ring
              SizedBox(
                width: 36,
                height: 36,
                child: _ProgressRing(
                  progress: fraction,
                  isCompleted: isCompleted,
                  isLocked: isLocked,
                ),
              ),
              const SizedBox(width: 12),
              // Title and count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isLocked
                            ? AppColors.onSurfaceVariant
                            : AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLocked
                          ? 'Bloqueada'
                          : '$percent% · ${progress.completedExercises}/${progress.totalExercises} ejercicios',
                      style: TextStyle(
                        fontSize: 11,
                        color: isLocked
                            ? AppColors.onSurfaceVariant.withValues(alpha: 0.6)
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLocked)
                Icon(
                  isCompleted ? Icons.check_circle : Icons.chevron_right,
                  size: 20,
                  color: isCompleted
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.progress,
    required this.isCompleted,
    required this.isLocked,
  });

  final double progress;
  final bool isCompleted;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    final color = switch ((isCompleted, isLocked)) {
      (true, _) => AppColors.primary,
      (_, true) => AppColors.onSurfaceVariant.withValues(alpha: 0.4),
      (false, false) => AppColors.primary,
    };

    return CustomPaint(
      painter: _RingPainter(
        progress: progress.clamp(0.0, 1.0),
        color: color,
        trackColor: isLocked
            ? AppColors.onSurfaceVariant.withValues(alpha: 0.1)
            : AppColors.surfaceContainerHigh,
      ),
      child: Center(
        child: isCompleted
            ? Icon(Icons.check, size: 16, color: color)
            : isLocked
                ? Icon(Icons.lock_outline, size: 14, color: color)
                : Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 3.0;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      rect.center,
      rect.width / 2,
      trackPaint,
    );

    // Progress
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
}
