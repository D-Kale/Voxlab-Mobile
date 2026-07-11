class CompletedExercise {
  final String exerciseId;
  final int score;

  const CompletedExercise({
    required this.exerciseId,
    required this.score,
  });

  factory CompletedExercise.fromJson(Map<String, dynamic> json) {
    return CompletedExercise(
      exerciseId: json['exercise_id'] as String? ?? '',
      score: json['score'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'exercise_id': exerciseId,
    'score': score,
  };
}
