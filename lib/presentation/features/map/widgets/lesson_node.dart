import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/lesson_status.dart';

class LessonNode extends StatelessWidget {
  const LessonNode({
    super.key,
    required this.lessonId,
    required this.lessonNumber,
    required this.status,
    this.onTap,
  });

  final int lessonId;
  final int lessonNumber;
  final LessonStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = status == LessonStatus.locked;
    final isCompleted = status == LessonStatus.completed;

    final color = switch (status) {
      LessonStatus.completed => AppColors.success,
      LessonStatus.inProgress => AppColors.secondary,
      LessonStatus.available => AppColors.primary,
      LessonStatus.locked => AppColors.onSurfaceVariant,
    };

    final icon = switch (status) {
      LessonStatus.completed => Icons.check,
      LessonStatus.inProgress => Icons.play_arrow,
      LessonStatus.available => Icons.play_arrow,
      LessonStatus.locked => Icons.lock,
    };

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Semantics(
        label: 'Lección $lessonNumber${isLocked ? ', bloqueada' : ''}',
        button: !isLocked,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCompleted
                    ? color.withValues(alpha: 0.15)
                    : isLocked
                        ? AppColors.surfaceContainerHigh
                        : color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? color
                      : isLocked
                          ? AppColors.surfaceContainerHigh
                          : color,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: isCompleted ? 22 : 20,
                color: isLocked
                    ? AppColors.onSurfaceVariant.withValues(alpha: 0.5)
                    : color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$lessonNumber',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isLocked
                    ? AppColors.onSurfaceVariant.withValues(alpha: 0.5)
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
