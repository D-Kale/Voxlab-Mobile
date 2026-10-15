import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_theme.dart';
import 'core/router/app_router.dart';

class VoxlabApp extends ConsumerWidget {
  const VoxlabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Voxlab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      // On a desktop browser the app keeps its phone layout, centered, so
      // buttons and the map do not stretch across the whole window.
      builder: (context, child) => ColoredBox(
        color: AppColors.primaryDark,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxAppWidth),
            child: child,
          ),
        ),
      ),
    );
  }
}

const double _maxAppWidth = 480;
