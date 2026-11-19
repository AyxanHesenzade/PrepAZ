import 'dart:io';
import 'dart:typed_data';

import '../../offline/data/file_image_store.dart';
import '../domain/image_cache.dart';

/// Keş telefonun CACHE qovluğundadır (`getApplicationCacheDirectory`): yer azalanda sistem onu təmizləyə
/// bilər, bu normaldır (şəkil sadəcə yenidən yüklənir). Oflayn yüklənmiş mövzular ayrıca, silinməyən
/// qovluqdadır (`FileImageStore`, `offline_images`).
///
/// Düzəldilmiş şəkil serverə EYNİ adla yüklənir, ona görə keşdəki fayl [maxAge]-dən sonra köhnə sayılır
/// və yenidən yüklənir (düzəliş ən gec bu müddətdə hamıya çatır).
class FileImageCache implements ImageCache {
  FileImageCache(
    Directory root, {
    this.maxAge = const Duration(days: 7),
    DateTime Function()? now,
  }) : _store = FileImageStore(root),
       _now = now ?? DateTime.now;

  final FileImageStore _store;
  final Duration maxAge;
  final DateTime Function() _now;

  @override
  Future<Uint8List?> read(String path) async {
    final file = _store.fileOf(path);
    if (!await file.exists()) return null;
    if (_now().difference(await file.lastModified()) > maxAge) return null;
    return file.readAsBytes();
  }

  @override
  Future<void> write(String path, Uint8List bytes) => _store.write(path, bytes);
}
