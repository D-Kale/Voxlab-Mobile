import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Anillo de progreso circular que rodea los nodos de lección
class LessonProgressRing extends StatelessWidget {
  const LessonProgressRing({
    super.key,
    required this.progress,
    required this.color,
    this.size = 72,
    this.strokeWidth = 4,
  });

  /// Progreso de 0.0 a 1.0
  final double progress;
  final Color color;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Anillo de fondo (gris)
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.surfaceContainerHigh,
              ),
            ),
          ),
          // Anillo de progreso (color)
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}