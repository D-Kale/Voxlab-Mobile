import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/audio/sound_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../utils/exercise_name_utils.dart';
import '../../../shared/widgets/chunky.dart';
import '../../../shared/widgets/exercise_type_style.dart';
import '../../../shared/widgets/motion.dart';
import 'lesson_popover.dart';
import 'map_geometry.dart';
import 'map_path_model.dart';
import 'path_connector_painter.dart';
import 'path_lesson_node.dart';

typedef StartExercise = void Function(PathExerciseNode node);

/// Slivers for the whole learning path: per unit, a header that stays
/// pinned while the unit scrolls, followed by its serpentine of nodes.
///
/// [currentKey] is attached to the current node so the screen can scroll
/// to it.
List<Widget> buildMapSlivers({
  required MapPathModel model,
  required StartExercise onStart,
  required void Function(PathUnit unit) onGuide,
  GlobalKey? currentKey,
}) {
  final slivers = <Widget>[];
  int? lastTrack;
  for (final unit in model.units) {
    if (unit.trackIndex != lastTrack) {
      lastTrack = unit.trackIndex;
      slivers.add(
        SliverToBoxAdapter(child: _SectionTitle(title: unit.trackTitle)),
      );
    }
    slivers.add(
      SliverMainAxisGroup(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _UnitHeaderDelegate(unit: unit, onGuide: onGuide),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: UnitPathSection(
                key: ValueKey('unit-${unit.module.id}-${unit.trackIndex}'),
                unit: unit,
                onStart: onStart,
                currentKey: unit.hasCurrent ? currentKey : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
  return slivers;
}

class _UnitHeaderDelegate extends SliverPersistentHeaderDelegate {
  _UnitHeaderDelegate({required this.unit, required this.onGuide});

  final PathUnit unit;
  final void Function(PathUnit unit) onGuide;

  @override
  double get minExtent => UnitHeader.extent;

  @override
  double get maxExtent => UnitHeader.extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return UnitHeader(
      colors: unit.colors,
      unitNumber: unit.unitNumber,
      title: unit.module.title,
      doneCount: unit.doneCount,
      totalCount: unit.nodes.length,
      onGuide: () => onGuide(unit),
    );
  }

  @override
  bool shouldRebuild(_UnitHeaderDelegate old) =>
      old.unit.doneCount != unit.doneCount ||
      old.unit.module.title != unit.module.title ||
      old.unit.colors != unit.colors;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(
        height: 2,
        color: AppColors.darkBrown.withValues(alpha: 0.15),
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Row(
        children: [
          line,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBrown.withValues(alpha: 0.75),
              ),
            ),
          ),
          line,
        ],
      ),
    );
  }
}

/// One unit's serpentine. Layout (`Positioned`) and the road painter use the
/// same [MapGeometry] centers, so nodes always sit on the road.
class UnitPathSection extends StatelessWidget {
  const UnitPathSection({
    super.key,
    required this.unit,
    required this.onStart,
    this.currentKey,
  });

  final PathUnit unit;
  final StartExercise onStart;
  final GlobalKey? currentKey;

  static const double _mascotSize = 84;

  /// Muted card for locked nodes, like Duolingo's grey popover.
  static const _lockedColors = ChunkyColors(
    face: AppColors.darkBrownLight,
    lip: AppColors.darkBrown,
    content: Colors.white,
  );
  static const double _ringDiameter = 104;

