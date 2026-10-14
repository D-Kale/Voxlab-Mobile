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
