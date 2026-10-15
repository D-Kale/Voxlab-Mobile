import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/lesson_status.dart';
import '../../../../domain/models/progress.dart';
import '../../../../utils/exercise_name_utils.dart';
import '../../../shared/providers/content_provider.dart';
import '../../../shared/widgets/chunky.dart';
import '../../../shared/widgets/exercise_type_style.dart';

class CompletedExercisesCard extends ConsumerWidget {
  const CompletedExercisesCard({super.key, required this.progress});

  final List<Progress> progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exerciseByIdProvider);

    final completed = progress
        .where((p) => p.status == LessonStatus.completed)
        .toList();

    if (completed.isEmpty) return const SizedBox.shrink();

    return ChunkyCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ejercicios completados',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBrown,
            ),
          ),
          const SizedBox(height: 10),
          for (final entry in completed)
            _CompletedRow(
              entry: entry,
              type: exercises[entry.exerciseId]?.type ?? '',
              name: () {
                final exercise = exercises[entry.exerciseId];
                if (exercise == null) return 'Ejercicio';
                return exercise.name.isNotEmpty
                    ? exercise.name
                    : formatExerciseType(exercise.type);
              }(),
            ),
        ],
      ),
    );
  }
}

class _CompletedRow extends StatelessWidget {
  const _CompletedRow({
    required this.entry,
    required this.type,
    required this.name,
  });

  final Progress entry;
  final String type;
  final String name;

  @override
  Widget build(BuildContext context) {
    final style = ExerciseTypeStyle.of(type);
    final xp = entry.score ?? 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: style.colors.face,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: style.colors.lip, offset: const Offset(0, 3)),
              ],
            ),
            child: Icon(style.icon, size: 19, color: style.colors.content),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBrown,
              ),
            ),
          ),
          if (xp > 0)
            ChunkyTag(
              label: '+$xp XP',
              icon: Icons.bolt_rounded,
              color: AppColors.accentRed,
            ),
        ],
      ),
    );
  }
}
