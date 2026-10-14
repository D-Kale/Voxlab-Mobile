import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/storage/secure_storage.dart';
import 'data/local/local_progress_store.dart';
import 'data/remote/services/analyzer_service.dart';
import 'data/repositories/content_repository_impl.dart';
import 'dev/demo_data.dart';
import 'presentation/shared/providers/repository_providers.dart';

/// Offline demo build: fake auth, local fixture content, in-memory storage.
/// Every run is a first launch (welcome, onboarding, register, tour); add
/// `--dart-define=DEMO_SIGNED_IN=true` to start signed in on the map.
/// Run with `flutter run -t lib/main_demo.dart`.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(DemoAuthRepository()),
        secureStorageProvider.overrideWithValue(DemoSecureStorage()),
        contentRepositoryProvider.overrideWithValue(DemoContentRepository()),
        localProgressStoreProvider.overrideWithValue(DemoProgressStore()),
        analyzerServiceProvider.overrideWithValue(DemoAnalyzerService()),
      ],
      child: const VoxlabApp(),
    ),
  );
}
