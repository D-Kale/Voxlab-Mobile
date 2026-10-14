import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/chunky.dart';

/// Kinds of props drawn around the path.
enum SceneProp { tree, pine, bush, flower, rock, cactus, mushroom, grass }

/// Landscape of a level. Each level (track) gets the next biome, so moving
/// to a new track also changes the scenery around the path.
enum MapBiome {
  meadow(
    label: 'Pradera',
    sky: Color(0xFFFFE7B0),
    hillBack: Color(0xFF8EE0AA),
    hillFront: AppColors.success,
    accent: ChunkyColors.green,
    props: [
      SceneProp.tree,
      SceneProp.bush,
      SceneProp.flower,
      SceneProp.grass,
      SceneProp.tree,
      SceneProp.flower,
    ],
  ),
  canyon(
    label: 'Cañón',
    sky: Color(0xFFFFDCA3),
    hillBack: Color(0xFFE39A5C),
    hillFront: Color(0xFFB8652F),
    accent: ChunkyColors.brown,
    props: [
      SceneProp.cactus,
      SceneProp.rock,
      SceneProp.grass,
      SceneProp.cactus,
      SceneProp.rock,
      SceneProp.flower,
    ],
  ),
  autumn(
    label: 'Bosque otoñal',
    sky: Color(0xFFFFE2BF),
    hillBack: Color(0xFFF29468),
    hillFront: AppColors.accentRed,
    accent: ChunkyColors.red,
    props: [
      SceneProp.tree,
      SceneProp.mushroom,
      SceneProp.bush,
      SceneProp.tree,
      SceneProp.mushroom,
      SceneProp.grass,
    ],
  ),
  summit(
    label: 'La cumbre',
    sky: Color(0xFFFFF2DE),
    hillBack: Color(0xFFCDB9A4),
    hillFront: Color(0xFF8C6A4F),
    accent: ChunkyColors.orange,
    props: [
      SceneProp.pine,
      SceneProp.rock,
      SceneProp.pine,
      SceneProp.grass,
      SceneProp.pine,
      SceneProp.rock,
    ],
  );

  const MapBiome({
    required this.label,
    required this.sky,
    required this.hillBack,
    required this.hillFront,
    required this.accent,
    required this.props,
  });

  final String label;
  final Color sky;
  final Color hillBack;
  final Color hillFront;
  final ChunkyColors accent;
  final List<SceneProp> props;

  /// Autumn trees are red and orange; everywhere else they are green.
  Color get foliage =>
      this == MapBiome.autumn ? const Color(0xFFE8682E) : AppColors.success;

  Color get foliageDark =>
      this == MapBiome.autumn ? AppColors.accentRedDark : AppColors.successDark;

  static MapBiome forLevel(int levelNumber) =>
      values[(levelNumber - 1) % values.length];
}

