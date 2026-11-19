import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/error/app_exception.dart';
import 'package:prep_az/features/quiz/data/file_image_cache.dart';
import 'package:prep_az/features/quiz/data/layered_image_repositories.dart';
import 'package:prep_az/features/quiz/data/public_url_image_repository.dart';
import 'package:prep_az/features/quiz/domain/image_cache.dart';
import 'package:prep_az/features/quiz/domain/question_image_repository.dart';

class _Source implements QuestionImageRepository {
  _Source(this.files);

  final Map<String, List<int>> files;
  final asked = <String>[];

  @override
  Future<Uint8List> fetch(String path) async {
    asked.add(path);
    final bytes = files[path];
    if (bytes == null) throw const AppException('yoxdur');
    return Uint8List.fromList(bytes);
  }
}

class _MemoryCache implements ImageCache {
  final files = <String, Uint8List>{};
  bool broken = false;

  @override
  Future<Uint8List?> read(String path) async {
    if (broken) throw const FileSystemException('disk');
    return files[path];
  }

  @override
  Future<void> write(String path, Uint8List bytes) async {
    if (broken) throw const FileSystemException('disk');
    files[path] = bytes;
  }
}

void main() {
  group('FallbackImageRepository', () {
    test('uses the primary source when it has the image', () async {
      final r2 = _Source({'A.webp': [1]});
      final supabase = _Source({'A.webp': [2]});

      expect(await FallbackImageRepository(r2, supabase).fetch('A.webp'), [1]);
      expect(supabase.asked, isEmpty);
    });

    test('an image not yet moved to the primary source still opens from the fallback', () async {
      final r2 = _Source({});
      final supabase = _Source({'B.webp': [2]});

      expect(await FallbackImageRepository(r2, supabase).fetch('B.webp'), [2]);
    });

    test('fails only when both sources fail', () async {
      final repo = FallbackImageRepository(_Source({}), _Source({}));
      await expectLater(repo.fetch('C.webp'), throwsA(isA<AppException>()));
    });
  });

  group('CachedImageRepository', () {
    test('the second view of the same image does not touch the network', () async {
      final server = _Source({'A.webp': [7]});
      final repo = CachedImageRepository(server, _MemoryCache());

      expect(await repo.fetch('A.webp'), [7]);
      expect(await repo.fetch('A.webp'), [7]);
      expect(server.asked, ['A.webp']);
    });

    test('a broken cache never hides the image', () async {
      final server = _Source({'A.webp': [7]});
      final repo = CachedImageRepository(server, _MemoryCache()..broken = true);

      expect(await repo.fetch('A.webp'), [7]);
    });
  });

  test('FileImageCache keeps the bytes on disk and refuses paths outside its folder', () async {
    final dir = Directory.systemTemp.createTempSync('prepaz_cache');
    addTearDown(() => dir.deleteSync(recursive: true));
    final cache = FileImageCache(dir);

    expect(await cache.read('A.webp'), isNull);
    await cache.write('A.webp', Uint8List.fromList([1, 2, 3]));
    expect(await cache.read('A.webp'), [1, 2, 3]);
    expect(() => cache.read('../x.webp'), throwsArgumentError);
  });

  test('FileImageCache: an old copy is treated as missing (a corrected image with the same name reaches everyone)', () async {
    final dir = Directory.systemTemp.createTempSync('prepaz_cache_age');
    addTearDown(() => dir.deleteSync(recursive: true));
    final later = DateTime.now().add(const Duration(days: 8));
    await FileImageCache(dir).write('A.webp', Uint8List.fromList([1]));

    expect(await FileImageCache(dir, now: () => later).read('A.webp'), isNull);
    expect(await FileImageCache(dir).read('A.webp'), [1]);
  });

  group('PublicUrlImageRepository (real HTTP on localhost)', () {
    late HttpServer server;
    late String base;

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      base = 'http://${server.address.host}:${server.port}/';
      server.listen((request) {
        if (request.uri.path == '/KT1-S01-Q001.webp') {
          request.response.add([9, 8, 7]);
        } else {
          request.response.statusCode = HttpStatus.notFound;
        }
        request.response.close();
      });
    });
    tearDown(() => server.close(force: true));

    test('downloads <base>/<path> (a trailing slash in the base is fine)', () async {
      final repo = PublicUrlImageRepository(base);
      expect(await repo.fetch('KT1-S01-Q001.webp'), [9, 8, 7]);
    });

    test('a missing image is an AppException (so the fallback can take over)', () async {
      final repo = PublicUrlImageRepository(base);
      await expectLater(repo.fetch('NOPE.webp'), throwsA(isA<AppException>()));
    });
  });
}
