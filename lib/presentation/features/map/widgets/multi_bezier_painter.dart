import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BezierSegment {
  final GlobalKey fromKey;
  final GlobalKey toKey;
  final bool isConnected;

  const BezierSegment({
    required this.fromKey,
    required this.toKey,
    required this.isConnected,
  });
}

class MultiBezierPainter extends StatelessWidget {
  const MultiBezierPainter({
    super.key,
    required this.segments,
  });

  final List<BezierSegment> segments;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _MultiBezierPainter(
            segments: segments,
          ),
        );
      },
    );
  }
}

class _MultiBezierPainter extends CustomPainter {
  _MultiBezierPainter({
    required this.segments,
  });

  final List<BezierSegment> segments;

  Offset _getNodeCenter(GlobalKey key, Offset parentOffset) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;

    final size = renderBox.size;
    final localOffset = renderBox.localToGlobal(Offset.zero);
    final center = Offset(
      localOffset.dx - parentOffset.dx + size.width / 2,
      localOffset.dy - parentOffset.dy + size.height / 2,
    );
    return center;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final parentOffset = Offset.zero;

    for (final segment in segments) {
      final start = _getNodeCenter(segment.fromKey, parentOffset);
      final end = _getNodeCenter(segment.toKey, parentOffset);

      if (start == Offset.zero || end == Offset.zero) continue;

      final paint = Paint()
        ..color = segment.isConnected
            ? AppColors.success
            : AppColors.onSurfaceVariant.withValues(alpha: 0.35)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx + dx * 0.3,
          start.dy + dy * 0.33,
          start.dx + dx * 0.7,
          start.dy + dy * 0.67,
          end.dx,
          end.dy,
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_MultiBezierPainter oldDelegate) {
    if (oldDelegate.segments.length != segments.length) return true;
    for (var i = 0; i < segments.length; i++) {
      if (oldDelegate.segments[i].isConnected != segments[i].isConnected) {
        return true;
      }
    }
    return false;
  }
}