/// Draws one [SceneProp] standing on [base] (bottom center), [size] tall.
void paintSceneProp(
  Canvas canvas,
  SceneProp prop,
  Offset base,
  double size,
  MapBiome biome, {
  bool shadow = true,
}) {
  final paint = Paint()..isAntiAlias = true;
  if (shadow) {
    paint.color = AppColors.primaryDark.withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromCenter(center: base, width: size * 0.8, height: size * 0.16),
      paint,
    );
  }
  final s = size;
  final x = base.dx;
  final y = base.dy;

  switch (prop) {
    case SceneProp.tree:
      paint.color = AppColors.darkBrown;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - s * 0.07, y - s * 0.42, s * 0.14, s * 0.42),
          Radius.circular(s * 0.05),
        ),
        paint,
      );
      paint.color = biome.foliageDark;
      canvas.drawCircle(Offset(x, y - s * 0.6), s * 0.34, paint);
      paint.color = biome.foliage;
      canvas.drawCircle(Offset(x - s * 0.04, y - s * 0.66), s * 0.3, paint);
      paint.color = Colors.white.withValues(alpha: 0.35);
      canvas.drawCircle(Offset(x - s * 0.13, y - s * 0.78), s * 0.08, paint);
    case SceneProp.pine:
      paint.color = AppColors.darkBrown;
      canvas.drawRect(
        Rect.fromLTWH(x - s * 0.06, y - s * 0.22, s * 0.12, s * 0.22),
        paint,
      );
      for (var i = 0; i < 3; i++) {
        final top = y - s * (0.55 + i * 0.2);
        final half = s * (0.34 - i * 0.07);
        final tri = Path()
          ..moveTo(x, top - s * 0.24)
          ..lineTo(x + half, top + s * 0.08)
          ..lineTo(x - half, top + s * 0.08)
          ..close();
        paint.color = i.isEven
            ? const Color(0xFF2C8F55)
            : const Color(0xFF237446);
        canvas.drawPath(tri, paint);
      }
      final cap = Path()
        ..moveTo(x, y - s * 1.19)
        ..lineTo(x + s * 0.11, y - s * 1.04)
        ..lineTo(x - s * 0.11, y - s * 1.04)
        ..close();
      paint.color = Colors.white;
      canvas.drawPath(cap, paint);
    case SceneProp.bush:
      paint.color = biome.foliageDark;
      canvas.drawCircle(Offset(x - s * 0.2, y - s * 0.18), s * 0.2, paint);
      canvas.drawCircle(Offset(x + s * 0.2, y - s * 0.18), s * 0.2, paint);
      paint.color = biome.foliage;
      canvas.drawCircle(Offset(x, y - s * 0.28), s * 0.25, paint);
      paint.color = Colors.white.withValues(alpha: 0.3);
      canvas.drawCircle(Offset(x - s * 0.07, y - s * 0.38), s * 0.06, paint);
    case SceneProp.flower:
      final stem = Paint()
        ..color = AppColors.successDark
        ..strokeWidth = s * 0.06
        ..strokeCap = StrokeCap.round;
      for (final dx in [-0.18, 0.16]) {
        final head = Offset(x + s * dx, y - s * (dx < 0 ? 0.5 : 0.38));
        canvas.drawLine(Offset(x + s * dx * 0.6, y), head, stem);
        paint.color = dx < 0 ? Colors.white : AppColors.accentRed;
        for (var k = 0; k < 5; k++) {
          final a = k * 2 * math.pi / 5;
          canvas.drawCircle(
            head + Offset(math.cos(a), math.sin(a)) * s * 0.09,
            s * 0.07,
            paint,
          );
        }
        paint.color = AppColors.gold;
        canvas.drawCircle(head, s * 0.06, paint);
      }
    case SceneProp.rock:
      final rock = Path()
        ..moveTo(x - s * 0.4, y)
        ..quadraticBezierTo(
          x - s * 0.42,
          y - s * 0.3,
          x - s * 0.12,
          y - s * 0.42,
        )
        ..quadraticBezierTo(
          x + s * 0.2,
          y - s * 0.5,
          x + s * 0.36,
          y - s * 0.22,
        )
        ..quadraticBezierTo(x + s * 0.44, y - s * 0.05, x + s * 0.38, y)
        ..close();
      paint.color = const Color(0xFF8C6A4F);
      canvas.drawPath(rock, paint);
      paint.color = const Color(0xFFB08B6C);
      canvas.drawOval(
        Rect.fromLTWH(x - s * 0.2, y - s * 0.4, s * 0.34, s * 0.14),
        paint,
      );
    case SceneProp.cactus:
      paint.color = AppColors.successDark;
      final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - s * 0.1, y - s * 0.75, s * 0.2, s * 0.75),
        Radius.circular(s * 0.1),
      );
      canvas.drawRRect(body, paint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - s * 0.32, y - s * 0.52, s * 0.14, s * 0.3),
          Radius.circular(s * 0.07),
        ),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTWH(x - s * 0.26, y - s * 0.3, s * 0.18, s * 0.1),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + s * 0.18, y - s * 0.62, s * 0.14, s * 0.3),
          Radius.circular(s * 0.07),
        ),
        paint,
      );
      canvas.drawRect(
        Rect.fromLTWH(x + s * 0.08, y - s * 0.4, s * 0.18, s * 0.1),
        paint,
      );
      paint.color = AppColors.success;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - s * 0.06, y - s * 0.72, s * 0.07, s * 0.6),
          Radius.circular(s * 0.04),
        ),
        paint,
      );
    case SceneProp.mushroom:
      paint.color = AppColors.idleFace;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - s * 0.1, y - s * 0.3, s * 0.2, s * 0.3),
          Radius.circular(s * 0.06),
        ),
        paint,
      );
      paint.color = AppColors.accentRed;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(x, y - s * 0.3),
          width: s * 0.62,
          height: s * 0.56,
        ),
        math.pi,
        math.pi,
        true,
        paint,
      );
      paint.color = Colors.white;
      canvas.drawCircle(Offset(x - s * 0.12, y - s * 0.42), s * 0.05, paint);
      canvas.drawCircle(Offset(x + s * 0.1, y - s * 0.47), s * 0.04, paint);
      canvas.drawCircle(Offset(x + s * 0.02, y - s * 0.36), s * 0.03, paint);
    case SceneProp.grass:
      final blade = Paint()
        ..color = AppColors.primaryDark
        ..strokeWidth = s * 0.08
        ..strokeCap = StrokeCap.round;
      for (final (dx, h, lean) in [
        (-0.16, 0.34, -0.1),
        (0.0, 0.46, 0.0),
        (0.15, 0.3, 0.12),
      ]) {
        canvas.drawLine(
          Offset(x + s * dx, y),
          Offset(x + s * (dx + lean), y - s * h),
          blade,
        );
      }
  }
}

