import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

Color scoreColor(int percent) {
  if (percent >= 80) {
    return AppColors.success;
  }
  if (percent >= 60) {
    return AppColors.accentRed;
  }
  return AppColors.error;
}

class SkillBar extends StatelessWidget {
  const SkillBar({
    super.key,
    required this.icon,
    required this.label,
    required this.percent,
  });

  final IconData icon;
  final String label;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final color = scoreColor(percent);
    final ratio = (percent.clamp(0, 100) / 100).toDouble();

    return Semantics(
      label: '$label: $percent por ciento',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Semantics(
                excludeSemantics: true,
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 14,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: AppColors.accentRed, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: ratio),
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
                    color: color,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
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