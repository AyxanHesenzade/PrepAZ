import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/browse/presentation/browse_providers.dart';
import 'package:prep_az/features/browse/presentation/topic_list_screen.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/home/presentation/home_providers.dart';
import 'package:prep_az/features/offline/data/drift_offline_store.dart';
import 'package:prep_az/features/offline/data/local_database.dart';
import 'package:prep_az/features/offline/domain/offline_models.dart';
import 'package:prep_az/features/offline/presentation/download_screen.dart';
import 'package:prep_az/features/offline/presentation/offline_providers.dart';
import 'package:prep_az/features/quiz/presentation/quiz_providers.dart';

import '../../support/fakes.dart';
import 'fakes.dart';

const _subject = Subject(id: 5, slug: 'kimya', name: 'Kimya');

final _questions = [imageOnlyQuestion(id: 'Q001'), imageOnlyQuestion(id: 'Q002')];

CatalogTopic _topic({int version = 1}) => CatalogTopic(
  topicId: 1,
  topicName: 'Əsas anlayışlar',
  sectionName: 'Ümumi kimya',
  questionCount: 2,
  version: version,
  imageCount: 2,
  imageBytes: 3125990,
);

void main() {
  late LocalDatabase db;
  late DriftOfflineStore store;
  late FakeRemote remote;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    store = DriftOfflineStore(db);
    remote = FakeRemote()
      ..catalog.add(_topic())
      ..questions[1] = _questions;
  });
  tearDown(() => db.close());

  List<Override> overrides() => [
    imagesEnabledProvider.overrideWithValue(true),
    browseRepositoryProvider.overrideWithValue(FakeBrowseRepository(_questions)),
    progressRepositoryProvider.overrideWithValue(FakeProgressRepository()),
    localDatabaseProvider.overrideWithValue(db),
    remoteDownloadSourceProvider.overrideWithValue(remote),
    imageStoreProvider.overrideWithValue(FakeImages()),
  ];

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 25)));
      await tester.pump();
    }
  }

  Future<void> show(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1000, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: overrides(),
        child: const MaterialApp(home: TopicListScreen(subject: _subject)),
      ),
    );
    await settle(tester);
  }

  Future<void> storeTopic(CatalogTopic t) async {
    await store.saveTopic(subjectId: 5, topic: t, questions: _questions.map((q) => q).toList());
  }

  testWidgets('nothing downloaded yet: a card explains the idea and every topic shows its size', (tester) async {
    await show(tester);

    expect(find.text(AppStrings.offlineTitle), findsOneWidget);
    expect(find.text(AppStrings.offlineHintAction), findsOneWidget);
    expect(find.text('3.0 MB'), findsOneWidget, reason: 'the student sees how much data it takes');
  });

  testWidgets('the card opens the download screen', (tester) async {
    await show(tester);

    await tester.tap(find.text(AppStrings.offlineHintAction));
    await tester.pumpAndSettle();

    expect(find.byType(DownloadScreen), findsOneWidget);
  });

  testWidgets('one tap on the size button downloads the topic without leaving the list', (tester) async {
    await show(tester);

    await tester.tap(find.text('3.0 MB'));
    await settle(tester);

    expect(find.text(AppStrings.onPhoneLabel), findsOneWidget);
    expect(find.text('3.0 MB'), findsNothing);
    expect(find.text(AppStrings.offlineHintAction), findsNothing, reason: 'the card goes away after the first download');
    expect(find.text(AppStrings.topicsTitle), findsOneWidget, reason: 'still on the list');
    expect((await tester.runAsync(() => store.getTopic(1)))!.isComplete, isTrue);
  });

  testWidgets('while downloading the button becomes a ring that stops it', (tester) async {
    remote.gate = Completer<void>();
    await show(tester);

    await tester.tap(find.text('3.0 MB'));
    await settle(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byTooltip(AppStrings.downloadStop), findsOneWidget);

    remote.gate!.complete();
    await settle(tester);
    expect(find.text(AppStrings.onPhoneLabel), findsOneWidget);
  });

  testWidgets('a downloaded topic shows "Telefonda" and no card', (tester) async {
    await storeTopic(_topic());
    await tester.runAsync(() => store.recordImage(topicId: 1, path: 'KT1-S01-Q001.png', bytes: 1));
    await tester.runAsync(() => store.recordImage(topicId: 1, path: 'KT1-S01-Q002.png', bytes: 1));

    await show(tester);

    expect(find.text(AppStrings.onPhoneLabel), findsOneWidget);
    expect(find.text(AppStrings.offlineHintAction), findsNothing);
  });

  testWidgets('a topic changed on the server offers "Yenilə" right in the list', (tester) async {
    await storeTopic(_topic(version: 1));
    await tester.runAsync(() => store.recordImage(topicId: 1, path: 'KT1-S01-Q001.png', bytes: 1));
    await tester.runAsync(() => store.recordImage(topicId: 1, path: 'KT1-S01-Q002.png', bytes: 1));
    remote.catalog
      ..clear()
      ..add(_topic(version: 2));

    await show(tester);

    expect(find.text(AppStrings.downloadUpdate), findsOneWidget);
  });

  testWidgets('without internet (no catalog) there is no card and no button, only the topics', (tester) async {
    remote.catalogError = const AppException('no internet');

    await show(tester);

    expect(find.text('Əsas anlayışlar'), findsOneWidget);
    expect(find.text(AppStrings.offlineHintAction), findsNothing);
    expect(find.text('3.0 MB'), findsNothing);
  });

  testWidgets('the top bar still opens the download screen', (tester) async {
    await show(tester);

    await tester.tap(find.byTooltip(AppStrings.offlineTitle));
    await tester.pumpAndSettle();

    expect(find.byType(DownloadScreen), findsOneWidget);
    expect(find.text(AppStrings.offlineStatsEmpty), findsOneWidget);
  });
}
