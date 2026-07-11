import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/module.dart';
import '../../../../domain/models/track.dart';
import '../../../../utils/lesson_progress_utils.dart';
import 'module_ship.dart';
import 'serpentine_path_with_connectors.dart';

class TrackIsland extends StatelessWidget {
  const TrackIsland({
    super.key,
    required this.track,
    required this.completedExerciseIds,
    required this.onLessonTap,
  });

  final Track track;
  final Set<String> completedExerciseIds;
  final void Function(int lessonId) onLessonTap;

  @override
  Widget build(BuildContext context) {
    // Filtrar módulos/lecciones sin ejercicios
    final filteredModules = track.modules
        .map((m) => Module(
              id: m.id,
              trackId: m.trackId,
              title: m.title,
              description: m.description,
              orderIndex: m.orderIndex,
              lessons: m.lessons.where((l) => l.exercises.isNotEmpty).toList(),
            ))
        .where((m) => m.lessons.isNotEmpty)
        .toList();

    final completedCount = filteredModules.fold<int>(
      0,
      (sum, m) => sum + m.lessons.where((l) {
        final progress = computeLessonProgress(l, completedExerciseIds);
        return progress.completedExercises == progress.totalExercises &&
            progress.totalExercises > 0;
      }).length,
    );
    final totalCount = filteredModules.fold<int>(
      0,
      (sum, m) => sum + m.lessons.length,
    );
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de la isla
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      track.iconUrl?.isNotEmpty == true
                          ? track.iconUrl!
                          : '🏝️',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Barra de progreso del track
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: const AlwaysStoppedAnimation(AppColors.success),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedCount / $totalCount lecciones completadas',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Módulos como barcos con camino serpenteante
            ...filteredModules.asMap().entries.map((entry) {
              final moduleIndex = entry.key;
              final module = entry.value;

              // Calcular lecciones completadas en este módulo
              final moduleCompleted = module.lessons.where((l) {
                final progress = computeLessonProgress(l, completedExerciseIds);
                return progress.completedExercises == progress.totalExercises &&
                    progress.totalExercises > 0;
              }).length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barco módulo
                  ModuleShip(
                    title: module.title,
                    completedLessons: moduleCompleted,
                    totalLessons: module.lessons.length,
                  ),

                  // Camino serpenteante de lecciones
                  SerpentinePathWithConnectors(
                    lessons: module.lessons,
                    completedExerciseIds: completedExerciseIds,
                    moduleIndex: moduleIndex,
                    onLessonTap: onLessonTap,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}