import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/lesson_status.dart';
import '../../../../domain/models/track.dart';
import '../../../../utils/lesson_progress_utils.dart';
import 'module_ship.dart';
import 'serpentine_lesson_node.dart';
import 'bezier_connector.dart';

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

  /// Calcula el alineamiento serpenteante basado en el índice
  Alignment getSnakeAlignment(int index) {
    return switch (index % 4) {
      0 => Alignment.center,
      1 => Alignment(0.5, 0), // derecha
      2 => Alignment.center,
      3 => Alignment(-0.5, 0), // izquierda
      _ => Alignment.center, // fallback
    };
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = track.modules.fold<int>(
      0,
      (sum, m) => sum + m.lessons.where((l) {
        final progress = computeLessonProgress(l, completedExerciseIds);
        return progress.completedExercises == progress.totalExercises &&
            progress.totalExercises > 0;
      }).length,
    );
    final totalCount = track.modules.fold<int>(
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
            ...track.modules.asMap().entries.map((entry) {
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
                  ..._buildSerpentinePath(module.lessons, moduleIndex),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSerpentinePath(
    List lessons,
    int moduleIndex,
  ) {
    final widgets = <Widget>[];
    final lessonProgressList = <LessonProgressInfo>[];

    // Calcular progreso de todas las lecciones primero
    for (final lesson in lessons) {
      lessonProgressList.add(computeLessonProgress(lesson, completedExerciseIds));
    }

    // Determinar estados con locking
    for (var i = 0; i < lessons.length; i++) {
      lessonProgressList[i] = LessonProgressInfo(
        lessonId: lessonProgressList[i].lessonId,
        status: determineLessonStatus(i, lessonProgressList[i], lessonProgressList),
        completedExercises: lessonProgressList[i].completedExercises,
        totalExercises: lessonProgressList[i].totalExercises,
        progressPercent: lessonProgressList[i].progressPercent,
      );
    }

    // Construir nodos y conectores
    for (var i = 0; i < lessons.length; i++) {
      final lesson = lessons[i];
      final progressInfo = lessonProgressList[i];

      // Conector desde el nodo anterior (si no es el primero)
      if (i > 0) {
        final prevProgress = lessonProgressList[i - 1];
        widgets.add(
          SizedBox(
            height: 80, // Espacio para el conector
            child: BezierConnector(
              startOffset: Offset(0, 0), // Se calculará en runtime
              endOffset: Offset(0, 80),
              isConnected: prevProgress.status == LessonStatus.completed,
            ),
          ),
        );
      }

      // Nodo de lección
      widgets.add(
        Align(
          alignment: getSnakeAlignment(i),
          child: SerpentineLessonNode(
            lesson: lesson,
            status: progressInfo.status,
            progressPercent: progressInfo.progressPercent,
            onTap: () => onLessonTap(lesson.id),
          ),
        ),
      );

      // Espacio vertical
      if (i < lessons.length - 1) {
        widgets.add(const SizedBox(height: 16));
      }
    }

    return widgets;
  }
}