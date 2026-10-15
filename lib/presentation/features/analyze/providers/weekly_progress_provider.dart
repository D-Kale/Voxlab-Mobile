import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/progress.dart';
import '../../../shared/providers/progress_provider.dart';

/// XP earned per day of the current week, Monday first.
class WeeklyProgressData {
  WeeklyProgressData({required this.weekStart, required this.daily});

  final String weekStart;
  final List<int> daily;

  int get total => daily.fold(0, (a, b) => a + b);

  factory WeeklyProgressData.fromEntries(
    List<Progress> entries, {
    DateTime? now,
  }) {
    final clock = now ?? DateTime.now();
    final today = DateTime(clock.year, clock.month, clock.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final daily = List<int>.filled(7, 0);

    for (final entry in entries) {
      final completedAt = entry.completedAt;
      if (completedAt == null) continue;
      final day = DateTime(
        completedAt.year,
        completedAt.month,
        completedAt.day,
      );
      final diff = day.difference(monday).inDays;
      if (diff >= 0 && diff < 7) {
        daily[diff] += entry.score ?? 0;
      }
    }

    return WeeklyProgressData(
      weekStart: monday.toIso8601String(),
      daily: daily,
    );
  }
}

/// The current time; overridden in tests so the "today" highlight and the
/// week window do not change from one day to the next.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final weeklyProgressProvider = Provider<WeeklyProgressData>((ref) {
  final entries = ref.watch(progressNotifierProvider);
  return WeeklyProgressData.fromEntries(
    entries,
    now: ref.watch(clockProvider)(),
  );
});
