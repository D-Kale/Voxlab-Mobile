import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import 'lesson_widgets.dart';

Color scoreColor(int percent) {
  if (percent >= 80) {
    return AppColors.success;
  }
  if (percent >= 60) {
    return AppColors.primary;
  }
  return AppColors.accentRed;
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
          LessonProgressBar(value: ratio, color: color, height: 14),
        ],
      ),
    );
  }
}