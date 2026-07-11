import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/router/routes.dart';
import '../../../domain/models/module.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import '../../shared/widgets/lesson_card.dart';
import '../../shared/widgets/loading_skeleton.dart';

class ModuleDetailScreen extends ConsumerWidget {
  const ModuleDetailScreen({super.key, required this.moduleId});

  final int moduleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moduleAsync = ref.watch(moduleProvider(moduleId));
    final progress = ref.watch(progressNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: moduleAsync.when(
          data: (m) => Text(m.title),
          loading: () => const Text(''),
          error: (_, _) => const Text('Error'),
        ),
      ),
      body: moduleAsync.when(
        data: (module) => _ModuleContent(
          module: module,
          completedIds: progress
                  .where((p) => p.status.isCompleted)
                  .map((p) => p.exerciseId)
                  .toList(),
        ),
        loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: LoadingSkeleton(itemCount: 4),
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
                    'No pudimos cargar este módulo',
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
                    label: 'Reintentar cargar módulo',
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => ref.invalidate(moduleProvider(moduleId)),
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

class _ModuleContent extends StatelessWidget {
  const _ModuleContent({
    required this.module,
    required this.completedIds,
  });

  final Module module;
  final List<String> completedIds;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (module.description.isNotEmpty) ...[
          Text(
            module.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
        ],
        Row(
          children: [
            Semantics(
              excludeSemantics: true,
              child: Icon(
                Icons.menu_book,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Lecciones (${module.lessons.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (module.lessons.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No hay lecciones en este módulo',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ),
          )
        else
          ...module.lessons.map(
            (lesson) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LessonCard(
                lesson: lesson,
                isCompleted: completedIds.contains(lesson.id.toString()),
                onTap: () => context.push(AppRoutes.lessonPath(lesson.id)),
              ),
            ),
          ),
      ],
    );
  }
}
