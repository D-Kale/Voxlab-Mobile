import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'path_lesson_node.dart';

class PathConnectorPainter extends CustomPainter {
  PathConnectorPainter({
    required this.nodePositions,
    required this.states,
    this.nodeRadius = 32.0,
  });

  static const double _strokeWidth = 8.0;
  static const double _dashLength = 10.0;
  static const double _dashGap = 8.0;

  /// Upcoming segment color: white reads clearly on the orange app
  /// background, where the previous beige was nearly invisible.
  static const Color _upcomingColor = Color(0xFFFFFFFF);

  /// Node centers produced by `MapGeometry.centers`: `dx` relative to the
  /// horizontal center of the painted area, `dy` absolute from the top.
  final List<Offset> nodePositions;
  final List<PathNodeState> states;
  final double nodeRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;
    final cx = size.width / 2;

    for (var i = 1; i < nodePositions.length; i++) {
      final start = Offset(
        cx + nodePositions[i - 1].dx,
        nodePositions[i - 1].dy,
      );
      final end = Offset(cx + nodePositions[i].dx, nodePositions[i].dy);

      // Connect node edge to node edge (bottom of previous → top of next).
      final adjustedStart = Offset(start.dx, start.dy + nodeRadius);
      final adjustedEnd = Offset(end.dx, end.dy - nodeRadius);
      if (adjustedEnd.dy <= adjustedStart.dy) continue;

      final dy = adjustedEnd.dy - adjustedStart.dy;
      final path = Path()
        ..moveTo(adjustedStart.dx, adjustedStart.dy)
        ..cubicTo(
          adjustedStart.dx,
          adjustedStart.dy + dy * 0.5,
          adjustedEnd.dx,
          adjustedEnd.dy - dy * 0.5,
          adjustedEnd.dx,
          adjustedEnd.dy,
        );

      final segmentState =
          i - 1 < states.length ? states[i - 1] : PathNodeState.pending;

      if (segmentState == PathNodeState.completed) {
        canvas.drawPath(path, _paintFor(AppColors.secondary));
      } else {
        _drawDashed(canvas, path);
      }
    }
  }

  Paint _paintFor(Color color) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth
    ..strokeCap = StrokeCap.round;

  void _drawDashed(Canvas canvas, Path path) {
    final paint = _paintFor(_upcomingColor);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + _dashLength >= metric.length
            ? metric.length
            : distance + _dashLength;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + _dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(PathConnectorPainter oldDelegate) {
    if (oldDelegate.nodePositions.length != nodePositions.length) return true;
    if (oldDelegate.states.length != states.length) return true;
    if (oldDelegate.nodeRadius != nodeRadius) return true;
    for (var i = 0; i < nodePositions.length; i++) {
      if (oldDelegate.nodePositions[i] != nodePositions[i]) return true;
    }
    for (var i = 0; i < states.length; i++) {
      if (oldDelegate.states[i] != states[i]) return true;
    }
    return false;
  }
}
