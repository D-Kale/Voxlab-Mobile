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
  List<CompletedExercise> get completedExercises =>
      throw _privateConstructorUsedError;

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
    List<CompletedExercise> completedExercises,
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
    Object? completedExercises = null,
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
            completedExercises: null == completedExercises
                ? _value.completedExercises
                : completedExercises // ignore: cast_nullable_to_non_nullable
                      as List<CompletedExercise>,
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
    List<CompletedExercise> completedExercises,
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
    Object? completedExercises = null,
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
        completedExercises: null == completedExercises
            ? _value._completedExercises
            : completedExercises // ignore: cast_nullable_to_non_nullable
                  as List<CompletedExercise>,
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
    final List<CompletedExercise> completedExercises = const [],
  }) : _completedExercises = completedExercises;

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
  final List<CompletedExercise> _completedExercises;
  @override
  @JsonKey()
  List<CompletedExercise> get completedExercises {
    if (_completedExercises is EqualUnmodifiableListView)
      return _completedExercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedExercises);
  }

  @override
  String toString() {
    return 'Progress(exerciseId: $exerciseId, lessonId: $lessonId, status: $status, score: $score, xpEarned: $xpEarned, completedAt: $completedAt, startedAt: $startedAt, completedExercises: $completedExercises)';
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
                other.startedAt == startedAt) &&
            const DeepCollectionEquality().equals(
              other._completedExercises,
              _completedExercises,
            ));
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
    const DeepCollectionEquality().hash(_completedExercises),
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
    final List<CompletedExercise> completedExercises,
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
  @override
  List<CompletedExercise> get completedExercises;

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressImplCopyWith<_$ProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) {
  return _UserProgress.fromJson(json);
}

/// @nodoc
mixin _$UserProgress {
  int get xp => throw _privateConstructorUsedError;
  @JsonKey(name: 'streak_days')
  int get streakDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_exercise_ids')
  List<String> get completedExerciseIds => throw _privateConstructorUsedError;
  @JsonKey(name: 'weekly_chart')
  List<WeeklyChartEntry> get weeklyChart => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_synced_at')
  String get lastSyncedAt => throw _privateConstructorUsedError;

  /// Serializes this UserProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProgressCopyWith<UserProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProgressCopyWith<$Res> {
  factory $UserProgressCopyWith(
    UserProgress value,
    $Res Function(UserProgress) then,
  ) = _$UserProgressCopyWithImpl<$Res, UserProgress>;
  @useResult
  $Res call({
    int xp,
    @JsonKey(name: 'streak_days') int streakDays,
    @JsonKey(name: 'completed_exercise_ids') List<String> completedExerciseIds,
    @JsonKey(name: 'weekly_chart') List<WeeklyChartEntry> weeklyChart,
    @JsonKey(name: 'last_synced_at') String lastSyncedAt,
  });
}

