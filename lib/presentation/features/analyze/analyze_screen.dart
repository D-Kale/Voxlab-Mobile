import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../../domain/models/progress.dart';
import '../../shared/providers/content_provider.dart';
import '../../shared/providers/progress_provider.dart';
import '../../shared/widgets/pill_badge.dart';
import '../../shared/widgets/section_header.dart';
import '../../../utils/exercise_name_utils.dart';
import 'widgets/weekly_chart.dart';

class AnalyzeScreen extends ConsumerWidget {
  const AnalyzeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(progressNotifierProvider);
    final totalXp = ref.watch(totalXpStateProvider);
    final completedCount = ref.watch(completedExerciseCountProvider);
    final nameMap = ref.watch(exerciseNameMapProvider);
    final recent = entries.reversed.take(10).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Analizar')),
      body: entries.isEmpty
          ? _EmptyAnalysis(onGoPractice: () => context.go(AppRoutes.practice))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    PillBadge(
                      icon: Icons.auto_awesome,
                      label: '$totalXp',
                      style: PillBadgeStyle.xp,
                    ),
                    const SizedBox(width: 8),
                    PillBadge(
                      icon: Icons.check_circle_outline,
                      label: '$completedCount',
                      style: PillBadgeStyle.streak,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const WeeklyChart(),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Historial reciente'),
                const SizedBox(height: 8),
                for (final entry in recent)
                  _HistoryTile(entry: entry, nameMap: nameMap),
              ],
            ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.nameMap});

  final Progress entry;
  final Map<String, String> nameMap;

  @override
  Widget build(BuildContext context) {
    final name = resolveExerciseName(
      entry.exerciseId,
      '',
      nameMap,
    );
    final completedAt = entry.completedAt;
    final dateLabel = completedAt == null
        ? ''
        : '${completedAt.day}/${completedAt.month} '
            '${completedAt.hour.toString().padLeft(2, '0')}:'
            '${completedAt.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: Semantics(
            excludeSemantics: true,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: AppColors.success,
                size: 20,
              ),
            ),
          ),
          title: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: dateLabel.isEmpty
              ? null
              : Text(dateLabel, style: Theme.of(context).textTheme.bodyMedium),
          trailing: Text(
            '+${entry.score ?? 0} XP',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}

class _EmptyAnalysis extends StatelessWidget {
  const _EmptyAnalysis({required this.onGoPractice});

  final VoidCallback onGoPractice;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              excludeSemantics: true,
              child: Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insights_outlined,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Todavía no hay datos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Completá tu primer ejercicio y acá vas a ver '
              'tu progreso semanal y tu historial.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onGoPractice,
              icon: const Icon(Icons.fitness_center),
              label: const Text('Ir a practicar'),
            ),
          ],
        ),
      ),
    );
  }
}