  @override
  Widget build(BuildContext context) {
    final centers = MapGeometry.centers(
      globalStartIndex: unit.globalStartIndex,
      count: unit.slotCount,
    );
    final reached = [
      for (final n in unit.nodes) n.state != PathNodeState.locked,
      unit.isDone,
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cx = constraints.maxWidth / 2;
        final currentIndex = unit.nodes.indexWhere(
          (n) => n.state == PathNodeState.current,
        );

        Offset faceCenter(int i) => Offset(
          cx + centers[i].dx,
          centers[i].dy - MapGeometry.nodeDepth / 2,
        );

        return SizedBox(
          height: MapGeometry.height(unit.slotCount),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: PathConnectorPainter(
                      nodePositions: centers,
                      reached: reached,
                    ),
                  ),
                ),
              ),
              ..._mascot(centers, cx),
              if (currentIndex >= 0) ...[
                _centeredAt(
                  faceCenter(currentIndex),
                  PulseHalo(color: Colors.white, diameter: _ringDiameter - 8),
                ),
                _centeredAt(
                  faceCenter(currentIndex),
                  UnitProgressRing(
                    progress: unit.doneCount / unit.nodes.length,
                    color: unit.colors.face,
                    diameter: _ringDiameter,
                  ),
                ),
              ],
              for (var i = 0; i < unit.nodes.length; i++)
                _node(context, i, centers[i], cx),
              _trophy(centers.last, cx),
              if (currentIndex >= 0)
                Positioned(
                  left: cx + centers[currentIndex].dx - 70,
                  width: 140,
                  top:
                      faceCenter(currentIndex).dy -
                      _ringDiameter / 2 -
                      StartBubble.height +
                      4,
                  child: IgnorePointer(
                    child: Center(
                      child: Bob(child: StartBubble(color: unit.colors.face)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _centeredAt(Offset center, Widget child) {
    return Positioned(
      left: center.dx - 100,
      top: center.dy - 100,
      width: 200,
      height: 200,
      child: IgnorePointer(child: Center(child: child)),
    );
  }

  /// Voxi sits on the free side of the widest swing of the unit: awake and
  /// floating on units the user reached, asleep on the ones ahead.
  List<Widget> _mascot(List<Offset> centers, double cx) {
    var index = -1;
    for (var i = 0; i < unit.nodes.length; i++) {
      if (centers[i].dx.abs() >= MapGeometry.amplitude * 0.95) {
        index = i;
        break;
      }
    }
    if (index < 0) return const [];
    final side = centers[index].dx > 0 ? -1 : 1;
    final awake = unit.isDone || unit.hasCurrent;
    final image = Image.asset(
      awake
          ? 'assets/images/voxi_awake.png'
          : 'assets/images/voxi_sleeping.png',
      width: _mascotSize,
      height: _mascotSize,
      fit: BoxFit.contain,
    );
    // The mascot art is a bust cut flat at the bottom: a ground shadow
    // makes it read as Voxi peeking out of the map.
    final ground = Container(
      width: _mascotSize * 0.9,
      height: 16,
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.55),
        borderRadius: const BorderRadius.all(Radius.elliptical(40, 8)),
      ),
    );
    return [
      Positioned(
        left: cx + side * (MapGeometry.amplitude + 12) - _mascotSize / 2,
        top: centers[index].dy - _mascotSize / 2,
        width: _mascotSize,
        height: _mascotSize + 8,
        child: IgnorePointer(
          child: Semantics(
            label: 'Voxi',
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ground,
                Positioned(
                  bottom: 8,
                  child: awake ? Bob(amplitude: 3, child: image) : image,
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget _node(BuildContext context, int i, Offset center, double cx) {
    final node = unit.nodes[i];
    final style = ExerciseTypeStyle.of(node.exercise.type);
    final colors = switch (node.state) {
      PathNodeState.locked => ChunkyColors.idle,
      _ => unit.colors,
    };
    final icon = switch (node.state) {
      PathNodeState.completed => Icons.check_rounded,
      PathNodeState.current => style.icon,
      PathNodeState.locked => Icons.lock_rounded,
    };
    final name = node.exercise.name.isNotEmpty
        ? node.exercise.name
        : formatExerciseType(node.exercise.type);

    Widget child = Builder(
      builder: (nodeContext) => PathNodeButton(
        colors: colors,
        icon: icon,
        iconSize: switch (node.state) {
          PathNodeState.completed => 40,
          PathNodeState.current => 32,
          PathNodeState.locked => 28,
        },
        semanticsLabel: node.state == PathNodeState.locked
            ? '$name, bloqueado'
            : '$name, ${formatExerciseType(node.exercise.type)}',
        onTap: () => _openExercisePopover(nodeContext, i),
      ),
    );
    child = EntranceAnimation(
      delay: EntranceAnimation.stagger(i),
      offsetY: 0,
      scaleFrom: 0.5,
      child: child,
    );
    if (node.state == PathNodeState.current && currentKey != null) {
      child = KeyedSubtree(key: currentKey, child: child);
    }
    return Positioned(
      left: cx + center.dx - MapGeometry.nodeRadius,
      top: center.dy - MapGeometry.nodeRadius,
      child: child,
    );
  }

  Widget _trophy(Offset center, double cx) {
    return Positioned(
      left: cx + center.dx - MapGeometry.nodeRadius,
      top: center.dy - MapGeometry.nodeRadius,
      child: EntranceAnimation(
        delay: EntranceAnimation.stagger(unit.nodes.length),
        offsetY: 0,
        scaleFrom: 0.5,
        child: Builder(
          builder: (trophyContext) => PathNodeButton(
            colors: unit.isDone ? ChunkyColors.gold : ChunkyColors.idle,
            icon: Icons.emoji_events_rounded,
            iconSize: 36,
            semanticsLabel: 'Trofeo de la unidad ${unit.unitNumber}',
            onTap: () => _openTrophyPopover(trophyContext),
          ),
        ),
      ),
    );
  }

  static Rect _rectOf(BuildContext context) {
    final box = context.findRenderObject()! as RenderBox;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  void _openExercisePopover(BuildContext nodeContext, int i) {
    final node = unit.nodes[i];
    final exercise = node.exercise;
    final typeLabel = formatExerciseType(exercise.type);
    final xp = exerciseXpReward(exercise);
    final done = node.state == PathNodeState.completed;
    playSfx(nodeContext, Sfx.pop);

    if (node.state == PathNodeState.locked) {
      showLessonPopover(
        nodeContext,
        anchor: _rectOf(nodeContext),
        colors: _lockedColors,
        title: exercise.name.isNotEmpty ? exercise.name : typeLabel,
        subtitle: 'Completá los ejercicios anteriores para desbloquearlo.',
        buttonLabel: 'BLOQUEADO',
      );
      return;
    }

    showLessonPopover(
      nodeContext,
      anchor: _rectOf(nodeContext),
      colors: unit.colors,
      title: exercise.name.isNotEmpty ? exercise.name : typeLabel,
      subtitle: done
          ? '$typeLabel · Ya lo completaste. Repasalo cuando quieras.'
          : '$typeLabel · Ejercicio ${i + 1} de ${unit.nodes.length}',
      buttonLabel: done
          ? 'REPASAR'
          : xp > 0
          ? 'EMPEZAR +$xp XP'
          : 'EMPEZAR',
      onStart: () => onStart(node),
    );
  }

  void _openTrophyPopover(BuildContext trophyContext) {
    playSfx(trophyContext, unit.isDone ? Sfx.unlock : Sfx.pop);
    final remaining = unit.nodes.length - unit.doneCount;
    showLessonPopover(
      trophyContext,
      anchor: _rectOf(trophyContext),
      colors: unit.isDone ? ChunkyColors.gold : unit.colors,
      title: unit.isDone
          ? '¡Unidad ${unit.unitNumber} superada!'
          : 'Trofeo de la unidad',
      subtitle: unit.isDone
          ? 'Completaste todos los ejercicios de "${unit.module.title}".'
          : remaining == 1
          ? 'Completá el último ejercicio para ganarlo.'
          : 'Completá los $remaining ejercicios restantes para ganarlo.',
    );
  }
}

/// Bottom sheet listing a unit's exercises and progress.
Future<void> showUnitGuide(
  BuildContext context, {
  required PathUnit unit,
  required StartExercise onStart,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      final progress = unit.doneCount / unit.nodes.length;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UNIDAD ${unit.unitNumber}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: unit.colors.face,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                unit.module.title,
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkBrown,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  color: unit.colors.face,
                  backgroundColor: AppColors.idleFace,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${unit.doneCount} de ${unit.nodes.length} ejercicios completados',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBrownLight,
                ),
              ),
              const SizedBox(height: 14),
              for (final node in unit.nodes)
                _GuideRow(
                  node: node,
                  color: unit.colors.face,
                  onTap: node.state == PathNodeState.locked
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          onStart(node);
                        },
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _GuideRow extends StatelessWidget {
  const _GuideRow({
    required this.node,
    required this.color,
    required this.onTap,
  });

  final PathExerciseNode node;
  final Color color;

  /// Null for locked exercises.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = node.state == PathNodeState.completed;
    final current = node.state == PathNodeState.current;
    final locked = node.state == PathNodeState.locked;
    final style = ExerciseTypeStyle.of(node.exercise.type);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done || current ? color : AppColors.idleFace,
              ),
              child: Icon(
                done
                    ? Icons.check_rounded
                    : locked
                    ? Icons.lock_rounded
                    : style.icon,
                size: 22,
                color: done || current
                    ? Colors.white
                    : AppColors.darkBrownLight,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                node.exercise.name.isNotEmpty
                    ? node.exercise.name
                    : formatExerciseType(node.exercise.type),
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: current ? FontWeight.w900 : FontWeight.w700,
                  color: locked
                      ? AppColors.darkBrownLight
                      : AppColors.darkBrown,
                ),
              ),
            ),
            Text(
              formatExerciseType(node.exercise.type),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBrownLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
