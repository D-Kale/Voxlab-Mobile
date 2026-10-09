import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/widgets/error_view.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final error = await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (error == null && mounted) {
      context.go(AppRoutes.map);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Volver',
          onPressed: () => context.pop(),
        ),
        title: Image.asset(
          'assets/images/voxi_logo.png',
          height: 28,
          fit: BoxFit.contain,
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Voxi greeting
              Row(
                children: [
                  Image.asset(
                    'assets/images/voxi_awake.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido de vuelta',
                          style: GoogleFonts.dmSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkBrown,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ingresá tus datos para continuar',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkBrownLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (authState.error != null) ...[
                ErrorView(error: authState.error!, showVoxi: false),
                const SizedBox(height: 16),
              ],
              _VoxLabTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'tu@email.com',
                prefixIcon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingresá tu email';
                  }
                  final parts = v.split('@');
                  if (parts.length != 2 || !parts.last.contains('.')) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _VoxLabTextField(
                controller: _passwordController,
                label: 'Contraseña',
                hint: '••••••••',
                prefixIcon: Icons.lock_rounded,
                obscureText: _obscurePassword,
                suffixIcon: Semantics(
                  label: _obscurePassword ? 'Mostrar contraseña' : 'Ocultar contraseña',
                  child: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Ingresá tu contraseña';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _VoxLabButton(
                label: authState.isLoading ? 'Ingresando…' : 'Iniciar sesión',
                onPressed: authState.isLoading ? null : _login,
                color: AppColors.accentRed,
                icon: authState.isLoading ? Icons.hourglass_top_rounded : Icons.login_rounded,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    context.pushReplacement(AppRoutes.register);
                  },
                  child: Text(
                    '¿No tenés cuenta? Registrate',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentRed,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoxLabTextField extends StatelessWidget {
  const _VoxLabTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkBrown,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon, color: AppColors.accentRed),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        labelStyle: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.darkBrownLight,
        ),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.darkBrownLight.withValues(alpha: 0.7),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: AppColors.accentRed, width: 3.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: AppColors.accentRed, width: 3.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: AppColors.accentRed, width: 4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: AppColors.error, width: 3.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
      validator: validator,
    );
  }
}

class _VoxLabButton extends StatelessWidget {
  const _VoxLabButton({
    required this.label,
    required this.onPressed,
    required this.color,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: onPressed == null ? AppColors.locked : color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: onPressed == null ? AppColors.outline : color,
              width: 3.5,
            ),
            boxShadow: onPressed == null
                ? []
                : [
                    BoxShadow(
                      color: color,
                      offset: const Offset(0, 5),
                      blurRadius: 0,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
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
                  Icon(icon, size: 20, color: Colors.white),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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