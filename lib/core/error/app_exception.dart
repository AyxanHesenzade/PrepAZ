import '../constants/app_strings.dart';
import '../logging/app_log.dart';

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
/// Hər xəta admin panelin "Loglar" bölməsinə də düşür ([AppLog.error]).
Future<T> guard<T>(
  Future<T> Function() action, {
  AppException? Function(Object error)? mapper,
}) async {
  // Harada baş verdiyini bilmək üçün çağıranın yeri (yalnız log açıqdırsa).
  final origin = AppLog.enabled ? StackTrace.current : null;
  try {
    return await action();
  } on AppException {
    rethrow; // məqsədli xəta ("hesab var" və s.): texniki xəta deyil, loga yazılmır
  } catch (error, stack) {
    AppLog.error(error, stack: stack, origin: origin);
    throw mapper?.call(error) ?? AppException(AppStrings.unknownError);
  }
}

/// Provider xətasından istifadəçi mesajı çıxarır.
String errorMessage(Object error) =>
    error is AppException ? error.message : AppStrings.unknownError;
