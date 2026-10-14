import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voxlab/core/constants/app_theme.dart';
import 'package:voxlab/presentation/features/games/game_catalog.dart';
import 'package:voxlab/presentation/features/games/game_content.dart';
import 'package:voxlab/presentation/features/games/game_screen.dart';
import 'package:voxlab/presentation/features/games/widgets/game_kit.dart';
import 'package:voxlab/presentation/features/games/widgets/voice_helpers.dart';
import 'package:voxlab/presentation/shared/providers/game_records_provider.dart';

import '../golden/golden_fonts.dart';

void main() {
  setUpAll(loadGoldenFonts);

  group('scoring', () {
    test('stars follow the accuracy thresholds', () {
      GameScore s(double r) => GameScore(points: 0, ratio: r);
      expect(s(0.49).stars, 0);
      expect(s(0.5).stars, 1);
      expect(s(0.75).stars, 2);
      expect(s(0.9).stars, 3);
    });

    test('combo multiplier', () {
      expect(comboMultiplier(2), 1);
      expect(comboMultiplier(3), 2);
      expect(comboMultiplier(6), 3);
    });

    test('xp rewards stars and records', () {
      expect(GameRecordsNotifier.xpFor(0, isRecord: false), 2);
      expect(GameRecordsNotifier.xpFor(3, isRecord: true), 25);
    });
  });

  group('speech helpers', () {
    test('similarity ignores accents, case and punctuation', () {
      expect(
        speechSimilarity('Pablito clavó un clavito.', 'pablito clavo un clavito'),
        1,
      );
      expect(
        speechSimilarity('Tres tristes tigres', 'tres tristes tigres tragaban'),
        lessThan(1),
      );
      expect(speechSimilarity('hola', ''), 0);
    });

    test('missing words lists what was not heard', () {
      expect(
        missingWords('Pepe Pecas pica papas', 'pepe pica papas'),
        ['Pecas'],
      );
    });
  });

  group('content', () {
    test('every filler sentence of level 1 has a filler', () {
      for (final s in fillerSentencesL1) {
        expect(RegExp(r'\*[^*]+\*').hasMatch(s), isTrue, reason: s);
      }
    });

    test('emphasis answers point at a word', () {
      for (final r in emphasisRounds) {
        expect(r.answer, lessThan(r.sentence.split(' ').length), reason: r.meaning);
      }
    });

    test('taboo answers avoid the banned words', () {
      for (final r in tabooRounds) {
        for (final word in r.banned) {
          expect(
            RegExp('\\b$word', caseSensitive: false).hasMatch(r.correct),
            isFalse,
            reason: '${r.target}: "$word"',
          );
        }
      }
    });

    test('every game has a unique slug', () {
      final slugs = GameId.values.map((g) => g.slug).toSet();
      expect(slugs.length, GameId.values.length);
    });
  });

  group('game screens', () {
    Future<void> pumpGame(WidgetTester tester, GameId game) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      useReducedMotion(tester);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: GameScreen(game: game),
          ),
        ),
      );
      await tester.pump();
    }

    for (final game in GameId.values) {
      testWidgets('${game.slug} shows its intro and starts', (tester) async {
        await pumpGame(tester, game);
        expect(find.text(game.title), findsOneWidget);
        expect(find.text('¡A JUGAR!'), findsOneWidget);

        await tester.tap(find.text('¡A JUGAR!'));
        // Run a few seconds of game time.
        for (var i = 0; i < 30; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(tester.takeException(), isNull);

        // Unmount and flush pending delays.
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });
    }

    testWidgets('swipe games explain each card after the call',
        (tester) async {
      await pumpGame(tester, GameId.bodySwipe);
      await tester.tap(find.text('¡A JUGAR!'));
      await tester.pump();
      await tester.tap(find.text('NERVIOS'));
      // The card flies away, then the verdict shows.
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(VerdictBadge), findsOneWidget);
      final why = bodyCards.map((c) => c.why).where(
        (w) => find.text(w).evaluate().isNotEmpty,
      );
      expect(why, hasLength(1));
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('myth or fact plays to the results screen', (tester) async {
      await pumpGame(tester, GameId.mythFact);
      await tester.tap(find.text('¡A JUGAR!'));
      await tester.pump();
      for (var round = 0; round < 10; round++) {
        await tester.tap(find.text('REALIDAD'));
        await tester.pump(const Duration(milliseconds: 1800));
      }
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('JUGAR DE NUEVO'), findsOneWidget);
      expect(find.text('PUNTOS'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
