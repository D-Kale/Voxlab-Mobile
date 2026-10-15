import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../shared/widgets/chunky.dart';
import '../../shared/widgets/motion.dart';

class AuthWallScreen extends StatelessWidget {
  const AuthWallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {},
      child: Semantics(
        label: 'Iniciar sesión o crear cuenta para guardar tu progreso',
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  EntranceAnimation(
                    scaleFrom: 0.4,
                    duration: const Duration(milliseconds: 650),
                    child: Bob(
                      amplitude: 6,
                      child: Image.asset(
                        'assets/images/voxi_awake.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '¡Seguí aprendiendo!',
                    style: GoogleFonts.dmSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkBrown,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Creá una cuenta para guardar tu progreso '
                    'y seguir avanzando en tus cursos de oratoria.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkBrownLight,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ChunkyButton(
                    label: 'CREAR CUENTA GRATIS',
                    onPressed: () => context.push(AppRoutes.register),
                    icon: Icons.person_add_rounded,
                  ),
                  const SizedBox(height: 14),
                  ChunkyButton(
                    label: 'YA TENGO CUENTA',
                    onPressed: () => context.push(AppRoutes.login),
                    colors: const ChunkyColors(
                      face: AppColors.surface,
                      lip: AppColors.cardLip,
                      content: AppColors.accentRed,
                      border: AppColors.cardBorder,
                    ),
                    icon: Icons.login_rounded,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Es gratis y te lleva menos de un minuto.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkBrownLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
