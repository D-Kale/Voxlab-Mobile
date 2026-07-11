import '../domain/models/lesson.dart';
import '../domain/models/lesson_status.dart';

/// Resultado del cálculo de progreso de una lección
class LessonProgressInfo {
  final int lessonId;
  final LessonStatus status;
  final int completedExercises;
  final int totalExercises;
  final double progressPercent;

  LessonProgressInfo({
    required this.lessonId,
    required this.status,
    required this.completedExercises,
    required this.totalExercises,
    required this.progressPercent,
  });
}

/// Calcula el progreso de una lección basado en los ejercicios completados
LessonProgressInfo computeLessonProgress(
  Lesson lesson,
  Set<String> completedExerciseIds,
) {
  final total = lesson.exercises.length;
  final completed = lesson.exercises
      .where((e) => completedExerciseIds.contains(e.id))
      .length;

  final progressPercent = total > 0 ? completed / total : 0.0;

  return LessonProgressInfo(
    lessonId: lesson.id,
    status: LessonStatus.available, // Se determina después con locking
    completedExercises: completed,
    totalExercises: total,
    progressPercent: progressPercent,
  );
}

/// Determina el estado de una lección basado en el locking secuencial
/// 
/// Reglas:
/// - Lección 0: siempre available (si no está completada)
/// - Lección N: locked si alguna lección anterior no está completed
/// - Lección: completed si todos sus ejercicios están completados
LessonStatus determineLessonStatus(
  int lessonIndex,
  LessonProgressInfo currentProgress,
  List<LessonProgressInfo> allLessonsInModule,
) {
  // Si ya está completada, retornar completed
  if (currentProgress.completedExercises == currentProgress.totalExercises &&
      currentProgress.totalExercises > 0) {
    return LessonStatus.completed;
  }

  // Primera lección siempre está disponible (si no completada)
  if (lessonIndex == 0) {
    return currentProgress.progressPercent > 0
        ? LessonStatus.inProgress
        : LessonStatus.available;
  }

  // Verificar si TODAS las lecciones anteriores están completadas
  for (var i = 0; i < lessonIndex; i++) {
    final previous = allLessonsInModule[i];
    final isPreviousCompleted =
        previous.completedExercises == previous.totalExercises &&
        previous.totalExercises > 0;

    if (!isPreviousCompleted) {
      return LessonStatus.locked;
    }
  }

  // Si llegó acá, todas las anteriores están completadas
  return currentProgress.progressPercent > 0
      ? LessonStatus.inProgress
      : LessonStatus.available;
}

/// Obtiene el icono adecuado según el tipo del primer ejercicio de la lección
String getLessonIconType(Lesson lesson) {
  if (lesson.exercises.isEmpty) {
    return 'reading'; // Default
  }

  // Usar el tipo del primer ejercicio
  return lesson.exercises.first.type;
}