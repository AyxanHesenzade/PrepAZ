import 'dart:typed_data';

import '../domain/image_store.dart';

/// Testlər və ilkin dəyər üçün: faylları yaddaşda saxlayır, telefonda real fayl olmadığı üçün
/// [localPath] həmişə `null` qaytarır (şəkil əvvəlki kimi serverdən göstərilir).
/// `main.dart` burada `FileImageStore` verir.
class InMemoryImageStore implements ImageStore {
  final _files = <String>{};

  @override
  Future<void> write(String path, Uint8List bytes) async => _files.add(path);

  @override
  Future<bool> exists(String path) async => _files.contains(path);

  @override
  Future<String?> localPath(String path) async => null;

  @override
  Future<void> delete(String path) async => _files.remove(path);
}
