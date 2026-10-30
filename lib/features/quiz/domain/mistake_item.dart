import 'question.dart';

/// Səhvlər dəftərindəki bir sual (`review_queue` sətri).
class MistakeItem {
  const MistakeItem({
    required this.question,
    required this.dueAt,
    required this.intervalDays,
  });

  final Question question;

  /// Təkrar tarixi (yalnız gün).
  final DateTime dueAt;
  final int intervalDays;

  /// Təkrar vaxtı çatıb? [today] yalnız gün hissəsi ilə müqayisə olunur.
  bool isDue(DateTime today) =>
      !dueAt.isAfter(DateTime(today.year, today.month, today.day));

  /// Təkrara neçə gün qalıb (vaxtı çatıbsa 0).
  int daysUntilDue(DateTime today) {
    final days = dueAt
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    return days < 0 ? 0 : days;
  }
}
