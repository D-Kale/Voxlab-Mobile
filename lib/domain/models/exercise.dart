import 'package:freezed_annotation/freezed_annotation.dart';
import 'exercise_content.dart';

part 'exercise.freezed.dart';

@Freezed(fromJson: false, toJson: false)
class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String type,
    required String name,
    required ExerciseContent content,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final contentJson = json['content'] as Map<String, dynamic>;
    return Exercise(
      id: json['id'] as String? ?? '',
      type: type,
      name: json['name'] as String? ?? '',
      content: ExerciseContent.fromJson(contentJson, type),
    );
  }
}
