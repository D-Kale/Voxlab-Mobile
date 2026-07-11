import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/stat_tile.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({
    super.key,
    required this.streakDays,
    required this.completedCount,
    required this.totalXp,
    required this.totalExercises,
  });

  final int streakDays;
  final int completedCount;
  final int totalXp;
  final int totalExercises;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Estadísticas'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    icon: Icons.local_fire_department,
                    label: 'Racha',
                    value: '$streakDays días',
                    color: AppColors.secondary,
                  ),
                ),
                Expanded(
                  child: StatTile(
                    icon: Icons.star,
                    label: 'Rol',
                    value: 'Estudiante',
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.surfaceContainerHigh),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    icon: Icons.check_circle,
                    label: 'Completados',
                    value: '$completedCount',
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: StatTile(
                    icon: Icons.auto_awesome,
                    label: 'XP Total',
                    value: '$totalXp',
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: StatTile(
                    icon: Icons.pending,
                    label: 'Pendientes',
                    value: '$totalExercises',
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
