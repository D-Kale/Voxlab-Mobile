import 'package:flutter_test/flutter_test.dart';
import 'package:voxlab/core/audio/music_service.dart';
import 'package:voxlab/presentation/features/games/game_catalog.dart';

void main() {
  test('the latest scope wins and popping restores the previous one', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final music = MusicService(() => 0); // muted: nothing actually plays
    final shell = Object();
    final game = Object();

    music.push(shell, MusicTrack.map);
    expect(music.wanted, MusicTrack.map);
    music.push(game, MusicTrack.upbeatSpark);
    expect(music.wanted, MusicTrack.upbeatSpark);
    music.pop(game);
    expect(music.wanted, MusicTrack.map);
  });

  test('voice games stay silent, the rest have music', () {
    for (final game in GameId.values) {
      expect(game.music == null, game.usesMic, reason: game.slug);
    }
  });
}
