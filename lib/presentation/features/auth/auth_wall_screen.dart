import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';

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
                  Image.asset(
                    'assets/images/voxi_awake.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
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
                  _VoxLabButton(
                    label: 'Crear cuenta gratis',
                    onPressed: () => context.pushReplacement(AppRoutes.register),
                    color: AppColors.accentRed,
                    icon: Icons.person_add_rounded,
                  ),
                  const SizedBox(height: 16),
                  _VoxLabButton(
                    label: 'Ya tengo cuenta',
                    onPressed: () => context.pushReplacement(AppRoutes.login),
                    color: Colors.white,
                    borderColor: AppColors.accentRed,
                    textColor: AppColors.accentRed,
                    icon: Icons.login_rounded,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tu progreso actual se guardará automáticamente',
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

class _VoxLabButton extends StatelessWidget {
  const _VoxLabButton({
    required this.label,
    required this.onPressed,
    required this.color,
    this.borderColor,
    this.textColor,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final Color? borderColor;
  final Color? textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? color;
    final effectiveTextColor = textColor ?? Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: effectiveBorderColor, width: 3.5),
            boxShadow: [
              BoxShadow(
                color: effectiveBorderColor,
                offset: const Offset(0, 5),
                blurRadius: 0,
                spreadRadius: 0,
              ),
              BoxShadow(
                color: effectiveBorderColor.withValues(alpha: 0.2),
                offset: const Offset(0, 2),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: effectiveTextColor),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: effectiveTextColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}