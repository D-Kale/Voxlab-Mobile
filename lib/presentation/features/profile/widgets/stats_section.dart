import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/stat_tile.dart';

class StatsSection extends StatelessWidget {
  const StatsSection({
    super.key,
    required this.streakDays,
    required this.completedCount,
    required this.totalXp,
    required this.pendingCount,
  });

  final int streakDays;
  final int completedCount;
  final int totalXp;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'Estadísticas',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBrown,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.local_fire_department_rounded,
                color: streakDays > 0
                    ? AppColors.accentRed
                    : AppColors.darkBrownLight,
                value: '$streakDays',
                label: streakDays == 1 ? 'Día de racha' : 'Días de racha',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                icon: Icons.bolt_rounded,
                color: AppColors.primary,
                value: '$totalXp',
                label: 'XP total',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.check_circle_rounded,
                color: AppColors.success,
                value: '$completedCount',
                label: 'Completados',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StatTile(
                icon: Icons.hourglass_bottom_rounded,
                color: AppColors.darkBrown,
                value: '$pendingCount',
                label: 'Pendientes',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
