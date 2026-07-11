import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({
    super.key,
    required this.totalXp,
    required this.streakDays,
    required this.completedCount,
    required this.totalExercises,
  });

  final int totalXp;
  final int streakDays;
  final int completedCount;
  final int totalExercises;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.auto_awesome,
            label: 'XP Total',
            value: '$totalXp',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.local_fire_department,
            label: 'Racha',
            value: '$streakDays días',
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.check_circle,
            label: 'Completados',
            value: '$completedCount',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Semantics(
              excludeSemantics: true,
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
