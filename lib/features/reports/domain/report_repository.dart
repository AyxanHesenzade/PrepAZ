/// Problem bildirişi: sualda xəta ([questionId] + [questionCode] verilir) və ya tətbiqdə xəta (ikisi də null).
abstract interface class ReportRepository {
  Future<void> submit({
    required String message,
    required String appVersion,
    String? questionId,
    String? questionCode,
  });
}

/// Açıqlama bazanın qaydası ilə eyni olmalıdır (10-1000 simvol).
abstract final class ReportRules {
  static const minLength = 10;
  static const maxLength = 1000;

  static bool isValid(String message) {
    final length = message.trim().length;
    return length >= minLength && length <= maxLength;
  }
}
