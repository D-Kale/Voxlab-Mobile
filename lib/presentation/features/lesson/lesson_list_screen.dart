import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/router/routes.dart';
import '../../../domain/models/exercise.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import '../../shared/widgets/loading_skeleton.dart';
import 'widgets/serpentine_exercise_node.dart';

class LessonListScreen extends ConsumerWidget {
  const LessonListScreen({super.key, required this.lessonId});

  final int lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonAsync = ref.watch(lessonProvider(lessonId));
    final exercisesAsync = ref.watch(lessonExercisesProvider(lessonId));

    final completedExerciseIds = ref.watch(completedExerciseIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: lessonAsync.when(
          data: (lesson) => Text(lesson.title),
          loading: () => const Text('Lección'),
          error: (_, _) => const Text('Error'),
        ),
      ),
      body: exercisesAsync.when(
        data: (exercises) => _SerpentineExercisePath(
          exercises: exercises,
          completedExerciseIds: completedExerciseIds,
          lessonId: lessonId,
        ),
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: LoadingSkeleton(itemCount: 3),
        ),
        error: (err, _) {
          String message;
          if (err is ApiException) {
            message = err.message;
          } else if (err is DioException) {
            message = switch (err.type) {
              DioExceptionType.connectionTimeout ||
              DioExceptionType.receiveTimeout ||
              DioExceptionType.sendTimeout =>
                'Tiempo de espera agotado. Revisá tu conexión.',
              DioExceptionType.connectionError =>
                'Sin conexión a internet.',
              DioExceptionType.badResponse =>
                'Error del servidor (${err.response?.statusCode}).',
              _ => 'Error de conexión inesperado.',
            };
          } else {
            message = 'Ocurrió un error inesperado.';
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      size: 40,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No pudimos cargar los ejercicios',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          ref.invalidate(lessonExercisesProvider(lessonId)),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reintentar'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SerpentineExercisePath extends StatelessWidget {
  const _SerpentineExercisePath({
    required this.exercises,
    required this.completedExerciseIds,
    required this.lessonId,
  });

  final List<Exercise> exercises;
  final Set<String> completedExerciseIds;
  final int lessonId;

  Alignment getSnakeAlignment(int index) {
    return switch (index % 4) {
      0 => Alignment.center,
      1 => Alignment(0.5, 0),
      2 => Alignment.center,
      3 => Alignment(-0.5, 0),
      _ => Alignment.center,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay ejercicios disponibles',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final isLessonCompleted = exercises.every((e) =>
        completedExerciseIds.contains(e.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (isLessonCompleted)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '¡Lección completada!',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          ...exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            final isCompleted = completedExerciseIds.contains(exercise.id);
            final isLocked = _isExerciseLocked(index, exercises, completedExerciseIds);

            return Column(
              children: [
                Align(
                  alignment: getSnakeAlignment(index),
                  child: SerpentineExerciseNode(
                    exercise: exercise,
                    isCompleted: isCompleted,
                    isLocked: isLocked,
                    onTap: isLocked
                        ? null
                        : () => context.push(
                              AppRoutes.exercisePath(exercise.id),
                              extra: {'exercise': exercise, 'lessonId': lessonId},
                            ),
                  ),
                ),
                if (index < exercises.length - 1)
                  const SizedBox(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }
}

bool _isExerciseLocked(
  int index,
  List<Exercise> exercises,
  Set<String> completedExerciseIds,
) {
  // Primer ejercicio siempre disponible
  if (index == 0) return false;

  // El ejercicio anterior debe estar completado
  final previous = exercises[index - 1];
  return !completedExerciseIds.contains(previous.id);
}
