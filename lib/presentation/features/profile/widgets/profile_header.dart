import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/user.dart';
import '../../../shared/widgets/chunky.dart';

/// Identity card: a red banner with the avatar overlapping it, then name,
/// email and role.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final User user;

  static const double _avatar = 92;
  static const double _banner = 78;

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role == 'admin';
    return ChunkyCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            SizedBox(
              height: _banner + _avatar / 2,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    height: _banner,
                    color: AppColors.accentRed,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      'assets/images/voxi_awake.png',
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: _banner - _avatar / 2,
                    child: Container(
                      width: _avatar,
                      height: _avatar,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 5),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.primaryDark,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: GoogleFonts.dmSans(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                children: [
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkBrown,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBrownLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ChunkyTag(
                    label: isAdmin ? 'Admin' : 'Estudiante',
                    icon: isAdmin ? Icons.shield_rounded : Icons.school_rounded,
                    color: isAdmin
                        ? AppColors.accentRedDark
                        : AppColors.onPrimaryContainer,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
