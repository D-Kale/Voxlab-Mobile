// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ExerciseContent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      List<QuizQuestion> questions,
      int pointsPerQuestion,
    )
    quiz,
    required TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )
    reading,
    required TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )
    writing,
    required TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )
    oratory,
    required TResult Function(String prompt, int durationSeconds, int points)
    audio,
    required TResult Function(String prompt, int durationSeconds, int points)
    video,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<QuizQuestion> questions, int pointsPerQuestion)?
    quiz,
    TResult? Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult? Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult? Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult? Function(String prompt, int durationSeconds, int points)? audio,
    TResult? Function(String prompt, int durationSeconds, int points)? video,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<QuizQuestion> questions, int pointsPerQuestion)? quiz,
    TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult Function(String prompt, int durationSeconds, int points)? audio,
    TResult Function(String prompt, int durationSeconds, int points)? video,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QuizContent value) quiz,
    required TResult Function(ReadingContent value) reading,
    required TResult Function(WritingContent value) writing,
    required TResult Function(OratoryContent value) oratory,
    required TResult Function(AudioContent value) audio,
    required TResult Function(VideoContent value) video,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QuizContent value)? quiz,
    TResult? Function(ReadingContent value)? reading,
    TResult? Function(WritingContent value)? writing,
    TResult? Function(OratoryContent value)? oratory,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(VideoContent value)? video,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QuizContent value)? quiz,
    TResult Function(ReadingContent value)? reading,
    TResult Function(WritingContent value)? writing,
    TResult Function(OratoryContent value)? oratory,
    TResult Function(AudioContent value)? audio,
    TResult Function(VideoContent value)? video,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseContentCopyWith<$Res> {
  factory $ExerciseContentCopyWith(
    ExerciseContent value,
    $Res Function(ExerciseContent) then,
  ) = _$ExerciseContentCopyWithImpl<$Res, ExerciseContent>;
}

/// @nodoc
class _$ExerciseContentCopyWithImpl<$Res, $Val extends ExerciseContent>
    implements $ExerciseContentCopyWith<$Res> {
  _$ExerciseContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$QuizContentImplCopyWith<$Res> {
  factory _$$QuizContentImplCopyWith(
    _$QuizContentImpl value,
    $Res Function(_$QuizContentImpl) then,
  ) = __$$QuizContentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({List<QuizQuestion> questions, int pointsPerQuestion});
}

/// @nodoc
class __$$QuizContentImplCopyWithImpl<$Res>
    extends _$ExerciseContentCopyWithImpl<$Res, _$QuizContentImpl>
    implements _$$QuizContentImplCopyWith<$Res> {
  __$$QuizContentImplCopyWithImpl(
    _$QuizContentImpl _value,
    $Res Function(_$QuizContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? questions = null, Object? pointsPerQuestion = null}) {
    return _then(
      _$QuizContentImpl(
        questions: null == questions
            ? _value._questions
            : questions // ignore: cast_nullable_to_non_nullable
                  as List<QuizQuestion>,
        pointsPerQuestion: null == pointsPerQuestion
            ? _value.pointsPerQuestion
            : pointsPerQuestion // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$QuizContentImpl implements QuizContent {
  const _$QuizContentImpl({
    required final List<QuizQuestion> questions,
    required this.pointsPerQuestion,
  }) : _questions = questions;

  final List<QuizQuestion> _questions;
  @override
  List<QuizQuestion> get questions {
    if (_questions is EqualUnmodifiableListView) return _questions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_questions);
  }

  @override
  final int pointsPerQuestion;

  @override
  String toString() {
    return 'ExerciseContent.quiz(questions: $questions, pointsPerQuestion: $pointsPerQuestion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizContentImpl &&
            const DeepCollectionEquality().equals(
              other._questions,
              _questions,
            ) &&
            (identical(other.pointsPerQuestion, pointsPerQuestion) ||
                other.pointsPerQuestion == pointsPerQuestion));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_questions),
    pointsPerQuestion,
  );

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizContentImplCopyWith<_$QuizContentImpl> get copyWith =>
      __$$QuizContentImplCopyWithImpl<_$QuizContentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      List<QuizQuestion> questions,
      int pointsPerQuestion,
    )
    quiz,
    required TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )
    reading,
    required TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )
    writing,
    required TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )
    oratory,
    required TResult Function(String prompt, int durationSeconds, int points)
    audio,
    required TResult Function(String prompt, int durationSeconds, int points)
    video,
  }) {
    return quiz(questions, pointsPerQuestion);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<QuizQuestion> questions, int pointsPerQuestion)?
    quiz,
    TResult? Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult? Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult? Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult? Function(String prompt, int durationSeconds, int points)? audio,
    TResult? Function(String prompt, int durationSeconds, int points)? video,
  }) {
    return quiz?.call(questions, pointsPerQuestion);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<QuizQuestion> questions, int pointsPerQuestion)? quiz,
    TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult Function(String prompt, int durationSeconds, int points)? audio,
    TResult Function(String prompt, int durationSeconds, int points)? video,
    required TResult orElse(),
  }) {
    if (quiz != null) {
      return quiz(questions, pointsPerQuestion);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QuizContent value) quiz,
    required TResult Function(ReadingContent value) reading,
    required TResult Function(WritingContent value) writing,
    required TResult Function(OratoryContent value) oratory,
    required TResult Function(AudioContent value) audio,
    required TResult Function(VideoContent value) video,
  }) {
    return quiz(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QuizContent value)? quiz,
    TResult? Function(ReadingContent value)? reading,
    TResult? Function(WritingContent value)? writing,
    TResult? Function(OratoryContent value)? oratory,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(VideoContent value)? video,
  }) {
    return quiz?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QuizContent value)? quiz,
    TResult Function(ReadingContent value)? reading,
    TResult Function(WritingContent value)? writing,
    TResult Function(OratoryContent value)? oratory,
    TResult Function(AudioContent value)? audio,
    TResult Function(VideoContent value)? video,
    required TResult orElse(),
  }) {
    if (quiz != null) {
      return quiz(this);
    }
    return orElse();
  }
}

