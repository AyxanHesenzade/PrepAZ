/// Telefonun öz paylaşma pəncərəsini açır. UI bunu birbaşa share_plus ilə çağırmır,
/// testdə fake ilə əvəz olunur.
abstract interface class ShareService {
  /// Xəta olsa [AppException] atır. İstifadəçinin pəncərəni bağlaması xəta deyil.
  Future<void> shareText(String text, {String? subject});
}
