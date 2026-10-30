import '../constants/app_strings.dart';

/// UI-a çatan yeganə xəta tipi. Mesaj istifadəçiyə göstərilməyə hazırdır.
/// Plugin xətaları (Supabase və s.) data qatında bu tipə çevrilir.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => 'AppException: $message';
}

/// Data qatındakı hər əməliyyatı bununla sarıyın: xəta həmişə [AppException] olur.
/// [mapper] konkret xətanı (məs. AuthException) tanıyırsa, onun mesajını qaytarır.
Future<T> guard<T>(
  Future<T> Function() action, {
  AppException? Function(Object error)? mapper,
}) async {
  try {
    return await action();
  } on AppException {
    rethrow;
  } catch (error) {
    throw mapper?.call(error) ?? AppException(AppStrings.unknownError);
  }
}

/// Provider xətasından istifadəçi mesajı çıxarır.
String errorMessage(Object error) =>
    error is AppException ? error.message : AppStrings.unknownError;
