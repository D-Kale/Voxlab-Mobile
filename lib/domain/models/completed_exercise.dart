class CompletedExercise {
  final String exerciseId;
  final int score;
  final DateTime? completedAt;

  const CompletedExercise({
    required this.exerciseId,
    required this.score,
    this.completedAt,
  });

  factory CompletedExercise.fromJson(Map<String, dynamic> json) {
    return CompletedExercise(
      exerciseId: json['exercise_id'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'exercise_id': exerciseId,
    'score': score,
    if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
  };
}
