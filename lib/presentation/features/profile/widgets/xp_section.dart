import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/chunky.dart';
import '../../../shared/widgets/xp_bar.dart';

/// Level card: every 100 XP is a level.
class XpSection extends StatelessWidget {
  const XpSection({super.key, required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    final level = xp ~/ 100 + 1;
    return ChunkyCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.goldDark, offset: Offset(0, 4)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'NIV',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: AppColors.darkBrown,
                  ),
                ),
                Text(
                  '$level',
                  style: GoogleFonts.dmSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkBrown,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Experiencia',
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 8),
                XpBar(xp: xp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
