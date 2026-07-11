import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class XpBar extends StatelessWidget {
  const XpBar({super.key, required this.xp, this.maxXp = 100});

  final int xp;
  final int maxXp;

  @override
  Widget build(BuildContext context) {
    final progress = (xp / maxXp).clamp(0.0, 1.0);

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
                child: Icon(Icons.auto_awesome, size: 14, color: AppColors.secondary),
              ),
              const SizedBox(width: 4),
              Text(
                '$xp XP',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
