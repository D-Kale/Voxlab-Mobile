import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/exercise.dart';

/// Nodo de ejercicio en el camino serpenteante
class SerpentineExerciseNode extends StatelessWidget {
  const SerpentineExerciseNode({
    super.key,
    required this.exercise,
    required this.isCompleted,
    this.onTap,
  });

  final Exercise exercise;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isCompleted
        ? AppColors.success
        : AppColors.primary;

    final iconData = _getIconForExercise(exercise);

    return GestureDetector(
      onTap: isCompleted ? null : onTap,
      child: Opacity(
        opacity: isCompleted ? 0.7 : 1.0,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(
              color: color,
              width: 3,
            ),
            boxShadow: [
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
    if (isCompleted) {
      return Icons.check;
    }

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