import 'package:freezed_annotation/freezed_annotation.dart';
import 'lesson_status.dart';

part 'progress.freezed.dart';
part 'progress.g.dart';

@freezed
class Progress with _$Progress {
  const factory Progress({
    required String exerciseId,
    int? lessonId,
    required LessonStatus status,
    int? score,
    int? xpEarned,
    DateTime? completedAt,
    DateTime? startedAt,
  }) = _Progress;

  factory Progress.fromJson(Map<String, dynamic> json) =>
      _$ProgressFromJson(json);
}
