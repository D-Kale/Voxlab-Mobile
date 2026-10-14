import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Single source of truth for map path layout math.
///
/// Both the widget layout (`Positioned` nodes in `UnitPathSection`) and
/// `PathConnectorPainter` consume these values, so the road and the nodes
/// can never drift apart.
class MapGeometry {
  MapGeometry._();

  /// Square layout box of one node: the oval face plus its 3D lip.
  static const double nodeDiameter = 76.0;
  static const double nodeRadius = nodeDiameter / 2;

  /// Height of the darker lip under the node face.
  static const double nodeDepth = 8.0;

  /// Leaves room for the "EMPEZAR" bubble between a node and the next one.
  static const double nodeSpacing = 124.0;

  /// Free space above the first node, where the "EMPEZAR" bubble of a
  /// current first node is drawn.
  static const double topInset = 62.0;
  static const double bottomInset = 28.0;

  /// Horizontal swing of the serpentine (Duolingo-style).
  static const double amplitude = 64.0;

  /// Eight nodes per full left-right swing: the path drifts to one side,
  /// comes back through the center and drifts to the other.
  static const double _frequency = math.pi / 4;

  /// Node centers for [count] nodes whose first one has global index
  /// [globalStartIndex]. `dx` is relative to the horizontal center of the
  /// container; `dy` is absolute from the top of the container.
  ///
  /// The x phase uses the global index so the serpentine stays continuous
  /// across units.
  static List<Offset> centers({
    required int globalStartIndex,
    required int count,
  }) {
    return List<Offset>.generate(count, (i) {
      final g = globalStartIndex + i;
      return Offset(
        amplitude * math.sin(g * _frequency),
        topInset + nodeRadius + i * nodeSpacing,
      );
    });
  }

  /// Height of the container that holds [count] nodes.
  static double height(int count) {
    if (count <= 0) return 0;
    return topInset + (count - 1) * nodeSpacing + nodeDiameter + bottomInset;
  }
}
