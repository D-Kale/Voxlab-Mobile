import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import 'widgets/leaderboard_section.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/user_header_card.dart';
import 'widgets/weekly_chart.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final progress = ref.watch(progressNotifierProvider);
    final userXp = auth.user?.xp ?? 0;

    final leaderboard = _buildLeaderboard(auth.user?.name ?? 'Vos', userXp);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Voxlab'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
            onPressed: () => context.go(AppRoutes.profile),
          ),
        ],
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
            UserHeaderCard(auth: auth, totalXp: userXp),
            const SizedBox(height: 20),
            WeeklyChart(progress: progress),
            const SizedBox(height: 20),
            const Text(
              'Acceso rápido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: QuickActionCard(
                    icon: Icons.map_outlined,
                    title: 'Mapa de rutas',
                    subtitle: 'Seguí tu progreso',
                    color: AppColors.primary,
                    onTap: () => context.go(AppRoutes.map),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: QuickActionCard(
                    icon: Icons.person_outline,
                    title: 'Mi perfil',
                    subtitle: 'Estadísticas y logros',
                    color: AppColors.secondary,
                    onTap: () => context.go(AppRoutes.profile),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LeaderboardSection(
              entries: leaderboard,
              currentUserXp: userXp,
            ),
          ],
        ),
      ),
    );
  }

  List<LeaderboardEntry> _buildLeaderboard(String userName, int userXp) {
    return [
      const LeaderboardEntry(rank: 1, name: 'Axel', xp: 2840),
      const LeaderboardEntry(rank: 2, name: 'Martina', xp: 2100),
      const LeaderboardEntry(rank: 3, name: 'Tomás', xp: 1950),
      LeaderboardEntry(rank: 4, name: userName, xp: userXp, isCurrentUser: true),
      const LeaderboardEntry(rank: 5, name: 'Camila', xp: 1200),
    ];
  }
}
