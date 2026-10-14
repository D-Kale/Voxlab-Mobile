import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/storage/secure_storage.dart';
import 'data/local/local_progress_store.dart';
import 'data/repositories/content_repository_impl.dart';
import 'dev/demo_data.dart';
import 'presentation/shared/providers/repository_providers.dart';

/// Offline demo build: signed-in user, local fixture content, in-memory
/// progress. Run with `flutter run -t lib/main_demo.dart`.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(DemoAuthRepository()),
        secureStorageProvider.overrideWithValue(DemoSecureStorage()),
        contentRepositoryProvider.overrideWithValue(DemoContentRepository()),
        localProgressStoreProvider.overrideWithValue(DemoProgressStore()),
      ],
      child: const VoxlabApp(),
    ),
  );
}
