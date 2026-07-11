import 'package:drift/drift.dart';
import 'tables/guest_progress_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [GuestProgressTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from == 1) {
          await m.deleteTable('guest_progress');
          await m.createTable(guestProgressTable);
        }
      },
    );
  }
}
