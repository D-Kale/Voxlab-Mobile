import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/storage/drift/database_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await buildDatabase();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const VoxlabApp(),
    ),
  );
}
