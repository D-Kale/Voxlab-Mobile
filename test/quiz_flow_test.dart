import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voxlab/core/constants/app_theme.dart';
import 'package:voxlab/domain/models/exercise_content.dart';
import 'package:voxlab/domain/models/exercise_outcome.dart';
import 'package:voxlab/presentation/features/exercise/quiz/quiz_screen.dart';

import 'golden/golden_fonts.dart';

void main() {
  const questions = [
    QuizQuestion(
      question: '¿Qué conviene hacer antes de hablar?',
      options: ['Respirar profundo', 'Hablar rápido'],
      correctIndex: 0,
    ),
    QuizQuestion(
      question: '¿Para qué sirven las pausas?',
      options: ['Rellenar', 'Que la audiencia procese'],
      correctIndex: 1,
      explanation: 'Marcan las ideas importantes.',
    ),
  ];

  Future<List<ExerciseOutcome>> pumpQuiz(WidgetTester tester) async {
    useReducedMotion(tester);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final outcomes = <ExerciseOutcome>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: QuizWidget(
            questions: questions,
            pointsPerQuestion: 5,
            onCompleted: outcomes.add,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return outcomes;
  }

  testWidgets('check, feedback and score across questions', (tester) async {
    final outcomes = await pumpQuiz(tester);

    await tester.tap(find.text('Respirar profundo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pumpAndSettle();
    expect(find.text('¡Excelente!'), findsOneWidget);

    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
    expect(find.text('¿Para qué sirven las pausas?'), findsOneWidget);

    await tester.tap(find.text('Rellenar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('COMPROBAR'));
    await tester.pumpAndSettle();
    expect(find.text('Casi...'), findsOneWidget);
    expect(
      find.textContaining('Respuesta correcta: Que la audiencia procese'),
      findsOneWidget,
    );

    await tester.tap(find.text('CONTINUAR'));
    await tester.pumpAndSettle();
    expect(outcomes.single.score, 5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cannot check before choosing an answer', (tester) async {
    await pumpQuiz(tester);
    await tester.tap(find.text('COMPROBAR'));
    await tester.pumpAndSettle();
    expect(find.text('¡Excelente!'), findsNothing);
    expect(find.text('Casi...'), findsNothing);
  });
}
