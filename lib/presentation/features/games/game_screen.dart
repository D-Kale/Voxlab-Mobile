import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/sound_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../shared/providers/game_records_provider.dart';
import '../../shared/widgets/chunky.dart';
import '../../shared/widgets/lesson_widgets.dart';
import '../../shared/widgets/motion.dart';
import '../../shared/widgets/voxi_mood.dart';
import 'game_catalog.dart';
import 'games/body_swipe_game.dart';
import 'games/breath_balloon_game.dart';
import 'games/emphasis_game.dart';
import 'games/filler_hunt_game.dart';
import 'games/hook_swipe_game.dart';
import 'games/improv_wheel_game.dart';
import 'games/last_row_game.dart';
import 'games/myth_fact_game.dart';
import 'games/pause_perfect_game.dart';
import 'games/speech_builder_game.dart';
import 'games/story_cards_game.dart';
import 'games/taboo_game.dart';
import 'games/tongue_twister_game.dart';
import 'widgets/game_kit.dart';

enum _Phase { intro, play, results }

/// Full-screen host of a minigame: intro card, the game, results.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key, required this.game});

  final GameId game;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  _Phase _phase = _Phase.intro;
  int _round = 0;
  GameScore? _score;
  GameReward? _reward;

  void _play() {
    playSfx(context, Sfx.tap);
    setState(() {
      _round++;
      _phase = _Phase.play;
    });
  }

  void _finish(GameScore score) {
    if (!mounted || _phase != _Phase.play) return;
    final reward = ref
        .read(gameRecordsProvider.notifier)
        .record(
          slug: widget.game.slug,
          points: score.points,
          stars: score.stars,
          daily: widget.game == GameId.improvWheel,
        );
    playSfx(context, score.stars > 0 ? Sfx.complete : Sfx.wrong);
    setState(() {
      _score = score;
      _reward = reward;
      _phase = _Phase.results;
    });
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/practice');
    }
  }

  Widget _game() {
    final key = ValueKey(_round);
    final onFinish = _finish;
    final onClose = _close;
    return switch (widget.game) {
      GameId.fillerHunt => FillerHuntGame(
        key: key,
        onFinish: onFinish,
        onClose: onClose,
      ),
      GameId.pausePerfect => PausePerfectGame(
        key: key,
        onFinish: onFinish,
        onClose: onClose,
      ),
      GameId.emphasis => EmphasisGame(
        key: key,
        onFinish: onFinish,
        onClose: onClose,
      ),
      GameId.breathBalloon => BreathBalloonGame(
        key: key,
        onFinish: onFinish,
        onClose: onClose,
      ),
      GameId.lastRow => LastRowGame(
        key: key,
        onFinish: onFinish,
        onClose: onClose,
      ),
      GameId.tongueTwister => TongueTwisterGame(
        key: key,
        onFinish: onFinish,
        onClose: onClose,
      ),
      GameId.bodySwipe => BodySwipeGame(
        key: key,
        onFinish: onFinish,
        onClose: onClose,
      ),
      GameId.hookSwipe => HookSwipeGame(
        key: key,
        onFinish: onFinish,
        onClose: onClose,
      ),
      GameId.speechBuilder => SpeechBuilderGame(
        key: key,
        onFinish: onFinish,
        onClose: onClose,
      ),
      GameId.taboo => TabooGame(key: key, onFinish: onFinish, onClose: onClose),
      GameId.storyCards => StoryCardsGame(
        key: key,
        onFinish: onFinish,
        onClose: onClose,
      ),
      GameId.improvWheel => ImprovWheelGame(
        key: key,
        onFinish: onFinish,
        onClose: onClose,
      ),
      GameId.mythFact => MythFactGame(
        key: key,
        onFinish: onFinish,
        onClose: onClose,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lessonBackground,
      body: SafeArea(
        child: switch (_phase) {
          _Phase.intro => _Intro(
            game: widget.game,
            onPlay: _play,
            onClose: _close,
          ),
          _Phase.play => _game(),
          _Phase.results => _Results(
            game: widget.game,
            score: _score!,
            reward: _reward!,
            onReplay: _play,
            onClose: _close,
          ),
        },
      ),
    );
  }
}

class _Intro extends ConsumerWidget {
  const _Intro({
    required this.game,
    required this.onPlay,
    required this.onClose,
  });

