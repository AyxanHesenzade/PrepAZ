import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/config/app_version.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/quiz/presentation/widgets/question_code_label.dart';
import 'package:prep_az/features/reports/domain/report_repository.dart';
import 'package:prep_az/features/reports/presentation/report_providers.dart';
import 'package:prep_az/features/reports/presentation/report_sheet.dart';

import '../support/fakes.dart';

class _FakeReports implements ReportRepository {
  final sent = <({String message, String version, String? id, String? code})>[];
  bool fail = false;

  @override
  Future<void> submit({required String message, required String appVersion, String? questionId, String? questionCode}) async {
    if (fail) throw const AppException('Çox bildiriş');
    sent.add((message: message, version: appVersion, id: questionId, code: questionCode));
  }
}

Widget _app(_FakeReports repo, Widget body) => ProviderScope(
      overrides: [
        reportRepositoryProvider.overrideWithValue(repo),
        appVersionProvider.overrideWith((ref) async => const AppVersion(version: '0.0.1', build: 2)),
      ],
      child: MaterialApp(home: Scaffold(body: body)),
    );

void main() {
  test('description rule: 10 to 1000 characters after trimming', () {
    expect(ReportRules.isValid(''), isFalse);
    expect(ReportRules.isValid('         x'), isFalse);
    expect(ReportRules.isValid('on simvol!'), isTrue);
    expect(ReportRules.isValid('x' * 1001), isFalse);
  });

  testWidgets('question report: send is disabled until the description is long enough, then id and code are sent', (tester) async {
    final repo = _FakeReports();
    await tester.pumpWidget(_app(repo, QuestionCodeLabel(question: closedQuestion(id: 'q7'))));

    await tester.tap(find.text(AppStrings.reportButton));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.reportQuestionTitle), findsOneWidget);
    expect(find.textContaining('KIM-q7'), findsWidgets); // the code is shown in the hint

    FilledButton send() => tester.widget<FilledButton>(find.widgetWithText(FilledButton, AppStrings.reportSend));
    expect(send().onPressed, isNull);
    await tester.enterText(find.byType(TextField), 'qısa');
    await tester.pump();
    expect(send().onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Düzgün cavab B yox C-dir');
    await tester.pump();
    expect(send().onPressed, isNotNull);
    await tester.tap(find.text(AppStrings.reportSend));
    await tester.pumpAndSettle();

    expect(repo.sent.single.id, 'q7');
    expect(repo.sent.single.code, 'KIM-q7');
    expect(repo.sent.single.message, 'Düzgün cavab B yox C-dir');
    expect(repo.sent.single.version, '0.0.1+2');
    expect(find.text(AppStrings.reportSent), findsOneWidget);
    expect(find.text(AppStrings.reportQuestionTitle), findsNothing); // the sheet closed
  });

  testWidgets('app report: no question id or code', (tester) async {
    final repo = _FakeReports();
    await tester.pumpWidget(_app(repo, Builder(builder: (context) => TextButton(onPressed: () => showReportSheet(context), child: const Text('open')))));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.reportAppTitle), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Tətbiq açılışda donur');
    await tester.pump();
    await tester.tap(find.text(AppStrings.reportSend));
    await tester.pumpAndSettle();
    expect(repo.sent.single.id, isNull);
    expect(repo.sent.single.code, isNull);
  });

  testWidgets('a failed send keeps the sheet and the text, shows the error', (tester) async {
    final repo = _FakeReports()..fail = true;
    await tester.pumpWidget(_app(repo, QuestionCodeLabel(question: closedQuestion())));
    await tester.tap(find.text(AppStrings.reportButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Variant yoxdur, şəkil kəsikdir');
    await tester.pump();
    await tester.tap(find.text(AppStrings.reportSend));
    await tester.pumpAndSettle();
    expect(find.text('Çox bildiriş'), findsOneWidget);
    expect(find.text('Variant yoxdur, şəkil kəsikdir'), findsOneWidget);
  });
}
