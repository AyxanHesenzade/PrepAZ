import 'dart:ui' show Size;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/offline/data/drift_offline_store.dart';
import 'package:prep_az/features/offline/data/local_database.dart';
import 'package:prep_az/features/offline/domain/offline_models.dart';
import 'package:prep_az/features/offline/presentation/download_screen.dart';
import 'package:prep_az/features/offline/presentation/offline_providers.dart';

import '../home_screen_test.dart';
import 'fakes.dart';

void main() {
  const subjects = [
    Subject(id: 1, slug: 'kimya', name: 'Kimya'),
    Subject(id: 2, slug: 'biologiya', name: 'Biologiya'),
  ];

  late LocalDatabase db;

  setUp(() => db = LocalDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> show(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      buildHome(
        subjects: FakeSubjects(() async => subjects),
        profile: FakeProfile(2),
        extraOverrides: [localDatabaseProvider.overrideWithValue(db)],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('every subject card has the "İnternetsiz həll et" row with a call to action', (tester) async {
    await show(tester);

    expect(find.text(AppStrings.offlineTitle), findsNWidgets(2));
    expect(find.text(AppStrings.offlineHintAction), findsNWidgets(2));
  });

  testWidgets('a subject with downloaded topics shows how much is on the phone', (tester) async {
    await DriftOfflineStore(db).saveTopic(
      subjectId: 1,
      topic: CatalogTopic(
        topicId: 7,
        topicName: 'Atom',
        sectionName: 'Quruluş',
        questionCount: 1,
        version: 1,
        imageCount: 0,
        imageBytes: 3 * 1024 * 1024,
      ),
      questions: [question('a', 7)],
    );

    await show(tester);

    expect(find.text(AppStrings.offlineStats(1, '3.0 MB')), findsOneWidget);
    expect(find.text(AppStrings.offlineHintAction), findsOneWidget, reason: 'only the other subject still invites');
  });

  testWidgets('tapping the row opens the download screen of that subject', (tester) async {
    await show(tester);

    await tester.tap(find.text(AppStrings.offlineTitle).first);
    await tester.pumpAndSettle();

    expect(find.byType(DownloadScreen), findsOneWidget);
    expect(find.text('Kimya'), findsWidgets);
  });
}
