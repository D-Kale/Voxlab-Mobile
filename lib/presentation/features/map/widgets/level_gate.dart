import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/chunky.dart';
import '../../../shared/widgets/motion.dart';
import 'map_path_model.dart';
import 'map_scenery.dart';

/// Opening card of a level (track): its landscape, number, title and
/// progress. Marks the jump to a new level on the map.
class LevelGate extends StatelessWidget {
  const LevelGate({super.key, required this.level});

  final PathLevel level;

  static const double _sceneHeight = 118;
  static const double _badgeSize = 60;

  @override
  Widget build(BuildContext context) {
    final state = level.state;
    final locked = state == LevelState.locked;
    final badgeColors = switch (state) {
      LevelState.completed => ChunkyColors.gold,
      LevelState.current => level.biome.accent,
      LevelState.locked => ChunkyColors.idle,
    };
    final isNew =
        state == LevelState.current && level.number > 1 && level.doneCount == 0;
    final progress = level.exerciseCount == 0
        ? 0.0
        : level.doneCount / level.exerciseCount;
    final stateLabel = switch (state) {
      LevelState.completed => 'Completado',
      LevelState.current => 'En curso',
      LevelState.locked => 'Bloqueado',
    };

    return Semantics(
      container: true,
      label:
          'Nivel ${level.number}: ${level.title}. $stateLabel, '
          '${level.doneCount} de ${level.exerciseCount} ejercicios.',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 14),
        child: EntranceAnimation(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              ChunkyCard(
                padding: EdgeInsets.zero,
                radius: 24,
                depth: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(23),
                      ),
                      child: SizedBox(
                        height: _sceneHeight,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CustomPaint(
                              painter: LevelLandscapePainter(
                                biome: level.biome,
                                flagColor: state == LevelState.completed
                                    ? AppColors.gold
                                    : AppColors.accentRed,
                              ),
                            ),
                            if (locked)
                              ColoredBox(
                                color: AppColors.darkBrown.withValues(
                                  alpha: 0.45,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: _badgeSize + 10,
                            ),
                            child: Text(
                              'NIVEL ${level.number} · '
                              '${level.biome.label.toUpperCase()}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                color: locked
                                    ? AppColors.darkBrownLight
                                    : level.biome.accent.lip,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            level.title,
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkBrown,
                              height: 1.15,
                            ),
                          ),
                          if (level.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              level.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBrownLight,
                                height: 1.35,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(99),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 10,
                                    color: state == LevelState.completed
                                        ? AppColors.gold
                                        : level.biome.accent.face,
                                    backgroundColor: AppColors.idleFace,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${level.doneCount}/${level.exerciseCount}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkBrownLight,
                                ),
                              ),
                              const SizedBox(width: 10),
                              ChunkyTag(
                                label: stateLabel,
                                icon: switch (state) {
                                  LevelState.completed =>
                                    Icons.emoji_events_rounded,
                                  LevelState.current => Icons.flag_rounded,
                                  LevelState.locked => Icons.lock_rounded,
                                },
                                color: switch (state) {
                                  LevelState.completed => AppColors.goldDark,
                                  LevelState.current => level.biome.accent.lip,
                                  LevelState.locked => AppColors.darkBrownLight,
                                },
                              ),
                            ],
                          ),
                          if (locked) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Completá el nivel ${level.number - 1} para '
                              'desbloquearlo.',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkBrownLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                top: _sceneHeight - _badgeSize / 2,
                child: _LevelBadge(
                  number: level.number,
                  colors: badgeColors,
                  size: _badgeSize,
                ),
              ),
              if (isNew)
                Positioned(
                  right: 12,
                  top: -14,
                  child: Bob(
                    amplitude: 3,
                    child: ChunkyCard(
                      colors: ChunkyColors.red,
                      radius: 99,
                      depth: 3,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        '¡NUEVO NIVEL!',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({
    required this.number,
    required this.colors,
    required this.size,
  });

  final int number;
  final ChunkyColors colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.face,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [BoxShadow(color: colors.lip, offset: const Offset(0, 4))],
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: GoogleFonts.dmSans(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: colors.content,
          height: 1,
        ),
      ),
    );
  }
}
