import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final completedCount = ref.watch(completedExerciseCountProvider);
    final progress = ref.watch(progressNotifierProvider);
    final totalExercises = ref.watch(totalExercisesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Image.asset(
          'assets/images/voxi_logo.png',
          height: 28,
          fit: BoxFit.contain,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.accentRed,
        backgroundColor: Colors.white,
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
              const SizedBox(height: 16),
              XpSection(xp: user.xp),
              const SizedBox(height: 16),
              StatsSection(
                streakDays: user.streakDays,
                completedCount: completedCount,
                totalXp: user.xp,
                totalExercises: totalExercises,
              ),
              const SizedBox(height: 16),
              CompletedExercisesCard(progress: progress),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/voxi_sleeping.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cargando perfil...',
                        style: GoogleFonts.dmSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBrownLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (auth.isAuthenticated)
              _LogoutButton(),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.authWall);
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.error, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.error,
                    offset: Offset(0, 4),
                    blurRadius: 0,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                    const SizedBox(width: 10),
                    Text(
                      'Cerrar sesión',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}