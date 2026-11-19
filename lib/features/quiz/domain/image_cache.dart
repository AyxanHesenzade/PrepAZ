import 'dart:typed_data';

/// Bir dəfə yüklənmiş şəklin telefondakı keşi: eyni sual sabah açılanda şəkil yenidən yüklənmir
/// (trafik). Açar şəklin yoludur (link yox), çünki link mənbədən asılı olaraq dəyişə bilər.
abstract interface class ImageCache {
  /// Şəkil keşdə yoxdursa (və ya oxunmursa) `null`.
  Future<Uint8List?> read(String path);

  Future<void> write(String path, Uint8List bytes);
}

/// Keş yoxdur (testlər və ilkin dəyər). `main.dart` telefonda fayl keşi verir.
class NoImageCache implements ImageCache {
  const NoImageCache();

  @override
  Future<Uint8List?> read(String path) async => null;

  @override
  Future<void> write(String path, Uint8List bytes) async {}
}