abstract class QuizContent implements ExerciseContent {
  const factory QuizContent({
    required final List<QuizQuestion> questions,
    required final int pointsPerQuestion,
  }) = _$QuizContentImpl;

  List<QuizQuestion> get questions;
  int get pointsPerQuestion;

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuizContentImplCopyWith<_$QuizContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ReadingContentImplCopyWith<$Res> {
  factory _$$ReadingContentImplCopyWith(
    _$ReadingContentImpl value,
    $Res Function(_$ReadingContentImpl) then,
  ) = __$$ReadingContentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String title, String content, int readingTimeSeconds, int points});
}

/// @nodoc
class __$$ReadingContentImplCopyWithImpl<$Res>
    extends _$ExerciseContentCopyWithImpl<$Res, _$ReadingContentImpl>
    implements _$$ReadingContentImplCopyWith<$Res> {
  __$$ReadingContentImplCopyWithImpl(
    _$ReadingContentImpl _value,
    $Res Function(_$ReadingContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? content = null,
    Object? readingTimeSeconds = null,
    Object? points = null,
  }) {
    return _then(
      _$ReadingContentImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        readingTimeSeconds: null == readingTimeSeconds
            ? _value.readingTimeSeconds
            : readingTimeSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ReadingContentImpl implements ReadingContent {
  const _$ReadingContentImpl({
    required this.title,
    required this.content,
    required this.readingTimeSeconds,
    required this.points,
  });

  @override
  final String title;
  @override
  final String content;
  @override
  final int readingTimeSeconds;
  @override
  final int points;

  @override
  String toString() {
    return 'ExerciseContent.reading(title: $title, content: $content, readingTimeSeconds: $readingTimeSeconds, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReadingContentImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.readingTimeSeconds, readingTimeSeconds) ||
                other.readingTimeSeconds == readingTimeSeconds) &&
            (identical(other.points, points) || other.points == points));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, title, content, readingTimeSeconds, points);

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReadingContentImplCopyWith<_$ReadingContentImpl> get copyWith =>
      __$$ReadingContentImplCopyWithImpl<_$ReadingContentImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      List<QuizQuestion> questions,
      int pointsPerQuestion,
    )
    quiz,
    required TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )
    reading,
    required TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )
    writing,
    required TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )
    oratory,
    required TResult Function(String prompt, int durationSeconds, int points)
    audio,
    required TResult Function(String prompt, int durationSeconds, int points)
    video,
  }) {
    return reading(title, content, readingTimeSeconds, points);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<QuizQuestion> questions, int pointsPerQuestion)?
    quiz,
    TResult? Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult? Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult? Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult? Function(String prompt, int durationSeconds, int points)? audio,
    TResult? Function(String prompt, int durationSeconds, int points)? video,
  }) {
    return reading?.call(title, content, readingTimeSeconds, points);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<QuizQuestion> questions, int pointsPerQuestion)? quiz,
    TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult Function(String prompt, int durationSeconds, int points)? audio,
    TResult Function(String prompt, int durationSeconds, int points)? video,
    required TResult orElse(),
  }) {
    if (reading != null) {
      return reading(title, content, readingTimeSeconds, points);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QuizContent value) quiz,
    required TResult Function(ReadingContent value) reading,
    required TResult Function(WritingContent value) writing,
    required TResult Function(OratoryContent value) oratory,
    required TResult Function(AudioContent value) audio,
    required TResult Function(VideoContent value) video,
  }) {
    return reading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QuizContent value)? quiz,
    TResult? Function(ReadingContent value)? reading,
    TResult? Function(WritingContent value)? writing,
    TResult? Function(OratoryContent value)? oratory,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(VideoContent value)? video,
  }) {
    return reading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QuizContent value)? quiz,
    TResult Function(ReadingContent value)? reading,
    TResult Function(WritingContent value)? writing,
    TResult Function(OratoryContent value)? oratory,
    TResult Function(AudioContent value)? audio,
    TResult Function(VideoContent value)? video,
    required TResult orElse(),
  }) {
    if (reading != null) {
      return reading(this);
    }
    return orElse();
  }
}

