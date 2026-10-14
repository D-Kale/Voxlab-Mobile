import 'package:flutter/material.dart';

/// Draws the road between map nodes: a solid white band up to the furthest
/// reached node and a dotted trail beyond it.
///
/// Segments run center to center; the opaque nodes drawn on top hide the
/// ends, so the road always meets a node exactly.
class PathConnectorPainter extends CustomPainter {
  PathConnectorPainter({required this.nodePositions, required this.reached});

  static const double _roadWidth = 12.0;
  static const double _dotRadius = 4.0;
  static const double _dotGap = 15.0;

  // White reads on every unit color and on the orange background.
  static const Color _roadColor = Color(0xF2FFFFFF);
  static const Color _trailColor = Color(0x99FFFFFF);

  /// Node centers produced by `MapGeometry.centers`: `dx` relative to the
  /// horizontal center of the painted area, `dy` absolute from the top.
  final List<Offset> nodePositions;

  /// Whether each node has been reached (completed or current). A segment
  /// is solid when its destination node is reached.
  final List<bool> reached;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodePositions.length < 2) return;
    final cx = size.width / 2;
    final road = Paint()
      ..color = _roadColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _roadWidth
      ..strokeCap = StrokeCap.round;
    final dot = Paint()..color = _trailColor;

    for (var i = 1; i < nodePositions.length; i++) {
      final a = Offset(cx + nodePositions[i - 1].dx, nodePositions[i - 1].dy);
      final b = Offset(cx + nodePositions[i].dx, nodePositions[i].dy);
      final dy = b.dy - a.dy;
      final path = Path()
        ..moveTo(a.dx, a.dy)
        ..cubicTo(a.dx, a.dy + dy * 0.5, b.dx, b.dy - dy * 0.5, b.dx, b.dy);

      if (i < reached.length && reached[i]) {
        canvas.drawPath(path, road);
        continue;
      }
      for (final metric in path.computeMetrics()) {
        for (var d = _dotGap / 2; d < metric.length; d += _dotGap) {
          final tangent = metric.getTangentForOffset(d);
          if (tangent != null) {
            canvas.drawCircle(tangent.position, _dotRadius, dot);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(PathConnectorPainter oldDelegate) {
    if (oldDelegate.nodePositions.length != nodePositions.length) return true;
    if (oldDelegate.reached.length != reached.length) return true;
    for (var i = 0; i < nodePositions.length; i++) {
      if (oldDelegate.nodePositions[i] != nodePositions[i]) return true;
    }
    for (var i = 0; i < reached.length; i++) {
      if (oldDelegate.reached[i] != reached[i]) return true;
    }
    return false;
  }
}
