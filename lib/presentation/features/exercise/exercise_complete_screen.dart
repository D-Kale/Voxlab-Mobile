import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';

class ExerciseCompleteScreen extends ConsumerWidget {
  const ExerciseCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final score = (extra?['score'] as int?) ?? 0;
    final type = (extra?['type'] as String?) ?? '';
    final name = (extra?['name'] as String?) ?? '';
    final isReview = (extra?['isReview'] as bool?) ?? false;
    final accumulatedXp = (extra?['accumulatedXp'] as int?) ?? score;
    final isQuiz = type == 'quiz';

    Future<void> refreshAndGo() async {
      await ref.read(authProvider.notifier).refreshUser();
      ref.invalidate(tracksProvider);
      await ref.read(progressNotifierProvider.notifier).reload();
      if (context.mounted) context.go(AppRoutes.map);
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) refreshAndGo();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Semantics(
                  excludeSemantics: true,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      isQuiz ? Icons.emoji_events : Icons.menu_book,
                      size: 48,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isReview
                      ? '\u00a1Repaso completado!'
                      : (isQuiz ? '\u00a1Quiz completado!' : '\u00a1Lectura completada!'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                if (isReview)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Ya hab\u00edas hecho este ejercicio. No se sumaron puntos extra.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (!isReview && name.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _XpCard(
                        label: 'Ganados',
                        xp: isReview ? 0 : score,
                        color: AppColors.secondary,
                        icon: Icons.star,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _XpCard(
                        label: 'Acumulados',
                        xp: accumulatedXp,
                        color: AppColors.primary,
                        icon: Icons.auto_awesome,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => refreshAndGo(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Seguir aprendiendo'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => refreshAndGo(),
                    child: const Text('Volver al mapa'),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _XpCard extends StatelessWidget {
  const _XpCard({
    required this.label,
    required this.xp,
    required this.color,
    required this.icon,
  });

  final String label;
  final int xp;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Semantics(
            excludeSemantics: true,
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '+$xp XP',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
