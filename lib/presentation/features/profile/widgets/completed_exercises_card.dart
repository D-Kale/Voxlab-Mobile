import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/voxi_state.dart';
import '../../../../domain/models/progress.dart';
import '../../../shared/providers/content_provider.dart';

class CompletedExercisesCard extends ConsumerWidget {
  const CompletedExercisesCard({super.key, required this.progress});

  final List<Progress> progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameMap = ref.watch(exerciseNameMapProvider);

    final completed = progress
        .expand((p) => p.completedExercises)
        .toList();

    if (completed.isEmpty) return const SizedBox.shrink();

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
            title: 'Ejercicios completados',
            icon: Icons.checklist_rounded,
            showVoxi: true,
            voxiState: VoxiState.awake,
          ),
          const SizedBox(height: 12),
          ...completed.map((ex) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.successContainer,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.success, width: 2),
                      ),
                      child: Center(
                        child: Icon(Icons.check_rounded, size: 18, color: AppColors.success),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        nameMap[ex.exerciseId] ?? ex.exerciseId,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBrown,
                        ),
                      ),
                    ),
                    if (ex.score > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.primary, width: 2),
                        ),
                        child: Text(
                          '+${ex.score} XP',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}