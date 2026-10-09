import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import 'voxi_state.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    this.icon,
    required this.title,
    this.action,
    this.showVoxi = false,
    this.voxiState = VoxiState.awake,
  });

  final IconData? icon;
  final String title;
  final Widget? action;
  final bool showVoxi;
  final VoxiState voxiState;

  @override
  Widget build(BuildContext context) {
    final voxiAsset = voxiState == VoxiState.awake
        ? 'assets/images/voxi_awake.png'
        : 'assets/images/voxi_sleeping.png';

    return Row(
      children: [
        if (showVoxi) ...[
          Image.asset(
            voxiAsset,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
        ],
        if (icon != null) ...[
          Semantics(
            excludeSemantics: true,
            child: Icon(icon, size: 20, color: AppColors.accentRed),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBrown,
              height: 1.2,
            ),
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}