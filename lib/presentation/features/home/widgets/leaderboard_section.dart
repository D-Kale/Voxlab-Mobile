import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LeaderboardEntry {
  final int rank;
  final String name;
  final int xp;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.xp,
    this.isCurrentUser = false,
  });
}

class LeaderboardSection extends StatelessWidget {
  const LeaderboardSection({
    super.key,
    required this.entries,
    this.currentUserXp,
  });

  final List<LeaderboardEntry> entries;
  final int? currentUserXp;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.leaderboard_rounded,
                  size: 18,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Leaderboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...entries.map((entry) => _LeaderboardRow(entry: entry)),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final LeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final medalColor = switch (entry.rank) {
      1 => AppColors.secondary,
      2 => AppColors.onSurfaceVariant,
      3 => AppColors.primary,
      _ => null,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.08)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: medalColor != null
                ? Icon(Icons.emoji_events, size: 18, color: medalColor)
                : Text(
                    '${entry.rank}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    entry.isCurrentUser ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Text(
            '${entry.xp} XP',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: entry.isCurrentUser
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
