import 'package:flutter/material.dart';

import '../../../../domain/models/exercise.dart';
import '../../../../domain/models/lesson.dart';
import '../../../../domain/models/module.dart';
import '../../../../domain/models/track.dart';
import 'map_geometry.dart';
import 'path_connector_painter.dart';
import 'path_lesson_node.dart';

class TrackPath extends StatelessWidget {
  const TrackPath({
    super.key,
    required this.track,
    required this.completedExerciseIds,
    required this.onExerciseTap,
    this.anchorKey,
  });

  final Track track;
  final Set<String> completedExerciseIds;
  final void Function(String exerciseId, int lessonId) onExerciseTap;
  final GlobalKey? anchorKey;

  @override
  Widget build(BuildContext context) {
    final modules = _modulesWithContent;
    if (modules.isEmpty) return const SizedBox.shrink();

    // Flatten all exercises across modules/lessons with metadata.
    final exerciseNodes = <_ExerciseNodeInfo>[];
    var globalExerciseIndex = 0;
    for (var moduleIndex = 0; moduleIndex < modules.length; moduleIndex++) {
      final module = modules[moduleIndex];
      for (final lesson in module.lessons) {
        for (final exercise in lesson.exercises) {
          exerciseNodes.add(_ExerciseNodeInfo(
            globalIndex: globalExerciseIndex++,
            moduleIndex: moduleIndex,
            moduleId: module.id,
            lessonId: lesson.id,
            exercise: exercise,
            state: _computeExerciseState(exercise),
          ));
        }
      }
    }
    if (exerciseNodes.isEmpty) return const SizedBox.shrink();

    final nodeKeys = List.generate(exerciseNodes.length, (_) => GlobalKey());
    final currentModuleIndex = _findCurrentModuleIndex(modules);

    final columnChildren = <Widget>[];
    for (var moduleIndex = 0; moduleIndex < modules.length; moduleIndex++) {
      columnChildren.add(UnitBanner(
        state: _moduleState(
          modules[moduleIndex],
          moduleIndex,
          currentModuleIndex,
        ),
        unitNumber: moduleIndex + 1,
        title: modules[moduleIndex].title,
        onTap: () => _scrollToModule(moduleIndex, exerciseNodes, nodeKeys),
      ));
      columnChildren.add(const SizedBox(height: 12));
      columnChildren.add(_ModuleExercisesPath(
        exerciseNodes: exerciseNodes
            .where((n) => n.moduleIndex == moduleIndex)
            .toList(),
        nodeKeys: nodeKeys,
        anchorKey: moduleIndex == currentModuleIndex ? anchorKey : null,
        onExerciseTap: onExerciseTap,
      ));
      if (moduleIndex != modules.length - 1) {
        columnChildren.add(const SizedBox(height: 28));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );
  }

  int _findCurrentModuleIndex(List<Module> modules) =>
      modules.indexWhere((m) => !_isModuleDone(m));

  void _scrollToModule(
    int moduleIndex,
    List<_ExerciseNodeInfo> exerciseNodes,
    List<GlobalKey> nodeKeys,
  ) {
    final flatIndex =
        exerciseNodes.indexWhere((n) => n.moduleIndex == moduleIndex);
    if (flatIndex < 0) return;
    final ctx = nodeKeys[flatIndex].currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      alignment: 0.2,
    );
  }

  List<Module> get _modulesWithContent => track.modules
      .map((m) => m.copyWith(
            lessons: m.lessons.where((l) => l.exercises.isNotEmpty).toList(),
          ))
      .where((m) => m.lessons.isNotEmpty)
      .toList();

  bool _isExerciseDone(Exercise exercise) =>
      completedExerciseIds.contains(exercise.id);

  bool _isLessonDone(Lesson lesson) =>
      lesson.exercises.every((e) => _isExerciseDone(e));

  bool _isModuleDone(Module module) => module.lessons.every(_isLessonDone);

  PathNodeState _moduleState(Module module, int index, int currentModuleIndex) {
    if (_isModuleDone(module)) return PathNodeState.completed;
    if (index == currentModuleIndex) return PathNodeState.current;
    return PathNodeState.pending;
  }

  PathNodeState _computeExerciseState(Exercise exercise) {
    if (_isExerciseDone(exercise)) return PathNodeState.completed;

    final allExercises = _getAllExercisesInOrder();
    final firstIncompleteIndex =
        allExercises.indexWhere((e) => !_isExerciseDone(e));
    final thisIndex = allExercises.indexWhere((e) => e.id == exercise.id);

    if (firstIncompleteIndex >= 0 && thisIndex == firstIncompleteIndex) {
      return PathNodeState.current;
    }
    return PathNodeState.pending;
  }

  List<Exercise> _getAllExercisesInOrder() {
    final exercises = <Exercise>[];
    for (final module in _modulesWithContent) {
      for (final lesson in module.lessons) {
        exercises.addAll(lesson.exercises);
      }
    }
    return exercises;
  }
}

class _ExerciseNodeInfo {
  _ExerciseNodeInfo({
    required this.globalIndex,
    required this.moduleIndex,
    required this.moduleId,
    required this.lessonId,
    required this.exercise,
    required this.state,
  });

  final int globalIndex;
  final int moduleIndex;
  final int moduleId;
  final int lessonId;
  final Exercise exercise;
  final PathNodeState state;
}

/// Renders one module's exercise nodes with a shared geometry:
/// layout (`Positioned`) and paint (`PathConnectorPainter`) consume the
/// exact same centers from [MapGeometry], so lines always hit node edges
/// and nothing can overflow into the next unit header.
class _ModuleExercisesPath extends StatelessWidget {
  const _ModuleExercisesPath({
    required this.exerciseNodes,
    required this.nodeKeys,
    required this.onExerciseTap,
    this.anchorKey,
  });

  final List<_ExerciseNodeInfo> exerciseNodes;
  final List<GlobalKey> nodeKeys;
  final void Function(String exerciseId, int lessonId) onExerciseTap;
  final GlobalKey? anchorKey;

  @override
  Widget build(BuildContext context) {
    final centers = MapGeometry.centers(
      globalStartIndex: exerciseNodes.first.globalIndex,
      count: exerciseNodes.length,
    );
    final states = [for (final n in exerciseNodes) n.state];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cx = constraints.maxWidth / 2;
        return SizedBox(
          height: MapGeometry.height(exerciseNodes.length),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: PathConnectorPainter(
                      nodePositions: centers,
                      states: states,
                      nodeRadius: MapGeometry.nodeRadius,
                    ),
                  ),
                ),
              ),
              for (var i = 0; i < exerciseNodes.length; i++)
                _buildNode(i, cx, centers),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNode(int i, double cx, List<Offset> centers) {
    final info = exerciseNodes[i];
    Widget child = KeyedSubtree(
      key: nodeKeys[info.globalIndex],
      child: ExercisePathNode(
        exercise: info.exercise,
        state: info.state,
        onTap: () => onExerciseTap(info.exercise.id, info.lessonId),
      ),
    );
    if (i == 0 && anchorKey != null) {
      child = KeyedSubtree(key: anchorKey!, child: child);
    }
    return Positioned(
      left: cx + centers[i].dx - MapGeometry.labelWidth / 2,
      top: centers[i].dy - MapGeometry.nodeRadius,
      width: MapGeometry.labelWidth,
      child: child,
    );
  }
}
