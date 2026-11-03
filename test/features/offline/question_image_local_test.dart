import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/features/offline/data/file_image_store.dart';
import 'package:prep_az/features/offline/presentation/offline_providers.dart';
import 'package:prep_az/features/quiz/domain/question_image_repository.dart';
import 'package:prep_az/features/quiz/presentation/quiz_providers.dart';
import 'package:prep_az/features/quiz/presentation/widgets/question_image.dart';

class CountingLinks implements QuestionImageRepository {
  int calls = 0;

  @override
  Future<String> signedUrl(String path) async {
    calls++;
    return 'https://example.com/$path';
  }
}

/// 1x1 şəffaf PNG.
final _png = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

void main() {
  late Directory dir;
  late FileImageStore store;
  late CountingLinks links;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('prepaz_qimg');
    store = FileImageStore(dir);
    links = CountingLinks();
  });
  tearDown(() {
    // Windows-da şəkil keşi faylı açıq saxlaya bilər: müvəqqəti qovluğu silə bilməməyin zərəri yoxdur.
    try {
      dir.deleteSync(recursive: true);
    } on FileSystemException {
      // sistem özü təmizləyəcək
    }
  });

  Future<void> show(WidgetTester tester, String path) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          imageStoreProvider.overrideWithValue(store),
          questionImageRepositoryProvider.overrideWithValue(links),
        ],
        child: MaterialApp(home: Scaffold(body: QuestionImage(path))),
      ),
    );
    // Əvvəl telefondakı fayl yoxlanır, sonra (yoxdursa) server linki alınır: iki asinxron addım.
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
    }
  }

  testWidgets('an image that is on the phone is shown from the file, without asking the server', (tester) async {
    await tester.runAsync(() => store.write('A.webp', Uint8List.fromList(_png)));

    await show(tester, 'A.webp');

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<FileImage>());
    expect(links.calls, 0);
  });

  testWidgets('an image that is not on the phone is loaded through the signed link', (tester) async {
    await show(tester, 'B.webp');

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    expect(links.calls, 1);
  });
}
