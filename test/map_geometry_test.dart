import 'package:flutter_test/flutter_test.dart';
import 'package:voxlab/presentation/features/map/widgets/map_geometry.dart';

void main() {
  group('MapGeometry.centers', () {
    test('first node starts at the top with the node radius offset', () {
      final centers = MapGeometry.centers(globalStartIndex: 0, count: 3);
      expect(centers.first.dy, MapGeometry.nodeRadius);
      expect(centers.first.dx, 0.0);
    });

    test('y increments by exactly nodeSpacing', () {
      final centers = MapGeometry.centers(globalStartIndex: 0, count: 5);
      for (var i = 1; i < centers.length; i++) {
        expect(
          centers[i].dy - centers[i - 1].dy,
          MapGeometry.nodeSpacing,
          reason: 'vertical gap between node $i - 1 and $i',
        );
      }
    });

    test('x stays within amplitude (nodes fit the container width)', () {
      final centers = MapGeometry.centers(globalStartIndex: 0, count: 50);
      for (final c in centers) {
        expect(c.dx.abs(), lessThanOrEqualTo(MapGeometry.amplitude));
      }
    });

    test('x phase follows the global index (continuity across modules)', () {
      final global = MapGeometry.centers(globalStartIndex: 0, count: 10);
      final secondModule =
          MapGeometry.centers(globalStartIndex: 6, count: 4);
      expect(secondModule.first.dx, global[6].dx);
      expect(secondModule.first.dy, MapGeometry.nodeRadius);
    });
  });

  group('MapGeometry.height', () {
    test('holds node + label zone for a single node', () {
      expect(
        MapGeometry.height(1),
        MapGeometry.nodeDiameter + MapGeometry.labelZone,
      );
    });

    test('grows by nodeSpacing per additional node', () {
      expect(
        MapGeometry.height(4),
        MapGeometry.height(1) + 3 * MapGeometry.nodeSpacing,
      );
    });

    test('zero for empty content', () {
      expect(MapGeometry.height(0), 0);
    });

    test('every node top/label bottom fits inside the container', () {
      const count = 6;
      final centers = MapGeometry.centers(globalStartIndex: 0, count: count);
      final totalHeight = MapGeometry.height(count);

      for (final c in centers) {
        final nodeTop = c.dy - MapGeometry.nodeRadius;
        final nodeBottom = c.dy + MapGeometry.nodeRadius;
        expect(nodeTop, greaterThanOrEqualTo(0));
        expect(nodeBottom, lessThan(totalHeight));
        // Label zone must fit below the node inside the container.
        expect(
          nodeBottom + MapGeometry.labelZone - 3,
          lessThanOrEqualTo(totalHeight),
        );
      }
    });
  });
}
