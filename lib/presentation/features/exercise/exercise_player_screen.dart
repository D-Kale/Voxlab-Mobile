import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../domain/models/exercise.dart';
import '../../../domain/models/exercise_content.dart';
import '../../../domain/models/exercise_outcome.dart';
import '../../../domain/models/lesson_status.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import '../../shared/widgets/exercise_widget_factory.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/voxi_state.dart';

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
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Cerrar',
          onPressed: () => context.pop(),
        ),
        title: exerciseAsync.when(
          data: (e) => Text(
            e.name.isNotEmpty ? e.name : 'Ejercicio',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBrown,
            ),
          ),
          loading: () => const Text(''),
          error: (_, _) => const Text('Error'),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
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
        error: (err, _) => _ExerciseErrorView(
          error: err,
          onRetry: () => ref.invalidate(exerciseProvider(exerciseId)),
        ),
      ),
    );
  }
}

class _ExerciseErrorView extends StatelessWidget {
  const _ExerciseErrorView({required this.error, required this.onRetry});

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

class _ExerciseBody extends ConsumerWidget {
  const _ExerciseBody({
    required this.exercise,
    required this.lessonId,
  });

  final Exercise exercise;
  final int? lessonId;

  int get _xpReward {
    final content = exercise.content;
    return switch (content) {
      final QuizContent q => q.questions.length * q.pointsPerQuestion,
      final ReadingContent r => r.points,
      final WritingContent w => w.points,
      final OratoryContent o => o.points,
      final AudioContent a => a.points,
      final VideoContent v => v.points,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedExerciseIds = ref.watch(completedExerciseIdsProvider);
    final isAlreadyCompleted = completedExerciseIds.contains(exercise.id);

    return Column(
      children: [
        if (isAlreadyCompleted)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.successContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success, width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.refresh_rounded, size: 20, color: AppColors.success),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Ya completaste este ejercicio. Repasalo sin sumar puntos.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSuccessContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // Header with Voxi + XP/Type badges
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.accentRed, width: 3),
            boxShadow: const [
              BoxShadow(
                color: AppColors.accentRed,
                offset: Offset(0, 4),
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
            children: [
              Image.asset(
                'assets/images/voxi_awake.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name.isNotEmpty ? exercise.name : 'Ejercicio',
                      style: GoogleFonts.dmSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _TypeBadge(type: exercise.type),
                        const SizedBox(width: 8),
                        _XpBadge(xp: _xpReward),
                      ],
                    ),
                  ],
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

    await ref.read(progressNotifierProvider.notifier).saveProgress(
          exerciseId: exercise.id,
          lessonId: lessonId,
          status: LessonStatus.completed,
          score: effectiveScore,
        );

    if (!context.mounted) return;
    context.go(AppRoutes.exerciseComplete, extra: {
      'score': effectiveScore,
      'type': exercise.type,
      'name': exercise.name,
      'isReview': isAlreadyCompleted,
      'sessionResult': outcome.sessionResult,
    });
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.accentRed, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconForType(type),
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            _labelForType(type),
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'quiz':
        return Icons.quiz_rounded;
      case 'reading':
        return Icons.menu_book_rounded;
      case 'writing':
        return Icons.edit_rounded;
      case 'oratory':
        return Icons.mic_rounded;
      default:
        return Icons.help_outline;
    }
  }

  String _labelForType(String type) {
    switch (type) {
      case 'quiz':
        return 'Quiz';
      case 'reading':
        return 'Lectura';
      case 'writing':
        return 'Escritura';
      case 'oratory':
        return 'Oratoria';
      default:
        return type;
    }
  }
}

class _XpBadge extends StatelessWidget {
  const _XpBadge({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accentRedContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.accentRed, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.accentRed),
          const SizedBox(width: 4),
          Text(
            '+$xp XP',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.accentRed,
            ),
          ),
        ],
      ),
    );
  }
}