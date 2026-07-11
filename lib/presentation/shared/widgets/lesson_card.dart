import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/models/lesson.dart';
import 'loading_skeleton.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lesson,
    this.isCompleted = false,
    this.isLocked = false,
    this.onTap,
    this.score,
  });

  final Lesson lesson;
  final bool isCompleted;
  final bool isLocked;
  final VoidCallback? onTap;
  final int? score;

  @override
  Widget build(BuildContext context) {
    final String semanticsLabel;
    if (isCompleted) {
      semanticsLabel = 'Lección completada: ${lesson.title}';
    } else if (isLocked) {
      semanticsLabel = 'Lección bloqueada: ${lesson.title}';
    } else {
      semanticsLabel = 'Lección: ${lesson.title}';
    }

    return Semantics(
      label: semanticsLabel,
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Card(
          child: InkWell(
            onTap: isLocked ? null : onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Semantics(
                    excludeSemantics: true,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            isCompleted
                                ? AppColors.success.withValues(alpha: 0.15)
                                : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child:
                            isCompleted
                                ? const Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                  size: 24,
                                )
                                : isLocked
                                ? const Icon(
                                  Icons.lock,
                                  color: AppColors.onSurfaceVariant,
                                  size: 20,
                                )
                                : const Icon(
                                  Icons.play_arrow,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExcludeSemantics(
                          child: Text(
                            lesson.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        if (lesson.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            lesson.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (lesson.estimatedTimeSeconds != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Semantics(
                                excludeSemantics: true,
                                child: const Icon(
                                  Icons.timer_outlined,
                                  size: 14,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(lesson.estimatedTimeSeconds! / 60).round()} min',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Semantics(
                    excludeSemantics: true,
                    child: Icon(
                      isCompleted
                          ? Icons.check_circle
                          : Icons.chevron_right,
                      color:
                          isCompleted
                              ? AppColors.success
                              : AppColors.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LessonCardSkeleton extends StatelessWidget {
  const LessonCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLine(width: 200, height: 16),
                  SizedBox(height: 8),
                  SkeletonLine(width: 280, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
