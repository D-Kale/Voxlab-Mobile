import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../domain/models/track.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/voxi_state.dart';
import 'widgets/track_path.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _currentAnchorKey = GlobalKey();
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
      final ctx = _currentAnchorKey.currentContext;
      if (ctx == null) return;
      _scrolledToCurrent = true;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        alignment: 0.2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(tracksProvider);
    final completedExerciseIds = ref.watch(completedExerciseIdsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/voxi_logo.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Perfil',
            onPressed: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accentRed,
        backgroundColor: Colors.white,
        onRefresh: () async {
          await ref.read(authProvider.notifier).refreshUser();
          ref.invalidate(tracksProvider);
          await ref.read(progressNotifierProvider.notifier).reload();
        },
        child: tracksAsync.when(
          data: (tracks) {
            _scheduleScrollToCurrent();
            return _PathListView(
              tracks: tracks,
              completedExerciseIds: completedExerciseIds,
              scrollController: _scrollController,
              currentAnchorKey: _currentAnchorKey,
              onExerciseTap: (exerciseId, lessonId) => context.push(
                AppRoutes.exercisePath(exerciseId),
                extra: {'lessonId': lessonId},
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: LoadingSkeleton(itemCount: 3),
          ),
          error: (err, _) => _MapErrorView(
            error: err,
            onRetry: () {
              ref.invalidate(tracksProvider);
              ref.read(progressNotifierProvider.notifier).reload();
            },
          ),
        ),
      ),
    );
  }
}

class _MapErrorView extends StatelessWidget {
  const _MapErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ErrorView(
      error: error,
      onRetry: onRetry,
      showVoxi: true,
      voxiState: VoxiState.awake,
    );
  }
}

class _PathListView extends StatelessWidget {
  const _PathListView({
    required this.tracks,
    required this.completedExerciseIds,
    required this.scrollController,
    required this.currentAnchorKey,
    required this.onExerciseTap,
  });

  final List<Track> tracks;
  final Set<String> completedExerciseIds;
  final ScrollController scrollController;
  final GlobalKey currentAnchorKey;
  final void Function(String exerciseId, int lessonId) onExerciseTap;

  static int _currentTrackIndex(
    List<Track> tracks,
    Set<String> completed,
  ) {
    for (var i = 0; i < tracks.length; i++) {
      final isDone = tracks[i].modules.every(
        (m) => m.lessons.every(
          (l) => l.exercises.every((e) => completed.contains(e.id)),
        ),
      );
      if (!isDone) return i;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = _currentTrackIndex(tracks, completedExerciseIds);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        const _GreetingCard(),
        for (var t = 0; t < tracks.length; t++) ...[
          _TrackHeaderCard(track: tracks[t]),
          TrackPath(
            key: ValueKey(tracks[t].id),
            track: tracks[t],
            completedExerciseIds: completedExerciseIds,
            onExerciseTap: onExerciseTap,
            anchorKey: t == currentTrack ? currentAnchorKey : null,
          ),
        ],
      ],
    );
  }
}

class _TrackHeaderCard extends StatelessWidget {
  const _TrackHeaderCard({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentRed, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.accentRed,
            offset: Offset(0, 5),
            blurRadius: 0,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x33D93B27),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (track.iconUrl != null && track.iconUrl!.isNotEmpty) ...[
            Text(track.iconUrl!, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkBrown,
                    height: 1.25,
                  ),
                ),
                if (track.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    track.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkBrownLight,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentRed, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.accentRed,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x33D93B27),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/voxi_awake.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Seguí así!',
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkBrown,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Estás sonando cada día más seguro.',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkBrownLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