abstract class ReadingContent implements ExerciseContent {
  const factory ReadingContent({
    required final String title,
    required final String content,
    required final int readingTimeSeconds,
    required final int points,
  }) = _$ReadingContentImpl;

  String get title;
  String get content;
  int get readingTimeSeconds;
  int get points;

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReadingContentImplCopyWith<_$ReadingContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$WritingContentImplCopyWith<$Res> {
  factory _$$WritingContentImplCopyWith(
    _$WritingContentImpl value,
    $Res Function(_$WritingContentImpl) then,
  ) = __$$WritingContentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String prompt,
    int minWords,
    int maxWords,
    List<String> requirements,
    int points,
  });
}

/// @nodoc
class __$$WritingContentImplCopyWithImpl<$Res>
    extends _$ExerciseContentCopyWithImpl<$Res, _$WritingContentImpl>
    implements _$$WritingContentImplCopyWith<$Res> {
  __$$WritingContentImplCopyWithImpl(
    _$WritingContentImpl _value,
    $Res Function(_$WritingContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prompt = null,
    Object? minWords = null,
    Object? maxWords = null,
    Object? requirements = null,
    Object? points = null,
  }) {
    return _then(
      _$WritingContentImpl(
        prompt: null == prompt
            ? _value.prompt
            : prompt // ignore: cast_nullable_to_non_nullable
                  as String,
        minWords: null == minWords
            ? _value.minWords
            : minWords // ignore: cast_nullable_to_non_nullable
                  as int,
        maxWords: null == maxWords
            ? _value.maxWords
            : maxWords // ignore: cast_nullable_to_non_nullable
                  as int,
        requirements: null == requirements
            ? _value._requirements
            : requirements // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$WritingContentImpl implements WritingContent {
  const _$WritingContentImpl({
    required this.prompt,
    required this.minWords,
    required this.maxWords,
    required final List<String> requirements,
    required this.points,
  }) : _requirements = requirements;

  @override
  final String prompt;
  @override
  final int minWords;
  @override
  final int maxWords;
  final List<String> _requirements;
  @override
  List<String> get requirements {
    if (_requirements is EqualUnmodifiableListView) return _requirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requirements);
  }

  @override
  final int points;

  @override
  String toString() {
    return 'ExerciseContent.writing(prompt: $prompt, minWords: $minWords, maxWords: $maxWords, requirements: $requirements, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WritingContentImpl &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.minWords, minWords) ||
                other.minWords == minWords) &&
            (identical(other.maxWords, maxWords) ||
                other.maxWords == maxWords) &&
            const DeepCollectionEquality().equals(
              other._requirements,
              _requirements,
            ) &&
            (identical(other.points, points) || other.points == points));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    prompt,
    minWords,
    maxWords,
    const DeepCollectionEquality().hash(_requirements),
    points,
  );

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WritingContentImplCopyWith<_$WritingContentImpl> get copyWith =>
      __$$WritingContentImplCopyWithImpl<_$WritingContentImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      List<QuizQuestion> questions,
      int pointsPerQuestion,
    )
    quiz,
    required TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )
    reading,
    required TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )
    writing,
    required TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )
    oratory,
    required TResult Function(String prompt, int durationSeconds, int points)
    audio,
    required TResult Function(String prompt, int durationSeconds, int points)
    video,
  }) {
    return writing(prompt, minWords, maxWords, requirements, points);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<QuizQuestion> questions, int pointsPerQuestion)?
    quiz,
    TResult? Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult? Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult? Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult? Function(String prompt, int durationSeconds, int points)? audio,
    TResult? Function(String prompt, int durationSeconds, int points)? video,
  }) {
    return writing?.call(prompt, minWords, maxWords, requirements, points);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<QuizQuestion> questions, int pointsPerQuestion)? quiz,
    TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult Function(String prompt, int durationSeconds, int points)? audio,
    TResult Function(String prompt, int durationSeconds, int points)? video,
    required TResult orElse(),
  }) {
    if (writing != null) {
      return writing(prompt, minWords, maxWords, requirements, points);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QuizContent value) quiz,
    required TResult Function(ReadingContent value) reading,
    required TResult Function(WritingContent value) writing,
    required TResult Function(OratoryContent value) oratory,
    required TResult Function(AudioContent value) audio,
    required TResult Function(VideoContent value) video,
  }) {
    return writing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QuizContent value)? quiz,
    TResult? Function(ReadingContent value)? reading,
    TResult? Function(WritingContent value)? writing,
    TResult? Function(OratoryContent value)? oratory,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(VideoContent value)? video,
  }) {
    return writing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QuizContent value)? quiz,
    TResult Function(ReadingContent value)? reading,
    TResult Function(WritingContent value)? writing,
    TResult Function(OratoryContent value)? oratory,
    TResult Function(AudioContent value)? audio,
    TResult Function(VideoContent value)? video,
    required TResult orElse(),
  }) {
    if (writing != null) {
      return writing(this);
    }
    return orElse();
  }
}