/// A prop placed in a unit, in the unit's local coordinates.
class PlacedProp {
  const PlacedProp(this.prop, this.base, this.size);

  final SceneProp prop;
  final Offset base;
  final double size;
}

/// Props on both margins of a unit's serpentine, on the side away from the
/// road so they never cover a node. Deterministic per [seed].
List<PlacedProp> layoutUnitProps({
  required List<Offset> centers,
  required double width,
  required double amplitude,
  required double nodeRadius,
  required MapBiome biome,
  required int seed,
  int? skipIndex,
}) {
  final rnd = math.Random(seed);
  final cx = width / 2;
  final out = <PlacedProp>[];
  final clearance = amplitude + nodeRadius + 14;
  final room = cx - clearance;
  if (room < 18) return out;

  void place(double y, int side) {
    final prop = biome.props[rnd.nextInt(biome.props.length)];
    final size = 36 + rnd.nextDouble() * 20;
    final half = size * 0.42;
    final reach = (room - half).clamp(half, room);
    final x =
        cx + side * (clearance + half + rnd.nextDouble() * (reach - half));
    final base = Offset(x.clamp(half, width - half), y);
    out.add(PlacedProp(prop, base, size));
    // A small companion (grass or a flower) makes it read as a clearing.
    if (rnd.nextDouble() < 0.45) {
      final small = rnd.nextBool() ? SceneProp.grass : SceneProp.flower;
      final dx = (base.dx - cx).sign * -1 * (half + 6);
      final at = Offset((base.dx + dx).clamp(12, width - 12), y + 6);
      if ((at.dx - cx).abs() > clearance) out.add(PlacedProp(small, at, 20));
    }
  }

  for (var i = 0; i < centers.length; i++) {
    final c = centers[i];
    final towardFree = c.dx > 4 ? -1 : (c.dx < -4 ? 1 : (i.isEven ? 1 : -1));
    if (i != skipIndex) place(c.dy + 18 + rnd.nextDouble() * 16, towardFree);
    // Between nodes the road crosses the middle, so both margins are free.
    if (i < centers.length - 1 && rnd.nextDouble() < 0.7) {
      final midY = (c.dy + centers[i + 1].dy) / 2 + 30;
      place(midY, rnd.nextBool() ? 1 : -1);
    }
  }
  return out;
}

