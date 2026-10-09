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

_$UserProgressImpl _$$UserProgressImplFromJson(Map<String, dynamic> json) =>
    _$UserProgressImpl(
      xp: (json['xp'] as num).toInt(),
      streakDays: (json['streak_days'] as num).toInt(),
      completedExerciseIds: (json['completed_exercise_ids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      weeklyChart: (json['weekly_chart'] as List<dynamic>)
          .map((e) => WeeklyChartEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastSyncedAt: json['last_synced_at'] as String,
    );

Map<String, dynamic> _$$UserProgressImplToJson(_$UserProgressImpl instance) =>
    <String, dynamic>{
      'xp': instance.xp,
      'streak_days': instance.streakDays,
      'completed_exercise_ids': instance.completedExerciseIds,
      'weekly_chart': instance.weeklyChart,
      'last_synced_at': instance.lastSyncedAt,
    };

_$WeeklyChartEntryImpl _$$WeeklyChartEntryImplFromJson(
  Map<String, dynamic> json,
) => _$WeeklyChartEntryImpl(
  date: json['date'] as String,
  xp: (json['xp'] as num).toInt(),
);

Map<String, dynamic> _$$WeeklyChartEntryImplToJson(
  _$WeeklyChartEntryImpl instance,
) => <String, dynamic>{'date': instance.date, 'xp': instance.xp};

_$ProgressSubmitRequestImpl _$$ProgressSubmitRequestImplFromJson(
  Map<String, dynamic> json,
) => _$ProgressSubmitRequestImpl(
  exerciseId: json['exercise_id'] as String,
  score: (json['score'] as num).toInt(),
  completedAt: json['completed_at'] as String,
  lessonId: (json['lesson_id'] as num?)?.toInt(),
);

Map<String, dynamic> _$$ProgressSubmitRequestImplToJson(
  _$ProgressSubmitRequestImpl instance,
) => <String, dynamic>{
  'exercise_id': instance.exerciseId,
  'score': instance.score,
  'completed_at': instance.completedAt,
  'lesson_id': instance.lessonId,
};

_$ProgressSubmitResponseImpl _$$ProgressSubmitResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ProgressSubmitResponseImpl(
  success: json['success'] as bool,
  data: ProgressSubmitData.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$ProgressSubmitResponseImplToJson(
  _$ProgressSubmitResponseImpl instance,
) => <String, dynamic>{'success': instance.success, 'data': instance.data};

_$ProgressSubmitDataImpl _$$ProgressSubmitDataImplFromJson(
  Map<String, dynamic> json,
) => _$ProgressSubmitDataImpl(
  xp: (json['xp'] as num).toInt(),
  streakDays: (json['streak_days'] as num).toInt(),
  newlyCompleted: (json['newly_completed'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  streakUpdated: json['streak_updated'] as bool,
);

Map<String, dynamic> _$$ProgressSubmitDataImplToJson(
  _$ProgressSubmitDataImpl instance,
) => <String, dynamic>{
  'xp': instance.xp,
  'streak_days': instance.streakDays,
  'newly_completed': instance.newlyCompleted,
  'streak_updated': instance.streakUpdated,
};
