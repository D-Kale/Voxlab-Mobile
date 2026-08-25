import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../domain/models/exercise.dart';
import '../../../domain/models/track.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_skeleton.dart';
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
      appBar: AppBar(title: const Text('Practicar')),
      body: SafeArea(
        child: tracksAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: LoadingSkeleton(itemCount: 6),
          ),
          error: (error, _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(tracksProvider),
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

  @override
  Widget build(BuildContext context) {
    final filtered = selectedType == null
        ? exercises
        : exercises.where((e) => e.type == selectedType).toList();
    final types = exercises.map((e) => e.type).toSet().toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _RandomExerciseCard(exercises: filtered),
        const SizedBox(height: 20),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: const Text('Todos'),
                  selected: selectedType == null,
                  onSelected: (_) => onTypeSelected(null),
                ),
              ),
              for (final type in types)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(formatExerciseType(type)),
                    selected: selectedType == type,
                    onSelected: (_) => onTypeSelected(type),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${filtered.length} ejercicios disponibles',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
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
    return Card(
      color: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.primary),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: exercises.isEmpty
            ? null
            : () => _goRandom(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Semantics(
                excludeSemantics: true,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.24),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.casino_outlined,
                    color: AppColors.onPrimary,
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
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: AppColors.onPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dejá que la suerte elija por vos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onPrimary.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.onPrimary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goRandom(BuildContext context) {
    final exercise = exercises[Random().nextInt(exercises.length)];
    context.push(
      AppRoutes.exercisePath(exercise.id),
      extra: {'lessonId': null},
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  const _ExerciseTile({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          onTap: () => context.push(
            AppRoutes.exercisePath(exercise.id),
            extra: {'lessonId': null},
          ),
          leading: Semantics(
            excludeSemantics: true,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                exerciseTypeIcon(exercise.type),
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ),
          title: Text(
            exercise.name.isNotEmpty
                ? exercise.name
                : formatExerciseType(exercise.type),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Text(
            formatExerciseType(exercise.type),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: AppColors.onSurfaceVariant,
          ),
        ),
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
            Semantics(
              excludeSemantics: true,
              child: const Icon(
                Icons.extension_off_outlined,
                size: 56,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay ejercicios disponibles',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Revisá tu conexión e intentá de nuevo.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
