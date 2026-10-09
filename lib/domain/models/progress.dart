import 'package:freezed_annotation/freezed_annotation.dart';
import 'lesson_status.dart';
import 'completed_exercise.dart';

part 'progress.freezed.dart';
part 'progress.g.dart';

@freezed
class Progress with _$Progress {
  const factory Progress({
    @JsonKey(name: 'exercise_id') required String exerciseId,
    @JsonKey(name: 'lesson_id') int? lessonId,
    required LessonStatus status,
    int? score,
    @JsonKey(name: 'xp_earned') int? xpEarned,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'started_at') DateTime? startedAt,
    @Default([]) List<CompletedExercise> completedExercises,
  }) = _Progress;

  factory Progress.fromJson(Map<String, dynamic> json) =>
      _$ProgressFromJson(json);
}

@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    required int xp,
    @JsonKey(name: 'streak_days') required int streakDays,
    @JsonKey(name: 'completed_exercise_ids') required List<String> completedExerciseIds,
    @JsonKey(name: 'weekly_chart') required List<WeeklyChartEntry> weeklyChart,
    @JsonKey(name: 'last_synced_at') required String lastSyncedAt,
  }) = _UserProgress;

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);
}

@freezed
class WeeklyChartEntry with _$WeeklyChartEntry {
  const factory WeeklyChartEntry({
    required String date,
    required int xp,
  }) = _WeeklyChartEntry;

  factory WeeklyChartEntry.fromJson(Map<String, dynamic> json) =>
      _$WeeklyChartEntryFromJson(json);
}

@freezed
class ProgressSubmitRequest with _$ProgressSubmitRequest {
  const factory ProgressSubmitRequest({
    @JsonKey(name: 'exercise_id') required String exerciseId,
    required int score,
    @JsonKey(name: 'completed_at') required String completedAt,
    @JsonKey(name: 'lesson_id') int? lessonId,
  }) = _ProgressSubmitRequest;

  factory ProgressSubmitRequest.fromJson(Map<String, dynamic> json) =>
      _$ProgressSubmitRequestFromJson(json);
}

@freezed
class ProgressSubmitResponse with _$ProgressSubmitResponse {
  const factory ProgressSubmitResponse({
    required bool success,
    required ProgressSubmitData data,
  }) = _ProgressSubmitResponse;

  factory ProgressSubmitResponse.fromJson(Map<String, dynamic> json) =>
      _$ProgressSubmitResponseFromJson(json);
}

@freezed
class ProgressSubmitData with _$ProgressSubmitData {
  const factory ProgressSubmitData({
    required int xp,
    @JsonKey(name: 'streak_days') required int streakDays,
    @JsonKey(name: 'newly_completed') required List<String> newlyCompleted,
    @JsonKey(name: 'streak_updated') required bool streakUpdated,
  }) = _ProgressSubmitData;

  factory ProgressSubmitData.fromJson(Map<String, dynamic> json) =>
      _$ProgressSubmitDataFromJson(json);
}