import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../data/local/onboarding_store.dart';
import '../../shared/widgets/motion.dart';
import '../../shared/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    final start = DateTime.now();

    try {
      await ref.read(authProvider.notifier).checkAuth();
    } catch (e) {
      debugPrint('SplashScreen checkAuth error: $e');
      try {
        ref.read(authProvider.notifier).clearError();
      } catch (_) {}
    }

    if (!mounted) return;

    final elapsed = DateTime.now().difference(start).inMilliseconds;
    if (elapsed < 1500) {
      await Future.delayed(Duration(milliseconds: 1500 - elapsed));
    }

    if (!mounted) return;

    final auth = ref.read(authProvider);
    if (auth.isAuthenticated) {
      context.go(AppRoutes.map);
      return;
    }
    // First launch on this device: Duolingo-style welcome and questions,
    // which end in the register screen. Returning users see the auth wall.
    final seen = await ref.read(onboardingStoreProvider).isOnboardingSeen();
    if (!mounted) return;
    context.go(seen ? AppRoutes.authWall : AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            EntranceAnimation(
              scaleFrom: 0.3,
              offsetY: 40,
              duration: const Duration(milliseconds: 700),
              child: Bob(
                amplitude: 6,
                child: Image.asset(
                  'assets/images/voxi_awake.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                  semanticLabel: 'Voxi',
                ),
              ),
            ),
            const SizedBox(height: 20),
            EntranceAnimation(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Voxlab',
                style: GoogleFonts.dmSans(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                  shadows: const [
                    Shadow(color: AppColors.primaryDark, offset: Offset(0, 4)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            EntranceAnimation(
              delay: const Duration(milliseconds: 300),
              child: Text(
                'Domina el arte de hablar en público',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBrown,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Semantics(
              label: 'Cargando',
              liveRegion: true,
              child: const SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  minHeight: 10,
                  borderRadius: BorderRadius.all(Radius.circular(99)),
                  color: Colors.white,
                  backgroundColor: AppColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