/// @nodoc
class _$UserProgressCopyWithImpl<$Res, $Val extends UserProgress>
    implements $UserProgressCopyWith<$Res> {
  _$UserProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? xp = null,
    Object? streakDays = null,
    Object? completedExerciseIds = null,
    Object? weeklyChart = null,
    Object? lastSyncedAt = null,
  }) {
    return _then(
      _value.copyWith(
            xp: null == xp
                ? _value.xp
                : xp // ignore: cast_nullable_to_non_nullable
                      as int,
            streakDays: null == streakDays
                ? _value.streakDays
                : streakDays // ignore: cast_nullable_to_non_nullable
                      as int,
            completedExerciseIds: null == completedExerciseIds
                ? _value.completedExerciseIds
                : completedExerciseIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            weeklyChart: null == weeklyChart
                ? _value.weeklyChart
                : weeklyChart // ignore: cast_nullable_to_non_nullable
                      as List<WeeklyChartEntry>,
            lastSyncedAt: null == lastSyncedAt
                ? _value.lastSyncedAt
                : lastSyncedAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProgressImplCopyWith<$Res>
    implements $UserProgressCopyWith<$Res> {
  factory _$$UserProgressImplCopyWith(
    _$UserProgressImpl value,
    $Res Function(_$UserProgressImpl) then,
  ) = __$$UserProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int xp,
    @JsonKey(name: 'streak_days') int streakDays,
    @JsonKey(name: 'completed_exercise_ids') List<String> completedExerciseIds,
    @JsonKey(name: 'weekly_chart') List<WeeklyChartEntry> weeklyChart,
    @JsonKey(name: 'last_synced_at') String lastSyncedAt,
  });
}

/// @nodoc
class __$$UserProgressImplCopyWithImpl<$Res>
    extends _$UserProgressCopyWithImpl<$Res, _$UserProgressImpl>
    implements _$$UserProgressImplCopyWith<$Res> {
  __$$UserProgressImplCopyWithImpl(
    _$UserProgressImpl _value,
    $Res Function(_$UserProgressImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? xp = null,
    Object? streakDays = null,
    Object? completedExerciseIds = null,
    Object? weeklyChart = null,
    Object? lastSyncedAt = null,
  }) {
    return _then(
      _$UserProgressImpl(
        xp: null == xp
            ? _value.xp
            : xp // ignore: cast_nullable_to_non_nullable
                  as int,
        streakDays: null == streakDays
            ? _value.streakDays
            : streakDays // ignore: cast_nullable_to_non_nullable
                  as int,
        completedExerciseIds: null == completedExerciseIds
            ? _value._completedExerciseIds
            : completedExerciseIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        weeklyChart: null == weeklyChart
            ? _value._weeklyChart
            : weeklyChart // ignore: cast_nullable_to_non_nullable
                  as List<WeeklyChartEntry>,
        lastSyncedAt: null == lastSyncedAt
            ? _value.lastSyncedAt
            : lastSyncedAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProgressImpl implements _UserProgress {
  const _$UserProgressImpl({
    required this.xp,
    @JsonKey(name: 'streak_days') required this.streakDays,
    @JsonKey(name: 'completed_exercise_ids')
    required final List<String> completedExerciseIds,
    @JsonKey(name: 'weekly_chart')
    required final List<WeeklyChartEntry> weeklyChart,
    @JsonKey(name: 'last_synced_at') required this.lastSyncedAt,
  }) : _completedExerciseIds = completedExerciseIds,
       _weeklyChart = weeklyChart;

  factory _$UserProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProgressImplFromJson(json);

  @override
  final int xp;
  @override
  @JsonKey(name: 'streak_days')
  final int streakDays;
  final List<String> _completedExerciseIds;
  @override
  @JsonKey(name: 'completed_exercise_ids')
  List<String> get completedExerciseIds {
    if (_completedExerciseIds is EqualUnmodifiableListView)
      return _completedExerciseIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedExerciseIds);
  }

  final List<WeeklyChartEntry> _weeklyChart;
  @override
  @JsonKey(name: 'weekly_chart')
  List<WeeklyChartEntry> get weeklyChart {
    if (_weeklyChart is EqualUnmodifiableListView) return _weeklyChart;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weeklyChart);
  }

  @override
  @JsonKey(name: 'last_synced_at')
  final String lastSyncedAt;

  @override
  String toString() {
    return 'UserProgress(xp: $xp, streakDays: $streakDays, completedExerciseIds: $completedExerciseIds, weeklyChart: $weeklyChart, lastSyncedAt: $lastSyncedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProgressImpl &&
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.streakDays, streakDays) ||
                other.streakDays == streakDays) &&
            const DeepCollectionEquality().equals(
              other._completedExerciseIds,
              _completedExerciseIds,
            ) &&
            const DeepCollectionEquality().equals(
              other._weeklyChart,
              _weeklyChart,
            ) &&
            (identical(other.lastSyncedAt, lastSyncedAt) ||
                other.lastSyncedAt == lastSyncedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    xp,
    streakDays,
    const DeepCollectionEquality().hash(_completedExerciseIds),
    const DeepCollectionEquality().hash(_weeklyChart),
    lastSyncedAt,
  );

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      __$$UserProgressImplCopyWithImpl<_$UserProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProgressImplToJson(this);
  }
}

abstract class _UserProgress implements UserProgress {
  const factory _UserProgress({
    required final int xp,
    @JsonKey(name: 'streak_days') required final int streakDays,
    @JsonKey(name: 'completed_exercise_ids')
    required final List<String> completedExerciseIds,
    @JsonKey(name: 'weekly_chart')
    required final List<WeeklyChartEntry> weeklyChart,
    @JsonKey(name: 'last_synced_at') required final String lastSyncedAt,
  }) = _$UserProgressImpl;

  factory _UserProgress.fromJson(Map<String, dynamic> json) =
      _$UserProgressImpl.fromJson;

  @override
  int get xp;
  @override
  @JsonKey(name: 'streak_days')
  int get streakDays;
  @override
  @JsonKey(name: 'completed_exercise_ids')
  List<String> get completedExerciseIds;
  @override
  @JsonKey(name: 'weekly_chart')
  List<WeeklyChartEntry> get weeklyChart;
  @override
  @JsonKey(name: 'last_synced_at')
  String get lastSyncedAt;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WeeklyChartEntry _$WeeklyChartEntryFromJson(Map<String, dynamic> json) {
  return _WeeklyChartEntry.fromJson(json);
}

/// @nodoc
mixin _$WeeklyChartEntry {
  String get date => throw _privateConstructorUsedError;
  int get xp => throw _privateConstructorUsedError;

  /// Serializes this WeeklyChartEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeeklyChartEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeeklyChartEntryCopyWith<WeeklyChartEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeeklyChartEntryCopyWith<$Res> {
  factory $WeeklyChartEntryCopyWith(
    WeeklyChartEntry value,
    $Res Function(WeeklyChartEntry) then,
  ) = _$WeeklyChartEntryCopyWithImpl<$Res, WeeklyChartEntry>;
  @useResult
  $Res call({String date, int xp});
}

/// @nodoc
class _$WeeklyChartEntryCopyWithImpl<$Res, $Val extends WeeklyChartEntry>
    implements $WeeklyChartEntryCopyWith<$Res> {
  _$WeeklyChartEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeeklyChartEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? xp = null}) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            xp: null == xp
                ? _value.xp
                : xp // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeeklyChartEntryImplCopyWith<$Res>
    implements $WeeklyChartEntryCopyWith<$Res> {
  factory _$$WeeklyChartEntryImplCopyWith(
    _$WeeklyChartEntryImpl value,
    $Res Function(_$WeeklyChartEntryImpl) then,
  ) = __$$WeeklyChartEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String date, int xp});
}

