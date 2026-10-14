// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgressImpl _$$ProgressImplFromJson(Map<String, dynamic> json) =>
    _$ProgressImpl(
      exerciseId: json['exercise_id'] as String,
      lessonId: (json['lesson_id'] as num?)?.toInt(),
      status: $enumDecode(_$LessonStatusEnumMap, json['status']),
      score: (json['score'] as num?)?.toInt(),
      xpEarned: (json['xp_earned'] as num?)?.toInt(),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      completedExercises:
          (json['completedExercises'] as List<dynamic>?)
              ?.map(
                (e) => CompletedExercise.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ProgressImplToJson(_$ProgressImpl instance) =>
    <String, dynamic>{
      'exercise_id': instance.exerciseId,
      'lesson_id': instance.lessonId,
      'status': _$LessonStatusEnumMap[instance.status]!,
      'score': instance.score,
      'xp_earned': instance.xpEarned,
      'completed_at': instance.completedAt?.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'completedExercises': instance.completedExercises,
    };

const _$LessonStatusEnumMap = {
  LessonStatus.locked: 'locked',
  LessonStatus.available: 'available',
  LessonStatus.inProgress: 'inProgress',
  LessonStatus.completed: 'completed',
};
