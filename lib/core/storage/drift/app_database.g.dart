// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GuestProgressTableTable extends GuestProgressTable
    with TableInfo<$GuestProgressTableTable, GuestProgress> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GuestProgressTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<int> lessonId = GeneratedColumn<int>(
    'lesson_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _exerciseTypeMeta = const VerificationMeta(
    'exerciseType',
  );
  @override
  late final GeneratedColumn<String> exerciseType = GeneratedColumn<String>(
    'exercise_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    exerciseId,
    lessonId,
    score,
    status,
    completedAt,
    isSynced,
    exerciseType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'guest_progress_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<GuestProgress> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    if (data.containsKey('exercise_type')) {
      context.handle(
        _exerciseTypeMeta,
        exerciseType.isAcceptableOrUnknown(
          data['exercise_type']!,
          _exerciseTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId};
  @override
  GuestProgress map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GuestProgress(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lesson_id'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
      exerciseType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_type'],
      ),
    );
  }

  @override
  $GuestProgressTableTable createAlias(String alias) {
    return $GuestProgressTableTable(attachedDatabase, alias);
  }
}

class GuestProgress extends DataClass implements Insertable<GuestProgress> {
  final String exerciseId;
  final int? lessonId;
  final int? score;
  final String status;
  final DateTime? completedAt;
  final bool isSynced;
  final String? exerciseType;
  const GuestProgress({
    required this.exerciseId,
    this.lessonId,
    this.score,
    required this.status,
    this.completedAt,
    required this.isSynced,
    this.exerciseType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    if (!nullToAbsent || lessonId != null) {
      map['lesson_id'] = Variable<int>(lessonId);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<int>(score);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    map['is_synced'] = Variable<bool>(isSynced);
    if (!nullToAbsent || exerciseType != null) {
      map['exercise_type'] = Variable<String>(exerciseType);
    }
    return map;
  }

  GuestProgressTableCompanion toCompanion(bool nullToAbsent) {
    return GuestProgressTableCompanion(
      exerciseId: Value(exerciseId),
      lessonId: lessonId == null && nullToAbsent
          ? const Value.absent()
          : Value(lessonId),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      status: Value(status),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      isSynced: Value(isSynced),
      exerciseType: exerciseType == null && nullToAbsent
          ? const Value.absent()
          : Value(exerciseType),
    );
  }

  factory GuestProgress.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GuestProgress(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      lessonId: serializer.fromJson<int?>(json['lessonId']),
      score: serializer.fromJson<int?>(json['score']),
      status: serializer.fromJson<String>(json['status']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
      exerciseType: serializer.fromJson<String?>(json['exerciseType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'lessonId': serializer.toJson<int?>(lessonId),
      'score': serializer.toJson<int?>(score),
      'status': serializer.toJson<String>(status),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
      'exerciseType': serializer.toJson<String?>(exerciseType),
    };
  }

  GuestProgress copyWith({
    String? exerciseId,
    Value<int?> lessonId = const Value.absent(),
    Value<int?> score = const Value.absent(),
    String? status,
    Value<DateTime?> completedAt = const Value.absent(),
    bool? isSynced,
    Value<String?> exerciseType = const Value.absent(),
  }) => GuestProgress(
    exerciseId: exerciseId ?? this.exerciseId,
    lessonId: lessonId.present ? lessonId.value : this.lessonId,
    score: score.present ? score.value : this.score,
    status: status ?? this.status,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    isSynced: isSynced ?? this.isSynced,
    exerciseType: exerciseType.present ? exerciseType.value : this.exerciseType,
  );
  GuestProgress copyWithCompanion(GuestProgressTableCompanion data) {
    return GuestProgress(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      score: data.score.present ? data.score.value : this.score,
      status: data.status.present ? data.status.value : this.status,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
      exerciseType: data.exerciseType.present
          ? data.exerciseType.value
          : this.exerciseType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GuestProgress(')
          ..write('exerciseId: $exerciseId, ')
          ..write('lessonId: $lessonId, ')
          ..write('score: $score, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('exerciseType: $exerciseType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    exerciseId,
    lessonId,
    score,
    status,
    completedAt,
    isSynced,
    exerciseType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GuestProgress &&
          other.exerciseId == this.exerciseId &&
          other.lessonId == this.lessonId &&
          other.score == this.score &&
          other.status == this.status &&
          other.completedAt == this.completedAt &&
          other.isSynced == this.isSynced &&
          other.exerciseType == this.exerciseType);
}

class GuestProgressTableCompanion extends UpdateCompanion<GuestProgress> {
  final Value<String> exerciseId;
  final Value<int?> lessonId;
  final Value<int?> score;
  final Value<String> status;
  final Value<DateTime?> completedAt;
  final Value<bool> isSynced;
  final Value<String?> exerciseType;
  final Value<int> rowid;
  const GuestProgressTableCompanion({
    this.exerciseId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.score = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.exerciseType = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GuestProgressTableCompanion.insert({
    required String exerciseId,
    this.lessonId = const Value.absent(),
    this.score = const Value.absent(),
    required String status,
    this.completedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.exerciseType = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       status = Value(status);
  static Insertable<GuestProgress> custom({
    Expression<String>? exerciseId,
    Expression<int>? lessonId,
    Expression<int>? score,
    Expression<String>? status,
    Expression<DateTime>? completedAt,
    Expression<bool>? isSynced,
    Expression<String>? exerciseType,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (score != null) 'score': score,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (exerciseType != null) 'exercise_type': exerciseType,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GuestProgressTableCompanion copyWith({
    Value<String>? exerciseId,
    Value<int?>? lessonId,
    Value<int?>? score,
    Value<String>? status,
    Value<DateTime?>? completedAt,
    Value<bool>? isSynced,
    Value<String?>? exerciseType,
    Value<int>? rowid,
  }) {
    return GuestProgressTableCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      lessonId: lessonId ?? this.lessonId,
      score: score ?? this.score,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      isSynced: isSynced ?? this.isSynced,
      exerciseType: exerciseType ?? this.exerciseType,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<int>(lessonId.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (exerciseType.present) {
      map['exercise_type'] = Variable<String>(exerciseType.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GuestProgressTableCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('lessonId: $lessonId, ')
          ..write('score: $score, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('exerciseType: $exerciseType, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GuestProgressTableTable guestProgressTable =
      $GuestProgressTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [guestProgressTable];
}

typedef $$GuestProgressTableTableCreateCompanionBuilder =
    GuestProgressTableCompanion Function({
      required String exerciseId,
      Value<int?> lessonId,
      Value<int?> score,
      required String status,
      Value<DateTime?> completedAt,
      Value<bool> isSynced,
      Value<String?> exerciseType,
      Value<int> rowid,
    });
typedef $$GuestProgressTableTableUpdateCompanionBuilder =
    GuestProgressTableCompanion Function({
      Value<String> exerciseId,
      Value<int?> lessonId,
      Value<int?> score,
      Value<String> status,
      Value<DateTime?> completedAt,
      Value<bool> isSynced,
      Value<String?> exerciseType,
      Value<int> rowid,
    });

class $$GuestProgressTableTableFilterComposer
    extends Composer<_$AppDatabase, $GuestProgressTableTable> {
  $$GuestProgressTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseType => $composableBuilder(
    column: $table.exerciseType,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GuestProgressTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GuestProgressTableTable> {
  $$GuestProgressTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseType => $composableBuilder(
    column: $table.exerciseType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GuestProgressTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GuestProgressTableTable> {
  $$GuestProgressTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  GeneratedColumn<String> get exerciseType => $composableBuilder(
    column: $table.exerciseType,
    builder: (column) => column,
  );
}

class $$GuestProgressTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GuestProgressTableTable,
          GuestProgress,
          $$GuestProgressTableTableFilterComposer,
          $$GuestProgressTableTableOrderingComposer,
          $$GuestProgressTableTableAnnotationComposer,
          $$GuestProgressTableTableCreateCompanionBuilder,
          $$GuestProgressTableTableUpdateCompanionBuilder,
          (
            GuestProgress,
            BaseReferences<
              _$AppDatabase,
              $GuestProgressTableTable,
              GuestProgress
            >,
          ),
          GuestProgress,
          PrefetchHooks Function()
        > {
  $$GuestProgressTableTableTableManager(
    _$AppDatabase db,
    $GuestProgressTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GuestProgressTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GuestProgressTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GuestProgressTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<int?> lessonId = const Value.absent(),
                Value<int?> score = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> exerciseType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GuestProgressTableCompanion(
                exerciseId: exerciseId,
                lessonId: lessonId,
                score: score,
                status: status,
                completedAt: completedAt,
                isSynced: isSynced,
                exerciseType: exerciseType,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                Value<int?> lessonId = const Value.absent(),
                Value<int?> score = const Value.absent(),
                required String status,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<String?> exerciseType = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GuestProgressTableCompanion.insert(
                exerciseId: exerciseId,
                lessonId: lessonId,
                score: score,
                status: status,
                completedAt: completedAt,
                isSynced: isSynced,
                exerciseType: exerciseType,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GuestProgressTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GuestProgressTableTable,
      GuestProgress,
      $$GuestProgressTableTableFilterComposer,
      $$GuestProgressTableTableOrderingComposer,
      $$GuestProgressTableTableAnnotationComposer,
      $$GuestProgressTableTableCreateCompanionBuilder,
      $$GuestProgressTableTableUpdateCompanionBuilder,
      (
        GuestProgress,
        BaseReferences<_$AppDatabase, $GuestProgressTableTable, GuestProgress>,
      ),
      GuestProgress,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GuestProgressTableTableTableManager get guestProgressTable =>
      $$GuestProgressTableTableTableManager(_db, _db.guestProgressTable);
}
