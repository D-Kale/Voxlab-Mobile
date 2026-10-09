import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/user.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.primaryContainer,
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: GoogleFonts.dmSans(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                right: -4,
                child: Image.asset(
                  'assets/images/voxi_awake.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: GoogleFonts.dmSans(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBrown,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBrownLight,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: user.role == 'admin'
                  ? AppColors.accentRedContainer
                  : AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: user.role == 'admin' ? AppColors.accentRed : AppColors.primary,
                width: 2,
              ),
            ),
            child: Text(
              user.role == 'admin' ? 'Admin' : 'Estudiante',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: user.role == 'admin' ? AppColors.accentRed : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}