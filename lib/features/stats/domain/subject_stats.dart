/// Bir günün nəticəsi (Bakı vaxtı ilə).
class DayStat {
  const DayStat({
    required this.day,
    required this.answered,
    required this.correct,
  });

  final DateTime day;
  final int answered;
  final int correct;
}

/// Şagirdin bir fənn üzrə statistikası. Server hesablayır (`get_my_stats`, migration 018).
class SubjectStats {
  const SubjectStats({
    required this.answered,
    required this.correct,
    required this.questionsTried,
    required this.questionsSolved,
    required this.questionsTotal,
    required this.topicsTotal,
    required this.bestStreak,
    required this.days,
  });

  static const empty = SubjectStats(
    answered: 0,
    correct: 0,
    questionsTried: 0,
    questionsSolved: 0,
    questionsTotal: 0,
    topicsTotal: 0,
    bestStreak: 0,
    days: [],
  );

  /// Qrafikdə göstərilən günlər (bu həftə); əvvəlki həftə yalnız müqayisə üçündür.
  static const weekDays = 7;

  /// Bütün cavablar (təkrarlar daxil).
  final int answered;
  final int correct;

  /// Fərqli aktiv testlər: cəhd edilən və son cavabı düz olan.
  final int questionsTried;
  final int questionsSolved;

  /// Fənndəki aktiv testlər və onları olan mövzular.
  final int questionsTotal;
  final int topicsTotal;

  /// Ardıcıl ən uzun aktiv günlər (bütün fənlər üzrə).
  final int bestStreak;

  /// Ən köhnədən ən yeniyə, boş günlər də daxil.
  final List<DayStat> days;

  bool get isEmpty => answered == 0;

  int get accuracyPct => answered == 0 ? 0 : (100 * correct / answered).round();

  /// Fənnin neçə faizi həll edilib (0..1).
  double get coverage =>
      questionsTotal == 0 ? 0 : (questionsSolved / questionsTotal).clamp(0, 1);

  List<DayStat> get thisWeek =>
      days.length <= weekDays ? days : days.sublist(days.length - weekDays);

  List<DayStat> get lastWeek => days.length <= weekDays
      ? const []
      : days.sublist(
          (days.length - 2 * weekDays).clamp(0, days.length),
          days.length - weekDays,
        );

  int get thisWeekAnswered => _sum(thisWeek);
  int get lastWeekAnswered => _sum(lastWeek);

  /// Bu həftə keçən həftədən nə qədər çox (mənfi = az).
  int get weekDelta => thisWeekAnswered - lastWeekAnswered;

  static int _sum(List<DayStat> days) =>
      days.fold(0, (sum, d) => sum + d.answered);
}
