import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/constants/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kReleaseMode) {
    FlutterError.onError = (details) {
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };
    ErrorWidget.builder = (_) => const _FallbackErrorWidget();
  }

  runApp(
    const ProviderScope(
      child: VoxlabApp(),
    ),
  );
}

class _FallbackErrorWidget extends StatelessWidget {
  const _FallbackErrorWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      color: AppColors.background,
      child: const Icon(
        Icons.error_outline_rounded,
        color: AppColors.error,
        size: 32,
      ),
    );
  }
}
