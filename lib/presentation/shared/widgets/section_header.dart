import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    this.icon,
    required this.title,
  });

  final IconData? icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return icon != null
        ? Row(
            children: [
              Semantics(
                excludeSemantics: true,
                child: Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          )
        : Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          );
  }
}
