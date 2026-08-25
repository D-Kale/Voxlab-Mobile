import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/progress.dart';
import '../../../shared/providers/progress_provider.dart';

class WeeklyProgressData {
  final String weekStart;
  final List<int> daily;

  WeeklyProgressData({required this.weekStart, required this.daily});

  factory WeeklyProgressData.fromEntries(List<Progress> entries) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final daily = List<int>.filled(7, 0);

    for (final entry in entries) {
      final completedAt = entry.completedAt;
      if (completedAt == null) continue;
      final day =
          DateTime(completedAt.year, completedAt.month, completedAt.day);
      final diff = day.difference(monday).inDays;
      if (diff >= 0 && diff < 7) {
        daily[diff] += 1;
      }
    }

    return WeeklyProgressData(
      weekStart: monday.toIso8601String(),
      daily: daily,
    );
  }
}

final weeklyProgressProvider = Provider<WeeklyProgressData>((ref) {
  final entries = ref.watch(progressNotifierProvider);
  return WeeklyProgressData.fromEntries(entries);
});
