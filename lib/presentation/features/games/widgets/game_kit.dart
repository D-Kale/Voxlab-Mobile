import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../shared/widgets/chunky.dart';

/// Result of one play, reported by every minigame.
@immutable
class GameScore {
  const GameScore({
    required this.points,
    required this.ratio,
    this.headline,
    this.notes = const [],
    this.coachTip,
  });

  /// Arcade points (with combos). Used for records.
  final int points;

  /// Accuracy 0..1. Decides the stars.
  final double ratio;

  /// One-line summary for the results screen ("8 de 10 muletillas").
  final String? headline;

  /// Short learning notes shown under the stars.
  final List<String> notes;

  /// Tip from the AI coach, for voice games.
  final String? coachTip;

  int get stars {
    if (ratio >= 0.9) return 3;
    if (ratio >= 0.75) return 2;
    if (ratio >= 0.5) return 1;
    return 0;
  }
}

typedef OnGameFinish = void Function(GameScore score);

/// x1, x2 from 3 hits in a row, x3 from 6.
int comboMultiplier(int streak) => streak >= 6 ? 3 : (streak >= 3 ? 2 : 1);

/// Big text style used across the games.
TextStyle gameText(
  double size, {
  Color color = AppColors.darkBrown,
  FontWeight weight = FontWeight.w900,
  double? height,
}) => GoogleFonts.dmSans(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
);

/// Top bar of a running game: close, time bar, lives, combo and points.
class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.onClose,
    this.timeLeft,
    this.lives,
    this.maxLives = 3,
    this.points,
    this.streak = 0,
    this.progressColor = AppColors.accentRed,
  });

  final VoidCallback onClose;

  /// 0..1 of the time (or rounds) left; hidden when null.
  final double? timeLeft;
  final int? lives;
  final int maxLives;
  final int? points;
  final int streak;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    final multiplier = comboMultiplier(streak);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onClose,
                tooltip: 'Salir del juego',
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.darkBrownLight,
                  size: 28,
                ),
              ),
              if (timeLeft != null)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: timeLeft!.clamp(0.0, 1.0),
                      minHeight: 14,
                      backgroundColor: AppColors.idleLip.withValues(alpha: 0.5),
                      color: timeLeft! < 0.25
                          ? AppColors.accentRed
                          : progressColor,
                    ),
                  ),
                )
              else
                const Spacer(),
              if (lives != null) ...[
                const SizedBox(width: 10),
                for (var i = 0; i < maxLives; i++)
                  Icon(
                    i < lives!
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: AppColors.accentRed,
                    size: 22,
                  ),
              ],
            ],
          ),
          if (points != null)
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 2),
              child: Row(
                children: [
                  ChunkyTag(
                    label: '$points pts',
                    icon: Icons.bolt_rounded,
                    color: AppColors.accentRed,
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, a) =>
                        ScaleTransition(scale: a, child: child),
                    child: multiplier > 1
                        ? ChunkyTag(
                            key: ValueKey(multiplier),
                            label: 'COMBO x$multiplier',
                            icon: Icons.local_fire_department_rounded,
                            color: AppColors.onPrimaryContainer,
                            filled: true,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Three stars, filled up to [stars].
class StarsRow extends StatelessWidget {
  const StarsRow({super.key, required this.stars, this.size = 44});

  final int stars;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: EdgeInsets.only(
              left: 2,
              right: 2,
              bottom: i == 1 ? size * 0.25 : 0,
            ),
            child: Icon(
              i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
              size: i == 1 ? size * 1.2 : size,
              color: i < stars ? AppColors.gold : AppColors.idleLip,
            ),
          ),
      ],
    );
  }
}

/// Short floating verdict ("¡Perfecta!", "Apurado") over the play area.
class VerdictBadge extends StatelessWidget {
  const VerdictBadge({super.key, required this.text, required this.good});

  final String text;
  final bool good;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(text + good.toString()),
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Transform.scale(scale: v, child: child),
      child: ChunkyCard(
        colors: good ? ChunkyColors.green : ChunkyColors.red,
        radius: 99,
        depth: 4,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Text(text, style: gameText(18, color: Colors.white)),
      ),
    );
  }
}