  final GameId game;
  final VoidCallback onPlay;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final record = ref.watch(gameRecordsProvider).of(game.slug);
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onClose,
            tooltip: 'Volver',
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.darkBrownLight,
              size: 28,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            children: [
              const SizedBox(height: 8),
              Center(
                child: EntranceAnimation(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: game.colors.face,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: game.colors.lip,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      game.icon,
                      size: 52,
                      color: game.colors.content,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                game.title,
                textAlign: TextAlign.center,
                style: gameText(28),
              ),
              const SizedBox(height: 6),
              Text(
                game.skill.label.toUpperCase(),
                textAlign: TextAlign.center,
                style: gameText(
                  13,
                  color: AppColors.darkBrownLight,
                  weight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 22),
              VoxiSays(text: game.howTo),
              const SizedBox(height: 18),
              if (game.usesMic)
                const _InfoRow(
                  icon: Icons.mic_rounded,
                  text:
                      'Este juego usa el micrófono. Buscá un lugar tranquilo.',
                ),
              if (record.plays > 0)
                _InfoRow(
                  icon: Icons.emoji_events_rounded,
                  text:
                      'Tu récord: ${record.bestPoints} pts · '
                      '${record.plays} ${record.plays == 1 ? 'partida' : 'partidas'}',
                  trailing: StarsRow(stars: record.bestStars, size: 18),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: ChunkyButton(
            label: '¡A JUGAR!',
            icon: Icons.play_arrow_rounded,
            colors: ChunkyColors.green,
            onPressed: onPlay,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.trailing});

  final IconData icon;
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ChunkyCard(
        depth: 3,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentRed, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: gameText(14, weight: FontWeight.w700)),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({
    required this.game,
    required this.score,
    required this.reward,
    required this.onReplay,
    required this.onClose,
  });

  final GameId game;
  final GameScore score;
  final GameReward reward;
  final VoidCallback onReplay;
  final VoidCallback onClose;

  String get _title => switch (score.stars) {
    3 => '¡Impecable!',
    2 => '¡Muy bien!',
    1 => '¡Bien hecho!',
    _ => '¡Seguí practicando!',
  };

  VoxiMood get _mood => switch (score.stars) {
    3 => VoxiMood.love,
    2 => VoxiMood.singing,
    1 => VoxiMood.laugh,
    _ => VoxiMood.shy,
  };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                children: [
                  Center(
                    child: Bob(
                      child: Image.asset(_mood.asset, width: 120, height: 120),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _title,
                    textAlign: TextAlign.center,
                    style: gameText(30),
                  ),
                  const SizedBox(height: 12),
                  Center(child: StarsRow(stars: score.stars)),
                  if (score.headline != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      score.headline!,
                      textAlign: TextAlign.center,
                      style: gameText(16, weight: FontWeight.w700),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _Stat(
                          label: 'PUNTOS',
                          value: '${score.points}',
                          colors: ChunkyColors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Stat(
                          label: 'XP',
                          value: '+${reward.xp}',
                          colors: ChunkyColors.gold,
                        ),
                      ),
                    ],
                  ),
                  if (reward.isRecord) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: ChunkyTag(
                        label: '¡NUEVO RÉCORD! Antes: ${reward.previousBest}',
                        icon: Icons.emoji_events_rounded,
                        color: AppColors.goldDark,
                      ),
                    ),
                  ],
                  if (score.coachTip != null) ...[
                    const SizedBox(height: 16),
                    AiCoachCard(text: score.coachTip!),
                  ],
                  if (score.notes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    for (final note in score.notes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.lightbulb_rounded,
                                size: 18,
                                color: AppColors.goldDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                note,
                                style: gameText(14, weight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Column(
                children: [
                  ChunkyButton(
                    label: 'JUGAR DE NUEVO',
                    icon: Icons.replay_rounded,
                    colors: ChunkyColors.green,
                    onPressed: onReplay,
                  ),
                  const SizedBox(height: 12),
                  ChunkyButton(
                    label: 'SALIR',
                    colors: ChunkyColors.white,
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (score.stars >= 2)
          const Positioned.fill(
            child: IgnorePointer(
              child: ConfettiBurst(
                colors: [
                  AppColors.accentRed,
                  AppColors.gold,
                  AppColors.success,
                  AppColors.primary,
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.colors});

  final String label;
  final String value;
  final ChunkyColors colors;

  @override
  Widget build(BuildContext context) {
    return ChunkyCard(
      colors: colors,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Column(
        children: [
          Text(
            label,
            style: gameText(12, color: colors.content, weight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(value, style: gameText(28, color: colors.content)),
        ],
      ),
    );
  }
}
