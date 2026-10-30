import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/home/domain/topic_mastery.dart';
import 'package:prep_az/features/home/presentation/home_providers.dart';
import 'package:prep_az/features/home/presentation/weak_topics_screen.dart';
import 'package:prep_az/features/mistakes/presentation/mistakes_screen.dart';
import 'package:prep_az/features/quiz/data/supabase_quiz_repository.dart';
import 'package:prep_az/features/quiz/domain/mistake_item.dart';
import 'package:prep_az/features/quiz/domain/quiz_request.dart';
import 'package:prep_az/features/quiz/presentation/quiz_controller.dart';
import 'package:prep_az/features/quiz/presentation/quiz_providers.dart';

import '../support/fakes.dart';

const _subject = Subject(id: 1, slug: 'kimya', name: 'Kimya');

MistakeItem _mistake(String id, {required DateTime due}) =>
    MistakeItem(question: closedQuestion(id: id, body: 'Sual $id'), dueAt: due, intervalDays: 3);

Widget _app(Widget home, {FakeQuizRepository? quiz, List<TopicMastery> mastery = const []}) => ProviderScope(
      retry: (_, _) => null,
      overrides: [
        quizRepositoryProvider.overrideWithValue(quiz ?? FakeQuizRepository(const [])),
        progressRepositoryProvider.overrideWithValue(FakeProgressRepository(mastery)),
      ],
      child: MaterialApp(home: home),
    );

void main() {
  group('MistakeItem', () {
    final today = DateTime(2026, 10, 30, 15, 40);

    test('is due when the date is today or earlier', () {
      expect(_mistake('a', due: DateTime(2026, 10, 30)).isDue(today), isTrue);
      expect(_mistake('a', due: DateTime(2026, 10, 25)).isDue(today), isTrue);
      expect(_mistake('a', due: DateTime(2026, 10, 31)).isDue(today), isFalse);
    });

    test('counts days until due, never negative', () {
      expect(_mistake('a', due: DateTime(2026, 11, 2)).daysUntilDue(today), 3);
      expect(_mistake('a', due: DateTime(2026, 10, 1)).daysUntilDue(today), 0);
    });
  });

  test('mistakeFromRow reads the joined question and the schedule', () {
    final item = mistakeFromRow({
      'due_at': '2026-11-02',
      'interval_days': 7,
      'questions': {
        'id': 'q1',
        'code': 'KIM-0001',
        'topic_id': 5,
        'type': 'qapali',
        'body': 'Sual',
        'image_path': null,
        'options': {'B': 'iki', 'A': 'bir'},
        'correct_answer': 'A',
        'difficulty': 2,
        'solution': null,
        'topics': {'subject_id': 1},
      },
    });
    expect(item.dueAt, DateTime(2026, 11, 2));
    expect(item.intervalDays, 7);
    expect(item.question.options.keys, ['A', 'B']);
  });

  group('QuizController kinds', () {
    ProviderContainer containerFor(FakeQuizRepository repo) {
      final c = ProviderContainer(retry: (_, _) => null, overrides: [quizRepositoryProvider.overrideWithValue(repo)]);
      addTearDown(c.dispose);
      return c;
    }

    test('topic request loads only that topic', () async {
      final repo = FakeQuizRepository([closedQuestion(id: 'a'), closedQuestion(id: 'b')]);
      final c = containerFor(repo);
      const request = QuizRequest.topic(1, 999);
      c.listen(quizControllerProvider(request), (_, _) {});

      final state = await c.read(quizControllerProvider(request).future);
      expect(state.isEmpty, isTrue);
      expect(repo.sessionsStarted, 0);
    });

    test('mistakes request starts a session with the queued questions', () async {
      final repo = FakeQuizRepository(const [])
        ..mistakes = [_mistake('m1', due: DateTime(2026, 10, 1)), _mistake('m2', due: DateTime(2026, 10, 2))];
      final c = containerFor(repo);
      const request = QuizRequest.mistakes(1);
      c.listen(quizControllerProvider(request), (_, _) {});

      final state = await c.read(quizControllerProvider(request).future);
      expect(state.questions.map((q) => q.id), ['m1', 'm2']);
      expect(repo.sessionsStarted, 1);
    });

    test('requests with the same values share one provider', () {
      expect(const QuizRequest.topic(1, 2), const QuizRequest.topic(1, 2));
      expect(const QuizRequest.topic(1, 2), isNot(const QuizRequest.topic(1, 3)));
      expect(const QuizRequest.daily(1), isNot(const QuizRequest.mistakes(1)));
    });
  });

  group('MistakesScreen', () {
    testWidgets('shows empty state', (tester) async {
      await tester.pumpWidget(_app(const MistakesScreen(subject: _subject)));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.mistakesEmpty), findsOneWidget);
      expect(find.text(AppStrings.repeatMistakes), findsNothing);
    });

    testWidgets('lists questions with due labels and a repeat button', (tester) async {
      final now = DateTime.now();
      final repo = FakeQuizRepository(const [])
        ..mistakes = [
          _mistake('m1', due: DateTime(now.year, now.month, now.day - 1)),
          _mistake('m2', due: DateTime(now.year, now.month, now.day + 3)),
        ];
      await tester.pumpWidget(_app(const MistakesScreen(subject: _subject), quiz: repo));
      await tester.pumpAndSettle();

      expect(find.text('Sual m1'), findsOneWidget);
      expect(find.text('Sual m2'), findsOneWidget);
      expect(find.text(AppStrings.dueToday), findsOneWidget);
      expect(find.text(AppStrings.dueInDays(3)), findsOneWidget);
      expect(find.text(AppStrings.repeatMistakes), findsOneWidget);
    });

    testWidgets('repeat opens a quiz over the queue', (tester) async {
      final repo = FakeQuizRepository([closedQuestion(id: 'm1', body: 'Sual m1')])
        ..mistakes = [_mistake('m1', due: DateTime(2026, 1, 1))];
      await tester.pumpWidget(_app(const MistakesScreen(subject: _subject), quiz: repo));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.repeatMistakes));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.questionOf(1, 1)), findsOneWidget);
      expect(repo.sessionsStarted, 1);
    });
  });

  group('WeakTopicsScreen', () {
    testWidgets('shows empty state', (tester) async {
      await tester.pumpWidget(_app(const WeakTopicsScreen(subject: _subject)));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.noMasteryYet), findsOneWidget);
    });

    testWidgets('lists all topics and opens a topic quiz', (tester) async {
      final repo = FakeQuizRepository([closedQuestion(id: 'a', body: 'Mövzu sualı')]);
      const topics = [
        TopicMastery(topicId: 1, topicName: 'Turşular', answered: 10, masteryPct: 30),
        TopicMastery(topicId: 2, topicName: 'Əsaslar', answered: 8, masteryPct: 55),
        TopicMastery(topicId: 3, topicName: 'Duzlar', answered: 9, masteryPct: 60),
        TopicMastery(topicId: 4, topicName: 'Oksidlər', answered: 7, masteryPct: 90),
      ];
      await tester.pumpWidget(_app(const WeakTopicsScreen(subject: _subject), quiz: repo, mastery: topics));
      await tester.pumpAndSettle();

      // ana səhifədəki kartdan fərqli olaraq 3-lə məhdudlaşmır
      expect(find.text('Oksidlər'), findsOneWidget);

      await tester.tap(find.text('Turşular'));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.questionOf(1, 1)), findsOneWidget);
    });
  });
}
