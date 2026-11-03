/// Ölçü insan üçün: `820 KB`, `3.1 MB`. Yüklə ekranında hər mövzunun yanında göstərilir.
String formatBytes(int bytes) {
  if (bytes < 1024 * 1024) {
    final kb = (bytes / 1024).round();
    return '${kb < 1 && bytes > 0 ? 1 : kb} KB';
  }
  final mb = bytes / (1024 * 1024);
  return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
}
