import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/module.dart';
import '../../../../domain/models/lesson_status.dart';
import '../../../../domain/models/track.dart';
import '../../../../utils/lesson_progress_utils.dart';
import 'exercise_miniature.dart';
import 'lesson_progress_card.dart';
import 'module_ship.dart';

class TrackIsland extends StatelessWidget {
  const TrackIsland({
    super.key,
    required this.track,
    required this.completedExerciseIds,
    required this.onExerciseTap,
  });

  final Track track;
  final Set<String> completedExerciseIds;
  final void Function(String exerciseId) onExerciseTap;

  @override
  Widget build(BuildContext context) {
    final filteredModules = _filteredModules();

    final completedCount = filteredModules.fold<int>(
      0,
      (sum, m) => sum + m.lessons.where((l) {
        final p = computeLessonProgress(l, completedExerciseIds);
        return p.completedExercises == p.totalExercises && p.totalExercises > 0;
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
            _Header(track: track),
            const SizedBox(height: 16),
            _TrackProgress(progress: progress, completedCount: completedCount, totalCount: totalCount),
            const SizedBox(height: 24),
            ...filteredModules.map(_buildModule),
          ],
        ),
      ),
    );
  }

  List<Module> _filteredModules() {
    return track.modules
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
  }

  Widget _buildModule(Module module) {
    // Precalcular todo el progreso para este módulo
    final lessonProgresses = module.lessons
        .map((l) => computeLessonProgress(l, completedExerciseIds))
        .toList();
    final lessonStatuses = <LessonStatus>[];
    for (var i = 0; i < lessonProgresses.length; i++) {
      lessonStatuses.add(determineLessonStatus(i, lessonProgresses[i], lessonProgresses));
    }

    final moduleCompleted = lessonStatuses.where((s) => s == LessonStatus.completed).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModuleShip(
          title: module.title,
          completedLessons: moduleCompleted,
          totalLessons: module.lessons.length,
        ),
        ...module.lessons.asMap().entries.map((entry) {
          final i = entry.key;
          final lesson = entry.value;
          final status = lessonStatuses[i];
          final isCompleted = status == LessonStatus.completed;
          final isLocked = status == LessonStatus.locked;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 8),
                  child: ExerciseMiniaturesRow(
                    exercises: lesson.exercises,
                    firstUnlocked: i == 0 || !isLocked,
                    completedExerciseIds: completedExerciseIds,
                    lessonId: lesson.id,
                    onExerciseTap: (id, _) => onExerciseTap(id),
                  ),
                ),
                LessonProgressCard(
                  lesson: lesson,
                  isLocked: isLocked,
                  isCompleted: isCompleted,
                  completedExerciseIds: completedExerciseIds,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.track});
  final Track track;

  @override
  Widget build(BuildContext context) {
    return Row(
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
              track.iconUrl?.isNotEmpty == true ? track.iconUrl! : '🏝️',
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
    );
  }
}

class _TrackProgress extends StatelessWidget {
  const _TrackProgress({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
  });

  final double progress;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}
