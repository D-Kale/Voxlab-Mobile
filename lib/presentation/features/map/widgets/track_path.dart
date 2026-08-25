import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/lesson.dart';
import '../../../../domain/models/module.dart';
import '../../../../domain/models/track.dart';
import 'path_connector_painter.dart';
import 'path_lesson_node.dart';
import 'unit_header_pill.dart';

class TrackPath extends StatelessWidget {
  const TrackPath({
    super.key,
    required this.track,
    required this.completedExerciseIds,
    required this.onExerciseTap,
    required this.onModuleTap,
  });

  final Track track;
  final Set<String> completedExerciseIds;
  final void Function(String exerciseId, int lessonId) onExerciseTap;
  final void Function(int moduleId) onModuleTap;

  @override
  Widget build(BuildContext context) {
    final modules = _modulesWithContent;
    if (modules.isEmpty) return const SizedBox.shrink();

    final currentModuleIndex =
        modules.indexWhere((m) => !_isModuleDone(m));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < modules.length; i++) ...[
          UnitHeaderPill(
            unitNumber: i + 1,
            title: modules[i].title,
            state: _moduleState(modules[i], i, currentModuleIndex),
            onTap: () => onModuleTap(modules[i].id),
          ),
          const SizedBox(height: 24),
          _ModulePath(
            module: modules[i],
            isCurrentModule: i == currentModuleIndex,
            completedExerciseIds: completedExerciseIds,
            onExerciseTap: onExerciseTap,
          ),
          const SizedBox(height: 40),
        ],
      ],
    );
  }

  List<Module> get _modulesWithContent => track.modules
      .map(
        (m) => m.copyWith(
          lessons:
              m.lessons.where((l) => l.exercises.isNotEmpty).toList(),
        ),
      )
      .where((m) => m.lessons.isNotEmpty)
      .toList();

  bool _isLessonDone(Lesson lesson) =>
      lesson.exercises.every((e) => completedExerciseIds.contains(e.id));

  bool _isModuleDone(Module module) =>
      module.lessons.every(_isLessonDone);

  PathNodeState _moduleState(
    Module module,
    int index,
    int currentModuleIndex,
  ) {
    if (_isModuleDone(module)) return PathNodeState.completed;
    if (index == currentModuleIndex) return PathNodeState.current;
    return PathNodeState.pending;
  }
}

class _ModulePath extends StatefulWidget {
  const _ModulePath({
    required this.module,
    required this.isCurrentModule,
    required this.completedExerciseIds,
    required this.onExerciseTap,
  });

  final Module module;
  final bool isCurrentModule;
  final Set<String> completedExerciseIds;
  final void Function(String exerciseId, int lessonId) onExerciseTap;

  @override
  State<_ModulePath> createState() => _ModulePathState();
}

class _ModulePathState extends State<_ModulePath> {
  static Alignment _alignmentFor(int index) {
    return switch (index % 4) {
      1 => const Alignment(0.5, 0),
      3 => const Alignment(-0.5, 0),
      _ => Alignment.center,
    };
  }

  final GlobalKey _stackKey = GlobalKey();
  List<GlobalKey> _nodeKeys = [];

  @override
  void initState() {
    super.initState();
    _initKeys();
  }

  @override
  void didUpdateWidget(_ModulePath oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.module.lessons.map((l) => l.id).join(',');
    final newIds = widget.module.lessons.map((l) => l.id).join(',');
    if (oldIds != newIds) _initKeys();
  }

  void _initKeys() {
    _nodeKeys = List.generate(widget.module.lessons.length, (_) => GlobalKey());
  }

  List<PathNodeState> _computeStates(List<Lesson> lessons) {
    final currentLessonId = widget.isCurrentModule
        ? lessons
            .firstWhere(
              (l) => !_isLessonDone(l),
              orElse: () => lessons.first,
            )
            .id
        : null;

    return lessons.map((lesson) {
      if (_isLessonDone(lesson)) return PathNodeState.completed;
      if (widget.isCurrentModule && lesson.id == currentLessonId) {
        return PathNodeState.current;
      }
      return PathNodeState.pending;
    }).toList();
  }

  bool _isLessonDone(Lesson lesson) =>
      lesson.exercises.every((e) => widget.completedExerciseIds.contains(e.id));

  void _openLesson(Lesson lesson) {
    final exercise = lesson.exercises.firstWhere(
      (e) => !widget.completedExerciseIds.contains(e.id),
      orElse: () => lesson.exercises.first,
    );
    widget.onExerciseTap(exercise.id, lesson.id);
  }

  @override
  Widget build(BuildContext context) {
    final lessons = widget.module.lessons;
    final states = _computeStates(lessons);

    return Stack(
      key: _stackKey,
      clipBehavior: Clip.none,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < lessons.length; i++) ...[
              Align(
                alignment: _alignmentFor(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (states[i] == PathNodeState.current) ...[
                      const _StartBubble(),
                      const SizedBox(height: 6),
                    ],
                    PathLessonNode(
                      key: _nodeKeys[i],
                      state: states[i],
                      label: lessons[i].title,
                      onTap: () => _openLesson(lessons[i]),
                    ),
                  ],
                ),
              ),
              if (i < lessons.length - 1) const SizedBox(height: 28),
            ],
          ],
        ),
        if (_nodeKeys.length >= 2)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: PathConnectorPainter(
                  nodeKeys: _nodeKeys,
                  states: states,
                  stackKey: _stackKey,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _StartBubble extends StatelessWidget {
  const _StartBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: const Text(
        'INICIAR',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
