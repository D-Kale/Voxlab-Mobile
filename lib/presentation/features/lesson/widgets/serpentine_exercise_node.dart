import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/exercise.dart';

class SerpentineExerciseNode extends StatelessWidget {
  const SerpentineExerciseNode({
    super.key,
    required this.exercise,
    required this.isCompleted,
    this.isLocked = false,
    this.onTap,
  });

  final Exercise exercise;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch ((isCompleted, isLocked)) {
      (true, _) => AppColors.primary,
      (_, true) => AppColors.onSurfaceVariant,
      (false, false) => AppColors.primary,
    };

    final opacity = isLocked ? 0.45 : (isCompleted ? 0.8 : 1.0);

    final iconData = _getIconForExercise(exercise);

    return GestureDetector(
      onTap: (isCompleted || isLocked) ? null : onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(
              color: isLocked
                  ? AppColors.onSurfaceVariant.withValues(alpha: 0.3)
                  : color,
              width: 3,
            ),
            boxShadow: isLocked
                ? null
                : [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
          ),
          child: Icon(
            iconData,
            size: 24,
            color: color,
          ),
        ),
      ),
    );
  }

  IconData _getIconForExercise(Exercise exercise) {
    if (isCompleted) return Icons.check;

    if (isLocked) return Icons.lock_outline;

    return switch (exercise.type) {
      'quiz' => Icons.quiz_outlined,
      'reading' => Icons.menu_book_outlined,
      'oratory_minigame' => Icons.mic,
      'writing' => Icons.edit,
      'audio' => Icons.headphones,
      'video' => Icons.videocam,
      _ => Icons.star,
    };
  }
}
