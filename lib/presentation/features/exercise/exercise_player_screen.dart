import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../domain/models/exercise.dart';
import '../../../domain/models/exercise_outcome.dart';
import '../../../domain/models/lesson_status.dart';
import '../../../utils/exercise_name_utils.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import '../../shared/widgets/chunky.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/exercise_type_style.dart';
import '../../shared/widgets/exercise_widget_factory.dart';
import '../../shared/widgets/lesson_widgets.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/motion.dart';
import '../../shared/widgets/voxi_state.dart';
import '../../shared/widgets/voxi_mood.dart';

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
    final tracksAsync = ref.watch(tracksProvider);
    final unlocked = ref.watch(unlockedExerciseIdsProvider);

    Widget withTopBar(Widget child) => Column(
      children: [
        const _LessonTopBar(exercise: null),
        Expanded(child: child),
      ],
    );

    final Widget body;
    final error = exerciseAsync.error ?? tracksAsync.error;
    if (error != null) {
      body = withTopBar(
        ErrorView(
          error: error,
          onRetry: () {
            ref.invalidate(exerciseProvider(exerciseId));
            ref.invalidate(tracksProvider);
          },
          showVoxi: true,
          voxiState: VoxiState.awake,
        ),
      );
    } else if (!exerciseAsync.hasValue || unlocked == null) {
      body = withTopBar(
        const Padding(
          padding: EdgeInsets.all(16),
          child: LoadingSkeleton(itemCount: 3),
        ),
      );
    } else if (!unlocked.contains(exerciseId)) {
      // Also covers deep links: a locked exercise never starts.
      body = withTopBar(const _LockedExercise());
    } else {
      body = _ExerciseBody(
        exercise: exerciseAsync.requireValue,
        lessonId: lessonId,
      );
    }

    return Scaffold(
      backgroundColor: lessonBackground,
      body: SafeArea(child: body),
    );
  }
}

class _LockedExercise extends StatelessWidget {
  const _LockedExercise();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Bob(
              child: Image.asset(
                VoxiMood.bored.asset,
                width: 130,
                height: 130,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.idleFace,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: AppColors.darkBrownLight,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Ejercicio bloqueado',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completá los ejercicios anteriores del camino '
              'para desbloquearlo.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBrownLight,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            ChunkyButton(
              label: 'VOLVER AL MAPA',
              icon: Icons.map_rounded,
              onPressed: () => context.go(AppRoutes.map),
            ),
          ],
        ),
      ),
    );
  }
}

/// Close button plus the exercise identity: type badge, name and XP.
class _LessonTopBar extends StatelessWidget {
  const _LessonTopBar({required this.exercise});

  final Exercise? exercise;

  @override
  Widget build(BuildContext context) {
    final e = exercise;
    final style = ExerciseTypeStyle.of(e?.type ?? '');
    final xp = e == null ? 0 : exerciseXpReward(e);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              size: 30,
              color: AppColors.darkBrownLight,
            ),
            tooltip: 'Cerrar',
            onPressed: () => context.pop(),
          ),
          if (e != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: style.colors.face,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: style.colors.lip,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(style.icon, color: style.colors.content, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.name.isNotEmpty ? e.name : formatExerciseType(e.type),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  Text(
                    formatExerciseType(e.type),
                    style: GoogleFonts.dmSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBrownLight,
                    ),
                  ),
                ],
              ),
            ),
            if (xp > 0)
              ChunkyTag(
                label: '+$xp XP',
                icon: Icons.bolt_rounded,
                color: AppColors.accentRed,
              ),
          ],
        ],
      ),
    );
  }
}

class _ExerciseBody extends ConsumerWidget {
  const _ExerciseBody({required this.exercise, required this.lessonId});

  final Exercise exercise;
  final int? lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedExerciseIds = ref.watch(completedExerciseIdsProvider);
    final isAlreadyCompleted = completedExerciseIds.contains(exercise.id);

    return Column(
      children: [
        _LessonTopBar(exercise: exercise),
        if (isAlreadyCompleted)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.replay_rounded,
                  size: 20,
                  color: AppColors.onSuccessContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ya completaste este ejercicio. Repasalo sin sumar puntos.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ExerciseWidgetFactory(
              exercise: exercise,
              onCompleted: (outcome) =>
                  _onExerciseCompleted(context, ref, outcome),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _onExerciseCompleted(
    BuildContext context,
    WidgetRef ref,
    ExerciseOutcome outcome,
  ) async {
    final completedIds = ref.read(completedExerciseIdsProvider);
    final isAlreadyCompleted = completedIds.contains(exercise.id);
    final effectiveScore = isAlreadyCompleted ? 0 : outcome.score;

    await ref
        .read(progressNotifierProvider.notifier)
        .saveProgress(
          exerciseId: exercise.id,
          lessonId: lessonId,
          status: LessonStatus.completed,
          score: effectiveScore,
        );

    if (!context.mounted) return;
    context.go(
      AppRoutes.exerciseComplete,
      extra: {
        'score': effectiveScore,
        'type': exercise.type,
        'name': exercise.name,
        'isReview': isAlreadyCompleted,
        'sessionResult': outcome.sessionResult,
      },
    );
  }
}
