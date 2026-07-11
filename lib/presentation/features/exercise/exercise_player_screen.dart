import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/router/routes.dart';
import '../../../data/remote/services/progress_service.dart';
import '../../../domain/models/exercise.dart';
import '../../../domain/models/lesson_status.dart';
import '../../../core/storage/secure_storage.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import '../../shared/widgets/exercise_widget_factory.dart';
import '../../shared/widgets/loading_skeleton.dart';

class ExercisePlayerScreen extends ConsumerWidget {
  const ExercisePlayerScreen({
    super.key,
    required this.exerciseId,
    this.lessonId,
  });

  final String exerciseId;
  final int? lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(exerciseProvider(exerciseId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cerrar',
          onPressed: () => context.pop(),
        ),
        title: exerciseAsync.when(
          data: (e) => Text(
            e.name.isNotEmpty ? e.name : 'Ejercicio',
          ),
          loading: () => const Text(''),
          error: (_, _) => const Text('Error'),
        ),
      ),
      body: exerciseAsync.when(
        data: (exercise) => _ExerciseBody(
          exercise: exercise,
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
                  Semantics(
                    excludeSemantics: true,
                    child: Container(
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
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No pudimos cargar el ejercicio',
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
                  Semantics(
                    label: 'Reintentar cargar ejercicio',
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            ref.invalidate(exerciseProvider(exerciseId)),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reintentar'),
                      ),
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

class _ExerciseBody extends ConsumerWidget {
  const _ExerciseBody({
    required this.exercise,
    required this.lessonId,
  });

  final Exercise exercise;
  final int? lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedExerciseIds = ref.watch(completedExerciseIdsProvider);
    final progress = ref.watch(progressNotifierProvider);
    final isCompletedOnServer = lessonId != null && progress.any(
      (p) => p.lessonId == lessonId && p.status.isCompleted,
    );
    final isAlreadyCompleted = completedExerciseIds.contains(exercise.id) || isCompletedOnServer;

    return Column(
      children: [
        if (isAlreadyCompleted)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.secondary.withValues(alpha: 0.1),
            child: Row(
              children: [
                Semantics(
                  excludeSemantics: true,
                  child: Icon(Icons.refresh, size: 18, color: AppColors.secondary),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ya completaste este ejercicio. Repasalo sin sumar puntos.',
                    style: TextStyle(fontSize: 13, color: AppColors.secondary),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: ExerciseWidgetFactory(
            exercise: exercise,
            onCompleted: (score) {
              _onExerciseCompleted(context, ref, score);
            },
          ),
        ),
      ],
    );
  }

  Future<void> _onExerciseCompleted(
    BuildContext context,
    WidgetRef ref,
    int score,
  ) async {
    final authState = ref.read(authProvider);
    final isAuthenticated = authState.isAuthenticated;

    final completedIds = ref.read(completedExerciseIdsProvider);
    final progress = ref.read(progressNotifierProvider);
    final isCompletedOnServer = lessonId != null && progress.any(
      (p) => p.lessonId == lessonId && p.status.isCompleted,
    );
    final isAlreadyCompleted = completedIds.contains(exercise.id) || isCompletedOnServer;
    final effectiveScore = isAlreadyCompleted ? 0 : score;

    final currentXp = ref.read(totalXpStateProvider);
    final newXp = currentXp + effectiveScore;
    ref.read(totalXpStateProvider.notifier).state = newXp;

    if (!isAlreadyCompleted) {
      ref.read(completedExerciseIdsProvider.notifier).state = {
        ...completedIds,
        exercise.id,
      };
    }

    if (isAuthenticated && lessonId != null) {
      try {
        await ref.read(progressServiceProvider).updateProgress(
          lessonId!,
          effectiveScore,
        );
        ref.read(progressNotifierProvider.notifier).addProgress(
          exerciseId: exercise.id,
          lessonId: lessonId,
          status: LessonStatus.completed,
          score: effectiveScore,
        );
      } catch (e) {
        debugPrint('ExercisePlayer save server progress error: $e');
      }
    } else {
      ref.read(progressNotifierProvider.notifier).addProgress(
        exerciseId: exercise.id,
        status: LessonStatus.completed,
        score: effectiveScore,
      );

      try {
        final storage = ref.read(secureStorageProvider);
        await storage.saveTotalXp(newXp);
        if (!isAlreadyCompleted) {
        await storage.saveCompletedExerciseIds(
          ref.read(completedExerciseIdsProvider),
        );
        }
      } catch (e) {
        debugPrint('ExercisePlayer storage save error: $e');
      }

      try {
        await ref.read(progressNotifierProvider.notifier).saveProgress(
          exerciseId: exercise.id,
          status: LessonStatus.completed,
          score: effectiveScore,
          exerciseType: exercise.type,
        );
      } catch (e) {
        debugPrint('ExercisePlayer saveProgress error: $e');
      }
    }

    if (!context.mounted) return;
    context.go(AppRoutes.exerciseComplete, extra: {
      'score': score,
      'type': exercise.type,
      'name': exercise.name,
      'isReview': isAlreadyCompleted,
      'accumulatedXp': newXp,
    });
  }
}