abstract class WritingContent implements ExerciseContent {
  const factory WritingContent({
    required final String prompt,
    required final int minWords,
    required final int maxWords,
    required final List<String> requirements,
    required final int points,
  }) = _$WritingContentImpl;

  String get prompt;
  int get minWords;
  int get maxWords;
  List<String> get requirements;
  int get points;

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WritingContentImplCopyWith<_$WritingContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OratoryContentImplCopyWith<$Res> {
  factory _$$OratoryContentImplCopyWith(
    _$OratoryContentImpl value,
    $Res Function(_$OratoryContentImpl) then,
  ) = __$$OratoryContentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({
    String prompt,
    String topic,
    int durationSeconds,
    int minDurationSeconds,
    List<String> requirements,
    int points,
  });
}

/// @nodoc
class __$$OratoryContentImplCopyWithImpl<$Res>
    extends _$ExerciseContentCopyWithImpl<$Res, _$OratoryContentImpl>
    implements _$$OratoryContentImplCopyWith<$Res> {
  __$$OratoryContentImplCopyWithImpl(
    _$OratoryContentImpl _value,
    $Res Function(_$OratoryContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prompt = null,
    Object? topic = null,
    Object? durationSeconds = null,
    Object? minDurationSeconds = null,
    Object? requirements = null,
    Object? points = null,
  }) {
    return _then(
      _$OratoryContentImpl(
        prompt: null == prompt
            ? _value.prompt
            : prompt // ignore: cast_nullable_to_non_nullable
                  as String,
        topic: null == topic
            ? _value.topic
            : topic // ignore: cast_nullable_to_non_nullable
                  as String,
        durationSeconds: null == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        minDurationSeconds: null == minDurationSeconds
            ? _value.minDurationSeconds
            : minDurationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        requirements: null == requirements
            ? _value._requirements
            : requirements // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$OratoryContentImpl implements OratoryContent {
  const _$OratoryContentImpl({
    required this.prompt,
    required this.topic,
    required this.durationSeconds,
    required this.minDurationSeconds,
    required final List<String> requirements,
    required this.points,
  }) : _requirements = requirements;

  @override
  final String prompt;
  @override
  final String topic;
  @override
  final int durationSeconds;
  @override
  final int minDurationSeconds;
  final List<String> _requirements;
  @override
  List<String> get requirements {
    if (_requirements is EqualUnmodifiableListView) return _requirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requirements);
  }

  @override
  final int points;

  @override
  String toString() {
    return 'ExerciseContent.oratory(prompt: $prompt, topic: $topic, durationSeconds: $durationSeconds, minDurationSeconds: $minDurationSeconds, requirements: $requirements, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OratoryContentImpl &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.topic, topic) || other.topic == topic) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.minDurationSeconds, minDurationSeconds) ||
                other.minDurationSeconds == minDurationSeconds) &&
            const DeepCollectionEquality().equals(
              other._requirements,
              _requirements,
            ) &&
            (identical(other.points, points) || other.points == points));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    prompt,
    topic,
    durationSeconds,
    minDurationSeconds,
    const DeepCollectionEquality().hash(_requirements),
    points,
  );

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OratoryContentImplCopyWith<_$OratoryContentImpl> get copyWith =>
      __$$OratoryContentImplCopyWithImpl<_$OratoryContentImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      List<QuizQuestion> questions,
      int pointsPerQuestion,
    )
    quiz,
    required TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )
    reading,
    required TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )
    writing,
    required TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )
    oratory,
    required TResult Function(String prompt, int durationSeconds, int points)
    audio,
    required TResult Function(String prompt, int durationSeconds, int points)
    video,
  }) {
    return oratory(
      prompt,
      topic,
      durationSeconds,
      minDurationSeconds,
      requirements,
      points,
    );
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<QuizQuestion> questions, int pointsPerQuestion)?
    quiz,
    TResult? Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult? Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult? Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult? Function(String prompt, int durationSeconds, int points)? audio,
    TResult? Function(String prompt, int durationSeconds, int points)? video,
  }) {
    return oratory?.call(
      prompt,
      topic,
      durationSeconds,
      minDurationSeconds,
      requirements,
      points,
    );
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<QuizQuestion> questions, int pointsPerQuestion)? quiz,
    TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult Function(String prompt, int durationSeconds, int points)? audio,
    TResult Function(String prompt, int durationSeconds, int points)? video,
    required TResult orElse(),
  }) {
    if (oratory != null) {
      return oratory(
        prompt,
        topic,
        durationSeconds,
        minDurationSeconds,
        requirements,
        points,
      );
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QuizContent value) quiz,
    required TResult Function(ReadingContent value) reading,
    required TResult Function(WritingContent value) writing,
    required TResult Function(OratoryContent value) oratory,
    required TResult Function(AudioContent value) audio,
    required TResult Function(VideoContent value) video,
  }) {
    return oratory(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QuizContent value)? quiz,
    TResult? Function(ReadingContent value)? reading,
    TResult? Function(WritingContent value)? writing,
    TResult? Function(OratoryContent value)? oratory,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(VideoContent value)? video,
  }) {
    return oratory?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QuizContent value)? quiz,
    TResult Function(ReadingContent value)? reading,
    TResult Function(WritingContent value)? writing,
    TResult Function(OratoryContent value)? oratory,
    TResult Function(AudioContent value)? audio,
    TResult Function(VideoContent value)? video,
    required TResult orElse(),
  }) {
    if (oratory != null) {
      return oratory(this);
    }
    return orElse();
  }
}

