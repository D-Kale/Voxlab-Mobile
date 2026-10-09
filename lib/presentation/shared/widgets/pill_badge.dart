import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import 'voxi_state.dart';

enum PillBadgeStyle { streak, xp }

class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.icon,
    required this.label,
    required this.style,
    this.showVoxi = false,
    this.voxiState = VoxiState.awake,
  });

  final IconData icon;
  final String label;
  final PillBadgeStyle style;
  final bool showVoxi;
  final VoxiState voxiState;

  Color get _accent => style == PillBadgeStyle.streak
      ? AppColors.accentRed
      : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final voxiAsset = voxiState == VoxiState.awake
        ? 'assets/images/voxi_awake.png'
        : 'assets/images/voxi_sleeping.png';

    return Semantics(
      label: '$label puntos',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _accent, width: 3),
          boxShadow: [
            BoxShadow(
              color: _accent,
              offset: const Offset(0, 4),
              blurRadius: 0,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: _accent.withValues(alpha: 0.2),
              offset: const Offset(0, 2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showVoxi) ...[
              Image.asset(
                voxiAsset,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 6),
            ],
            Semantics(
              excludeSemantics: true,
              child: Icon(icon, size: 16, color: _accent),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBrown,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}