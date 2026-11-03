import 'dart:io';
import 'dart:typed_data';

import '../domain/image_store.dart';

/// Şəkillər bir qovluqda fayl kimi saxlanır. Qovluq sistemin təmizləyə bilməyəcəyi yerdə olmalıdır
/// (cache yox, tətbiq məlumatları: `getApplicationSupportDirectory`).
class FileImageStore implements ImageStore {
  FileImageStore(this.root);

  final Directory root;

  /// Yol bucket-dəki ad kimi düz fayl adı olmalıdır: qovluqdan kənara çıxmaq olmaz.
  File _file(String path) {
    if (path.isEmpty ||
        path.contains('/') ||
        path.contains('\\') ||
        path.contains('..')) {
      throw ArgumentError.value(path, 'path', 'unsafe image path');
    }
    return File('${root.path}${Platform.pathSeparator}$path');
  }

  @override
  Future<void> write(String path, Uint8List bytes) async {
    final target = _file(path);
    await root.create(recursive: true);
    // Əvvəl müvəqqəti fayla yazılır: yarıda kəsilsə, yarımçıq şəkil qalmır.
    final temp = File('${target.path}.part');
    await temp.writeAsBytes(bytes, flush: true);
    await temp.rename(target.path);
  }

  @override
  Future<bool> exists(String path) => _file(path).exists();

  @override
  Future<String?> localPath(String path) async {
    final file = _file(path);
    return await file.exists() ? file.path : null;
  }

  @override
  Future<void> delete(String path) async {
    final file = _file(path);
    if (await file.exists()) await file.delete();
  }

  /// Faylın özü (testlər üçün). Fayl yoxdursa, yenə də yol qaytarır.
  File fileOf(String path) => _file(path);
}
