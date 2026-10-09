import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/voxi_state.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentRed, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.accentRed,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x33D93B27),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Estadísticas',
            icon: Icons.insights_rounded,
            showVoxi: true,
            voxiState: VoxiState.awake,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Racha',
                  value: '$streakDays días',
                  color: AppColors.accentRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.emoji_events_rounded,
                  label: 'Rol',
                  value: 'Estudiante',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Completados',
                  value: '$completedCount',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.auto_awesome_rounded,
                  label: 'XP Total',
                  value: '$totalXp',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.pending_rounded,
                  label: 'Pendientes',
                  value: '$totalExercises',
                  color: AppColors.accentRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            offset: const Offset(0, 3),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Semantics(
            excludeSemantics: true,
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBrown,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBrownLight,
            ),
          ),
        ],
      ),
    );
  }
}