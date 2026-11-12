/// Axşam xatırlatmasının növü (mətn presentation-da seçilir).
enum ReminderKind {
  /// Seriya yoxdur, bu gün hələ test həll edilməyib.
  start,

  /// Seriya var, bu gün hələ həll edilməyib: qırılmasın.
  atRisk,

  /// Bu gün həll edilib: sabah davam et.
  keepGoing,

  /// Bir neçə gündür girmir: geri qayıt.
  comeBack,
}

class ReminderPlan {
  const ReminderPlan({required this.at, required this.kind, this.streak = 0});

  final DateTime at;
  final ReminderKind kind;
  final int streak;

  @override
  bool operator ==(Object other) =>
      other is ReminderPlan &&
      other.at == at &&
      other.kind == kind &&
      other.streak == streak;

  @override
  int get hashCode => Object.hash(at, kind, streak);

  @override
  String toString() => 'ReminderPlan($at, $kind, $streak)';
}

/// Serverdəki seriya vəziyyəti.
class StreakStatus {
  const StreakStatus({
    required this.streakDays,
    required this.lastActive,
    required this.answeredToday,
  });

  /// `profiles.streak_days`. Diqqət: seriya qırılanda server onu növbəti cavaba qədər sıfırlamır.
  final int streakDays;

  /// `profiles.last_active` (serverin tarixi, UTC). null = heç həll etməyib.
  final DateTime? lastActive;

  /// Telefonun vaxtı ilə bu gün (00:00-dan) verilən cavablar.
  final int answeredToday;
}

/// Növbəti günlər üçün xatırlatmalar. Hər açılışda və məşqdən sonra yenidən hesablanır,
/// ona görə köhnə plan həmişə təzəsi ilə əvəz olunur.
///
/// - bu gün həll edilməyibsə və saat [hour]-a çatmayıbsa: bu axşam (`atRisk` və ya `start`);
/// - sabah: bu gün həll edilibsə `keepGoing`, yoxsa `comeBack`;
/// - sonrakı günlər: `comeBack` (tətbiq açılmasa da ruhlandırsın).
List<ReminderPlan> planReminders({
  required DateTime now,
  required StreakStatus status,
  int hour = 20,
  int days = 3,
}) {
  final practicedToday = status.answeredToday > 0;
  final streak = currentStreak(now: now, status: status);
  final today = DateTime(now.year, now.month, now.day, hour);
  final plans = <ReminderPlan>[];
  if (!practicedToday && now.isBefore(today)) {
    plans.add(
      streak > 0
          ? ReminderPlan(at: today, kind: ReminderKind.atRisk, streak: streak)
          : ReminderPlan(at: today, kind: ReminderKind.start),
    );
  }
  for (var d = 1; d <= days; d++) {
    final at = DateTime(now.year, now.month, now.day + d, hour);
    plans.add(
      d == 1 && practicedToday && streak > 0
          ? ReminderPlan(at: at, kind: ReminderKind.keepGoing, streak: streak)
          : ReminderPlan(at: at, kind: ReminderKind.comeBack),
    );
  }
  return plans;
}

/// Hələ qırılmamış seriya: son aktiv gün bu gün və ya dünəndirsə (serverin UTC tarixi ilə).
int currentStreak({required DateTime now, required StreakStatus status}) {
  final last = status.lastActive;
  if (last == null || status.streakDays <= 0) return 0;
  final u = now.toUtc();
  final todayUtc = DateTime.utc(u.year, u.month, u.day);
  final lastDay = DateTime.utc(last.year, last.month, last.day);
  return todayUtc.difference(lastDay).inDays <= 1 ? status.streakDays : 0;
}
