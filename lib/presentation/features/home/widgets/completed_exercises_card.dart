import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../../domain/models/progress.dart';
import '../../../shared/providers/content_provider.dart';

class CompletedExercisesCard extends ConsumerWidget {
  const CompletedExercisesCard({super.key, required this.progress});

  final List<Progress> progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameMap = ref.watch(exerciseNameMapProvider);

    final completed = progress
        .where((p) => p.status.isCompleted)
        .expand((p) => p.completedExercises)
        .toList();

    if (completed.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(icon: Icons.checklist, title: 'Ejercicios completados'),
            const SizedBox(height: 12),
            ...completed.map((ex) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 18, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      nameMap[ex.exerciseId] ?? ex.exerciseId,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  if (ex.score > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+${ex.score} XP',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
