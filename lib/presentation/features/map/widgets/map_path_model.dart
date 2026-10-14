import '../../../../domain/models/exercise.dart';
import '../../../../domain/models/module.dart';
import '../../../../domain/models/track.dart';
import '../../../shared/widgets/chunky.dart';
import 'map_scenery.dart';

/// Completed and current exercises can be opened; locked ones cannot until
/// every exercise before them is done (same rule as `unlockedExerciseIds`).
enum PathNodeState { completed, current, locked }

class PathExerciseNode {
  const PathExerciseNode({
    required this.exercise,
    required this.lessonId,
    required this.state,
  });

  final Exercise exercise;
  final int lessonId;
  final PathNodeState state;
}

/// One unit (module) of the learning path, flattened to its exercises.
class PathUnit {
  const PathUnit({
    required this.trackIndex,
    required this.trackTitle,
    required this.levelNumber,
    required this.biome,
    required this.unitNumber,
    required this.module,
    required this.nodes,
    required this.globalStartIndex,
    required this.colors,
  });

  final int trackIndex;
  final String trackTitle;

  /// 1-based level (track) this unit belongs to; empty tracks are skipped.
  final int levelNumber;

  /// Landscape drawn around the unit, shared by every unit of the level.
  final MapBiome biome;

  /// 1-based position of the unit inside its track.
  final int unitNumber;
  final Module module;
  final List<PathExerciseNode> nodes;

  /// Serpentine phase of the first node; every unit also draws one trophy
  /// node after its exercises, which takes the next index.
  final int globalStartIndex;

  /// Unit identity color: completed and current nodes and the unit header
  /// use it, so every unit reads as its own chapter.
  final ChunkyColors colors;

  int get doneCount =>
      nodes.where((n) => n.state == PathNodeState.completed).length;

  bool get isDone => doneCount == nodes.length;

  bool get hasCurrent => nodes.any((n) => n.state == PathNodeState.current);

  /// Exercises plus the trophy.
  int get slotCount => nodes.length + 1;
}

enum LevelState { completed, current, locked }

/// One track of the path, shown as a "level" with its own landscape.
class PathLevel {
  const PathLevel({
    required this.number,
    required this.title,
    required this.description,
    required this.biome,
    required this.units,
  });

  final int number;
  final String title;
  final String description;
  final MapBiome biome;
  final List<PathUnit> units;

  int get exerciseCount => units.fold(0, (sum, u) => sum + u.nodes.length);

  int get doneCount => units.fold(0, (sum, u) => sum + u.doneCount);

  LevelState get state => doneCount == exerciseCount
      ? LevelState.completed
      : units.any((u) => u.hasCurrent)
      ? LevelState.current
      : LevelState.locked;
}

/// Pure path derivation from content and progress; no widgets.
///
/// The current node is the first incomplete exercise across every track, so
/// there is exactly one "EMPEZAR" call-out on the whole map.
class MapPathModel {
  const MapPathModel(this.units, [this.levels = const []]);

  final List<PathUnit> units;
  final List<PathLevel> levels;

  static const _unitPalette = [
    ChunkyColors.red,
    ChunkyColors.green,
    ChunkyColors.brown,
  ];

  factory MapPathModel.build(List<Track> tracks, Set<String> completed) {
    final units = <PathUnit>[];
    final levels = <PathLevel>[];
    var foundCurrent = false;
    var globalIndex = 0;

    for (var t = 0; t < tracks.length; t++) {
      final modules = tracks[t].modules
          .where((m) => m.lessons.any((l) => l.exercises.isNotEmpty))
          .toList();
      if (modules.isEmpty) continue;
      final levelNumber = levels.length + 1;
      final biome = MapBiome.forLevel(levelNumber);
      final levelUnits = <PathUnit>[];
      for (var m = 0; m < modules.length; m++) {
        final nodes = <PathExerciseNode>[];
        for (final lesson in modules[m].lessons) {
          for (final exercise in lesson.exercises) {
            final PathNodeState state;
            if (completed.contains(exercise.id)) {
              state = PathNodeState.completed;
            } else if (!foundCurrent) {
              state = PathNodeState.current;
              foundCurrent = true;
            } else {
              state = PathNodeState.locked;
            }
            nodes.add(
              PathExerciseNode(
                exercise: exercise,
                lessonId: lesson.id,
                state: state,
              ),
            );
          }
        }
        final unit = PathUnit(
          trackIndex: t,
          trackTitle: tracks[t].title,
          levelNumber: levelNumber,
          biome: biome,
          unitNumber: m + 1,
          module: modules[m],
          nodes: nodes,
          globalStartIndex: globalIndex,
          colors: _unitPalette[units.length % _unitPalette.length],
        );
        units.add(unit);
        levelUnits.add(unit);
        globalIndex += nodes.length + 1;
      }
      levels.add(
        PathLevel(
          number: levelNumber,
          title: tracks[t].title,
          description: tracks[t].description,
          biome: biome,
          units: levelUnits,
        ),
      );
    }
    return MapPathModel(units, levels);
  }
}
