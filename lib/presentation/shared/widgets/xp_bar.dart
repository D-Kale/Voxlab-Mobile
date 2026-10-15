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
                child: Icon(Icons.bolt_rounded, size: 18, color: AppColors.primary),
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
              color: AppColors.idleFace,
              borderRadius: BorderRadius.circular(100),
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
                // Duolingo-style fill with a glossy stripe on top.
                child: Container(
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.fromLTRB(8, 3, 8, 0),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(100),
                    ),
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