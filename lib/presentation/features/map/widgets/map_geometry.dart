import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Single source of truth for map path layout math.
///
/// Both the widget layout (`Positioned` nodes in `TrackPath`) and
/// `PathConnectorPainter` consume these values, so connector lines and
/// nodes can never drift apart.
class MapGeometry {
  MapGeometry._();

  static const double nodeDiameter = 64.0;
  static const double nodeRadius = nodeDiameter / 2;
  static const double nodeSpacing = 104.0;
  static const double labelZone = 26.0;
  static const double labelWidth = 132.0;

  /// Horizontal swing of the serpentine (Duolingo-style alternating).
  static const double amplitude = 44.0;
  static const double _frequency = math.pi / 2;

  /// Node centers for [count] exercises whose first one has global index
  /// [globalStartIndex]. `dx` is relative to the horizontal center of the
  /// container; `dy` is absolute from the top of the container.
  ///
  /// The x phase uses the global index so the serpentine stays continuous
  /// across module boundaries.
  static List<Offset> centers({
    required int globalStartIndex,
    required int count,
  }) {
    return List<Offset>.generate(count, (i) {
      final g = globalStartIndex + i;
      return Offset(
        amplitude * math.sin(g * _frequency),
        nodeRadius + i * nodeSpacing,
      );
    });
  }

  /// Height of the container that holds [count] nodes plus the current
  /// node's label below it.
  static double height(int count) {
    if (count <= 0) return 0;
    return (count - 1) * nodeSpacing + nodeDiameter + labelZone;
  }
}
