import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import 'voxi_state.dart';

class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.score,
    this.max = 100,
    this.size = 180,
    this.centerLabel,
    this.showVoxi = true,
    this.voxiState = VoxiState.awake,
  });

  final int score;
  final int max;
  final double size;
  final String? centerLabel;
  final bool showVoxi;
  final VoxiState voxiState;

  @override
  Widget build(BuildContext context) {
    final ratio = max <= 0 ? 0.0 : (score / max).clamp(0.0, 1.0);
    final voxiAsset = voxiState == VoxiState.awake
        ? 'assets/images/voxi_awake.png'
        : 'assets/images/voxi_sleeping.png';

    return Semantics(
      label: 'Puntaje: $score de $max',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: ratio),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return CustomPaint(
            painter: _ScoreRingPainter(progress: value),
            child: child,
          );
        },
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: GoogleFonts.dmSans(
                      fontSize: size * 0.24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkBrown,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    centerLabel ?? 'DE $max',
                    style: GoogleFonts.dmSans(
                      fontSize: size * 0.07,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.darkBrownLight,
                    ),
                  ),
                ],
              ),
              if (showVoxi)
                Positioned(
                  bottom: size * 0.08,
                  child: Image.asset(
                    voxiAsset,
                    width: size * 0.28,
                    height: size * 0.28,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScoreRingPainter extends CustomPainter {
  const _ScoreRingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final center = rect.center;

    // Track (background ring)
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppColors.surfaceContainerHigh;

    // Draw track with 3D effect (slight inner shadow)
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, trackPaint);

    // Inner shadow on track
    final innerShadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.3
      ..strokeCap = StrokeCap.round
      ..color = Colors.black.withValues(alpha: 0.08);
    canvas.drawArc(
      rect.inflate(strokeWidth * 0.15),
      -math.pi / 2,
      math.pi * 2,
      false,
      innerShadowPaint,
    );

    if (progress <= 0) return;

    // Progress ring with gradient
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: -math.pi / 2 + math.pi * 2,
        colors: [
          AppColors.primary,
          AppColors.primary.withValues(alpha: 0.8),
          AppColors.accentRed,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );

    // Glow effect on progress end
    if (progress > 0 && progress < 1.0) {
      final endAngle = -math.pi / 2 + math.pi * 2 * progress;
      final endPoint = Offset(
        center.dx + rect.width / 2 * math.cos(endAngle),
        center.dy + rect.height / 2 * math.sin(endAngle),
      );
      final glowPaint = Paint()
        ..color = AppColors.accentRed
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(endPoint, strokeWidth / 2 + 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}