/// @nodoc
class __$$WeeklyChartEntryImplCopyWithImpl<$Res>
    extends _$WeeklyChartEntryCopyWithImpl<$Res, _$WeeklyChartEntryImpl>
    implements _$$WeeklyChartEntryImplCopyWith<$Res> {
  __$$WeeklyChartEntryImplCopyWithImpl(
    _$WeeklyChartEntryImpl _value,
    $Res Function(_$WeeklyChartEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeeklyChartEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? xp = null}) {
    return _then(
      _$WeeklyChartEntryImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        xp: null == xp
            ? _value.xp
            : xp // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WeeklyChartEntryImpl implements _WeeklyChartEntry {
  const _$WeeklyChartEntryImpl({required this.date, required this.xp});

  factory _$WeeklyChartEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeeklyChartEntryImplFromJson(json);

  @override
  final String date;
  @override
  final int xp;

  @override
  String toString() {
    return 'WeeklyChartEntry(date: $date, xp: $xp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeeklyChartEntryImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.xp, xp) || other.xp == xp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, date, xp);

  /// Create a copy of WeeklyChartEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeeklyChartEntryImplCopyWith<_$WeeklyChartEntryImpl> get copyWith =>
      __$$WeeklyChartEntryImplCopyWithImpl<_$WeeklyChartEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeeklyChartEntryImplToJson(this);
  }
}

abstract class _WeeklyChartEntry implements WeeklyChartEntry {
  const factory _WeeklyChartEntry({
    required final String date,
    required final int xp,
  }) = _$WeeklyChartEntryImpl;

  factory _WeeklyChartEntry.fromJson(Map<String, dynamic> json) =
      _$WeeklyChartEntryImpl.fromJson;

  @override
  String get date;
  @override
  int get xp;

  /// Create a copy of WeeklyChartEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeeklyChartEntryImplCopyWith<_$WeeklyChartEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProgressSubmitRequest _$ProgressSubmitRequestFromJson(
  Map<String, dynamic> json,
) {
  return _ProgressSubmitRequest.fromJson(json);
}

/// @nodoc
mixin _$ProgressSubmitRequest {
  @JsonKey(name: 'exercise_id')
  String get exerciseId => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_at')
  String get completedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'lesson_id')
  int? get lessonId => throw _privateConstructorUsedError;

  /// Serializes this ProgressSubmitRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressSubmitRequestCopyWith<ProgressSubmitRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressSubmitRequestCopyWith<$Res> {
  factory $ProgressSubmitRequestCopyWith(
    ProgressSubmitRequest value,
    $Res Function(ProgressSubmitRequest) then,
  ) = _$ProgressSubmitRequestCopyWithImpl<$Res, ProgressSubmitRequest>;
  @useResult
  $Res call({
    @JsonKey(name: 'exercise_id') String exerciseId,
    int score,
    @JsonKey(name: 'completed_at') String completedAt,
    @JsonKey(name: 'lesson_id') int? lessonId,
  });
}

/// @nodoc
class _$ProgressSubmitRequestCopyWithImpl<
  $Res,
  $Val extends ProgressSubmitRequest
>
    implements $ProgressSubmitRequestCopyWith<$Res> {
  _$ProgressSubmitRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? score = null,
    Object? completedAt = null,
    Object? lessonId = freezed,
  }) {
    return _then(
      _value.copyWith(
            exerciseId: null == exerciseId
                ? _value.exerciseId
                : exerciseId // ignore: cast_nullable_to_non_nullable
                      as String,
            score: null == score
                ? _value.score
                : score // ignore: cast_nullable_to_non_nullable
                      as int,
            completedAt: null == completedAt
                ? _value.completedAt
                : completedAt // ignore: cast_nullable_to_non_nullable
                      as String,
            lessonId: freezed == lessonId
                ? _value.lessonId
                : lessonId // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProgressSubmitRequestImplCopyWith<$Res>
    implements $ProgressSubmitRequestCopyWith<$Res> {
  factory _$$ProgressSubmitRequestImplCopyWith(
    _$ProgressSubmitRequestImpl value,
    $Res Function(_$ProgressSubmitRequestImpl) then,
  ) = __$$ProgressSubmitRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'exercise_id') String exerciseId,
    int score,
    @JsonKey(name: 'completed_at') String completedAt,
    @JsonKey(name: 'lesson_id') int? lessonId,
  });
}

