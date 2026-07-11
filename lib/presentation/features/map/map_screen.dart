import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../core/router/routes.dart';
import '../../../domain/models/track.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/xp_bar.dart';
import 'widgets/track_island.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(loadXpFromStorageProvider);
    ref.watch(progressNotifierProvider);
    final tracksAsync = ref.watch(tracksProvider);
    final totalXp = ref.watch(totalXpStateProvider);
    final completedExerciseIds = ref.watch(completedExerciseIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Voxlab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
            onPressed: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          await ref.read(authProvider.notifier).refreshUser();
          ref.invalidate(tracksProvider);
          await ref.read(progressNotifierProvider.notifier).reload();
        },
        child: tracksAsync.when(
          data: (tracks) => _IslandListView(
            tracks: tracks,
            totalXp: totalXp,
            completedExerciseIds: completedExerciseIds,
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
                          Icons.cloud_off,
                          size: 40,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No pudimos cargar los cursos',
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
                      label: 'Reintentar cargar cursos',
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => ref.invalidate(tracksProvider),
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
      ),
    );
  }
}

class _IslandListView extends StatelessWidget {
  const _IslandListView({
    required this.tracks,
    required this.totalXp,
    required this.completedExerciseIds,
  });

  final List<Track> tracks;
  final int totalXp;
  final Set<String> completedExerciseIds;

  @override
  Widget build(BuildContext context) {
    return tracks.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  const Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay cursos disponibles',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          )
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
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
                            Icons.auto_awesome,
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
                            const Text(
                              'Tu progreso',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            XpBar(xp: totalXp),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...tracks.map(
                (track) => TrackIsland(
                  track: track,
                  completedExerciseIds: completedExerciseIds,
                  onLessonTap: (lessonId) =>
                      context.push(AppRoutes.lessonPath(lessonId)),
                ),
              ),
            ],
          );
  }
}
