import 'session_result.dart';

/// What an exercise produces when the user finishes it: the score used for
/// local progression and, when the backend AI analyzed the attempt, the
/// full session result for the results screen.
class ExerciseOutcome {
  const ExerciseOutcome({required this.score, this.sessionResult});

  final int score;
  final SessionResult? sessionResult;
}
