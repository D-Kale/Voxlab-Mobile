import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import 'widgets/completed_exercises_card.dart';
import 'widgets/profile_header.dart';
import 'widgets/stats_section.dart';
import 'widgets/xp_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;
    final totalXp = ref.watch(totalXpStateProvider);
    final completedCount = ref.watch(completedExerciseCountProvider);
    final progress = ref.watch(progressNotifierProvider);
    final totalExercises = ref.watch(totalExercisesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(authProvider.notifier).refreshUser();
          ref.invalidate(tracksProvider);
          await ref.read(progressNotifierProvider.notifier).reload();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (user != null) ...[
              ProfileHeader(user: user),
              const SizedBox(height: 20),
              XpSection(xp: totalXp),
              const SizedBox(height: 20),
              StatsSection(
                streakDays: user.streakDays,
                completedCount: completedCount,
                totalXp: totalXp,
                totalExercises: totalExercises,
              ),
              const SizedBox(height: 20),
              CompletedExercisesCard(progress: progress),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (auth.isAuthenticated)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go(AppRoutes.authWall);
                },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  child: const Text('Cerrar sesión'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
