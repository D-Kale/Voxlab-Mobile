import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../domain/models/exercise.dart';
import '../../../domain/models/exercise_content.dart';
import '../../../domain/models/track.dart';
import '../../../utils/exercise_name_utils.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import '../../shared/widgets/chunky.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/exercise_type_style.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/motion.dart';
import '../../shared/widgets/tab_header.dart';
import '../../shared/widgets/voxi_state.dart';

class PracticeScreen extends ConsumerStatefulWidget {
  const PracticeScreen({super.key});

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen> {
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    final tracksAsync = ref.watch(tracksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: tracksAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: LoadingSkeleton(itemCount: 6),
          ),
          error: (error, _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(tracksProvider),
            showVoxi: true,
            voxiState: VoxiState.awake,
          ),
          data: (tracks) {
            final exercises = _flatten(tracks);
            if (exercises.isEmpty) {
              return const _EmptyExercises();
            }
            return _PracticeBody(
              exercises: exercises,
              selectedType: _selectedType,
              onTypeSelected: (type) => setState(() => _selectedType = type),
            );
          },
        ),
      ),
    );
  }

  List<Exercise> _flatten(List<Track> tracks) {
    return [
      for (final track in tracks)
        for (final module in track.modules)
          for (final lesson in module.lessons) ...lesson.exercises,
    ];
  }
}

class _PracticeBody extends ConsumerWidget {
  const _PracticeBody({
    required this.exercises,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final List<Exercise> exercises;
  final String? selectedType;
  final void Function(String?) onTypeSelected;

  /// Canonical filter key derived from the parsed content, not the raw
  /// `type` string: the backend sends both `oratory` and `oratory_minigame`,
  /// which would otherwise produce two identical "Oratoria" chips.
  static String _typeKeyOf(Exercise exercise) {
    return switch (exercise.content) {
      QuizContent() => 'quiz',
      ReadingContent() => 'reading',
      WritingContent() => 'writing',
      OratoryContent() => 'oratory',
      AudioContent() => 'audio',
      VideoContent() => 'video',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completed = ref.watch(completedExerciseIdsProvider);
    final types = {for (final e in exercises) _typeKeyOf(e)}.toList()..sort();
    final filtered = selectedType == null
        ? exercises
        : exercises.where((e) => _typeKeyOf(e) == selectedType).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const TabHeader(
          title: 'Practicar',
          subtitle: 'Reforzá lo que quieras, a tu ritmo.',
        ),
        EntranceAnimation(child: _QuickPracticeCard(exercises: filtered)),
        const SizedBox(height: 26),
        Text(
          'Filtrar por tipo',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.darkBrown,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          key: const Key('practice-type-filters'),
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _FilterChip(
                label: 'Todos',
                selected: selectedType == null,
                onSelected: () => onTypeSelected(null),
              ),
              for (final type in types)
                _FilterChip(
                  label: formatExerciseType(type),
                  icon: ExerciseTypeStyle.of(type).icon,
                  selected: selectedType == type,
                  onSelected: () => onTypeSelected(type),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          '${filtered.length} ejercicios disponibles',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBrown.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < filtered.length; i++)
          EntranceAnimation(
            key: ValueKey('${selectedType ?? 'all'}-${filtered[i].id}'),
            delay: EntranceAnimation.stagger(i),
            child: _ExerciseTile(
              exercise: filtered[i],
              done: completed.contains(filtered[i].id),
            ),
          ),
      ],
    );
  }
}

/// Red hero card: start a random exercise from the current filter.
class _QuickPracticeCard extends StatelessWidget {
  const _QuickPracticeCard({required this.exercises});

  final List<Exercise> exercises;

  @override
  Widget build(BuildContext context) {
    void startRandom() {
      final exercise = exercises[Random().nextInt(exercises.length)];
      context.push(
        AppRoutes.exercisePath(exercise.id),
        extra: {'lessonId': null},
      );
    }

    return ChunkyCard(
      colors: ChunkyColors.red,
      radius: 24,
      depth: 6,
      padding: const EdgeInsets.fromLTRB(20, 20, 12, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practicar Libre',
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Dejá que Voxi elija un ejercicio por vos.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                ChunkyButton(
                  label: 'ALEATORIO',
                  icon: Icons.casino_rounded,
                  height: 46,
                  depth: 4,
                  colors: const ChunkyColors(
                    face: Colors.white,
                    lip: Color(0xFF8A2416),
                    content: AppColors.accentRed,
                  ),
                  onPressed: exercises.isEmpty ? null : startRandom,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Bob(
            child: Image.asset(
              'assets/images/voxi_awake.png',
              width: 96,
              height: 96,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = selected ? ChunkyColors.red : ChunkyColors.white;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChunkyCard(
        colors: colors,
        radius: 999,
        depth: 4,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        onTap: onSelected,
        semanticsLabel: 'Filtrar: $label',
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: colors.content),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: colors.content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise, required this.done});

  final Exercise exercise;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final style = ExerciseTypeStyle.of(exercise.type);
    final xp = exerciseXpReward(exercise);
    final name = exercise.name.isNotEmpty
        ? exercise.name
        : formatExerciseType(exercise.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ChunkyCard(
        onTap: () => context.push(
          AppRoutes.exercisePath(exercise.id),
          extra: {'lessonId': null},
        ),
        semanticsLabel: name,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _TypeBadge(style: style),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: ChunkyTag(
                          label: formatExerciseType(exercise.type),
                          icon: style.icon,
                          color: style.ink,
                        ),
                      ),
                      if (xp > 0 && !done) ...[
                        const SizedBox(width: 6),
                        ChunkyTag(
                          label: '+$xp XP',
                          icon: Icons.bolt_rounded,
                          color: AppColors.accentRed,
                        ),
                      ],
                      if (done) ...[
                        const SizedBox(width: 6),
                        const ChunkyTag(
                          label: 'Hecho',
                          icon: Icons.check_rounded,
                          color: AppColors.onSuccessContainer,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.darkBrownLight,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small 3D tile with the exercise type icon.
class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.style});

  final ExerciseTypeStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: style.colors.face,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: style.colors.lip, offset: const Offset(0, 4)),
        ],
      ),
      child: Icon(style.icon, color: style.colors.content, size: 26),
    );
  }
}

class _EmptyExercises extends StatelessWidget {
  const _EmptyExercises();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/voxi_sleeping.png',
              width: 96,
              height: 96,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay ejercicios disponibles',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revisá tu conexión e intentá de nuevo.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBrown.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
