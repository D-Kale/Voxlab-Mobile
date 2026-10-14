import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/routes.dart';
import '../../shared/providers/game_records_provider.dart';
import '../../shared/widgets/chunky.dart';
import '../../shared/widgets/motion.dart';
import '../../shared/widgets/tab_header.dart';
import '../../shared/widgets/voxi_mood.dart';
import '../games/game_catalog.dart';
import '../games/widgets/game_kit.dart';

/// Practice tab: speaking minigames grouped by skill, with the daily
/// improvisation challenge on top.
class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(gameRecordsProvider);
    final totalStars = GameId.values.fold(
      0,
      (int sum, g) => sum + records.of(g.slug).bestStars,
    );
    var index = 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          key: const Key('practice-games'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            const TabHeader(
              title: 'Practicar',
              subtitle: 'Minijuegos para entrenar tu oratoria jugando.',
            ),
            EntranceAnimation(child: _DailyChallengeCard(records: records)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    icon: Icons.star_rounded,
                    iconColor: AppColors.goldDark,
                    value: '$totalStars/${GameId.values.length * 3}',
                    label: 'estrellas',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    icon: Icons.bolt_rounded,
                    iconColor: AppColors.accentRed,
                    value: '${records.xp}',
                    label: 'XP en juegos',
                  ),
                ),
              ],
            ),
            for (final skill in GameSkill.values) ...[
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  skill.label,
                  style: GoogleFonts.dmSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkBrown,
                  ),
                ),
              ),
              for (final game in GameId.values.where((g) => g.skill == skill))
                EntranceAnimation(
                  delay: EntranceAnimation.stagger(index++),
                  child: _GameTile(game: game, record: records.of(game.slug)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

void _open(BuildContext context, GameId game) {
  context.push(AppRoutes.gamePath(game.slug));
}

/// Red hero card: the improvisation wheel as a daily streak challenge.
class _DailyChallengeCard extends StatelessWidget {
  const _DailyChallengeCard({required this.records});

  final GameRecords records;

  @override
  Widget build(BuildContext context) {
    final done = records.playedDailyToday;
    final streak = records.liveStreak;
    return ChunkyCard(
      colors: ChunkyColors.red,
      radius: 24,
      depth: 6,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Reto del día',
                        style: gameText(22, color: Colors.white, height: 1.15),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChunkyTag(
                      label: '$streak',
                      icon: Icons.local_fire_department_rounded,
                      color: AppColors.gold,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  done
                      ? '¡Hecho por hoy! Volvé mañana para seguir la racha.'
                      : 'Girá la ruleta e improvisá 45 segundos.',
                  style: gameText(
                    14,
                    color: Colors.white.withValues(alpha: 0.92),
                    weight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                ChunkyButton(
                  label: done ? 'OTRA VEZ' : 'GIRAR',
                  icon: Icons.casino_rounded,
                  height: 46,
                  depth: 4,
                  colors: const ChunkyColors(
                    face: Colors.white,
                    lip: Color(0xFF8A2416),
                    content: AppColors.accentRed,
                  ),
                  onPressed: () => _open(context, GameId.improvWheel),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Bob(
            child: Image.asset(
              (done ? VoxiMood.love : VoxiMood.singing).asset,
              width: 92,
              height: 92,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ChunkyCard(
      depth: 4,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: gameText(18)),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: gameText(
                    12,
                    color: AppColors.darkBrownLight,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameTile extends StatelessWidget {
  const _GameTile({required this.game, required this.record});

  final GameId game;
  final GameRecord record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ChunkyCard(
        onTap: () => _open(context, game),
        semanticsLabel: game.title,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: game.colors.face,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: game.colors.lip, offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(game.icon, color: game.colors.content, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: gameText(16.5, weight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    game.tagline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: gameText(
                      13.5,
                      color: AppColors.darkBrownLight,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StarsRow(stars: record.bestStars, size: 16),
                      if (game.usesMic) ...[
                        const SizedBox(width: 8),
                        const ChunkyTag(
                          label: 'Voz',
                          icon: Icons.mic_rounded,
                          color: AppColors.darkBrown,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.play_circle_fill_rounded,
              color: AppColors.success,
              size: 34,
            ),
          ],
        ),
      ),
    );
  }
}
