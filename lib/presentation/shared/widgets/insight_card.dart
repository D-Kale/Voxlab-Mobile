import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import 'voxi_state.dart';

class InsightItem {
  const InsightItem({
    required this.icon,
    required this.text,
    this.highlight = false,
  });

  final IconData icon;
  final String text;
  final bool highlight;
}

class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.title,
    required this.items,
    this.showVoxi = true,
    this.voxiState = VoxiState.awake,
  });

  final String title;
  final List<InsightItem> items;
  final bool showVoxi;
  final VoxiState voxiState;

  @override
  Widget build(BuildContext context) {
    final voxiAsset = voxiState == VoxiState.awake
        ? 'assets/images/voxi_awake.png'
        : 'assets/images/voxi_sleeping.png';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentRed, width: 3.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.accentRed,
            offset: Offset(0, 6),
            blurRadius: 0,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x33D93B27),
            offset: Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with Voxi mascot + title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showVoxi) ...[
                Image.asset(
                  voxiAsset,
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBrown,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Insight items
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            _ItemRow(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item});

  final InsightItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: item.highlight
                ? AppColors.accentRed.withValues(alpha: 0.12)
                : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(
              color: item.highlight ? AppColors.accentRed : AppColors.outline,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            item.icon,
            size: 16,
            color: item.highlight ? AppColors.accentRed : AppColors.darkBrownLight,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            item.text,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: item.highlight ? FontWeight.w700 : FontWeight.w500,
              color: item.highlight ? AppColors.darkBrown : AppColors.darkBrownLight,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}