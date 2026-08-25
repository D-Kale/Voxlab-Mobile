import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'path_lesson_node.dart';

class PathConnectorPainter extends CustomPainter {
  PathConnectorPainter({
    required this.nodeKeys,
    required this.states,
    required this.stackKey,
  });

  static const double _strokeWidth = 8;
  static const double _dashLength = 9;
  static const double _dashGap = 7;
  static const double _edgePadding = 6;

  final List<GlobalKey> nodeKeys;
  final List<PathNodeState> states;
  final GlobalKey stackKey;

  ({Offset center, Size size})? _metricsOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    final stack = stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stack == null || !box.hasSize || !stack.hasSize) {
      return null;
    }
    final nodeTopLeft = box.localToGlobal(Offset.zero);
    final stackTopLeft = stack.localToGlobal(Offset.zero);
    return (
      center: Offset(
        nodeTopLeft.dx - stackTopLeft.dx + box.size.width / 2,
        nodeTopLeft.dy - stackTopLeft.dy + box.size.height / 2,
      ),
      size: box.size,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 1; i < nodeKeys.length; i++) {
      final from = _metricsOf(nodeKeys[i - 1]);
      final to = _metricsOf(nodeKeys[i]);
      if (from == null || to == null) continue;

      final start = Offset(
        from.center.dx,
        from.center.dy + from.size.height / 2 + _edgePadding,
      );
      final end = Offset(
        to.center.dx,
        to.center.dy - to.size.height / 2 - _edgePadding,
      );

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx,
          start.dy + (end.dy - start.dy) * 0.5,
          end.dx,
          end.dy - (end.dy - start.dy) * 0.5,
          end.dx,
          end.dy,
        );

      if (states[i - 1] == PathNodeState.completed) {
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
    final paint = _paintFor(const Color(0xFFD6D3CA));
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
    if (oldDelegate.states.length != states.length) return true;
    for (var i = 0; i < states.length; i++) {
      if (oldDelegate.states[i] != states[i]) return true;
    }
    return false;
  }
}