abstract class OratoryContent implements ExerciseContent {
  const factory OratoryContent({
    required final String prompt,
    required final String topic,
    required final int durationSeconds,
    required final int minDurationSeconds,
    required final List<String> requirements,
    required final int points,
  }) = _$OratoryContentImpl;

  String get prompt;
  String get topic;
  int get durationSeconds;
  int get minDurationSeconds;
  List<String> get requirements;
  int get points;

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OratoryContentImplCopyWith<_$OratoryContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AudioContentImplCopyWith<$Res> {
  factory _$$AudioContentImplCopyWith(
    _$AudioContentImpl value,
    $Res Function(_$AudioContentImpl) then,
  ) = __$$AudioContentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String prompt, int durationSeconds, int points});
}

/// @nodoc
class __$$AudioContentImplCopyWithImpl<$Res>
    extends _$ExerciseContentCopyWithImpl<$Res, _$AudioContentImpl>
    implements _$$AudioContentImplCopyWith<$Res> {
  __$$AudioContentImplCopyWithImpl(
    _$AudioContentImpl _value,
    $Res Function(_$AudioContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prompt = null,
    Object? durationSeconds = null,
    Object? points = null,
  }) {
    return _then(
      _$AudioContentImpl(
        prompt: null == prompt
            ? _value.prompt
            : prompt // ignore: cast_nullable_to_non_nullable
                  as String,
        durationSeconds: null == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$AudioContentImpl implements AudioContent {
  const _$AudioContentImpl({
    required this.prompt,
    required this.durationSeconds,
    required this.points,
  });

  @override
  final String prompt;
  @override
  final int durationSeconds;
  @override
  final int points;

  @override
  String toString() {
    return 'ExerciseContent.audio(prompt: $prompt, durationSeconds: $durationSeconds, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AudioContentImpl &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.points, points) || other.points == points));
  }

  @override
  int get hashCode => Object.hash(runtimeType, prompt, durationSeconds, points);

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AudioContentImplCopyWith<_$AudioContentImpl> get copyWith =>
      __$$AudioContentImplCopyWithImpl<_$AudioContentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      List<QuizQuestion> questions,
      int pointsPerQuestion,
    )
    quiz,
    required TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )
    reading,
    required TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )
    writing,
    required TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )
    oratory,
    required TResult Function(String prompt, int durationSeconds, int points)
    audio,
    required TResult Function(String prompt, int durationSeconds, int points)
    video,
  }) {
    return audio(prompt, durationSeconds, points);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<QuizQuestion> questions, int pointsPerQuestion)?
    quiz,
    TResult? Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult? Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult? Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult? Function(String prompt, int durationSeconds, int points)? audio,
    TResult? Function(String prompt, int durationSeconds, int points)? video,
  }) {
    return audio?.call(prompt, durationSeconds, points);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<QuizQuestion> questions, int pointsPerQuestion)? quiz,
    TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult Function(String prompt, int durationSeconds, int points)? audio,
    TResult Function(String prompt, int durationSeconds, int points)? video,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(prompt, durationSeconds, points);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QuizContent value) quiz,
    required TResult Function(ReadingContent value) reading,
    required TResult Function(WritingContent value) writing,
    required TResult Function(OratoryContent value) oratory,
    required TResult Function(AudioContent value) audio,
    required TResult Function(VideoContent value) video,
  }) {
    return audio(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QuizContent value)? quiz,
    TResult? Function(ReadingContent value)? reading,
    TResult? Function(WritingContent value)? writing,
    TResult? Function(OratoryContent value)? oratory,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(VideoContent value)? video,
  }) {
    return audio?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QuizContent value)? quiz,
    TResult Function(ReadingContent value)? reading,
    TResult Function(WritingContent value)? writing,
    TResult Function(OratoryContent value)? oratory,
    TResult Function(AudioContent value)? audio,
    TResult Function(VideoContent value)? video,
    required TResult orElse(),
  }) {
    if (audio != null) {
      return audio(this);
    }
    return orElse();
  }
}

