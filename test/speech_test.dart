import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voxlab/core/constants/app_theme.dart';
import 'package:voxlab/data/media/media_permissions.dart';
import 'package:voxlab/data/media/speech_recorder.dart';
import 'package:voxlab/data/remote/services/analyzer_service.dart';
import 'package:voxlab/domain/models/exercise_outcome.dart';
import 'package:voxlab/domain/models/session_result.dart';
import 'package:voxlab/domain/models/speech_metrics.dart';
import 'package:voxlab/presentation/features/exercise/oratory/oratory_screen.dart';

import 'golden/golden_fonts.dart';

const _interval = SpeechRecorder.sampleInterval;

/// [seconds] of levels: speech at -20 dBFS, silence at -60 dBFS, with
/// silent gaps of [pause] every [every] seconds of speech.
List<double> _take({
  required int seconds,
  double pause = 1.0,
  int every = 6,
  double lead = 0.5,
}) {
  final samples = <double>[];
  void add(double secs, double db) {
    for (var i = 0; i < (secs * 10).round(); i++) {
      samples.add(db);
    }
  }

  add(lead, -60);
  var spoken = 0;
  while (samples.length < seconds * 10) {
    add(1, -20);
    spoken++;
    if (spoken % every == 0) add(pause, -60);
  }
  add(lead, -60);
  return samples;
}

int recorderLevelsSeen = 0;

class _FakeRecorder implements SpeechRecorder {
  _FakeRecorder(this.samples);

  final List<double> samples;
  final _levels = StreamController<double>.broadcast();
  bool started = false;

  @override
  Stream<double> get levels => _levels.stream;

  @override
  Future<void> start() async {
    started = true;
    // Like the real recorder: levels start flowing right away.
    Future(() {
      for (final db in samples.take(5)) {
        recorderLevelsSeen += _levels.hasListener ? 1 : 0;
        _levels.add(((db + 60) / 60).clamp(0.0, 1.0));
      }
    });
  }

  @override
  Future<SpeechRecording> stop() async => SpeechRecording(
    path: '/tmp/take.m4a',
    fileName: 'take.m4a',
    metrics: SpeechMetrics.fromLevels(samples, _interval),
  );

  @override
  Future<void> dispose() => _levels.close();
}

class _FakePermissions extends MediaPermissions {
  const _FakePermissions(this.access);

  final MediaAccess access;

  @override
  Future<MediaAccess> requestMicrophone() async => access;
}

class _FakeAnalyzer extends AnalyzerService {
  _FakeAnalyzer({this.response}) : super(Dio());

  final Map<String, dynamic>? response;
  int calls = 0;

  @override
  Future<Map<String, dynamic>> analyzeSpeech({
    required String path,
    required String fileName,
    int? minSeconds,
    int? targetSeconds,
  }) async {
    calls++;
    if (response == null) throw DioException(requestOptions: RequestOptions());
    return response!;
  }
}

