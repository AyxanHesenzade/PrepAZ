import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/quiz/domain/quiz_request.dart';
import 'package:prep_az/features/quiz/presentation/quiz_controller.dart';
import 'package:prep_az/features/quiz/presentation/quiz_providers.dart';
import 'package:prep_az/features/quiz/presentation/quiz_state.dart';

import '../../support/fakes.dart';

void main() {
  const request = QuizRequest.daily(4);
  late FakeQuizRepository repo;
  late ProviderContainer container;

  QuizController controller() => container.read(quizControllerProvider(request).notifier);
  QuizState state() => container.read(quizControllerProvider(request)).requireValue;

  Future<void> start(FakeQuizRepository fake) async {
    repo = fake;
    container = ProviderContainer(retry: (_, _) => null, overrides: [quizRepositoryProvider.overrideWithValue(repo)]);
    container.listen(quizControllerProvider(request), (_, _) {});
    addTearDown(container.dispose);
    await container.read(quizControllerProvider(request).future);
  }

  test('loads questions and opens exactly one session', () async {
    await start(FakeQuizRepository([closedQuestion(id: 'a'), closedQuestion(id: 'b')]));

    expect(state().questions.length, 2);
    expect(state().index, 0);
    expect(repo.sessionsStarted, 1);
  });

  test('empty daily set: no session is opened', () async {
    await start(FakeQuizRepository([]));

    expect(state().isEmpty, isTrue);
    expect(repo.sessionsStarted, 0);
  });

  test('load failure becomes an error state', () async {
    repo = FakeQuizRepository([closedQuestion()])..failLoad = true;
    container = ProviderContainer(retry: (_, _) => null, overrides: [quizRepositoryProvider.overrideWithValue(repo)]);
    container.listen(quizControllerProvider(request), (_, _) {});
    addTearDown(container.dispose);

    await expectLater(container.read(quizControllerProvider(request).future), throwsA(anything));
    expect(container.read(quizControllerProvider(request)).hasError, isTrue);
  });

  test('correct closed answer: server decision is shown, selection is locked', () async {
    await start(FakeQuizRepository([closedQuestion(correct: 'B')]));

    controller().select('B');
    expect(state().canSubmit, isTrue);
    await controller().check();
    expect(state().currentResult!.isCorrect, isTrue);
    expect(repo.submitted.single.given, 'B');

    controller().select('A'); // after the answer the choice must not change
    expect(state().selected, 'B');
  });

  test('cannot submit without choosing; submit is ignored', () async {
    await start(FakeQuizRepository([closedQuestion()]));

    expect(state().canSubmit, isFalse);
    await controller().check();
    expect(repo.submitted, isEmpty);
  });

  test('"Bilmirəm" sends null and counts as wrong', () async {
    await start(FakeQuizRepository([closedQuestion()]));

    await controller().check(skip: true);

    expect(repo.submitted.single.given, isNull);
    expect(state().currentResult!.isCorrect, isFalse);
  });

  test('numeric answer: typed text is trimmed and sent as is', () async {
    await start(FakeQuizRepository([numericQuestion(correct: '9,2')]));

    controller().type('  9,2 ');
    await controller().check();

    expect(repo.submitted.single.given, '9,2');
    expect(state().currentResult!.isCorrect, isTrue);
  });

  test('submit failure keeps the question open and shows the message; retry works', () async {
    await start(FakeQuizRepository([closedQuestion(correct: 'B')]));
    repo.failSubmit = true;
    controller().select('B');

    await controller().check();
    expect(state().isAnswered, isFalse);
    expect(state().isSending, isFalse);
    expect(state().error, AppStrings.unknownError);

    repo.failSubmit = false;
    await controller().check();
    expect(state().isAnswered, isTrue);
    expect(state().error, isNull);
  });

  test('double tap on "Yoxla" sends only one answer', () async {
    await start(FakeQuizRepository([closedQuestion(correct: 'B')]));
    controller().select('B');

    await Future.wait([controller().check(), controller().check()]);

    expect(repo.submitted.length, 1);
  });

  test('full run: advance, finish, session closed once, results kept in order', () async {
    await start(FakeQuizRepository([
      closedQuestion(id: 'a', correct: 'A'),
      closedQuestion(id: 'b', correct: 'B'),
      numericQuestion(id: 'c', correct: '5'),
    ]));

    controller().select('A');
    await controller().check();
    await controller().next();
    expect(state().index, 1);
    expect(state().selected, isNull, reason: 'selection resets for the next question');

    controller().select('C'); // wrong
    await controller().check();
    await controller().next();

    controller().type('5');
    await controller().check();
    expect(state().isLast, isTrue);
    await controller().next();

    expect(state().isFinished, isTrue);
    expect(repo.sessionsFinished, 1);
    expect(state().results.map((r) => r.isCorrect), [true, false, true]);
    expect(state().results.map((r) => r.question.id), ['a', 'b', 'c']);
  });

  test('next does nothing before the question is answered', () async {
    await start(FakeQuizRepository([closedQuestion(id: 'a'), closedQuestion(id: 'b')]));

    await controller().next();

    expect(state().index, 0);
  });

  test('failure to close the session does not lose the result', () async {
    await start(FakeQuizRepository([closedQuestion(correct: 'A')])..failFinish = true);
    controller().select('A');
    await controller().check();

    await controller().next();

    expect(state().isFinished, isTrue);
    expect(state().results.length, 1);
  });
}
