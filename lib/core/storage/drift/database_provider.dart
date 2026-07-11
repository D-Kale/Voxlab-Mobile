import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'app_database.dart';

Future<AppDatabase> buildDatabase() async {
  final dir = await getApplicationDocumentsDirectory();
  await dir.create(recursive: true);
  final file = File(p.join(dir.path, 'voxlab.db'));
  return AppDatabase(NativeDatabase(file));
}

final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('Must override databaseProvider in main()');
});
