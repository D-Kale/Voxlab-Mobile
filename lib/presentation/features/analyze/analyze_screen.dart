import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../domain/models/progress.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import '../../shared/widgets/pill_badge.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/voxi_state.dart';
import '../../../utils/exercise_name_utils.dart';
import 'widgets/weekly_chart.dart';

class AnalyzeScreen extends ConsumerWidget {
  const AnalyzeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(progressNotifierProvider);
    final totalXp = ref.watch(totalXpStateProvider);
    final completedCount = ref.watch(completedExerciseCountProvider);
    final nameMap = ref.watch(exerciseNameMapProvider);
    final recent = entries.reversed.take(10).toList();

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
      body: entries.isEmpty
          ? _EmptyAnalysis(onGoPractice: () => context.go(AppRoutes.practice))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Voxi greeting header
                Container(
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
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/voxi_awake.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tu Progreso',
                              style: GoogleFonts.dmSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppColors.darkBrown,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Seguí así, cada ejercicio cuenta.',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.darkBrownLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Stats badges
                Row(
                  children: [
                    Expanded(
                      child: PillBadge(
                        icon: Icons.auto_awesome_rounded,
                        label: '$totalXp XP',
                        style: PillBadgeStyle.xp,
                        showVoxi: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PillBadge(
                        icon: Icons.check_circle_rounded,
                        label: '$completedCount completados',
                        style: PillBadgeStyle.streak,
                        showVoxi: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Weekly chart
                _ChartCard(chart: const WeeklyChart()),
                const SizedBox(height: 24),
                // History
                SectionHeader(
                  title: 'Historial reciente',
                  icon: Icons.history_rounded,
                  showVoxi: true,
                  voxiState: VoxiState.awake,
                ),
                const SizedBox(height: 8),
                for (final entry in recent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _HistoryTile(entry: entry, nameMap: nameMap),
                  ),
              ],
            ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.chart});

  final Widget chart;

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
      child: chart,
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.nameMap});

  final Progress entry;
  final Map<String, String> nameMap;

  @override
  Widget build(BuildContext context) {
    final name = resolveExerciseName(
      entry.exerciseId,
      '',
      nameMap,
    );
    final completedAt = entry.completedAt;
    final dateLabel = completedAt == null
        ? ''
        : '${completedAt.day}/${completedAt.month} '
            '${completedAt.hour.toString().padLeft(2, '0')}:'
            '${completedAt.minute.toString().padLeft(2, '0')}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentRed, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentRed.withValues(alpha: 0.2),
            offset: const Offset(0, 3),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.successContainer,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.success, width: 2),
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 22,
            ),
          ),
        ),
        title: Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBrown,
          ),
        ),
        subtitle: dateLabel.isEmpty
            ? null
            : Text(
                dateLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBrownLight,
                ),
              ),
        trailing: Text(
          '+${entry.score ?? 0} XP',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _EmptyAnalysis extends StatelessWidget {
  const _EmptyAnalysis({required this.onGoPractice});

  final VoidCallback onGoPractice;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/voxi_sleeping.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              'Todavía no hay datos',
              style: GoogleFonts.dmSans(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.darkBrown,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Completá tu primer ejercicio y acá vas a ver '
              'tu progreso semanal y tu historial.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.darkBrownLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _VoxLabButton(
              label: 'Ir a practicar',
              onPressed: onGoPractice,
              color: AppColors.accentRed,
              icon: Icons.fitness_center_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _VoxLabButton extends StatelessWidget {
  const _VoxLabButton({
    required this.label,
    required this.onPressed,
    required this.color,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color, width: 3.5),
            boxShadow: [
              BoxShadow(
                color: color,
                offset: const Offset(0, 5),
                blurRadius: 0,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: Colors.white),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}