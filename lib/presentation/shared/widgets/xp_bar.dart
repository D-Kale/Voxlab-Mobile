import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

class XpBar extends StatelessWidget {
  const XpBar({super.key, required this.xp, this.maxXp});

  final int xp;

  /// Explicit bar target; when null it targets the next 100 XP milestone, so
  /// a user above 100 XP never sees the nonsensical "255 XP de 100".
  final int? maxXp;

  static int _nextMilestone(int xp) {
    if (xp < 100) return 100;
    return ((xp ~/ 100) + 1) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final target = maxXp ?? _nextMilestone(xp);
    final progress = (xp / target).clamp(0.0, 1.0);

    return Semantics(
      label: 'Experiencia: $xp puntos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Semantics(
                excludeSemantics: true,
                child: Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.accentRed),
              ),
              const SizedBox(width: 6),
              Text(
                '$xp XP',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBrown,
                ),
              ),
              const Spacer(),
              Text(
                'de $target XP',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBrownLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.accentRed, width: 2.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    widthFactor: value,
                    alignment: Alignment.centerLeft,
                    child: child,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}