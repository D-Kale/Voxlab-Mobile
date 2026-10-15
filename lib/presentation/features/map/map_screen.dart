import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../data/local/onboarding_store.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/top_stats_bar.dart';
import '../../shared/widgets/voxi_state.dart';
import '../tour/app_tour.dart';
import 'widgets/map_path_model.dart';
import 'widgets/map_scenery.dart';
import 'widgets/track_path.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _currentKey = GlobalKey();
  bool _scrolledToCurrent = false;
  bool _tourChecked = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleScrollToCurrent() {
    if (_scrolledToCurrent) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrolledToCurrent || !mounted) return;
      final ctx = _currentKey.currentContext;
      _scrolledToCurrent = true;
      if (ctx == null) {
        // Everything is completed: no node to scroll to, tour still runs.
        _maybeStartTour();
        return;
      }
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        alignment: 0.45,
      ).then((_) => _maybeStartTour());
    });
  }

  /// First signed-in visit on this device: walk the user through the map,
  /// the stats bar and every tab.
  Future<void> _maybeStartTour() async {
    if (_tourChecked) return;
    _tourChecked = true;
    final store = ref.read(onboardingStoreProvider);
    if (await store.isTourSeen() || !mounted) return;
    // Let the node entrance animations finish so the spotlight lands on
    // their final position.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await showAppTour(context, [
      const TourStep(
        title: '¡Bienvenido a Voxlab!',
        body: 'Te muestro cómo funciona la app en unos segundos.',
      ),
      TourStep(
        target: _currentKey,
        title: 'Tu camino',
        body:
            'Cada círculo es un ejercicio. El que brilla es el siguiente; '
            'los que tienen candado se desbloquean a medida que avanzás.',
      ),
      TourStep(
        target: TourKeys.statsBar,
        title: 'Tu progreso',
        body:
            'Acá ves tu racha de días, la XP que ganaste y los ejercicios '
            'completados.',
      ),
      TourStep(
        target: TourKeys.practiceTab,
        title: 'Practicar',
        body: 'Repasá cuando quieras los ejercicios que ya desbloqueaste.',
      ),
      TourStep(
        target: TourKeys.analyzeTab,
        title: 'Analizar',
        body: 'Tu meta diaria, la XP de la semana y tu historial.',
      ),
      TourStep(
        target: TourKeys.profileTab,
        title: 'Perfil',
        body: 'Tu nivel, tus estadísticas y la opción de cerrar sesión.',
      ),
      TourStep(
        target: _currentKey,
        title: '¡A practicar!',
        body: 'Tocá el ejercicio que brilla para empezar tu primera lección.',
      ),
    ]);
    await store.markTourSeen();
  }

  void _start(PathExerciseNode node) {
    context.push(
      AppRoutes.exercisePath(node.exercise.id),
      extra: {'lessonId': node.lessonId},
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(tracksProvider);
    final completed = ref.watch(completedExerciseIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TopStatsBar(spotlightKey: TourKeys.statsBar),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MapParallaxBackdrop(controller: _scrollController),
                  ),
                  RefreshIndicator(
                    color: AppColors.accentRed,
                    backgroundColor: Colors.white,
                    onRefresh: () async {
                      await ref.read(authProvider.notifier).refreshUser();
                      ref.invalidate(tracksProvider);
                      await ref
                          .read(progressNotifierProvider.notifier)
                          .reload();
                    },
                    child: tracksAsync.when(
                      data: (tracks) {
                        final model = MapPathModel.build(tracks, completed);
                        _scheduleScrollToCurrent();
                        return CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            ...buildMapSlivers(
                              model: model,
                              currentKey: _currentKey,
                              onStart: _start,
                              onGuide: (unit) => showUnitGuide(
                                context,
                                unit: unit,
                                onStart: _start,
                              ),
                            ),
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 32),
                            ),
                          ],
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(16),
                        child: LoadingSkeleton(itemCount: 3),
                      ),
                      error: (err, _) => ErrorView(
                        error: err,
                        onRetry: () {
                          ref.invalidate(tracksProvider);
                          ref.read(progressNotifierProvider.notifier).reload();
                        },
                        showVoxi: true,
                        voxiState: VoxiState.awake,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
