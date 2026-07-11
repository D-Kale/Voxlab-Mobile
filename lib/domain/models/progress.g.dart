// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProgressImpl _$$ProgressImplFromJson(Map<String, dynamic> json) =>
    _$ProgressImpl(
      exerciseId: json['exerciseId'] as String,
      lessonId: (json['lessonId'] as num?)?.toInt(),
      status: $enumDecode(_$LessonStatusEnumMap, json['status']),
      score: (json['score'] as num?)?.toInt(),
      xpEarned: (json['xpEarned'] as num?)?.toInt(),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
    );

Map<String, dynamic> _$$ProgressImplToJson(_$ProgressImpl instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'lessonId': instance.lessonId,
      'status': _$LessonStatusEnumMap[instance.status]!,
      'score': instance.score,
      'xpEarned': instance.xpEarned,
      'completedAt': instance.completedAt?.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
    };

const _$LessonStatusEnumMap = {
  LessonStatus.locked: 'locked',
  LessonStatus.available: 'available',
  LessonStatus.inProgress: 'inProgress',
  LessonStatus.completed: 'completed',
};
