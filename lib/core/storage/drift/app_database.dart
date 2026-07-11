import 'package:drift/drift.dart';
import 'tables/guest_progress_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [GuestProgressTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 3) {
          // Recrear tabla para garantizar schema correcto
          await m.deleteTable('guest_progress');
          await m.deleteTable('guest_progress_table');
          await m.createTable(guestProgressTable);
        }
      },
    );
  }
}
