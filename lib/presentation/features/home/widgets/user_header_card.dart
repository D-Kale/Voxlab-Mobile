import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/routes.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/streak_indicator.dart';
import '../../../shared/widgets/xp_bar.dart';

class UserHeaderCard extends StatelessWidget {
  const UserHeaderCard({super.key, required this.auth, required this.totalXp});

  final AuthState auth;
  final int totalXp;

  @override
  Widget build(BuildContext context) {
    final user = auth.user;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Semantics(
                  label: user != null ? 'Avatar de ${user.name}' : 'Avatar de invitado',
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: user != null
                        ? AppColors.primary.withValues(alpha: 0.2)
                        : AppColors.surfaceContainerHigh,
                    child: user != null
                        ? Text(
                            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : Semantics(
                            excludeSemantics: true,
                            child: Icon(
                              Icons.person_outline,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Modo invitado',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (user != null)
                        StreakIndicator(days: user.streakDays, size: 'medium')
                      else
                        const Text(
                          'Iniciá sesión para guardar tu progreso',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (user == null)
                  Semantics(
                    label: 'Iniciar sesión',
                    child: TextButton(
                      onPressed: () => context.push(AppRoutes.authWall),
                      child: const Text('Ingresar'),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            XpBar(xp: user?.xp ?? totalXp),
          ],
        ),
      ),
    );
  }
}
