import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/lesson_status.dart';
import '../../../../domain/models/progress.dart';

class WeeklyChart extends StatelessWidget {
  const WeeklyChart({
    super.key,
    required this.progress,
  });

  final List<Progress> progress;
  
  static const _dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    final dailyCounts = _computeDailyCounts(progress);
    final maxCount = dailyCounts.values.fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Actividad semanal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (i) {
                  final count = dailyCounts[i] ?? 0;
                  final barHeight = maxCount > 0
                      ? (count / maxCount) * 80
                      : 0.0;
                  final isToday = i == DateTime.now().weekday - 1;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (count > 0)
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isToday
                                    ? AppColors.primary
                                    : AppColors.onSurfaceVariant,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            height: barHeight.clamp(4.0, 80.0),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _dayLabels[i],
                            style: TextStyle(
                              fontSize: 10,
                              color: isToday
                                  ? AppColors.onSurface
                                  : AppColors.onSurfaceVariant,
                              fontWeight:
                                  isToday ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<int, int> _computeDailyCounts(List<Progress> progress) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final counts = <int, int>{};

    for (var p in progress) {
      final date = p.completedAt;
      if (date == null || p.status != LessonStatus.completed) continue;

      if (date.isAfter(weekStart.subtract(const Duration(hours: 1))) &&
          date.isBefore(weekStart.add(const Duration(days: 7)))) {
        final weekday = date.weekday - 1;
        counts[weekday] = (counts[weekday] ?? 0) + 1;
      }
    }

    return counts;
  }
}
