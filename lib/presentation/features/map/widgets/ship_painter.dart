import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Pintor del barco módulo
class ShipPainter extends CustomPainter {
  ShipPainter({
    required this.color,
    this.progress = 0.0,
  });

  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final hullPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final hullBorderPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final sailPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final sailBorderPaint = Paint()
      ..color = AppColors.onSurfaceVariant.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final mastPaint = Paint()
      ..color = const Color(0xFF8B4513) // Marrón
      ..style = PaintingStyle.fill;

    final flagPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final wavePaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Dimensiones
    final hullHeight = size.height * 0.4;
    final hullY = size.height - hullHeight - 8; // 8px para olas

    // 1. Dibujar casco (forma curva)
    final hullPath = Path();
    hullPath.moveTo(size.width * 0.1, hullY);
    hullPath.lineTo(size.width * 0.9, hullY);
    hullPath.quadraticBezierTo(
      size.width * 0.95,
      hullY + hullHeight * 0.5,
      size.width * 0.5,
      hullY + hullHeight,
    );
    hullPath.quadraticBezierTo(
      size.width * 0.05,
      hullY + hullHeight * 0.5,
      size.width * 0.1,
      hullY,
    );
    hullPath.close();

    canvas.drawPath(hullPath, hullPaint);
    canvas.drawPath(hullPath, hullBorderPaint);

    // 2. Dibujar cabina (rectángulo redondeado sobre el casco)
    final cabinWidth = size.width * 0.4;
    final cabinHeight = size.height * 0.25;
    final cabinX = (size.width - cabinWidth) / 2;
    final cabinY = hullY - cabinHeight;

    final cabinRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(cabinX, cabinY, cabinWidth, cabinHeight),
      const Radius.circular(8),
    );

    canvas.drawRRect(
      cabinRRect,
      Paint()
        ..color = AppColors.surface
        ..style = PaintingStyle.fill,
    );

    canvas.drawRRect(
      cabinRRect,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 3. Texto de progreso en la cabina
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(progress * 100).toInt()}%',
        style: TextStyle(
          color: AppColors.onSurface,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        cabinX + (cabinWidth - textPainter.width) / 2,
        cabinY + (cabinHeight - textPainter.height) / 2,
      ),
    );

    // 4. Dibujar mástil
    final mastWidth = size.width * 0.04;
    final mastHeight = size.height * 0.35;
    final mastX = size.width * 0.3;
    final mastY = cabinY - mastHeight;

    canvas.drawRect(
      Rect.fromLTWH(mastX, mastY, mastWidth, mastHeight),
      mastPaint,
    );

    // 5. Dibujar vela (triángulo curvo)
    final sailPath = Path();
    sailPath.moveTo(mastX + mastWidth, mastY + 5);
    sailPath.lineTo(size.width * 0.75, mastY + mastHeight * 0.5);
    sailPath.quadraticBezierTo(
      size.width * 0.6,
      mastY + mastHeight,
      mastX + mastWidth,
      mastY + mastHeight - 5,
    );
    sailPath.close();

    canvas.drawPath(sailPath, sailPaint);
    canvas.drawPath(sailPath, sailBorderPaint);

    // 6. Dibujar bandera en topo del mástil
    final flagPath = Path();
    flagPath.moveTo(mastX, mastY - 5);
    flagPath.lineTo(mastX + 15, mastY + 5);
    flagPath.lineTo(mastX, mastY + 10);
    flagPath.close();

    canvas.drawPath(flagPath, flagPaint);

    // 7. Dibujar olas (3 curvas sinusoidales)
    final waveY = size.height - 4;
    for (var i = 0; i < 3; i++) {
      final waveOffset = i * 6.0;
      final wavePath = Path();
      wavePath.moveTo(0, waveY + waveOffset);

      for (var x = 0.0; x < size.width; x += 5) {
        wavePath.lineTo(
          x,
          waveY + waveOffset + math.sin(x / 10) * 3,
        );
      }

      canvas.drawPath(wavePath, wavePaint);
    }
  }

  @override
  bool shouldRepaint(ShipPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.progress != progress;
  }
}