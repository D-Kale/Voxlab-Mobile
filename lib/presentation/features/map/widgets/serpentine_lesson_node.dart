import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/lesson.dart';
import '../../../../domain/models/lesson_status.dart';
import 'lesson_progress_ring.dart';

/// Nodo de lección en el camino serpenteante
class SerpentineLessonNode extends StatelessWidget {
  const SerpentineLessonNode({
    super.key,
    required this.lesson,
    required this.status,
    required this.progressPercent,
    this.onTap,
  });

  final Lesson lesson;
  final LessonStatus status;
  final double progressPercent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isLocked = status == LessonStatus.locked;
    final isCompleted = status == LessonStatus.completed;

    // Color según estado
    final color = switch (status) {
      LessonStatus.completed => AppColors.success,
      LessonStatus.inProgress => AppColors.primary,
      LessonStatus.available => AppColors.primary,
      LessonStatus.locked => AppColors.onSurfaceVariant,
    };

    // Icono según tipo de lección
    final iconData = _getIconForLesson(lesson);

    // Opacidad para bloqueados
    final opacity = isLocked ? 0.5 : 1.0;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Opacity(
        opacity: opacity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Anillo de progreso (detrás)
            if (progressPercent > 0 && progressPercent < 1)
              LessonProgressRing(
                progress: progressPercent,
                color: color,
                size: 72,
                strokeWidth: 4,
              ),

            // Círculo principal con efecto 3D
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? color.withValues(alpha: 0.15)
                    : color.withValues(alpha: 0.15),
                border: Border.all(
                  color: color,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                iconData,
                size: 32,
                color: isCompleted
                    ? color
                    : isLocked
                        ? AppColors.onSurfaceVariant.withValues(alpha: 0.5)
                        : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForLesson(Lesson lesson) {
    if (lesson.exercises.isEmpty) {
      return Icons.star; // Default
    }

    // Usar el tipo del primer ejercicio
    final type = lesson.exercises.first.type;

    return switch (type) {
      'reading' => Icons.menu_book_outlined,
      'quiz' => Icons.quiz_outlined,
      'oratory_minigame' => Icons.mic,
      'writing' => Icons.edit,
      'audio' => Icons.headphones,
      'video' => Icons.videocam,
      _ => Icons.star,
    };
  }
}