import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../domain/models/session_result.dart';
import '../../shared/widgets/insight_card.dart';
import '../../shared/widgets/pill_badge.dart';
import '../../shared/widgets/score_ring.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/skill_bar.dart';
import '../../shared/widgets/voxi_state.dart';
import '../../../utils/exercise_name_utils.dart';

class ExerciseCompleteScreen extends StatefulWidget {
  const ExerciseCompleteScreen({super.key});

  @override
  State<ExerciseCompleteScreen> createState() =>
      _ExerciseCompleteScreenState();
}

class _ExerciseCompleteScreenState extends State<ExerciseCompleteScreen> {
  bool _isNavigating = false;

  void goBack() {
    if (_isNavigating) return;
    _isNavigating = true;
    if (mounted) context.go(AppRoutes.map);
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
    final score = (extra?['score'] as int?) ?? 0;
    final type = (extra?['type'] as String?) ?? '';
    final name = (extra?['name'] as String?) ?? '';
    final isReview = (extra?['isReview'] as bool?) ?? false;
    final aiResult = extra?['sessionResult'] as SessionResult?;
    final result = aiResult ?? SessionResultBuilder.fromScore(score);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goBack();
      },
      child: Scaffold(
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
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Header with Voxi celebration
            Column(
              children: [
                Image.asset(
                  'assets/images/voxi_awake.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                Text(
                  isReview ? '¡Repaso completado!' : '¡Gran esfuerzo!',
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkBrown,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Acá tenés el desglose de tu presentación.',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkBrownLight,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            if (name.isNotEmpty || score > 0) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (score > 0) ...[
                    PillBadge(
                      icon: Icons.auto_awesome_rounded,
                      label: '+$score XP',
                      style: PillBadgeStyle.xp,
                      showVoxi: false,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (name.isNotEmpty)
                    PillBadge(
                      icon: exerciseTypeIcon(type),
                      label: formatExerciseType(type),
                      style: PillBadgeStyle.streak,
                      showVoxi: false,
                    ),
                ],
              ),
            ],
            if (result.readabilityLabel != null ||
                result.fillerWords != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (result.readabilityLabel != null)
                    PillBadge(
                      icon: Icons.menu_book_rounded,
                      label: result.readabilityLabel!,
                      style: PillBadgeStyle.xp,
                      showVoxi: false,
                    ),
                  if (result.readabilityLabel != null &&
                      result.fillerWords != null)
                    const SizedBox(width: 8),
                  if (result.fillerWords != null)
                    PillBadge(
                      icon: Icons.graphic_eq_rounded,
                      label: '${result.fillerWords} muletillas',
                      style: PillBadgeStyle.streak,
                      showVoxi: false,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Center(
              child: ScoreRing(
                score: result.overall,
                size: 200,
                centerLabel: 'DE 100',
                showVoxi: true,
                voxiState: VoxiState.awake,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.accentRed, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.accentRed,
                      offset: Offset(0, 4),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  'Nivel: ${result.level}',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SectionHeader(
              title: 'Desglose de Habilidades',
              icon: Icons.insights_rounded,
              showVoxi: true,
              voxiState: VoxiState.awake,
            ),
            const SizedBox(height: 12),
            for (final skill in result.skills)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SkillBar(
                  icon: skill.icon,
                  label: skill.label,
                  percent: skill.percent,
                ),
              ),
            const SizedBox(height: 16),
            InsightCard(
              title: 'Consejos de la IA',
              items: [
                for (final tip in result.tips)
                  InsightItem(
                    icon: tip.isPositive
                        ? Icons.check_circle_rounded
                        : Icons.arrow_upward_rounded,
                    text: tip.text,
                    highlight: tip.isPositive,
                  ),
              ],
              showVoxi: true,
              voxiState: VoxiState.awake,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: goBack,
                child: const Text('Continuar'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: goBack,
                child: const Text('Volver al mapa'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}