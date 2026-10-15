// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Progress _$ProgressFromJson(Map<String, dynamic> json) {
  return _Progress.fromJson(json);
}

/// @nodoc
mixin _$Progress {
  @JsonKey(name: 'exercise_id')
  String get exerciseId => throw _privateConstructorUsedError;
  @JsonKey(name: 'lesson_id')
  int? get lessonId => throw _privateConstructorUsedError;
  LessonStatus get status => throw _privateConstructorUsedError;
  int? get score => throw _privateConstructorUsedError;
  @JsonKey(name: 'xp_earned')
  int? get xpEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'started_at')
  DateTime? get startedAt => throw _privateConstructorUsedError;

  /// Serializes this Progress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressCopyWith<Progress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressCopyWith<$Res> {
  factory $ProgressCopyWith(Progress value, $Res Function(Progress) then) =
      _$ProgressCopyWithImpl<$Res, Progress>;
  @useResult
  $Res call({
    @JsonKey(name: 'exercise_id') String exerciseId,
    @JsonKey(name: 'lesson_id') int? lessonId,
    LessonStatus status,
    int? score,
    @JsonKey(name: 'xp_earned') int? xpEarned,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'started_at') DateTime? startedAt,
  });
}

/// @nodoc
class _$ProgressCopyWithImpl<$Res, $Val extends Progress>
    implements $ProgressCopyWith<$Res> {
  _$ProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? lessonId = freezed,
    Object? status = null,
    Object? score = freezed,
    Object? xpEarned = freezed,
    Object? completedAt = freezed,
    Object? startedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            exerciseId: null == exerciseId
                ? _value.exerciseId
                : exerciseId // ignore: cast_nullable_to_non_nullable
                      as String,
            lessonId: freezed == lessonId
                ? _value.lessonId
                : lessonId // ignore: cast_nullable_to_non_nullable
                      as int?,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as LessonStatus,
            score: freezed == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int?,
            xpEarned: freezed == xpEarned
                ? _value.xpEarned
                : xpEarned // ignore: cast_nullable_to_non_nullable
                      as int?,
            completedAt: freezed == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProgressImplCopyWith<$Res>
    implements $ProgressCopyWith<$Res> {
  factory _$$ProgressImplCopyWith(
    _$ProgressImpl value,
    $Res Function(_$ProgressImpl) then,
  ) = __$$ProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'exercise_id') String exerciseId,
    @JsonKey(name: 'lesson_id') int? lessonId,
    LessonStatus status,
    int? score,
    @JsonKey(name: 'xp_earned') int? xpEarned,
    @JsonKey(name: 'completed_at') DateTime? completedAt,
    @JsonKey(name: 'started_at') DateTime? startedAt,
  });
}

/// @nodoc
class __$$ProgressImplCopyWithImpl<$Res>
    extends _$ProgressCopyWithImpl<$Res, _$ProgressImpl>
    implements _$$ProgressImplCopyWith<$Res> {
  __$$ProgressImplCopyWithImpl(
    _$ProgressImpl _value,
    $Res Function(_$ProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? lessonId = freezed,
    Object? status = null,
    Object? score = freezed,
    Object? xpEarned = freezed,
    Object? completedAt = freezed,
    Object? startedAt = freezed,
  }) {
    return _then(
      _$ProgressImpl(
        exerciseId: null == exerciseId
            ? _value.exerciseId
            : exerciseId // ignore: cast_nullable_to_non_nullable
                  as String,
        lessonId: freezed == lessonId
            ? _value.lessonId
            : lessonId // ignore: cast_nullable_to_non_nullable
                  as int?,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as LessonStatus,
        score: freezed == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int?,
        xpEarned: freezed == xpEarned
            ? _value.xpEarned
            : xpEarned // ignore: cast_nullable_to_non_nullable
                  as int?,
        completedAt: freezed == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressImpl implements _Progress {
  const _$ProgressImpl({
    @JsonKey(name: 'exercise_id') required this.exerciseId,
    @JsonKey(name: 'lesson_id') this.lessonId,
    required this.status,
    this.score,
    @JsonKey(name: 'xp_earned') this.xpEarned,
    @JsonKey(name: 'completed_at') this.completedAt,
    @JsonKey(name: 'started_at') this.startedAt,
  });

  factory _$ProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressImplFromJson(json);

  @override
  @JsonKey(name: 'exercise_id')
  final String exerciseId;
  @override
  @JsonKey(name: 'lesson_id')
  final int? lessonId;
  @override
  final LessonStatus status;
  @override
  final int? score;
  @override
  @JsonKey(name: 'xp_earned')
  final int? xpEarned;
  @override
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  @override
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;

  @override
  String toString() {
    return 'Progress(exerciseId: $exerciseId, lessonId: $lessonId, status: $status, score: $score, xpEarned: $xpEarned, completedAt: $completedAt, startedAt: $startedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.xpEarned, xpEarned) ||
                other.xpEarned == xpEarned) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    exerciseId,
    lessonId,
    status,
    score,
    xpEarned,
    completedAt,
    startedAt,
  );

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressImplCopyWith<_$ProgressImpl> get copyWith =>
      __$$ProgressImplCopyWithImpl<_$ProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressImplToJson(this);
  }
}

abstract class _Progress implements Progress {
  const factory _Progress({
    @JsonKey(name: 'exercise_id') required final String exerciseId,
    @JsonKey(name: 'lesson_id') final int? lessonId,
    required final LessonStatus status,
    final int? score,
    @JsonKey(name: 'xp_earned') final int? xpEarned,
    @JsonKey(name: 'completed_at') final DateTime? completedAt,
    @JsonKey(name: 'started_at') final DateTime? startedAt,
  }) = _$ProgressImpl;

  factory _Progress.fromJson(Map<String, dynamic> json) =
      _$ProgressImpl.fromJson;

  @override
  @JsonKey(name: 'exercise_id')
  String get exerciseId;
  @override
  @JsonKey(name: 'lesson_id')
  int? get lessonId;
  @override
  LessonStatus get status;
  @override
  int? get score;
  @override
  @JsonKey(name: 'xp_earned')
  int? get xpEarned;
  @override
  @JsonKey(name: 'completed_at')
  DateTime? get completedAt;
  @override
  @JsonKey(name: 'started_at')
  DateTime? get startedAt;

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressImplCopyWith<_$ProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
