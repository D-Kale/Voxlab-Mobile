import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

enum PillBadgeStyle { streak, xp }

class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.style,
  });

  final IconData icon;
  final String label;
  final PillBadgeStyle style;

  Color get _accent => style == PillBadgeStyle.streak
      ? AppColors.tertiary
      : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label puntos',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _accent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              excludeSemantics: true,
              child: Icon(icon, size: 16, color: _accent),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
