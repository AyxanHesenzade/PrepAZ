/// İmtahan dövrü (məs. qış, yay). Tarixi admin paneldən dəyişir.
class ExamPeriod {
  const ExamPeriod({
    required this.id,
    required this.code,
    required this.name,
    required this.examDate,
  });

  final int id;
  final String code;
  final String name;
  final DateTime examDate;
}

/// Şagirdin seçimi: dövr və ya öz tarixi, həmçinin gündəlik sual hədəfi.
class UserGoal {
  const UserGoal({
    this.periodId,
    this.customDate,
    this.dailyGoal = defaultDailyGoal,
  });

  static const defaultDailyGoal = 20;
  static const dailyGoalOptions = [10, 20, 30, 50];

  final int? periodId;
  final DateTime? customDate;
  final int dailyGoal;

  /// Şagird öz tarixini yazıbsa, dövrün tarixindən üstündür.
  DateTime? examDate(List<ExamPeriod> periods) {
    if (customDate != null) return customDate;
    for (final p in periods) {
      if (p.id == periodId) return p.examDate;
    }
    return null;
  }

  /// İmtahana neçə gün qalıb. Tarix keçibsə və ya bilinmirsə null.
  int? daysLeft(List<ExamPeriod> periods, DateTime today) {
    final date = examDate(periods);
    if (date == null) return null;
    final from = DateTime(today.year, today.month, today.day);
    final to = DateTime(date.year, date.month, date.day);
    final days = to.difference(from).inDays;
    return days < 0 ? null : days;
  }
}
