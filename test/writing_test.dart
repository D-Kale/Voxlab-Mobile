import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voxlab/core/network/auth_interceptor.dart';
import 'package:voxlab/core/storage/secure_storage.dart';
import 'package:voxlab/core/constants/app_theme.dart';
import 'package:voxlab/data/remote/services/analyzer_service.dart';
import 'package:voxlab/dev/demo_data.dart';
import 'package:voxlab/domain/models/exercise_outcome.dart';
import 'package:voxlab/domain/models/session_result.dart';
import 'package:voxlab/presentation/features/exercise/writing/writing_screen.dart';
import 'package:voxlab/presentation/shared/providers/repository_providers.dart';

import 'golden/golden_fonts.dart';

/// Answers every request with [status].
class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.status, [this.body = const {}]);

  final int status;
  final Map<String, dynamic> body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

final _dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://api.test'))
    ..httpClientAdapter = _StatusAdapter(401, {'error': 'invalid token'})
    ..interceptors.add(AuthInterceptor(ref: ref));
});

const _text =
    'Hablar en público da nervios. Para mejorar conviene practicar cada día '
    'y respirar antes de empezar.\n\nUn buen ejemplo ayuda a que el público '
    'recuerde la idea.\n\nEn conclusión, la práctica hace al maestro.';

void main() {
  setUpAll(loadGoldenFonts);

  group('AuthInterceptor', () {
    Future<String?> tokenAfter401({required bool optional}) async {
      final storage = DemoSecureStorage();
      await storage.saveToken('expired');
      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(storage),
          authRepositoryProvider.overrideWithValue(DemoAuthRepository()),
        ],
      );
      addTearDown(container.dispose);
      final dio = container.read(_dioProvider);
      await expectLater(
        dio.post(
          '/exercises/analyze-text',
          options: Options(extra: {AuthInterceptor.skipLogoutOn401: optional}),
        ),
        throwsA(isA<DioException>()),
      );
      return storage.getToken();
    }

    test('a 401 on a regular request signs the user out', () async {
      expect(await tokenAfter401(optional: false), isNull);
    });

    test('a 401 on an optional AI request keeps the session', () async {
      expect(await tokenAfter401(optional: true), 'expired');
    });
  });

  group('SessionResult', () {
    test('fromJson shows the coach tip apart from the other tips', () {
      final result = SessionResult.fromJson({
        'data': {
          'score': 80,
          'score_breakdown': {},
          'feedback': ['Sumá un ejemplo.', 'Buena estructura.'],
          'ai_feedback': 'Sumá un ejemplo.',
        },
      });
      expect(result.byAi, isTrue);
      expect(result.aiFeedback, 'Sumá un ejemplo.');
      expect(result.tips.map((t) => t.text), ['Buena estructura.']);
    });

    test('fromWriting scores length, requirements and structure', () {
      final result = SessionResultBuilder.fromWriting(
        _text,
        requirements: ['Usar un ejemplo', 'Mencionar la respiración'],
        minWords: 20,
        maxWords: 200,
      );
      final byKey = {for (final s in result.skills) s.key: s.percent};
      expect(byKey['longitud'], 100);
      expect(byKey['cobertura_requisitos'], 100);
      expect(byKey['estructura'], greaterThanOrEqualTo(80));
      expect(result.byAi, isFalse);
    });

    test('quiz scores the share of correct answers, no made-up skills', () {
      final result = SessionResultBuilder.fromQuiz(correct: 2, total: 3);
      expect(result.overall, 67);
      expect(result.skills.map((s) => s.key), ['comprension']);
    });

    test('reading is complete, without delivery skills', () {
      final result = SessionResultBuilder.fromReading();
      expect(result.overall, 100);
      expect(result.skills.map((s) => s.key), ['lectura']);
    });

    test('fromScore never invents a skill breakdown', () {
      expect(SessionResultBuilder.fromScore(10).skills, isEmpty);
    });

    test('fromWriting points out a missing requirement', () {
      final result = SessionResultBuilder.fromWriting(
        _text,
        requirements: ['Citar una estadística'],
        minWords: 20,
        maxWords: 200,
      );
      expect(result.tips.last.text, contains('Citar una estadística'));
      expect(result.tips.last.isPositive, isFalse);
    });
  });

  group('WritingWidget', () {
    Future<List<ExerciseOutcome>> submit(
      WidgetTester tester,
      AnalyzerService analyzer,
    ) async {
      final outcomes = <ExerciseOutcome>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [analyzerServiceProvider.overrideWithValue(analyzer)],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: WritingWidget(
                prompt: 'Escribí sobre hablar en público.',
                minWords: 20,
                maxWords: 200,
                requirements: const ['Usar un ejemplo'],
                points: 15,
                onCompleted: outcomes.add,
              ),
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), _text);
      await tester.pump();
      final submitButton = find.textContaining('ENVIAR');
      await tester.ensureVisible(submitButton.first);
      await tester.tap(submitButton.first);
      for (var i = 0; i < 10 && outcomes.isEmpty; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      return outcomes;
    }

    testWidgets('offline AI falls back to an on-device result', (tester) async {
      final outcomes = await submit(tester, DemoAnalyzerService());
      expect(outcomes.single.score, 15);
      expect(outcomes.single.sessionResult?.byAi, isFalse);
    });

    testWidgets('XP is the exercise reward, not the AI score', (tester) async {
      final outcomes = await submit(tester, _ScoringAnalyzer());
      expect(outcomes.single.score, 15);
      expect(outcomes.single.sessionResult?.overall, 92);
      expect(outcomes.single.sessionResult?.aiFeedback, 'Muy claro.');
    });
  });
}

class _ScoringAnalyzer extends AnalyzerService {
  _ScoringAnalyzer() : super(Dio());

  @override
  Future<Map<String, dynamic>> analyzeText({
    required String text,
    required List<String> requirements,
    required int minWords,
    required int maxWords,
  }) async => {
    'success': true,
    'data': {
      'score': 92,
      'score_breakdown': <String, dynamic>{},
      'feedback': ['Muy claro.'],
      'ai_feedback': 'Muy claro.',
    },
  };
}
