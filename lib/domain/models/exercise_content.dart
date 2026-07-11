import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_content.freezed.dart';
part 'exercise_content.g.dart';

@Freezed(fromJson: false, toJson: false)
sealed class ExerciseContent with _$ExerciseContent {
  const factory ExerciseContent.quiz({
    required List<QuizQuestion> questions,
    required int pointsPerQuestion,
  }) = QuizContent;

  const factory ExerciseContent.reading({
    required String title,
    required String content,
    required int readingTimeSeconds,
    required int points,
  }) = ReadingContent;

  const factory ExerciseContent.writing({
    required String prompt,
    required int minWords,
    required int maxWords,
    required List<String> requirements,
    required int points,
  }) = WritingContent;

  const factory ExerciseContent.oratory({
    required String prompt,
    required String topic,
    required int durationSeconds,
    required int minDurationSeconds,
    required List<String> requirements,
    required int points,
  }) = OratoryContent;

  const factory ExerciseContent.audio({
    required String prompt,
    required int durationSeconds,
    required int points,
  }) = AudioContent;

  const factory ExerciseContent.video({
    required String prompt,
    required int durationSeconds,
    required int points,
  }) = VideoContent;

  factory ExerciseContent.fromJson(Map<String, dynamic> json, String type) {
    return switch (type) {
      'quiz' => ExerciseContent.quiz(
        questions: (json['questions'] as List?)
            ?.map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
            .toList() ??
            [],
        pointsPerQuestion: json['points_per_question'] as int? ?? 0,
      ),
      'reading' => ExerciseContent.reading(
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        readingTimeSeconds: json['reading_time_seconds'] as int? ?? 0,
        points: json['points'] as int? ?? 0,
      ),
      'writing' => ExerciseContent.writing(
        prompt: json['prompt'] as String? ?? '',
        minWords: json['min_words'] as int? ?? 0,
        maxWords: json['max_words'] as int? ?? 0,
        requirements: (json['requirements'] as List?)?.cast<String>() ?? [],
        points: json['points'] as int? ?? 0,
      ),
      'oratory_minigame' => ExerciseContent.oratory(
        prompt: json['prompt'] as String? ?? '',
        topic: json['topic'] as String? ?? '',
        durationSeconds: json['duration_seconds'] as int? ?? 0,
        minDurationSeconds: json['min_duration_seconds'] as int? ?? 0,
        requirements: (json['requirements'] as List?)?.cast<String>() ?? [],
        points: json['points'] as int? ?? 0,
      ),
      'audio' => ExerciseContent.audio(
        prompt: json['prompt'] as String? ?? '',
        durationSeconds: json['duration_seconds'] as int? ?? 0,
        points: json['points'] as int? ?? 0,
      ),
      'video' => ExerciseContent.video(
        prompt: json['prompt'] as String? ?? '',
        durationSeconds: json['duration_seconds'] as int? ?? 0,
        points: json['points'] as int? ?? 0,
      ),
      _ => ExerciseContent.reading(
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        readingTimeSeconds: json['reading_time_seconds'] as int? ?? 0,
        points: json['points'] as int? ?? 0,
      ),
    };
  }
}

@freezed
@JsonSerializable()
class QuizQuestion with _$QuizQuestion {
  const factory QuizQuestion({
    required String question,
    required List<String> options,
    required int correctIndex,
    String? explanation,
  }) = _QuizQuestion;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] as String? ?? '',
      options: (json['options'] as List?)?.cast<String>() ?? [],
      correctIndex: (json['correct_index'] as num?)?.toInt() ?? 0,
      explanation: json['explanation'] as String?,
    );
  }
}