class UnitSceneryPainter extends CustomPainter {
  UnitSceneryPainter({required this.props, required this.biome});

  final List<PlacedProp> props;
  final MapBiome biome;

  @override
  void paint(Canvas canvas, Size size) {
    // Soft ground patches under the props tie them into a landscape.
    final ground = Paint()
      ..isAntiAlias = true
      ..color = Colors.white.withValues(alpha: 0.2);
    for (final p in props) {
      if (p.size < 30) continue;
      canvas.drawOval(
        Rect.fromCenter(
          center: p.base.translate(0, -p.size * 0.05),
          width: p.size * 2.3,
          height: p.size * 0.8,
        ),
        ground,
      );
    }
    // Back to front, so lower props overlap the ones behind them.
    final sorted = [...props]..sort((a, b) => a.base.dy.compareTo(b.base.dy));
    for (final p in sorted) {
      paintSceneProp(canvas, p.prop, p.base, p.size, biome);
    }
  }

  @override
  bool shouldRepaint(UnitSceneryPainter old) =>
      old.biome != biome || old.props.length != props.length;
}

/// Far layer behind the whole map: soft clouds, hills and sparkles that
/// move slower than the path (parallax), so scrolling feels like travelling.
class MapParallaxBackdrop extends StatelessWidget {
  const MapParallaxBackdrop({super.key, required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _BackdropPainter(controller),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  _BackdropPainter(this.controller) : super(repaint: controller);

  final ScrollController controller;

  static const _factor = 0.35;
  static const _tile = 460.0;

  @override
  void paint(Canvas canvas, Size size) {
    final offset = controller.hasClients ? controller.offset : 0.0;
    final shift = offset * _factor;
    final first = (shift / _tile).floor() - 1;
    final last = ((shift + size.height) / _tile).ceil() + 1;
    final paint = Paint()..isAntiAlias = true;

    for (var t = first; t <= last; t++) {
      final rnd = math.Random(t * 7919 + 17);
      final top = t * _tile - shift;

      // Distant hill hugging one edge of the screen.
      final left = rnd.nextBool();
      final hillY = top + rnd.nextDouble() * _tile;
      final hillW = size.width * (0.35 + rnd.nextDouble() * 0.2);
      paint.color = AppColors.primaryDark.withValues(alpha: 0.22);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(left ? 0 : size.width, hillY),
          width: hillW * 2,
          height: hillW * 1.1,
        ),
        paint,
      );

      // Clouds.
      for (var c = 0; c < 2; c++) {
        final cx = rnd.nextDouble() * size.width;
        final cy = top + rnd.nextDouble() * _tile;
        final w = 70 + rnd.nextDouble() * 60;
        paint.color = Colors.white.withValues(alpha: 0.28);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, cy), width: w, height: w * 0.32),
            Radius.circular(w),
          ),
          paint,
        );
        canvas.drawCircle(
          Offset(cx - w * 0.12, cy - w * 0.14),
          w * 0.22,
          paint,
        );
        canvas.drawCircle(Offset(cx + w * 0.14, cy - w * 0.1), w * 0.16, paint);
      }

      // Sparkles.
      for (var k = 0; k < 4; k++) {
        final p = Offset(
          rnd.nextDouble() * size.width,
          top + rnd.nextDouble() * _tile,
        );
        final r = 3 + rnd.nextDouble() * 4;
        paint.color = Colors.white.withValues(alpha: 0.45);
        final star = Path()
          ..moveTo(p.dx, p.dy - r * 2)
          ..quadraticBezierTo(p.dx, p.dy, p.dx + r * 2, p.dy)
          ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + r * 2)
          ..quadraticBezierTo(p.dx, p.dy, p.dx - r * 2, p.dy)
          ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - r * 2)
          ..close();
        canvas.drawPath(star, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BackdropPainter old) => old.controller != controller;
}

