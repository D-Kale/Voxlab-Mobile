import 'package:drift/drift.dart';

@DataClassName('GuestProgress')
class GuestProgressTable extends Table {
  TextColumn get exerciseId => text()();
  IntColumn get lessonId => integer().nullable()();
  IntColumn get score => integer().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  TextColumn get exerciseType => text().nullable()();

  @override
  Set<Column> get primaryKey => {exerciseId};
}