abstract class AudioContent implements ExerciseContent {
  const factory AudioContent({
    required final String prompt,
    required final int durationSeconds,
    required final int points,
  }) = _$AudioContentImpl;

  String get prompt;
  int get durationSeconds;
  int get points;

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AudioContentImplCopyWith<_$AudioContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$VideoContentImplCopyWith<$Res> {
  factory _$$VideoContentImplCopyWith(
    _$VideoContentImpl value,
    $Res Function(_$VideoContentImpl) then,
  ) = __$$VideoContentImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String prompt, int durationSeconds, int points});
}

/// @nodoc
class __$$VideoContentImplCopyWithImpl<$Res>
    extends _$ExerciseContentCopyWithImpl<$Res, _$VideoContentImpl>
    implements _$$VideoContentImplCopyWith<$Res> {
  __$$VideoContentImplCopyWithImpl(
    _$VideoContentImpl _value,
    $Res Function(_$VideoContentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? prompt = null,
    Object? durationSeconds = null,
    Object? points = null,
  }) {
    return _then(
      _$VideoContentImpl(
        prompt: null == prompt
            ? _value.prompt
            : prompt // ignore: cast_nullable_to_non_nullable
                  as String,
        durationSeconds: null == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        points: null == points
            ? _value.points
            : points // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$VideoContentImpl implements VideoContent {
  const _$VideoContentImpl({
    required this.prompt,
    required this.durationSeconds,
    required this.points,
  });

  @override
  final String prompt;
  @override
  final int durationSeconds;
  @override
  final int points;

  @override
  String toString() {
    return 'ExerciseContent.video(prompt: $prompt, durationSeconds: $durationSeconds, points: $points)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VideoContentImpl &&
            (identical(other.prompt, prompt) || other.prompt == prompt) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.points, points) || other.points == points));
  }

  @override
  int get hashCode => Object.hash(runtimeType, prompt, durationSeconds, points);

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VideoContentImplCopyWith<_$VideoContentImpl> get copyWith =>
      __$$VideoContentImplCopyWithImpl<_$VideoContentImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
      List<QuizQuestion> questions,
      int pointsPerQuestion,
    )
    quiz,
    required TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )
    reading,
    required TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )
    writing,
    required TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )
    oratory,
    required TResult Function(String prompt, int durationSeconds, int points)
    audio,
    required TResult Function(String prompt, int durationSeconds, int points)
    video,
  }) {
    return video(prompt, durationSeconds, points);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(List<QuizQuestion> questions, int pointsPerQuestion)?
    quiz,
    TResult? Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult? Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult? Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult? Function(String prompt, int durationSeconds, int points)? audio,
    TResult? Function(String prompt, int durationSeconds, int points)? video,
  }) {
    return video?.call(prompt, durationSeconds, points);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(List<QuizQuestion> questions, int pointsPerQuestion)? quiz,
    TResult Function(
      String title,
      String content,
      int readingTimeSeconds,
      int points,
    )?
    reading,
    TResult Function(
      String prompt,
      int minWords,
      int maxWords,
      List<String> requirements,
      int points,
    )?
    writing,
    TResult Function(
      String prompt,
      String topic,
      int durationSeconds,
      int minDurationSeconds,
      List<String> requirements,
      int points,
    )?
    oratory,
    TResult Function(String prompt, int durationSeconds, int points)? audio,
    TResult Function(String prompt, int durationSeconds, int points)? video,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(prompt, durationSeconds, points);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(QuizContent value) quiz,
    required TResult Function(ReadingContent value) reading,
    required TResult Function(WritingContent value) writing,
    required TResult Function(OratoryContent value) oratory,
    required TResult Function(AudioContent value) audio,
    required TResult Function(VideoContent value) video,
  }) {
    return video(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(QuizContent value)? quiz,
    TResult? Function(ReadingContent value)? reading,
    TResult? Function(WritingContent value)? writing,
    TResult? Function(OratoryContent value)? oratory,
    TResult? Function(AudioContent value)? audio,
    TResult? Function(VideoContent value)? video,
  }) {
    return video?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(QuizContent value)? quiz,
    TResult Function(ReadingContent value)? reading,
    TResult Function(WritingContent value)? writing,
    TResult Function(OratoryContent value)? oratory,
    TResult Function(AudioContent value)? audio,
    TResult Function(VideoContent value)? video,
    required TResult orElse(),
  }) {
    if (video != null) {
      return video(this);
    }
    return orElse();
  }
}

