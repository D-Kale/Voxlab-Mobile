import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../data/local/onboarding_store.dart';
import '../../shared/widgets/chunky.dart';
import '../../shared/widgets/motion.dart';

/// First screen on a fresh install: Voxi says hi, then the user either
/// starts the onboarding questions or signs in to an existing account.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              const Spacer(),
              const EntranceAnimation(
                delay: Duration(milliseconds: 500),
                scaleFrom: 0.6,
                child: _SpeechBubble(text: '¡Hola! Soy Voxi.'),
              ),
              const SizedBox(height: 6),
              EntranceAnimation(
                scaleFrom: 0.3,
                offsetY: 40,
                duration: const Duration(milliseconds: 700),
                child: Bob(
                  amplitude: 7,
                  child: Image.asset(
                    'assets/images/voxi_awake.png',
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                    semanticLabel: 'Voxi',
                  ),
                ),
              ),
              const SizedBox(height: 22),
              EntranceAnimation(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Voxlab',
                  style: GoogleFonts.dmSans(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: AppColors.primaryDark,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              EntranceAnimation(
                delay: const Duration(milliseconds: 300),
                child: Text(
                  'Aprendé a hablar en público con ejercicios '
                  'cortos, divertidos y con feedback de IA.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBrown,
                    height: 1.4,
                  ),
                ),
              ),
              const Spacer(),
              EntranceAnimation(
                delay: const Duration(milliseconds: 400),
                child: ChunkyButton(
                  label: 'EMPEZAR',
                  onPressed: () => context.push(AppRoutes.onboarding),
                ),
              ),
              const SizedBox(height: 14),
              EntranceAnimation(
                delay: const Duration(milliseconds: 480),
                child: ChunkyButton(
                  label: 'YA TENGO UNA CUENTA',
                  colors: const ChunkyColors(
                    face: AppColors.surface,
                    lip: AppColors.cardLip,
                    content: AppColors.accentRed,
                    border: AppColors.cardBorder,
                  ),
                  onPressed: () async {
                    await ref
                        .read(onboardingStoreProvider)
                        .markOnboardingSeen();
                    if (context.mounted) context.push(AppRoutes.login);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder, width: 2),
          ),
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBrown,
            ),
          ),
        ),
        CustomPaint(size: const Size(20, 10), painter: _TailPainter()),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, -2)
        ..lineTo(size.width / 2, size.height)
        ..lineTo(size.width, -2)
        ..close(),
      Paint()..color = AppColors.surface,
    );
  }

  @override
  bool shouldRepaint(_TailPainter old) => false;
}
