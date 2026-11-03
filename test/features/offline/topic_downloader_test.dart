import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/offline/data/drift_offline_store.dart';
import 'package:prep_az/features/offline/data/local_database.dart';
import 'package:prep_az/features/offline/domain/offline_models.dart';
import 'package:prep_az/features/offline/domain/topic_downloader.dart';

import 'fakes.dart';

void main() {
  late LocalDatabase db;
  late DriftOfflineStore store;
  late FakeRemote remote;
  late FakeImages images;
  late TopicDownloader downloader;

  setUp(() {
    db = LocalDatabase(NativeDatabase.memory());
    store = DriftOfflineStore(db);
    remote = FakeRemote();
    images = FakeImages();
    downloader = TopicDownloader(remote: remote, store: store, images: images, parallel: 2);
  });
  tearDown(() => db.close());

  test('downloads the questions and every image, then the topic is complete', () async {
    remote.questions[1] = [
      question('a', 1, image: 'a.webp', solutionImage: 'a_izah.webp'),
      question('b', 1, image: 'b.webp'),
      question('c', 1),
    ];
    final progress = <String>[];

    await downloader.download(
      subjectId: 5,
      topic: catalog(1),
      onProgress: (done, total) => progress.add('$done/$total'),
    );

    final stored = (await store.getTopic(1))!;
    expect(stored.questionCount, 3);
    expect(stored.imageCount, 3);
    expect(stored.imagesDone, 3);
    expect(stored.isComplete, isTrue);
    expect(stored.subjectId, 5);
    expect(images.files, {'a.webp', 'a_izah.webp', 'b.webp'});
    expect(progress.first, '0/3');
    expect(progress.last, '3/3');
    expect(downloadStateOf(catalog(1), stored), TopicDownloadState.ready);
  });

  test('a topic without images is complete right after the questions', () async {
    remote.questions[1] = [question('a', 1), question('b', 1)];

    await downloader.download(subjectId: 5, topic: catalog(1));

    final stored = (await store.getTopic(1))!;
    expect(stored.imageCount, 0);
    expect(stored.isComplete, isTrue);
  });

  test('a lost connection leaves the topic incomplete and the retry downloads only what is missing', () async {
    remote.questions[1] = [
      question('a', 1, image: 'a.webp'),
      question('b', 1, image: 'b.webp'),
      question('c', 1, image: 'c.webp'),
      question('d', 1, image: 'd.webp'),
    ];
    remote.failOn = 'c.webp';

    await expectLater(downloader.download(subjectId: 5, topic: catalog(1)), throwsA(isA<AppException>()));

    var stored = (await store.getTopic(1))!;
    expect(stored.isComplete, isFalse);
    expect(downloadStateOf(catalog(1), stored), TopicDownloadState.incomplete);
    final before = remote.downloaded.length;
    expect(stored.imagesDone, before);

    remote.failOn = null;
    await downloader.download(subjectId: 5, topic: catalog(1));

    stored = (await store.getTopic(1))!;
    expect(stored.isComplete, isTrue);
    expect(remote.downloaded.toSet(), {'a.webp', 'b.webp', 'c.webp', 'd.webp'});
    expect(remote.downloaded.length, 4, reason: 'no image is downloaded twice');
  });

  test('cancelling stops further downloads and keeps the topic incomplete', () async {
    remote.questions[1] = [for (var i = 0; i < 6; i++) question('q$i', 1, image: 'i$i.webp')];
    final cancel = DownloadCancel();

    await downloader.download(
      subjectId: 5,
      topic: catalog(1),
      cancel: cancel,
      onProgress: (done, _) {
        if (done >= 2) cancel.cancel();
      },
    );

    final stored = (await store.getTopic(1))!;
    expect(stored.isComplete, isFalse);
    expect(remote.downloaded.length, lessThan(6));
  });

  test('an image whose file vanished from the phone is downloaded again', () async {
    remote.questions[1] = [question('a', 1, image: 'a.webp')];
    await downloader.download(subjectId: 5, topic: catalog(1));
    images.files.clear(); // sistem və ya istifadəçi təmizlədi

    await downloader.download(subjectId: 5, topic: catalog(1));

    expect(images.files, {'a.webp'});
    expect(remote.downloaded, ['a.webp', 'a.webp']);
  });

  test('an update replaces the questions, keeps images already on the phone and fetches only new ones', () async {
    remote.questions[1] = [question('a', 1, image: 'a.webp'), question('b', 1, image: 'b.webp')];
    await downloader.download(subjectId: 5, topic: catalog(1, version: 1));
    remote.downloaded.clear();

    remote.questions[1] = [question('a', 1, image: 'a.webp'), question('n', 1, image: 'n.webp')];
    final newer = catalog(1, version: 2);
    expect(downloadStateOf(newer, await store.getTopic(1)), TopicDownloadState.updateAvailable);
    await downloader.download(subjectId: 5, topic: newer);

    final stored = (await store.getTopic(1))!;
    expect(stored.version, 2);
    expect(stored.questionCount, 2);
    expect(remote.downloaded, ['n.webp']);
    final ids = (await db.select(db.localQuestions).get()).map((q) => q.id);
    expect(ids, unorderedEquals(['a', 'n']));
    expect(downloadStateOf(newer, stored), TopicDownloadState.ready);
  });

  test('deleting a topic removes its questions and only the images no other topic uses', () async {
    remote.questions[1] = [question('a', 1, image: 'own.webp'), question('b', 1, image: 'shared.webp')];
    remote.questions[2] = [question('c', 2, image: 'shared.webp')];
    await downloader.download(subjectId: 5, topic: catalog(1));
    await downloader.download(subjectId: 5, topic: catalog(2));

    await downloader.delete(1);

    expect(await store.getTopic(1), isNull);
    expect(await store.getTopic(2), isNotNull);
    expect(images.files, {'shared.webp'});
    expect(await store.hasImage('own.webp'), isFalse);
    expect(await store.hasImage('shared.webp'), isTrue);
    final left = await db.select(db.localQuestions).get();
    expect(left.map((q) => q.id), ['c']);
  });

  test('watchTopics lists only the subject and reports progress changes', () async {
    remote.questions[1] = [question('a', 1, image: 'a.webp')];
    remote.questions[2] = [question('b', 2)];

    final emitted = <List<int>>[];
    final sub = store.watchTopics(5).listen((rows) => emitted.add([for (final r in rows) r.imagesDone]));
    await downloader.download(subjectId: 5, topic: catalog(1));
    await downloader.download(subjectId: 9, topic: catalog(2)); // another subject
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(emitted.last, [1]);
    expect((await store.watchTopics(9).first).map((t) => t.topicId), [2]);
  });

  test('downloadStateOf: nothing stored, server topic gone, and version match', () async {
    expect(downloadStateOf(catalog(1), null), TopicDownloadState.notDownloaded);
    remote.questions[1] = [question('a', 1)];
    await downloader.download(subjectId: 5, topic: catalog(1, version: 3));
    final stored = await store.getTopic(1);
    expect(downloadStateOf(null, stored), TopicDownloadState.ready, reason: 'the server topic may be gone: keep using the copy');
    expect(downloadStateOf(catalog(1, version: 3), stored), TopicDownloadState.ready);
    expect(downloadStateOf(catalog(1, version: 4), stored), TopicDownloadState.updateAvailable);
  });
}
