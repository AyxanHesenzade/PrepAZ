import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/features/offline/data/file_image_store.dart';
import 'package:prep_az/features/offline/data/supabase_download_source.dart';

void main() {
  late Directory dir;
  late FileImageStore store;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('prepaz_images');
    store = FileImageStore(Directory('${dir.path}${Platform.pathSeparator}img'));
  });
  tearDown(() => dir.deleteSync(recursive: true));

  test('a written image exists, can be read back and leaves no .part file', () async {
    await store.write('A.webp', Uint8List.fromList([1, 2, 3]));

    expect(await store.exists('A.webp'), isTrue);
    expect(store.fileOf('A.webp').readAsBytesSync(), [1, 2, 3]);
    expect(store.root.listSync().map((e) => e.path.split(Platform.pathSeparator).last), ['A.webp']);
  });

  test('writing the same name again replaces the file', () async {
    await store.write('A.webp', Uint8List.fromList([1]));
    await store.write('A.webp', Uint8List.fromList([9, 9]));

    expect(store.fileOf('A.webp').readAsBytesSync(), [9, 9]);
  });

  test('delete removes the file and does nothing for a missing one', () async {
    await store.write('A.webp', Uint8List.fromList([1]));

    await store.delete('A.webp');
    await store.delete('A.webp');

    expect(await store.exists('A.webp'), isFalse);
  });

  test('a path that leaves the folder is rejected', () async {
    for (final bad in ['../x.webp', 'a/b.webp', r'a\b.webp', '']) {
      expect(() => store.exists(bad), throwsArgumentError, reason: bad);
    }
  });

  test('a catalog row from the server becomes a CatalogTopic', () {
    final topic = catalogTopicFromRow({
      'section_id': 6,
      'section_name': 'Ümumi kimya',
      'topic_id': 11,
      'topic_name': 'Kimyanın əsas anlayışları',
      'question_count': 100,
      'version': 1793706651634870,
      'image_count': 102,
      'image_bytes': 3125990,
    });

    expect(topic.topicId, 11);
    expect(topic.sectionName, 'Ümumi kimya');
    expect(topic.version, 1793706651634870);
    expect(topic.imageBytes, 3125990);
  });
}
