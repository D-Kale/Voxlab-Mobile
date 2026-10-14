import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:voxlab/core/constants/app_colors.dart';
import 'package:voxlab/core/constants/app_theme.dart';
import 'package:voxlab/presentation/features/map/widgets/map_path_model.dart';
import 'package:voxlab/presentation/features/map/widgets/track_path.dart';

import '../fixtures/map_fixtures.dart';
import 'golden_fonts.dart';

void main() {
  setUpAll(loadGoldenFonts);

  // The first test that uses a given `google_fonts` weight in an isolate
  // lays its text out before that weight is available, and the already laid
  // out text keeps the blocky fallback metrics. A throwaway first test that
  // uses the heaviest weight pays that cost outside the goldens.
  testWidgets('warm up text pipeline', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Primeros pasos',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await settleImages(tester);
  });

  Future<void> pumpMap(
    WidgetTester tester, {
    required Set<String> completed,
    Size surface = const Size(390, 1000),
  }) async {
    tester.view.physicalSize = surface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    useReducedMotion(tester);

    final model = MapPathModel.build([buildDemoTrack()], completed);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            slivers: buildMapSlivers(
              model: model,
              onStart: (_) {},
              onGuide: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await settleImages(tester);
  }

  group('Map path goldens', () {
    testWidgets('fresh progress', (tester) async {
      await pumpMap(tester, completed: const {});
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/map_path_fresh.png'),
      );
    });

    testWidgets('mid progress', (tester) async {
      await pumpMap(tester, completed: const {'e1', 'e2', 'e3'});
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/map_path_mid.png'),
      );
    });

    testWidgets('everything completed', (tester) async {
      await pumpMap(tester, completed: allExerciseIds(buildDemoTrack()));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/map_path_complete.png'),
      );
    });

    testWidgets('narrow screen', (tester) async {
      await pumpMap(
        tester,
        completed: const {'e1', 'e2'},
        surface: const Size(320, 1000),
      );
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/map_path_narrow.png'),
      );
    });
  });

  testWidgets('renders without overflow or layout exceptions',
      (tester) async {
    await pumpMap(tester, completed: const {'e1'});
    expect(tester.takeException(), isNull);
    expect(find.text('UNIDAD 1'), findsOneWidget);
    expect(find.text('UNIDAD 2'), findsOneWidget);
  });
}
