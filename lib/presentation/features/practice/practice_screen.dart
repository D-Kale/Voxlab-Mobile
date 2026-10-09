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
import '../../shared/providers/content_provider.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/voxi_state.dart';
import '../../../utils/exercise_name_utils.dart';

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
      appBar: AppBar(
        title: Image.asset(
          'assets/images/voxi_logo.png',
          height: 28,
          fit: BoxFit.contain,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SafeArea(
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
              onTypeSelected: (type) =>
                  setState(() => _selectedType = type),
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
          for (final lesson in module.lessons)
            ...lesson.exercises,
    ];
  }
}

class _PracticeBody extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final types = {for (final e in exercises) _typeKeyOf(e)}.toList()..sort();
    final filtered = selectedType == null
        ? exercises
        : exercises.where((e) => _typeKeyOf(e) == selectedType).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Voxi greeting header
        Container(
          width: double.infinity,
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
                      'Practicar Libre',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Elegí cualquier ejercicio para mejorar.',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkBrownLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Random exercise card
        _RandomExerciseCard(exercises: filtered),
        const SizedBox(height: 20),
        // Type filter chips
        SectionHeader(
          title: 'Filtrar por tipo',
          icon: Icons.filter_list_rounded,
          showVoxi: false,
        ),
        const SizedBox(height: 10),
        SizedBox(
          key: const Key('practice-type-filters'),
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChip(
                label: 'Todos',
                selected: selectedType == null,
                onSelected: () => onTypeSelected(null),
              ),
              for (final type in types)
                _FilterChip(
                  label: formatExerciseType(type),
                  selected: selectedType == type,
                  onSelected: () => onTypeSelected(type),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Exercise count
        Text(
          '${filtered.length} ejercicios disponibles',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBrownLight,
          ),
        ),
        const SizedBox(height: 12),
        // Exercise list
        for (final exercise in filtered)
          _ExerciseTile(exercise: exercise),
      ],
    );
  }
}

class _RandomExerciseCard extends StatelessWidget {
  const _RandomExerciseCard({required this.exercises});

  final List<Exercise> exercises;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: exercises.isEmpty
              ? null
              : () {
                  final exercise = exercises[Random().nextInt(exercises.length)];
                  context.push(
                    AppRoutes.exercisePath(exercise.id),
                    extra: {'lessonId': null},
                  );
                },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.casino_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ejercicio aleatorio',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBrown,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dejá que la suerte elija por vos',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkBrownLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.darkBrownLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.accentRed : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? AppColors.accentRed
                    : AppColors.darkBrown.withValues(alpha: 0.22),
                width: selected ? 3 : 2.5,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.accentRed,
                        offset: const Offset(0, 4),
                        blurRadius: 0,
                        spreadRadius: 0,
                      ),
                    ]
                  : [],
            ),
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.accentRed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise});

  final Exercise exercise;

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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
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
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push(
              AppRoutes.exercisePath(exercise.id),
              extra: {'lessonId': null},
            ),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Center(
                      child: Icon(
                        exerciseTypeIcon(exercise.type),
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name.isNotEmpty
                              ? exercise.name
                              : formatExerciseType(exercise.type),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.dmSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBrown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: _TypeChip(type: exercise.type),
                            ),
                            const SizedBox(width: 8),
                            _XpChip(xp: _xpReward),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.darkBrownLight,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconForType(type),
            size: 12,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _labelForType(type),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) => exerciseTypeIcon(type);

  String _labelForType(String type) => formatExerciseType(type);
}

class _XpChip extends StatelessWidget {
  const _XpChip({required this.xp});

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
          Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.accentRed),
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
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay ejercicios disponibles',
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Revisá tu conexión e intentá de nuevo.',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.darkBrownLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}