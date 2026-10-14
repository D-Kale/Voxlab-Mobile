import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../domain/models/session_result.dart';
import '../../shared/widgets/chunky.dart';
import '../../shared/widgets/lesson_widgets.dart';
import '../../shared/widgets/motion.dart';
import '../../shared/widgets/skill_bar.dart';

class ExerciseCompleteScreen extends StatefulWidget {
  const ExerciseCompleteScreen({super.key});

  @override
  State<ExerciseCompleteScreen> createState() => _ExerciseCompleteScreenState();
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
    final isReview = (extra?['isReview'] as bool?) ?? false;
    final aiResult = extra?['sessionResult'] as SessionResult?;
    final result = aiResult ?? SessionResultBuilder.fromScore(score);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) goBack();
      },
      child: Scaffold(
        backgroundColor: lessonBackground,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      children: [
                        _Hero(isReview: isReview, level: result.level),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: EntranceAnimation(
                                delay: const Duration(milliseconds: 250),
                                child: _ResultStat(
                                  label: 'XP GANADA',
                                  icon: Icons.bolt_rounded,
                                  value: score,
                                  prefix: '+',
                                  color: AppColors.gold,
                                  ink: AppColors.goldDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: EntranceAnimation(
                                delay: const Duration(milliseconds: 350),
                                child: _ResultStat(
                                  label: 'PUNTAJE',
                                  icon: Icons.track_changes_rounded,
                                  value: result.overall,
                                  suffix: '%',
                                  color: AppColors.success,
                                  ink: AppColors.successDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (result.readabilityLabel != null ||
                            result.fillerWords != null) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: [
                              if (result.readabilityLabel != null)
                                ChunkyTag(
                                  label: result.readabilityLabel!,
                                  icon: Icons.menu_book_rounded,
                                  color: AppColors.onPrimaryContainer,
                                ),
                              if (result.fillerWords != null)
                                ChunkyTag(
                                  label: '${result.fillerWords} muletillas',
                                  icon: Icons.graphic_eq_rounded,
                                  color: AppColors.accentRedDark,
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 22),
                        EntranceAnimation(
                          delay: const Duration(milliseconds: 450),
                          child: ChunkyCard(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const _CardTitle('Desglose de habilidades'),
                                const SizedBox(height: 14),
                                for (final skill in result.skills)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: SkillBar(
                                      icon: skill.icon,
                                      label: skill.label,
                                      percent: skill.percent,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (result.tips.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          EntranceAnimation(
                            delay: const Duration(milliseconds: 550),
                            child: ChunkyCard(
                              padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _CardTitle('Consejos de la IA'),
                                  const SizedBox(height: 12),
                                  for (final tip in result.tips)
                                    _TipRow(tip: tip),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: ChunkyButton(
                      label: 'CONTINUAR',
                      colors: ChunkyColors.green,
                      onPressed: goBack,
                    ),
                  ),
                ],
              ),
              if (!isReview)
                const Positioned.fill(
                  child: ConfettiBurst(
                    colors: [
                      AppColors.accentRed,
                      AppColors.success,
                      AppColors.gold,
                      AppColors.primary,
                      AppColors.darkBrown,
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.isReview, required this.level});

  final bool isReview;
  final String level;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EntranceAnimation(
          scaleFrom: 0.3,
          offsetY: 30,
          duration: const Duration(milliseconds: 650),
          child: Bob(
            amplitude: 6,
            child: Image.asset(
              'assets/images/voxi_awake.png',
              width: 140,
              height: 140,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 14),
        EntranceAnimation(
          delay: const Duration(milliseconds: 120),
          child: Text(
            isReview ? '¡Repaso completado!' : '¡Ejercicio completado!',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryDark,
              height: 1.15,
            ),
          ),
        ),
        const SizedBox(height: 6),
        EntranceAnimation(
          delay: const Duration(milliseconds: 180),
          child: Text(
            level,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBrownLight,
            ),
          ),
        ),
      ],
    );
  }
}

/// Duolingo-style result card: colored header label, white body with an
/// icon and a number that counts up.
class _ResultStat extends StatelessWidget {
  const _ResultStat({
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
    required this.ink,
    this.prefix = '',
    this.suffix = '',
  });

  final String label;
  final IconData icon;
  final int value;
  final Color color;
  final Color ink;
  final String prefix;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $prefix$value$suffix',
      excludeSemantics: true,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: ink, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(3),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              height: 58,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: ink, size: 26),
                  const SizedBox(width: 6),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: value),
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => Text(
                      '$prefix$v$suffix',
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: AppColors.darkBrown,
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.tip});

  final SessionTip tip;

  @override
  Widget build(BuildContext context) {
    final color = tip.isPositive ? AppColors.success : AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              tip.isPositive ? Icons.check_rounded : Icons.trending_up_rounded,
              size: 18,
              color: tip.isPositive
                  ? AppColors.onSuccessContainer
                  : AppColors.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip.text,
              style: GoogleFonts.dmSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBrown,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
