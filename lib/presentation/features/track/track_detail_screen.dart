import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/router/routes.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/widgets/loading_skeleton.dart';

class TrackDetailScreen extends ConsumerWidget {
  const TrackDetailScreen({super.key, required this.trackId});

  final int trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackAsync = ref.watch(trackProvider(trackId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: trackAsync.when(
          data: (track) => Text(track.title),
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const Text('Curso'),
        ),
      ),
      body: trackAsync.when(
        data: (track) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (track.description.isNotEmpty) ...[
              Text(
                track.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              'Módulos (${track.modules.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...track.modules.map(
              (module) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ModuleCard(
                  moduleTitle: module.title,
                  moduleDescription: module.description,
                  lessonCount: module.lessons.length,
                  onTap: () => context.push(AppRoutes.modulePath(module.id)),
                ),
              ),
            ),
          ],
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
                    'No pudimos cargar el curso',
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
                    label: 'Reintentar cargar curso',
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => ref.invalidate(trackProvider(trackId)),
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

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.moduleTitle,
    required this.moduleDescription,
    required this.lessonCount,
    required this.onTap,
  });

  final String moduleTitle;
  final String moduleDescription;
  final int lessonCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Módulo: $moduleTitle, $lessonCount lecciones',
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Semantics(
                  excludeSemantics: true,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.folder_outlined,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moduleTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (moduleDescription.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          moduleDescription,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        '$lessonCount lecciones',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  excludeSemantics: true,
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
