import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/quiz/domain/question.dart';
import 'package:prep_az/features/quiz/presentation/quiz_providers.dart';
import 'package:prep_az/features/quiz/presentation/quiz_screen.dart';

import '../../support/fakes.dart';

void main() {
  test('reportCode prefers the readable code and falls back to the uuid', () {
    expect(closedQuestion(id: 'x1').reportCode, 'KIM-x1');
    final noCode = Question(
      id: '3f0c-uuid',
      code: null,
      topicId: 1,
      type: QuestionType.qapali,
      body: 'b',
      imagePath: null,
      options: const {'A': 'a'},
      correctAnswer: 'A',
      difficulty: 1,
      solution: null,
    );
    expect(noCode.reportCode, '3f0c-uuid');
  });

  testWidgets('quiz screen shows the question code and copies it on tap', (tester) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied.add((call.arguments as Map)['text'] as String);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(ProviderScope(
      retry: (_, _) => null,
      overrides: [quizRepositoryProvider.overrideWithValue(FakeQuizRepository([closedQuestion(id: 'q7')]))],
      child: const MaterialApp(home: QuizScreen(subject: Subject(id: 1, slug: 'kimya', name: 'Kimya'))),
    ));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.questionCode('KIM-q7')), findsOneWidget);
    await tester.tap(find.text(AppStrings.questionCode('KIM-q7')));
    await tester.pump();

    expect(copied, ['KIM-q7']);
    expect(find.text(AppStrings.codeCopied), findsOneWidget);
  });
}
