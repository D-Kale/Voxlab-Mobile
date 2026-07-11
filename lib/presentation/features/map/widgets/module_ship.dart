import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'ship_painter.dart';

/// Barco módulo con animación de flotación
class ModuleShip extends StatefulWidget {
  const ModuleShip({
    super.key,
    required this.title,
    required this.completedLessons,
    required this.totalLessons,
  });

  final String title;
  final int completedLessons;
  final int totalLessons;

  @override
  State<ModuleShip> createState() => _ModuleShipState();
}

class _ModuleShipState extends State<ModuleShip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.totalLessons > 0
        ? widget.completedLessons / widget.totalLessons
        : 0.0;

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _floatAnimation.value,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.tertiary.withValues(alpha: 0.3),
              AppColors.tertiary.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.tertiary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            // Header del módulo
            Row(
              children: [
                const Icon(
                  Icons.directions_boat,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Barco custom
            SizedBox(
              width: 120,
              height: 90,
              child: CustomPaint(
                painter: ShipPainter(
                  color: AppColors.secondary,
                  progress: progress,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}