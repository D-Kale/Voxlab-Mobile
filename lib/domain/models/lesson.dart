import 'package:freezed_annotation/freezed_annotation.dart';
import 'exercise.dart';

part 'lesson.freezed.dart';
part 'lesson.g.dart';

@Freezed(toJson: false)
class Lesson with _$Lesson {
  const factory Lesson({
    required int id,
    required String title,
    required String description,
    String? imageUrl,
    int? estimatedTimeSeconds,
    required List<Exercise> exercises,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) =>
      _$LessonFromJson(json);
}
