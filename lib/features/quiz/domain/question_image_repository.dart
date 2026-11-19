import 'dart:typed_data';

/// Sual/izah şəklinin baytları. Şəklin HARADAN gəldiyini (Supabase Storage, Cloudflare R2, gələcəkdə
/// gizli server) yalnız implementasiya bilir; UI və oflayn yükləmə yalnız bu interfeysi tanıyır.
/// Yeni mənbəyə keçmək = yeni implementasiya + `quiz_providers.dart`-da bir sətir.
abstract interface class QuestionImageRepository {
  /// [path] bazadakı `image_path` / `solution_image_path` dəyəridir (məs. `KT1-S01-Q001.webp`).
  /// Alınmasa [AppException] atır.
  Future<Uint8List> fetch(String path);
}
