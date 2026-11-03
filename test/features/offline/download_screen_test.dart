import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/core/utils/format_bytes.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/offline/data/drift_offline_store.dart';
import 'package:prep_az/features/offline/data/local_database.dart';
import 'package:prep_az/features/offline/domain/offline_models.dart';
import 'package:prep_az/features/offline/presentation/download_controller.dart';
import 'package:prep_az/features/offline/presentation/download_screen.dart';
import 'package:prep_az/features/offline/presentation/offline_providers.dart';

import 'fakes.dart';

const _subject = Subject(id: 5, slug: 'kimya', name: 'Kimya');

CatalogTopic topic(int id, String name, {String? section = 'Ümumi kimya', int questions = 10, int bytes = 2 * 1024 * 1024, int version = 1}) =>
    CatalogTopic(
      topicId: id,
      topicName: name,
      sectionName: section,
      questionCount: questions,
      version: version,
      imageCount: 0,
      imageBytes: bytes,
    );

void main() {
  late LocalDatabase db;
  late DriftOfflineStore store;
  late FakeRemote remote;
  late FakeImages images;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    store = DriftOfflineStore(db);
    remote = FakeRemote();
    images = FakeImages();
  });
  tearDown(() => db.close());

  List<Override> overrides() => [
    localDatabaseProvider.overrideWithValue(db),
    remoteDownloadSourceProvider.overrideWithValue(remote),
    imageStoreProvider.overrideWithValue(images),
  ];

  /// Baza və axınlar real asinxron işləyir: testdə hər addımdan sonra bir az gözləyirik.
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
        child: const MaterialApp(home: DownloadScreen(subject: _subject)),
      ),
    );
    await settle(tester);
  }

  Future<void> storeTopic(CatalogTopic t, {List<String> imagePaths = const [], int? version}) async {
    final questions = [
      for (var i = 0; i < imagePaths.length; i++) question('q${t.topicId}-$i', t.topicId, image: imagePaths[i]),
      if (imagePaths.isEmpty) question('q${t.topicId}', t.topicId),
    ];
    await store.saveTopic(
      subjectId: 5,
      topic: CatalogTopic(
        topicId: t.topicId,
        topicName: t.topicName,
        sectionName: t.sectionName,
        questionCount: questions.length,
        version: version ?? t.version,
        imageCount: 0,
        imageBytes: t.imageBytes,
      ),
      questions: questions,
    );
  }

  group('screen', () {
    testWidgets('lists the topics under their section with the question count and the size', (tester) async {
      remote.catalog.addAll([
        topic(1, 'Kimyanın əsas anlayışları', questions: 100, bytes: 3125990),
        topic(2, 'Atom', section: 'Quruluş', questions: 4, bytes: 106522),
      ]);

      await show(tester);

      expect(find.text('Ümumi kimya'), findsOneWidget);
      expect(find.text('Quruluş'), findsOneWidget);
      expect(find.text('Kimyanın əsas anlayışları'), findsOneWidget);
      expect(find.text(AppStrings.topicSizeLine(100, '3.0 MB')), findsOneWidget);
      expect(find.text(AppStrings.topicSizeLine(4, '104 KB')), findsOneWidget);
      expect(find.text(AppStrings.downloadAction), findsNWidgets(2));
    });

    testWidgets('Yüklə downloads the topic: it ends as "Yükləndi" and the questions are on the phone', (tester) async {
      remote.catalog.add(topic(1, 'Atom'));
      remote.questions[1] = [question('a', 1, image: 'a.webp'), question('b', 1)];
      await show(tester);

      await tester.tap(find.text(AppStrings.downloadAction));
      await settle(tester);

      expect(find.text(AppStrings.downloadedLabel), findsOneWidget);
      expect(find.text(AppStrings.downloadAction), findsNothing);
      final stored = (await tester.runAsync(() => store.getTopic(1)))!;
      expect(stored.isComplete, isTrue);
      expect(stored.questionCount, 2);
      expect(images.files, {'a.webp'});
    });

    testWidgets('while it downloads: progress is shown and the stop button replaces the others', (tester) async {
      remote.catalog.add(topic(1, 'Atom'));
      remote.questions[1] = [question('a', 1, image: 'a.webp')];
      remote.gate = Completer<void>();
      await show(tester);

      await tester.tap(find.text(AppStrings.downloadAction));
      await settle(tester);

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text(AppStrings.downloadingPercent(0)), findsOneWidget);
      expect(find.byTooltip(AppStrings.downloadStop), findsOneWidget);
      expect(find.text(AppStrings.downloadAction), findsNothing);

      remote.gate!.complete();
      await settle(tester);
      expect(find.text(AppStrings.downloadedLabel), findsOneWidget);
    });

    testWidgets('stopping leaves a partly downloaded topic that can be resumed', (tester) async {
      remote.catalog.add(topic(1, 'Atom'));
      // 6 şəkil, eyni anda 4 endirilir: dayandırma növbəti partiyanın əvvəlində işləyir
      remote.questions[1] = [for (var i = 0; i < 6; i++) question('q$i', 1, image: 'i$i.webp')];
      remote.gate = Completer<void>();
      await show(tester);
      await tester.tap(find.text(AppStrings.downloadAction));
      await settle(tester);

      await tester.tap(find.byTooltip(AppStrings.downloadStop));
      remote.gate!.complete();
      await settle(tester);

      expect(find.text(AppStrings.downloadResume), findsOneWidget);
      expect(find.text(AppStrings.downloadIncomplete), findsOneWidget);
    });

    testWidgets('a failed download shows the reason and "Yenidən cəhd et", and the retry finishes it', (tester) async {
      remote.catalog.add(topic(1, 'Atom'));
      remote.questions[1] = [question('a', 1, image: 'a.webp')];
      remote.failOn = 'a.webp';
      await show(tester);

      await tester.tap(find.text(AppStrings.downloadAction));
      await settle(tester);

      expect(find.text('offline'), findsOneWidget);
      expect(find.text(AppStrings.retry), findsOneWidget);

      remote.failOn = null;
      await tester.tap(find.text(AppStrings.retry));
      await settle(tester);

      expect(find.text(AppStrings.downloadedLabel), findsOneWidget);
    });

    testWidgets('a topic changed on the server offers an update', (tester) async {
      await storeTopic(topic(1, 'Atom'), version: 1);
      remote.catalog.add(topic(1, 'Atom', version: 2));

      await show(tester);

      expect(find.text(AppStrings.downloadUpdate), findsOneWidget);
      expect(find.text(AppStrings.downloadUpdateAvailable), findsOneWidget);
    });

    testWidgets('an up to date topic offers no download, only removal', (tester) async {
      await storeTopic(topic(1, 'Atom'), version: 1);
      remote.catalog.add(topic(1, 'Atom', version: 1));

      await show(tester);

      expect(find.text(AppStrings.downloadedLabel), findsOneWidget);
      expect(find.text(AppStrings.downloadAction), findsNothing);
      expect(find.byTooltip(AppStrings.downloadDelete), findsOneWidget);
    });

    testWidgets('removal asks first; cancelling keeps the topic, confirming removes it from the phone', (tester) async {
      remote.catalog.add(topic(1, 'Atom'));
      await storeTopic(topic(1, 'Atom'));
      await show(tester);

      await tester.tap(find.byTooltip(AppStrings.downloadDelete));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.downloadDeleteTitle('Atom')), findsOneWidget);
      await tester.tap(find.text(AppStrings.cancel));
      await tester.pumpAndSettle();
      expect(await tester.runAsync(() => store.getTopic(1)), isNotNull);

      await tester.tap(find.byTooltip(AppStrings.downloadDelete));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.downloadDeleteConfirm));
      await settle(tester);

      expect(await tester.runAsync(() => store.getTopic(1)), isNull);
      expect(find.text(AppStrings.downloadAction), findsOneWidget);
    });

    testWidgets('without internet only the downloaded topics are shown, with a notice and no download button', (tester) async {
      await storeTopic(topic(1, 'Atom'));
      remote.catalogError = const AppException('no internet');

      await show(tester);

      expect(find.text(AppStrings.offlineNoInternet), findsOneWidget);
      expect(find.text('Atom'), findsOneWidget);
      expect(find.text(AppStrings.downloadAction), findsNothing);
      expect(find.byTooltip(AppStrings.downloadDelete), findsOneWidget);
    });

    testWidgets('without internet and nothing downloaded the error with a retry is shown', (tester) async {
      remote.catalogError = const AppException('no internet');

      await show(tester);

      expect(find.text(AppStrings.offlineNeedInternetToDownload), findsOneWidget);
      expect(find.text(AppStrings.retry), findsOneWidget);
    });

    testWidgets('a topic that disappeared from the server can still be removed from the phone', (tester) async {
      await storeTopic(topic(9, 'Köhnə mövzu'));
      remote.catalog.add(topic(1, 'Atom'));

      await show(tester);

      expect(find.text('Köhnə mövzu'), findsOneWidget);
      expect(find.byTooltip(AppStrings.downloadDelete), findsOneWidget);
      expect(find.text(AppStrings.downloadAction), findsOneWidget, reason: 'only Atom can be downloaded');
    });

    testWidgets('"Hamısını yüklə" asks first, shows the total size, then downloads every pending topic', (tester) async {
      remote.catalog.addAll([topic(1, 'A', bytes: 2 * 1024 * 1024), topic(2, 'B', bytes: 3 * 1024 * 1024)]);
      remote.questions[1] = [question('a', 1)];
      remote.questions[2] = [question('b', 2)];
      await show(tester);

      await tester.tap(find.text(AppStrings.downloadAll('5.0 MB')));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.downloadAllTitle(2, '5.0 MB')), findsOneWidget);
      await tester.tap(find.text(AppStrings.downloadAction).last);
      await settle(tester);

      expect(find.text(AppStrings.downloadedLabel), findsNWidgets(2));
      expect(find.textContaining(AppStrings.downloadAll('')), findsNothing, reason: 'nothing left to download');
    });

    testWidgets('a single pending topic has no "Hamısını yüklə" button', (tester) async {
      remote.catalog.add(topic(1, 'A'));

      await show(tester);

      expect(find.byIcon(Icons.download_rounded), findsNothing);
    });
  });

  group('controller', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(retry: (_, _) => null, overrides: overrides());
      addTearDown(container.dispose);
      container.listen(downloadsControllerProvider, (_, _) {});
    });

    DownloadsController controller() => container.read(downloadsControllerProvider.notifier);

    test('progress goes up to 100% and the finished topic leaves the active list', () async {
      remote.questions[1] = [for (var i = 0; i < 4; i++) question('q$i', 1, image: 'i$i.webp')];
      final seen = <double>[];
      container.listen(downloadsControllerProvider, (_, now) {
        final a = now[1];
        if (a != null) seen.add(a.fraction);
      });

      await controller().download(subjectId: 5, topic: topic(1, 'Atom'));

      expect(seen.first, 0);
      expect(seen.last, 1);
      expect(seen, orderedEquals([...seen]..sort()), reason: 'never goes backwards');
      expect(container.read(downloadsControllerProvider), isEmpty);
    });

    test('a failure is kept with its message until the next attempt', () async {
      remote.questions[1] = [question('a', 1, image: 'a.webp')];
      remote.failOn = 'a.webp';

      await controller().download(subjectId: 5, topic: topic(1, 'Atom'));

      final activity = container.read(downloadsControllerProvider)[1]!;
      expect(activity.failed, isTrue);
      expect(activity.error, 'offline');
      expect(controller().isBusy(1), isFalse, reason: 'a failed topic can be retried');
    });

    test('a second tap while it downloads does not start it twice', () async {
      remote.questions[1] = [question('a', 1, image: 'a.webp')];
      remote.gate = Completer<void>();

      final first = controller().download(subjectId: 5, topic: topic(1, 'Atom'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await controller().download(subjectId: 5, topic: topic(1, 'Atom'));
      remote.gate!.complete();
      await first;

      expect(remote.downloaded, ['a.webp']);
    });

    test('download all stops at the first failure instead of trying every topic', () async {
      remote.questions[1] = [question('a', 1, image: 'a.webp')];
      remote.questions[2] = [question('b', 2, image: 'b.webp')];
      remote.failOn = 'a.webp';

      await controller().downloadAll(subjectId: 5, topics: [topic(1, 'A'), topic(2, 'B')]);

      expect(container.read(downloadsControllerProvider).containsKey(2), isFalse);
      expect(await store.getTopic(2), isNull);
    });

    test('delete removes the topic and its images from the phone', () async {
      remote.questions[1] = [question('a', 1, image: 'a.webp')];
      await controller().download(subjectId: 5, topic: topic(1, 'Atom'));
      expect(images.files, {'a.webp'});

      await controller().delete(1);

      expect(await store.getTopic(1), isNull);
      expect(images.files, isEmpty);
    });
  });

  test('sizes are readable', () {
    expect(formatBytes(0), '0 KB');
    expect(formatBytes(300), '1 KB');
    expect(formatBytes(104 * 1024), '104 KB');
    expect(formatBytes(3125990), '3.0 MB');
    expect(formatBytes(15 * 1024 * 1024), '15 MB');
  });
}
