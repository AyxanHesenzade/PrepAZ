import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/quiz/domain/quiz_request.dart';
import 'package:prep_az/features/quiz/presentation/quiz_providers.dart';
import 'package:prep_az/features/quiz/presentation/quiz_screen.dart';
import 'package:prep_az/features/quiz/presentation/widgets/cheer_overlay.dart';

import '../../support/fakes.dart';

/// Həmişə siyahının SONUNCU sözünü seçir: fənnə aid sözlər ümumi sözlərdən sonra gəlir.
class _PickLast implements Random {
  @override
  int nextInt(int max) => max - 1;

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

Widget _app(
  FakeQuizRepository repo, {
  String slug = 'kimya',
  QuizKind kind = QuizKind.daily,
  Random? random,
}) => ProviderScope(
  retry: (_, _) => null,
  overrides: [
    imagesEnabledProvider.overrideWithValue(false),
    quizRepositoryProvider.overrideWithValue(repo),
    cheerRandomProvider.overrideWithValue(random ?? Random(1)),
  ],
  child: MaterialApp(
    home: QuizScreen(
      subject: Subject(id: 4, slug: slug, name: 'Fənn'),
      kind: kind,
      topicId: kind == QuizKind.topic ? 1 : null,
    ),
  ),
);

/// Hamısının düz cavabı B-dir.
FakeQuizRepository _repo(int n) => FakeQuizRepository([
  for (var i = 0; i < n; i++) closedQuestion(id: 'q$i', correct: 'B', solution: null),
]);

/// Cavab verir və köməkçinin girişini gözləyir (hələ çıxmayıb).
Future<void> _answer(WidgetTester tester, {required bool correct}) async {
  await tester.tap(find.text(correct ? 'B' : 'A'));
  await tester.pump();
  await tester.tap(find.text(AppStrings.check));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

/// Köməkçi çəkilsin, sonra növbəti suala keç.
Future<void> _next(WidgetTester tester) async {
  await tester.pump(CheerOverlay.total);
  await tester.tap(find.text(AppStrings.nextQuestion));
  await tester.pumpAndSettle();
}

String? _said(WidgetTester tester) => tester.widget<CheerOverlay>(find.byType(CheerOverlay)).message;

bool _visible(WidgetTester tester, Iterable<String> pool, int n) =>
    pool.any((m) => find.text(m.replaceAll('{n}', '$n')).evaluate().isNotEmpty);

void main() {
  testWidgets('3 right in a row: the helper says something, and not before', (tester) async {
    await tester.pumpWidget(_app(_repo(5), slug: 'math'));
    await tester.pumpAndSettle();

    await _answer(tester, correct: true);
    expect(_said(tester), isNull);
    await _next(tester);
    await _answer(tester, correct: true);
    expect(_said(tester), isNull);
    await _next(tester);
    await _answer(tester, correct: true);

    expect(_visible(tester, AppStrings.cheerThree, 3), isTrue, reason: 'the 3rd right answer');
  });

  testWidgets('the 4th is silent, the 5th is cheered again', (tester) async {
    await tester.pumpWidget(_app(_repo(6), slug: 'math'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      await _answer(tester, correct: true);
      await _next(tester);
    }

    await _answer(tester, correct: true);
    expect(_visible(tester, AppStrings.cheerThree, 4), isFalse);
    expect(_said(tester), anyOf(isNull, isNot(contains('4'))), reason: 'nothing new for the 4th');
    await _next(tester);

    await _answer(tester, correct: true);
    expect(_visible(tester, AppStrings.cheerFive, 5), isTrue);
  });

  testWidgets('one wrong after 5 right: an encouraging word, not a scolding', (tester) async {
    await tester.pumpWidget(_app(_repo(6), slug: 'math'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      await _answer(tester, correct: true);
      await _next(tester);
    }

    await _answer(tester, correct: false);

    expect(_visible(tester, AppStrings.cheerComeback, 5), isTrue);
  });

  testWidgets('8 wrong in a row: never a single word', (tester) async {
    await tester.pumpWidget(_app(_repo(8)));
    await tester.pumpAndSettle();

    for (var i = 0; i < 8; i++) {
      await _answer(tester, correct: false);
      expect(_said(tester), isNull, reason: 'wrong answer #${i + 1}');
      if (i < 7) await _next(tester);
    }
  });

  testWidgets('10 right in a row: the big cheer', (tester) async {
    await tester.pumpWidget(_app(_repo(10), slug: 'math'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 9; i++) {
      await _answer(tester, correct: true);
      await _next(tester);
    }

    await _answer(tester, correct: true);

    expect(_visible(tester, AppStrings.cheerBig, 10), isTrue);
  });

  testWidgets('a chemistry session mixes in chemistry lines', (tester) async {
    await tester.pumpWidget(_app(_repo(3), random: _PickLast()));
    await tester.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await _answer(tester, correct: true);
      await _next(tester);
    }

    await _answer(tester, correct: true);

    expect(find.text(AppStrings.cheerKimya.last.replaceAll('{n}', '3')), findsOneWidget);
  });

  testWidgets('a biology session mixes in biology lines', (tester) async {
    await tester.pumpWidget(_app(_repo(3), slug: 'biologiya', random: _PickLast()));
    await tester.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await _answer(tester, correct: true);
      await _next(tester);
    }

    await _answer(tester, correct: true);

    expect(find.text(AppStrings.cheerBiologiya.last.replaceAll('{n}', '3')), findsOneWidget);
  });

  testWidgets('after chemistry streak breaks, the line points to the recommended teachers', (tester) async {
    await tester.pumpWidget(_app(_repo(6), random: _PickLast()));
    await tester.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      await _answer(tester, correct: true);
      await _next(tester);
    }

    await _answer(tester, correct: false);

    expect(find.text(AppStrings.cheerKimyaComeback.single), findsOneWidget);
  });

  testWidgets('it goes away by itself', (tester) async {
    await tester.pumpWidget(_app(_repo(3), random: _PickLast()));
    await tester.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await _answer(tester, correct: true);
      await _next(tester);
    }
    await _answer(tester, correct: true);
    final line = AppStrings.cheerKimya.last.replaceAll('{n}', '3');
    expect(find.text(line), findsOneWidget);

    await tester.pump(CheerOverlay.total);

    expect(find.text(line), findsNothing);
  });

  testWidgets('a tap sends it away at once', (tester) async {
    await tester.pumpWidget(_app(_repo(3), random: _PickLast()));
    await tester.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await _answer(tester, correct: true);
      await _next(tester);
    }
    await _answer(tester, correct: true);
    final line = AppStrings.cheerKimya.last.replaceAll('{n}', '3');

    await tester.tap(find.text(line));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text(line), findsNothing);
  });

  testWidgets('topic practice is silent for now (only "Bugünkü məşq" has the helper)', (tester) async {
    await tester.pumpWidget(_app(_repo(3), kind: QuizKind.topic));
    await tester.pumpAndSettle();
    for (var i = 0; i < 2; i++) {
      await _answer(tester, correct: true);
      await _next(tester);
    }

    await _answer(tester, correct: true);

    expect(_said(tester), isNull);
  });
}
