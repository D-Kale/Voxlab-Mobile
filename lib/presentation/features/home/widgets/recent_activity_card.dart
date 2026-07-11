import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/progress.dart';
import '../../../shared/providers/content_provider.dart';
import '../../../../utils/exercise_name_utils.dart';

class RecentActivityCard extends ConsumerWidget {
  const RecentActivityCard({super.key, required this.progress});

  final List<Progress> progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameMap = ref.watch(exerciseNameMapProvider);

    // Collect all completed exercises from all progress records
    final allCompleted = <({String id, int score, DateTime? completedAt})>[];
    for (final p in progress) {
      if (p.status.isCompleted) {
        for (final ex in p.completedExercises) {
          allCompleted.add((
            id: ex.exerciseId,
            score: ex.score,
            completedAt: p.completedAt,
          ));
        }
      }
    }
    allCompleted.sort((a, b) {
      if (a.completedAt == null && b.completedAt == null) return 0;
      if (a.completedAt == null) return 1;
      if (b.completedAt == null) return -1;
      return b.completedAt!.compareTo(a.completedAt!);
    });

    final recent = allCompleted.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Semantics(
                  excludeSemantics: true,
                  child: const Icon(
                    Icons.history,
                    size: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Actividad reciente',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Todavía no completaste ejercicios',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              ...recent.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Semantics(
                      excludeSemantics: true,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          size: 18,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        nameMap[item.id] ?? formatExerciseType(''),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.score > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+${item.score} XP',
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
