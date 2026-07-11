import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/exercise.dart';

class ExerciseMiniature extends StatelessWidget {
  const ExerciseMiniature({
    super.key,
    required this.exercise,
    required this.isCompleted,
    required this.isLocked,
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

    final opacity = isLocked ? 0.4 : (isCompleted ? 0.85 : 1.0);

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(
              color: isLocked
                  ? AppColors.onSurfaceVariant.withValues(alpha: 0.3)
                  : color,
              width: 2.5,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check : (isLocked ? Icons.lock_outline : _iconForType(exercise.type)),
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
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

class ExerciseMiniaturesRow extends StatelessWidget {
  const ExerciseMiniaturesRow({
    super.key,
    required this.exercises,
    required this.firstUnlocked,
    required this.completedExerciseIds,
    required this.lessonId,
    this.onExerciseTap,
  });

  final List<Exercise> exercises;
  final bool firstUnlocked;
  final Set<String> completedExerciseIds;
  final int lessonId;
  final void Function(String exerciseId, Exercise exercise)? onExerciseTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(exercises.length, (i) {
        final exercise = exercises[i];
        final isCompleted = completedExerciseIds.contains(exercise.id);
        final isLocked = i > 0 && !completedExerciseIds.contains(exercises[i - 1].id);

        return Padding(
          padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
          child: ExerciseMiniature(
            exercise: exercise,
            isCompleted: isCompleted,
            isLocked: isLocked,
            onTap: () => onExerciseTap?.call(exercise.id, exercise),
          ),
        );
      }),
    );
  }
}