/// @nodoc
class __$$ProgressSubmitRequestImplCopyWithImpl<$Res>
    extends
        _$ProgressSubmitRequestCopyWithImpl<$Res, _$ProgressSubmitRequestImpl>
    implements _$$ProgressSubmitRequestImplCopyWith<$Res> {
  __$$ProgressSubmitRequestImplCopyWithImpl(
    _$ProgressSubmitRequestImpl _value,
    $Res Function(_$ProgressSubmitRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgressSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseId = null,
    Object? score = null,
    Object? completedAt = null,
    Object? lessonId = freezed,
  }) {
    return _then(
      _$ProgressSubmitRequestImpl(
        exerciseId: null == exerciseId
            ? _value.exerciseId
            : exerciseId // ignore: cast_nullable_to_non_nullable
                  as String,
        score: null == score
            ? _value.score
            : score // ignore: cast_nullable_to_non_nullable
                  as int,
        completedAt: null == completedAt
            ? _value.completedAt
            : completedAt // ignore: cast_nullable_to_non_nullable
                  as String,
        lessonId: freezed == lessonId
            ? _value.lessonId
            : lessonId // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressSubmitRequestImpl implements _ProgressSubmitRequest {
  const _$ProgressSubmitRequestImpl({
    @JsonKey(name: 'exercise_id') required this.exerciseId,
    required this.score,
    @JsonKey(name: 'completed_at') required this.completedAt,
    @JsonKey(name: 'lesson_id') this.lessonId,
  });

  factory _$ProgressSubmitRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressSubmitRequestImplFromJson(json);

  @override
  @JsonKey(name: 'exercise_id')
  final String exerciseId;
  @override
  final int score;
  @override
  @JsonKey(name: 'completed_at')
  final String completedAt;
  @override
  @JsonKey(name: 'lesson_id')
  final int? lessonId;

  @override
  String toString() {
    return 'ProgressSubmitRequest(exerciseId: $exerciseId, score: $score, completedAt: $completedAt, lessonId: $lessonId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressSubmitRequestImpl &&
            (identical(other.exerciseId, exerciseId) ||
                other.exerciseId == exerciseId) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.lessonId, lessonId) ||
                other.lessonId == lessonId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, exerciseId, score, completedAt, lessonId);

  /// Create a copy of ProgressSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressSubmitRequestImplCopyWith<_$ProgressSubmitRequestImpl>
  get copyWith =>
      __$$ProgressSubmitRequestImplCopyWithImpl<_$ProgressSubmitRequestImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressSubmitRequestImplToJson(this);
  }
}

abstract class _ProgressSubmitRequest implements ProgressSubmitRequest {
  const factory _ProgressSubmitRequest({
    @JsonKey(name: 'exercise_id') required final String exerciseId,
    required final int score,
    @JsonKey(name: 'completed_at') required final String completedAt,
    @JsonKey(name: 'lesson_id') final int? lessonId,
  }) = _$ProgressSubmitRequestImpl;

  factory _ProgressSubmitRequest.fromJson(Map<String, dynamic> json) =
      _$ProgressSubmitRequestImpl.fromJson;

  @override
  @JsonKey(name: 'exercise_id')
  String get exerciseId;
  @override
  int get score;
  @override
  @JsonKey(name: 'completed_at')
  String get completedAt;
  @override
  @JsonKey(name: 'lesson_id')
  int? get lessonId;

  /// Create a copy of ProgressSubmitRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressSubmitRequestImplCopyWith<_$ProgressSubmitRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ProgressSubmitResponse _$ProgressSubmitResponseFromJson(
  Map<String, dynamic> json,
) {
  return _ProgressSubmitResponse.fromJson(json);
}

/// @nodoc
mixin _$ProgressSubmitResponse {
  bool get success => throw _privateConstructorUsedError;
  ProgressSubmitData get data => throw _privateConstructorUsedError;

  /// Serializes this ProgressSubmitResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressSubmitResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressSubmitResponseCopyWith<ProgressSubmitResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressSubmitResponseCopyWith<$Res> {
  factory $ProgressSubmitResponseCopyWith(
    ProgressSubmitResponse value,
    $Res Function(ProgressSubmitResponse) then,
  ) = _$ProgressSubmitResponseCopyWithImpl<$Res, ProgressSubmitResponse>;
  @useResult
  $Res call({bool success, ProgressSubmitData data});

  $ProgressSubmitDataCopyWith<$Res> get data;
}

/// @nodoc
class _$ProgressSubmitResponseCopyWithImpl<
  $Res,
  $Val extends ProgressSubmitResponse
>
    implements $ProgressSubmitResponseCopyWith<$Res> {
  _$ProgressSubmitResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressSubmitResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? success = null, Object? data = null}) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as ProgressSubmitData,
          )
          as $Val,
    );
  }

  /// Create a copy of ProgressSubmitResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProgressSubmitDataCopyWith<$Res> get data {
    return $ProgressSubmitDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProgressSubmitResponseImplCopyWith<$Res>
    implements $ProgressSubmitResponseCopyWith<$Res> {
  factory _$$ProgressSubmitResponseImplCopyWith(
    _$ProgressSubmitResponseImpl value,
    $Res Function(_$ProgressSubmitResponseImpl) then,
  ) = __$$ProgressSubmitResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, ProgressSubmitData data});

  @override
  $ProgressSubmitDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$ProgressSubmitResponseImplCopyWithImpl<$Res>
    extends
        _$ProgressSubmitResponseCopyWithImpl<$Res, _$ProgressSubmitResponseImpl>
    implements _$$ProgressSubmitResponseImplCopyWith<$Res> {
  __$$ProgressSubmitResponseImplCopyWithImpl(
    _$ProgressSubmitResponseImpl _value,
    $Res Function(_$ProgressSubmitResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgressSubmitResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? success = null, Object? data = null}) {
    return _then(
      _$ProgressSubmitResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as ProgressSubmitData,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressSubmitResponseImpl implements _ProgressSubmitResponse {
  const _$ProgressSubmitResponseImpl({
    required this.success,
    required this.data,
  });

  factory _$ProgressSubmitResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressSubmitResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final ProgressSubmitData data;

  @override
  String toString() {
    return 'ProgressSubmitResponse(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressSubmitResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, success, data);

  /// Create a copy of ProgressSubmitResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressSubmitResponseImplCopyWith<_$ProgressSubmitResponseImpl>
  get copyWith =>
      __$$ProgressSubmitResponseImplCopyWithImpl<_$ProgressSubmitResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressSubmitResponseImplToJson(this);
  }
}

abstract class _ProgressSubmitResponse implements ProgressSubmitResponse {
  const factory _ProgressSubmitResponse({
    required final bool success,
    required final ProgressSubmitData data,
  }) = _$ProgressSubmitResponseImpl;

  factory _ProgressSubmitResponse.fromJson(Map<String, dynamic> json) =
      _$ProgressSubmitResponseImpl.fromJson;

  @override
  bool get success;
  @override
  ProgressSubmitData get data;

  /// Create a copy of ProgressSubmitResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressSubmitResponseImplCopyWith<_$ProgressSubmitResponseImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ProgressSubmitData _$ProgressSubmitDataFromJson(Map<String, dynamic> json) {
  return _ProgressSubmitData.fromJson(json);
}

/// @nodoc
mixin _$ProgressSubmitData {
  int get xp => throw _privateConstructorUsedError;
  @JsonKey(name: 'streak_days')
  int get streakDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'newly_completed')
  List<String> get newlyCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'streak_updated')
  bool get streakUpdated => throw _privateConstructorUsedError;

  /// Serializes this ProgressSubmitData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgressSubmitData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressSubmitDataCopyWith<ProgressSubmitData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressSubmitDataCopyWith<$Res> {
  factory $ProgressSubmitDataCopyWith(
    ProgressSubmitData value,
    $Res Function(ProgressSubmitData) then,
  ) = _$ProgressSubmitDataCopyWithImpl<$Res, ProgressSubmitData>;
  @useResult
  $Res call({
    int xp,
    @JsonKey(name: 'streak_days') int streakDays,
    @JsonKey(name: 'newly_completed') List<String> newlyCompleted,
    @JsonKey(name: 'streak_updated') bool streakUpdated,
  });
}

/// @nodoc
class _$ProgressSubmitDataCopyWithImpl<$Res, $Val extends ProgressSubmitData>
    implements $ProgressSubmitDataCopyWith<$Res> {
  _$ProgressSubmitDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressSubmitData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? xp = null,
    Object? streakDays = null,
    Object? newlyCompleted = null,
    Object? streakUpdated = null,
  }) {
    return _then(
      _value.copyWith(
            xp: null == xp
                ? _value.xp
                : xp // ignore: cast_nullable_to_non_nullable
                      as int,
            streakDays: null == streakDays
                ? _value.streakDays
                : streakDays // ignore: cast_nullable_to_non_nullable
                      as int,
            newlyCompleted: null == newlyCompleted
                ? _value.newlyCompleted
                : newlyCompleted // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            streakUpdated: null == streakUpdated
                ? _value.streakUpdated
                : streakUpdated // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProgressSubmitDataImplCopyWith<$Res>
    implements $ProgressSubmitDataCopyWith<$Res> {
  factory _$$ProgressSubmitDataImplCopyWith(
    _$ProgressSubmitDataImpl value,
    $Res Function(_$ProgressSubmitDataImpl) then,
  ) = __$$ProgressSubmitDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int xp,
    @JsonKey(name: 'streak_days') int streakDays,
    @JsonKey(name: 'newly_completed') List<String> newlyCompleted,
    @JsonKey(name: 'streak_updated') bool streakUpdated,
  });
}

/// @nodoc
class __$$ProgressSubmitDataImplCopyWithImpl<$Res>
    extends _$ProgressSubmitDataCopyWithImpl<$Res, _$ProgressSubmitDataImpl>
    implements _$$ProgressSubmitDataImplCopyWith<$Res> {
  __$$ProgressSubmitDataImplCopyWithImpl(
    _$ProgressSubmitDataImpl _value,
    $Res Function(_$ProgressSubmitDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgressSubmitData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? xp = null,
    Object? streakDays = null,
    Object? newlyCompleted = null,
    Object? streakUpdated = null,
  }) {
    return _then(
      _$ProgressSubmitDataImpl(
        xp: null == xp
            ? _value.xp
            : xp // ignore: cast_nullable_to_non_nullable
                  as int,
        streakDays: null == streakDays
            ? _value.streakDays
            : streakDays // ignore: cast_nullable_to_non_nullable
                  as int,
        newlyCompleted: null == newlyCompleted
            ? _value._newlyCompleted
            : newlyCompleted // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        streakUpdated: null == streakUpdated
            ? _value.streakUpdated
            : streakUpdated // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgressSubmitDataImpl implements _ProgressSubmitData {
  const _$ProgressSubmitDataImpl({
    required this.xp,
    @JsonKey(name: 'streak_days') required this.streakDays,
    @JsonKey(name: 'newly_completed')
    required final List<String> newlyCompleted,
    @JsonKey(name: 'streak_updated') required this.streakUpdated,
  }) : _newlyCompleted = newlyCompleted;

  factory _$ProgressSubmitDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgressSubmitDataImplFromJson(json);

  @override
  final int xp;
  @override
  @JsonKey(name: 'streak_days')
  final int streakDays;
  final List<String> _newlyCompleted;
  @override
  @JsonKey(name: 'newly_completed')
  List<String> get newlyCompleted {
    if (_newlyCompleted is EqualUnmodifiableListView) return _newlyCompleted;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_newlyCompleted);
  }

  @override
  @JsonKey(name: 'streak_updated')
  final bool streakUpdated;

  @override
  String toString() {
    return 'ProgressSubmitData(xp: $xp, streakDays: $streakDays, newlyCompleted: $newlyCompleted, streakUpdated: $streakUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressSubmitDataImpl &&
            (identical(other.xp, xp) || other.xp == xp) &&
            (identical(other.streakDays, streakDays) ||
                other.streakDays == streakDays) &&
            const DeepCollectionEquality().equals(
              other._newlyCompleted,
              _newlyCompleted,
            ) &&
            (identical(other.streakUpdated, streakUpdated) ||
                other.streakUpdated == streakUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    xp,
    streakDays,
    const DeepCollectionEquality().hash(_newlyCompleted),
    streakUpdated,
  );

  /// Create a copy of ProgressSubmitData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressSubmitDataImplCopyWith<_$ProgressSubmitDataImpl> get copyWith =>
      __$$ProgressSubmitDataImplCopyWithImpl<_$ProgressSubmitDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgressSubmitDataImplToJson(this);
  }
}

abstract class _ProgressSubmitData implements ProgressSubmitData {
  const factory _ProgressSubmitData({
    required final int xp,
    @JsonKey(name: 'streak_days') required final int streakDays,
    @JsonKey(name: 'newly_completed')
    required final List<String> newlyCompleted,
    @JsonKey(name: 'streak_updated') required final bool streakUpdated,
  }) = _$ProgressSubmitDataImpl;

  factory _ProgressSubmitData.fromJson(Map<String, dynamic> json) =
      _$ProgressSubmitDataImpl.fromJson;

  @override
  int get xp;
  @override
  @JsonKey(name: 'streak_days')
  int get streakDays;
  @override
  @JsonKey(name: 'newly_completed')
  List<String> get newlyCompleted;
  @override
  @JsonKey(name: 'streak_updated')
  bool get streakUpdated;

  /// Create a copy of ProgressSubmitData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressSubmitDataImplCopyWith<_$ProgressSubmitDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
