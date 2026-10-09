import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import 'voxi_state.dart';

enum FeedbackStatus { success, error }

class FeedbackBanner extends StatelessWidget {
  const FeedbackBanner({
    super.key,
    required this.status,
    required this.title,
    this.subtitle,
    this.action,
    this.showVoxi = true,
    this.voxiState = VoxiState.awake,
  });

  final FeedbackStatus status;
  final String title;
  final String? subtitle;
  final Widget? action;
  final bool showVoxi;
  final VoxiState voxiState;

  Color get _backgroundColor =>
      status == FeedbackStatus.success ? AppColors.success : AppColors.error;

  Color get _borderColor =>
      status == FeedbackStatus.success ? AppColors.success : AppColors.error;

  IconData get _iconData =>
      status == FeedbackStatus.success ? Icons.check_circle_rounded : Icons.error_rounded;

  @override
  Widget build(BuildContext context) {
    final voxiAsset = voxiState == VoxiState.awake
        ? 'assets/images/voxi_awake.png'
        : 'assets/images/voxi_sleeping.png';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: _borderColor,
            offset: const Offset(0, 5),
            blurRadius: 0,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: _borderColor.withValues(alpha: 0.2),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showVoxi) ...[
            Image.asset(
              voxiAsset,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
          ],
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _backgroundColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(_iconData, size: 22, color: _backgroundColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBrown,
                    height: 1.3,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkBrownLight,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 12),
            action!,
          ],
        ],
      ),
    );
  }
}