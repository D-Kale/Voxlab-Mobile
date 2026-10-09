import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/weekly_progress_provider.dart';

const _dayLabels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

class WeeklyChart extends ConsumerWidget {
  const WeeklyChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(weeklyProgressProvider);

    // No Card wrapper: this chart already sits inside the branded white card
    // of AnalyzeScreen, and a nested Card draws a second border around it.
    return Column(
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
        _ChartBars(daily: data.daily),
      ],
    );
  }
}

class _ChartBars extends StatelessWidget {
  const _ChartBars({required this.daily});

  final List<int> daily;

  @override
  Widget build(BuildContext context) {
    final maxCount = daily.fold(0, (a, b) => a > b ? a : b);
    final today = DateTime.now().weekday - 1;

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final count = i < daily.length ? daily[i] : 0;
          final barHeight = maxCount > 0 ? (count / maxCount) * 80 : 0.0;
          final isToday = i == today;

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
    );
  }
}