abstract class VideoContent implements ExerciseContent {
  const factory VideoContent({
    required final String prompt,
    required final int durationSeconds,
    required final int points,
  }) = _$VideoContentImpl;

  String get prompt;
  int get durationSeconds;
  int get points;

  /// Create a copy of ExerciseContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VideoContentImplCopyWith<_$VideoContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$QuizQuestion {
  String get question => throw _privateConstructorUsedError;
  List<String> get options => throw _privateConstructorUsedError;
  int get correctIndex => throw _privateConstructorUsedError;
  String? get explanation => throw _privateConstructorUsedError;

  /// Create a copy of QuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuizQuestionCopyWith<QuizQuestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuizQuestionCopyWith<$Res> {
  factory $QuizQuestionCopyWith(
    QuizQuestion value,
    $Res Function(QuizQuestion) then,
  ) = _$QuizQuestionCopyWithImpl<$Res, QuizQuestion>;
  @useResult
  $Res call({
    String question,
    List<String> options,
    int correctIndex,
    String? explanation,
  });
}

/// @nodoc
class _$QuizQuestionCopyWithImpl<$Res, $Val extends QuizQuestion>
    implements $QuizQuestionCopyWith<$Res> {
  _$QuizQuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? options = null,
    Object? correctIndex = null,
    Object? explanation = freezed,
  }) {
    return _then(
      _value.copyWith(
            question: null == question
                ? _value.question
                : question // ignore: cast_nullable_to_non_nullable
                      as String,
            options: null == options
                ? _value.options
                : options // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            correctIndex: null == correctIndex
                ? _value.correctIndex
                : correctIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            explanation: freezed == explanation
                ? _value.explanation
                : explanation // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuizQuestionImplCopyWith<$Res>
    implements $QuizQuestionCopyWith<$Res> {
  factory _$$QuizQuestionImplCopyWith(
    _$QuizQuestionImpl value,
    $Res Function(_$QuizQuestionImpl) then,
  ) = __$$QuizQuestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String question,
    List<String> options,
    int correctIndex,
    String? explanation,
  });
}

/// @nodoc
class __$$QuizQuestionImplCopyWithImpl<$Res>
    extends _$QuizQuestionCopyWithImpl<$Res, _$QuizQuestionImpl>
    implements _$$QuizQuestionImplCopyWith<$Res> {
  __$$QuizQuestionImplCopyWithImpl(
    _$QuizQuestionImpl _value,
    $Res Function(_$QuizQuestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = null,
    Object? options = null,
    Object? correctIndex = null,
    Object? explanation = freezed,
  }) {
    return _then(
      _$QuizQuestionImpl(
        question: null == question
            ? _value.question
            : question // ignore: cast_nullable_to_non_nullable
                  as String,
        options: null == options
            ? _value._options
            : options // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        correctIndex: null == correctIndex
            ? _value.correctIndex
            : correctIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        explanation: freezed == explanation
            ? _value.explanation
            : explanation // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$QuizQuestionImpl implements _QuizQuestion {
  const _$QuizQuestionImpl({
    required this.question,
    required final List<String> options,
    required this.correctIndex,
    this.explanation,
  }) : _options = options;

  @override
  final String question;
  final List<String> _options;
  @override
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final int correctIndex;
  @override
  final String? explanation;

  @override
  String toString() {
    return 'QuizQuestion(question: $question, options: $options, correctIndex: $correctIndex, explanation: $explanation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuizQuestionImpl &&
            (identical(other.question, question) ||
                other.question == question) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.correctIndex, correctIndex) ||
                other.correctIndex == correctIndex) &&
            (identical(other.explanation, explanation) ||
                other.explanation == explanation));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    question,
    const DeepCollectionEquality().hash(_options),
    correctIndex,
    explanation,
  );

  /// Create a copy of QuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuizQuestionImplCopyWith<_$QuizQuestionImpl> get copyWith =>
      __$$QuizQuestionImplCopyWithImpl<_$QuizQuestionImpl>(this, _$identity);
}

abstract class _QuizQuestion implements QuizQuestion {
  const factory _QuizQuestion({
    required final String question,
    required final List<String> options,
    required final int correctIndex,
    final String? explanation,
  }) = _$QuizQuestionImpl;

  @override
  String get question;
  @override
  List<String> get options;
  @override
  int get correctIndex;
  @override
  String? get explanation;

  /// Create a copy of QuizQuestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuizQuestionImplCopyWith<_$QuizQuestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
