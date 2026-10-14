import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/audio/sound_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import '../../shared/widgets/chunky.dart';
import '../../shared/widgets/motion.dart';
import '../../shared/widgets/tab_header.dart';
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
    final totalXp = ref.watch(totalXpStateProvider);
    final progress = ref.watch(progressNotifierProvider);
    final totalExercises = ref.watch(totalExercisesProvider);

    final sections = <Widget>[
      if (user != null) ...[
        ProfileHeader(user: user),
        XpSection(xp: totalXp),
        StatsSection(
          streakDays: user.streakDays,
          completedCount: completedCount,
          totalXp: totalXp,
          pendingCount: (totalExercises - completedCount).clamp(0, 1 << 30),
        ),
        CompletedExercisesCard(progress: progress),
        const _SettingsCard(),
      ] else
        const _LoadingProfile(),
      if (auth.isAuthenticated) const _LogoutButton(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accentRed,
          backgroundColor: Colors.white,
          onRefresh: () async {
            await ref.read(authProvider.notifier).refreshUser();
            ref.invalidate(tracksProvider);
            await ref.read(progressNotifierProvider.notifier).reload();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const TabHeader(title: 'Perfil'),
              for (var i = 0; i < sections.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: EntranceAnimation(
                    delay: EntranceAnimation.stagger(i),
                    child: sections[i],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends ConsumerWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundOn = ref.watch(soundEnabledProvider);
    return ChunkyCard(
      padding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
      child: Row(
        children: [
          Icon(
            soundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            color: AppColors.darkBrown,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Efectos de sonido',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBrown,
              ),
            ),
          ),
          Switch(
            value: soundOn,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.success,
            onChanged: (value) {
              ref.read(soundEnabledProvider.notifier).set(value);
              if (value) playSfx(context, Sfx.tap);
            },
          ),
        ],
      ),
    );
  }
}

class _LoadingProfile extends StatelessWidget {
  const _LoadingProfile();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ChunkyButton(
        label: 'CERRAR SESIÓN',
        icon: Icons.logout_rounded,
        colors: const ChunkyColors(
          face: AppColors.surface,
          lip: AppColors.cardLip,
          content: AppColors.accentRed,
          border: AppColors.cardBorder,
        ),
        onPressed: () async {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) context.go(AppRoutes.authWall);
        },
      ),
    );
  }
}