void main() {
  setUpAll(loadGoldenFonts);

  group('SpeechMetrics.fromLevels', () {
    test('continuous loud speech is all speech', () {
      final m = SpeechMetrics.fromLevels(List.filled(100, -18), _interval);
      expect(m.speakingRatio, 1);
      expect(m.pauseCount, 0);
    });

    test('silence has no speech', () {
      final m = SpeechMetrics.fromLevels(List.filled(100, -60), _interval);
      expect(m.hasSpeech, isFalse);
      expect(m.duration, const Duration(seconds: 10));
    });

    test('counts internal pauses but not leading or trailing silence', () {
      final m = SpeechMetrics.fromLevels(
        _take(seconds: 30, pause: 1.0, every: 6, lead: 2),
        _interval,
      );
      // 2 s lead, then 4 cycles of 6 s speech + 1 s pause; the last pause
      // is trailing silence.
      expect(m.pauseCount, 3);
      expect(m.longestPause, const Duration(seconds: 1));
      expect(m.speakingRatio, greaterThan(0.7));
    });

    test('short gaps between words are not pauses', () {
      final m = SpeechMetrics.fromLevels(
        _take(seconds: 20, pause: 0.3, every: 2),
        _interval,
      );
      expect(m.pauseCount, 0);
    });
  });

  group('SessionResultBuilder.fromSpeech', () {
    test('steady take with regular pauses scores well', () {
      final m = SpeechMetrics.fromLevels(
        _take(seconds: 60, pause: 0.8, every: 8),
        _interval,
      );
      final r = SessionResultBuilder.fromSpeech(
        m,
        targetSeconds: 60,
        minSeconds: 30,
      );
      expect(r.overall, greaterThanOrEqualTo(90));
      expect(r.skills.map((s) => s.label), contains('Pausas'));
    });

    test('silent take scores zero with a hint', () {
      final m = SpeechMetrics.fromLevels(List.filled(200, -60), _interval);
      final r = SessionResultBuilder.fromSpeech(
        m,
        targetSeconds: 60,
        minSeconds: 30,
      );
      expect(r.overall, 0);
      expect(r.tips.single.text, contains('No detectamos tu voz'));
    });
  });

  group('Oratory exercise', () {
    Future<List<ExerciseOutcome>> pumpOratory(
      WidgetTester tester, {
      required MediaAccess access,
      required _FakeAnalyzer analyzer,
      _FakeRecorder? recorder,
    }) async {
      useReducedMotion(tester);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final outcomes = <ExerciseOutcome>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            mediaPermissionsProvider.overrideWithValue(
              _FakePermissions(access),
            ),
            analyzerServiceProvider.overrideWithValue(analyzer),
            speechRecorderFactoryProvider.overrideWithValue(
              () => recorder ?? _FakeRecorder(_take(seconds: 40)),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: OratoryWidget(
                prompt: 'Hablá sobre el tema.',
                topic: 'Mi ciudad',
                durationSeconds: 60,
                minDurationSeconds: 0,
                requirements: const [],
                points: 20,
                onCompleted: outcomes.add,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return outcomes;
    }

    Future<void> recordAndFinish(WidgetTester tester) async {
      await tester.tap(find.text('GRABAR'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Grabando'), findsOneWidget);
      // The live meter consumed the levels without errors.
      expect(recorderLevelsSeen, greaterThan(0));
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('TERMINÉ'));
      // The analysis is a chain of fake futures; give it a few frames.
      for (
        var i = 0;
        i < 20 && find.text('CONTINUAR').evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    testWidgets('uses the speech AI result when it answers', (tester) async {
      final analyzer = _FakeAnalyzer(
        response: {
          'success': true,
          'data': {
            'transcript': 'Hola, eh, les cuento sobre mi ciudad.',
            'words_per_minute': 132,
            'filler_words': 3,
            'score': 78,
            'score_breakdown': {
              'muletillas': {
                'score': 55,
                'weight': 0.25,
                'feedbacks': ['Usaste 3 muletillas.'],
              },
              'ritmo': {'score': 100, 'weight': 0.25, 'feedbacks': []},
            },
            'feedback': ['Buen ritmo'],
          },
        },
      );
      final outcomes = await pumpOratory(
        tester,
        access: MediaAccess.granted,
        analyzer: analyzer,
      );
      await recordAndFinish(tester);

      expect(analyzer.calls, 1);
      expect(find.text('Analizado con IA'), findsOneWidget);
      expect(find.text('132'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(
        find.text('Hola, eh, les cuento sobre mi ciudad.'),
        findsOneWidget,
      );

      await tester.ensureVisible(find.text('CONTINUAR'));
      await tester.tap(find.text('CONTINUAR'));
      expect(outcomes.single.score, 20);
      expect(outcomes.single.sessionResult?.overall, 78);
      expect(outcomes.single.sessionResult?.fillerWords, 3);
    });

    testWidgets('falls back to on-device analysis when the AI is down', (
      tester,
    ) async {
      final outcomes = await pumpOratory(
        tester,
        access: MediaAccess.granted,
        analyzer: _FakeAnalyzer(),
      );
      await recordAndFinish(tester);

      expect(find.text('Análisis en el dispositivo'), findsOneWidget);
      expect(find.text('—'), findsNWidgets(2));
      await tester.ensureVisible(find.text('CONTINUAR'));
      await tester.tap(find.text('CONTINUAR'));
      expect(outcomes.single.sessionResult, isNotNull);
    });

    testWidgets('denied microphone offers practice without recording', (
      tester,
    ) async {
      final recorder = _FakeRecorder(const []);
      final outcomes = await pumpOratory(
        tester,
        access: MediaAccess.denied,
        analyzer: _FakeAnalyzer(),
        recorder: recorder,
      );
      await tester.tap(find.text('GRABAR'));
      await tester.pumpAndSettle();
      expect(find.text('Necesito escucharte'), findsOneWidget);

      await tester.tap(find.text('PRACTICAR SIN GRABAR'));
      await tester.pump();
      expect(find.text('Práctica sin grabación'), findsOneWidget);
      expect(recorder.started, isFalse);

      await tester.tap(find.text('TERMINÉ'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('CONTINUAR'));
      expect(outcomes.single.score, 20);
      expect(outcomes.single.sessionResult, isNull);
    });
  });
}
