import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/lesson.dart';
import '../../../../domain/models/lesson_status.dart';
import '../../../../utils/lesson_progress_utils.dart';
import 'serpentine_lesson_node.dart';

class SerpentinePathWithConnectors extends StatefulWidget {
  const SerpentinePathWithConnectors({
    super.key,
    required this.lessons,
    required this.completedExerciseIds,
    required this.moduleIndex,
    required this.onLessonTap,
  });

  final List<Lesson> lessons;
  final Set<String> completedExerciseIds;
  final int moduleIndex;
  final void Function(int lessonId) onLessonTap;

  @override
  State<SerpentinePathWithConnectors> createState() =>
      _SerpentinePathWithConnectorsState();
}

class _SerpentinePathWithConnectorsState
    extends State<SerpentinePathWithConnectors> {
  final List<GlobalKey> _nodeKeys = [];
  List<LessonProgressInfo> _progressList = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(SerpentinePathWithConnectors oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lessons.length != widget.lessons.length) {
      _init();
    }
  }

  void _init() {
    _nodeKeys.clear();
    for (var i = 0; i < widget.lessons.length; i++) {
      _nodeKeys.add(GlobalKey());
    }
    _progressList = [];

    for (final lesson in widget.lessons) {
      _progressList.add(
        computeLessonProgress(lesson, widget.completedExerciseIds),
      );
    }

    for (var i = 0; i < widget.lessons.length; i++) {
      _progressList[i] = LessonProgressInfo(
        lessonId: _progressList[i].lessonId,
        status: determineLessonStatus(i, _progressList[i], _progressList),
        completedExercises: _progressList[i].completedExercises,
        totalExercises: _progressList[i].totalExercises,
        progressPercent: _progressList[i].progressPercent,
      );
    }
  }

  Alignment getSnakeAlignment(int index) {
    return switch (index % 4) {
      0 => Alignment.center,
      1 => Alignment(0.5, 0),
      2 => Alignment.center,
      3 => Alignment(-0.5, 0),
      _ => Alignment.center,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stackKey = GlobalKey();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          key: stackKey,
          clipBehavior: Clip.none,
          children: [
            // Nodos en columna
            Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.lessons.length, (i) {
                final progressInfo = _progressList[i];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: getSnakeAlignment(i),
                      child: SerpentineLessonNode(
                        key: _nodeKeys[i],
                        lesson: widget.lessons[i],
                        status: progressInfo.status,
                        progressPercent: progressInfo.progressPercent,
                        onTap: () => widget.onLessonTap(widget.lessons[i].id),
                      ),
                    ),
                    if (i < widget.lessons.length - 1)
                      const SizedBox(height: 16),
                  ],
                );
              }),
            ),

            // Curvas Bezier encima
            if (_nodeKeys.length >= 2)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _ConnectorPainter(
                      nodeKeys: _nodeKeys,
                      progressStates: _progressList,
                      stackKey: stackKey,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  _ConnectorPainter({
    required this.nodeKeys,
    required this.progressStates,
    required this.stackKey,
  });

  final List<GlobalKey> nodeKeys;
  final List<LessonProgressInfo> progressStates;
  final GlobalKey stackKey;

  Offset _getCenter(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    final stackBox = stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || stackBox == null) return Offset.zero;

    final size = renderBox.size;
    final nodeGlobal = renderBox.localToGlobal(Offset.zero);
    final stackGlobal = stackBox.localToGlobal(Offset.zero);

    return Offset(
      nodeGlobal.dx - stackGlobal.dx + size.width / 2,
      nodeGlobal.dy - stackGlobal.dy + size.height / 2,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centers = nodeKeys.map((k) => _getCenter(k)).toList();

    for (var i = 1; i < centers.length; i++) {
      final start = centers[i - 1];
      final end = centers[i];

      if (start == Offset.zero || end == Offset.zero) continue;

      final isConnected =
          progressStates[i - 1].status == LessonStatus.completed;

      final paint = Paint()
        ..color = isConnected
            ? AppColors.success
            : AppColors.onSurfaceVariant.withValues(alpha: 0.35)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final dx = end.dx - start.dx;
      final dy = end.dy - start.dy;

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx + dx * 0.3,
          start.dy + dy * 0.33,
          start.dx + dx * 0.7,
          start.dy + dy * 0.67,
          end.dx,
          end.dy,
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ConnectorPainter oldDelegate) {
    return oldDelegate.nodeKeys.length != nodeKeys.length;
  }
}
