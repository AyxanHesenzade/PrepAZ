import 'dart:typed_data';

/// Telefonda şəkil faylları. Yol bucket-dəki ad ilə eynidir (məs. `KT1-S01-Q001.webp`).
abstract interface class ImageStore {
  Future<void> write(String path, Uint8List bytes);

  Future<bool> exists(String path);

  /// Faylın telefondakı tam yolu (göstərmək üçün). Şəkil telefonda yoxdursa `null`.
  Future<String?> localPath(String path);

  Future<void> delete(String path);
}