/// Illustration at the top of a level card: sky, sun, two rows of hills,
/// props of the biome and a flag on the summit.
class LevelLandscapePainter extends CustomPainter {
  LevelLandscapePainter({required this.biome, required this.flagColor});

  final MapBiome biome;
  final Color flagColor;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..isAntiAlias = true;

    paint.color = biome.sky;
    canvas.drawRect(Offset.zero & size, paint);

    paint.color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(w * 0.82, h * 0.3), h * 0.2, paint);
    paint.color = AppColors.gold;
    canvas.drawCircle(Offset(w * 0.82, h * 0.3), h * 0.14, paint);

    paint.color = Colors.white.withValues(alpha: 0.8);
    for (final (cx, cy, cw) in [(0.2, 0.22, 0.16), (0.55, 0.14, 0.11)]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(w * cx, h * cy),
            width: w * cw,
            height: h * 0.1,
          ),
          Radius.circular(h),
        ),
        paint,
      );
    }

    final back = Path()..moveTo(0, h);
    back.lineTo(0, h * 0.62);
    back.quadraticBezierTo(w * 0.18, h * 0.38, w * 0.36, h * 0.58);
    back.quadraticBezierTo(w * 0.5, h * 0.3, w * 0.68, h * 0.5);
    back.quadraticBezierTo(w * 0.86, h * 0.4, w, h * 0.6);
    back.lineTo(w, h);
    back.close();
    paint.color = biome.hillBack;
    canvas.drawPath(back, paint);

    if (biome == MapBiome.summit) {
      final snow = Path()
        ..moveTo(w * 0.44, h * 0.42)
        ..quadraticBezierTo(w * 0.5, h * 0.32, w * 0.56, h * 0.4)
        ..lineTo(w * 0.52, h * 0.44)
        ..lineTo(w * 0.48, h * 0.41)
        ..close();
      paint.color = Colors.white;
      canvas.drawPath(snow, paint);
    }

    final front = Path()..moveTo(0, h);
    front.lineTo(0, h * 0.8);
    front.quadraticBezierTo(w * 0.25, h * 0.6, w * 0.5, h * 0.72);
    front.quadraticBezierTo(w * 0.75, h * 0.84, w, h * 0.7);
    front.lineTo(w, h);
    front.close();
    paint.color = biome.hillFront;
    canvas.drawPath(front, paint);

    // Flag on the front hill: the goal of the level.
    final poleBase = Offset(w * 0.5, h * 0.72);
    final pole = Paint()
      ..color = AppColors.darkBrown
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(poleBase, poleBase - Offset(0, h * 0.42), pole);
    final flag = Path()
      ..moveTo(poleBase.dx, poleBase.dy - h * 0.42)
      ..lineTo(poleBase.dx + h * 0.24, poleBase.dy - h * 0.35)
      ..lineTo(poleBase.dx, poleBase.dy - h * 0.27)
      ..close();
    paint.color = flagColor;
    canvas.drawPath(flag, paint);

    final rnd = math.Random(biome.index * 31 + 5);
    for (final fx in [0.1, 0.24, 0.72, 0.9]) {
      final prop = biome.props[rnd.nextInt(biome.props.length)];
      final y =
          h * (fx < 0.5 ? 0.8 - (fx - 0.1) * 0.6 : 0.78 + (fx - 0.72) * 0.2);
      paintSceneProp(
        canvas,
        prop,
        Offset(w * fx, y + 4),
        h * 0.3,
        biome,
        shadow: false,
      );
    }
  }

  @override
  bool shouldRepaint(LevelLandscapePainter old) =>
      old.biome != biome || old.flagColor != flagColor;
}
