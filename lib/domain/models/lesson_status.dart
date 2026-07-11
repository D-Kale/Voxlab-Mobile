enum LessonStatus {
  locked,
  available,
  inProgress,
  completed;

  bool get isCompleted => this == LessonStatus.completed;
  bool get isAvailable =>
      this == LessonStatus.available || this == LessonStatus.inProgress;
}
