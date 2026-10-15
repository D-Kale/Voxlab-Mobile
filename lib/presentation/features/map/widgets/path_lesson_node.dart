import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/chunky.dart';
import 'map_geometry.dart';

/// Oval 3D map button: a colored face over a darker lip that sinks on press.
class PathNodeButton extends StatelessWidget {
  const PathNodeButton({
    super.key,
    required this.colors,
    required this.icon,
    required this.semanticsLabel,
    this.iconSize = 34,
    this.onTap,
  });

  final ChunkyColors colors;
  final IconData icon;
  final double iconSize;
  final String semanticsLabel;
  final VoidCallback? onTap;

  static const double _size = MapGeometry.nodeDiameter;
  static const double _depth = MapGeometry.nodeDepth;
  static const double _faceHeight = _size - _depth;
  static const _oval = BorderRadius.all(
    Radius.elliptical(_size / 2, _faceHeight / 2),
  );

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        builder: (pressed) => SizedBox.square(
          dimension: _size,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: _depth,
                height: _faceHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.lip,
                    borderRadius: _oval,
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 70),
                curve: Curves.easeOut,
                left: 0,
                right: 0,
                top: pressed ? _depth : 0,
                height: _faceHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.face,
                    borderRadius: _oval,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glossy highlight that sells the 3D face.
                      Positioned(
                        top: 9,
                        left: 17,
                        child: Transform.rotate(
                          angle: -0.5,
                          child: Container(
                            width: 16,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.32),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      Icon(icon, size: iconSize, color: colors.content),
                    ],
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

/// Ring around the current node: white track plus an arc showing how much
/// of the unit is done.
class UnitProgressRing extends StatelessWidget {
  const UnitProgressRing({
    super.key,
    required this.progress,
    required this.color,
    this.diameter = 104,
  });

  final double progress;
  final Color color;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => CustomPaint(
        size: Size.square(diameter),
        painter: _RingPainter(progress: value, color: color),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  static const double _stroke = 8;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final ring = rect.deflate(_stroke / 2);
    canvas.drawOval(
      ring,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke,
    );
    if (progress <= 0) return;
    canvas.drawArc(
      ring,
      -math.pi / 2,
      2 * math.pi * progress.clamp(0, 1),
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

/// "EMPEZAR" call-out above the current node, with a pointer to it.
class StartBubble extends StatelessWidget {
  const StartBubble({super.key, required this.color, this.label = 'EMPEZAR'});

  final Color color;
  final String label;

  static const double height = 42;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder, width: 2),
            ),
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                height: 1.2,
                color: color,
              ),
            ),
          ),
          CustomPaint(size: const Size(16, 8), painter: _PointerPainter()),
        ],
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, -2)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, -2)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_PointerPainter old) => false;
}

/// Colored unit header, pinned while its unit scrolls (Duolingo-style).
class UnitHeader extends StatelessWidget {
  const UnitHeader({
    super.key,
    required this.colors,
    required this.unitNumber,
    required this.title,
    required this.doneCount,
    required this.totalCount,
    this.onGuide,
  });

  final ChunkyColors colors;
  final int unitNumber;
  final String title;
  final int doneCount;
  final int totalCount;
  final VoidCallback? onGuide;

  /// Outer height including background padding, used as the sliver extent.
  static const double extent = 98;

  @override
  Widget build(BuildContext context) {
    final done = doneCount == totalCount;
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 9),
      child: ChunkyCard(
        colors: colors,
        radius: 18,
        padding: const EdgeInsets.fromLTRB(18, 10, 8, 10),
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'UNIDAD $unitNumber',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (done)
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        else
                          Text(
                            '$doneCount/$totalCount',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: onGuide,
                tooltip: 'Guía de la unidad',
                icon: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
