import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/exercise.dart';
import '../../../domain/models/exercise_content.dart';
import '../../features/exercise/oratory/oratory_screen.dart';
import '../../features/exercise/quiz/quiz_screen.dart';
import '../../features/exercise/reading/reading_screen.dart';
import '../../features/exercise/writing/writing_screen.dart';

class ExerciseWidgetFactory extends StatelessWidget {
  const ExerciseWidgetFactory({
    super.key,
    required this.exercise,
    this.onCompleted,
  });

  final Exercise exercise;
  final void Function(int score)? onCompleted;

  @override
  Widget build(BuildContext context) {
    final content = exercise.content;

    return switch (content) {
      QuizContent(:final questions, :final pointsPerQuestion) => QuizWidget(
        questions: questions,
        pointsPerQuestion: pointsPerQuestion,
        onCompleted: onCompleted,
      ),
      ReadingContent(:final title, :final content, :final readingTimeSeconds, :final points) =>
        ReadingWidget(
          title: title,
          content: content,
          readingTimeSeconds: readingTimeSeconds,
          points: points,
          onCompleted: onCompleted,
        ),
      WritingContent(:final prompt, :final minWords, :final maxWords, :final requirements, :final points) =>
        WritingWidget(
          prompt: prompt,
          minWords: minWords,
          maxWords: maxWords,
          requirements: requirements,
          points: points,
          onCompleted: onCompleted,
        ),
      OratoryContent(:final prompt, :final topic, :final durationSeconds, :final minDurationSeconds, :final requirements, :final points) =>
        OratoryWidget(
          prompt: prompt,
          topic: topic,
          durationSeconds: durationSeconds,
          minDurationSeconds: minDurationSeconds,
          requirements: requirements,
          points: points,
          onCompleted: onCompleted,
        ),
      _ => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              excludeSemantics: true,
              child: const Icon(Icons.construction, size: 48, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              'Tipo de ejercicio "${exercise.type}" no disponible en esta versión',
              style: const TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    };
  }
}
