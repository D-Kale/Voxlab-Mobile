import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/top_stats_bar.dart';
import '../../shared/widgets/voxi_state.dart';
import 'widgets/map_path_model.dart';
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
      if (ctx == null) return;
      _scrolledToCurrent = true;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        alignment: 0.45,
      );
    });
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
            const TopStatsBar(),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.accentRed,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  await ref.read(authProvider.notifier).refreshUser();
                  ref.invalidate(tracksProvider);
                  await ref.read(progressNotifierProvider.notifier).reload();
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
                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
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
            ),
          ],
        ),
      ),
    );
  }
}
