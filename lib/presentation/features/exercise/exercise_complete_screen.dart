import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../domain/models/session_result.dart';
import '../../shared/widgets/insight_card.dart';
import '../../shared/widgets/pill_badge.dart';
import '../../shared/widgets/score_ring.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/skill_bar.dart';
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

    final result = SessionResultBuilder.fromScore(score);
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isReview ? 'Repaso completado' : 'Resultados de la Sesión',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Column(
              children: [
                Semantics(
                  excludeSemantics: true,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_outlined,
                      size: 40,
                      color: AppColors.success,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '¡Gran esfuerzo!',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Acá tenés el desglose de tu presentación.',
                  style: theme.textTheme.bodyMedium,
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
                      icon: Icons.auto_awesome,
                      label: '+$score XP',
                      style: PillBadgeStyle.xp,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (name.isNotEmpty)
                    PillBadge(
                      icon: exerciseTypeIcon(type),
                      label: formatExerciseType(type),
                      style: PillBadgeStyle.streak,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            Center(
              child: ScoreRing(
                score: result.overall,
                size: 190,
                centerLabel: 'DE 100',
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Nivel: ${result.level}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SectionHeader(title: 'Desglose de Habilidades'),
            const SizedBox(height: 12),
            for (final skill in result.skills)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: SkillBar(
                  icon: _skillIcon(skill.name),
                  label: skill.name,
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
                        ? Icons.check_circle
                        : Icons.arrow_upward,
                    text: tip.text,
                  ),
              ],
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

  IconData _skillIcon(String skill) {
    return switch (skill) {
      'Dicción' => Icons.record_voice_over_outlined,
      'Postura' => Icons.accessibility_new_outlined,
      'Confianza' => Icons.psychology_outlined,
      'Contacto Visual' => Icons.visibility_outlined,
      _ => Icons.star_outline,
    };
  }
}
