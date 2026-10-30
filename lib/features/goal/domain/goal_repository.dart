import 'exam_goal.dart';

abstract interface class GoalRepository {
  /// Aktiv imtahan dövrləri (sıra ilə).
  Future<List<ExamPeriod>> getPeriods();

  /// Şagirdin hədəfi; hələ seçməyibsə null.
  Future<UserGoal?> getGoal();

  Future<void> saveGoal(UserGoal goal);

  /// [from] vaxtından bəri verilmiş cavabların sayı (bu gün üçün hədəf zolağı).
  Future<int> countAnswersSince(DateTime from);
}
