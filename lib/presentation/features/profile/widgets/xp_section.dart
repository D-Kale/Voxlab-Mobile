import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/xp_bar.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/voxi_state.dart';

class XpSection extends StatelessWidget {
  const XpSection({super.key, required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
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
        children: [
          SectionHeader(
            title: 'Experiencia',
            icon: Icons.auto_awesome_rounded,
            showVoxi: true,
            voxiState: VoxiState.awake,
          ),
          const SizedBox(height: 12),
          XpBar(xp: xp),
        ],
      ),
    );
  }
}