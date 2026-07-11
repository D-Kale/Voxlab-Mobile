import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/models/lesson.dart';
import '../../../../domain/models/lesson_status.dart';
import 'lesson_node.dart';

class ModuleSection extends StatelessWidget {
  const ModuleSection({
    super.key,
    required this.moduleTitle,
    required this.lessons,
    required this.lessonStatuses,
    required this.onLessonTap,
  });

  final String moduleTitle;
  final List<Lesson> lessons;
  final Map<int, LessonStatus> lessonStatuses;
  final void Function(int lessonId) onLessonTap;

  @override
  Widget build(BuildContext context) {
    if (lessons.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          moduleTitle,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: lessons.length,
            separatorBuilder: (_, i) {
              final leftStatus = lessonStatuses[lessons[i].id];
              final isConnected = leftStatus == LessonStatus.completed;
              return Container(
                width: 16,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppColors.success.withValues(alpha: 0.5)
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
            itemBuilder: (_, i) {
              final lesson = lessons[i];
              final status = lessonStatuses[lesson.id] ?? LessonStatus.locked;
              return Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? 2 : 0,
                  right: i == lessons.length - 1 ? 2 : 0,
                ),
                child: LessonNode(
                  lessonId: lesson.id,
                  lessonNumber: i + 1,
                  status: status,
                  onTap: () => onLessonTap(lesson.id),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
