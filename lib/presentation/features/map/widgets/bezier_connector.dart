import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Conector curvo Bézier entre dos nodos de lección
class BezierConnector extends StatelessWidget {
  const BezierConnector({
    super.key,
    required this.startOffset,
    required this.endOffset,
    required this.isConnected,
  });

  /// Punto de inicio (centro del nodo superior)
  final Offset startOffset;

  /// Punto final (centro del nodo inferior)
  final Offset endOffset;

  /// Si true: color verde (conectado), si false: gris (no conectado)
  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BezierConnectorPainter(
        startPoint: startOffset,
        endPoint: endOffset,
        isConnected: isConnected,
      ),
    );
  }
}

class BezierConnectorPainter extends CustomPainter {
  BezierConnectorPainter({
    required this.startPoint,
    required this.endPoint,
    required this.isConnected,
  });

  final Offset startPoint;
  final Offset endPoint;
  final bool isConnected;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isConnected
          ? AppColors.success
          : AppColors.onSurfaceVariant
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(startPoint.dx, startPoint.dy);

    // Calcular puntos de control para curva Bézier cúbica
    // La curva se desvía horizontalmente para crear el efecto serpenteante
    final dx = endPoint.dx - startPoint.dx;
    final dy = endPoint.dy - startPoint.dy;

    // Puntos de control: 1/3 y 2/3 del camino vertical
    // Con offset horizontal para crear la curva
    final controlPoint1 = Offset(
      startPoint.dx + dx * 0.3,
      startPoint.dy + dy * 0.33,
    );

    final controlPoint2 = Offset(
      startPoint.dx + dx * 0.7,
      startPoint.dy + dy * 0.67,
    );

    // Dibujar curva Bézier cúbica
    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      endPoint.dx,
      endPoint.dy,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BezierConnectorPainter oldDelegate) {
    return oldDelegate.startPoint != startPoint ||
        oldDelegate.endPoint != endPoint ||
        oldDelegate.isConnected != isConnected;
  }
}