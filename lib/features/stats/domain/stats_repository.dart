import 'subject_stats.dart';

abstract interface class StatsRepository {
  /// Şagirdin öz statistikası, son [days] gün ilə (bu və keçən həftə).
  Future<SubjectStats> getStats(int subjectId, {int days = 14});
}
