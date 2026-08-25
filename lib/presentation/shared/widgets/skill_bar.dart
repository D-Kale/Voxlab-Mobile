import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

Color scoreColor(int percent) {
  if (percent >= 80) {
    return AppColors.secondary;
  }
  if (percent >= 60) {
    return AppColors.tertiary;
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
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 10,
              width: double.infinity,
              color: AppColors.surfaceContainerHigh,
              alignment: Alignment.centerLeft,
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
                child: ColoredBox(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
