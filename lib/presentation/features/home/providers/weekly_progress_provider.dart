import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/remote/services/progress_service.dart';

class WeeklyProgressData {
  final String weekStart;
  final List<int> daily;

  WeeklyProgressData({required this.weekStart, required this.daily});

  factory WeeklyProgressData.fromJson(Map<String, dynamic> json) {
    final weekStart = json['week_start'] as String? ?? '';
    final dailyList = (json['daily'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .map((e) => e['count'] as int? ?? 0)
            .toList() ??
        [];

    return WeeklyProgressData(
      weekStart: weekStart,
      daily: dailyList.length == 7 ? dailyList : List.filled(7, 0),
    );
  }
}

final weeklyProgressProvider = FutureProvider<WeeklyProgressData>((ref) async {
  final service = ref.read(progressServiceProvider);
  final data = await service.getWeeklyProgress();
  return WeeklyProgressData.fromJson(data);
});
