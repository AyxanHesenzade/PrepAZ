import '../../../core/error/app_exception.dart';
import 'leaderboard.dart';

/// Nik-ad artıq başqasınındır.
class NicknameTakenException extends AppException {
  const NicknameTakenException(super.message);
}

abstract interface class LeaderboardRepository {
  /// Şagird hələ yarışa qoşulmayıbsa null.
  Future<Player?> getMyPlayer();

  /// İlk dəfə qoşulmaq və ya məlumatı dəyişmək. Nik-ad tutulubsa [NicknameTakenException].
  Future<void> savePlayer(Player player);

  /// Ümumi reytinq (bütün vaxt üzrə). Həftəlik cədvəl yoxdur (sahibin qərarı).
  Future<Leaderboard> getLeaderboard(int subjectId);
}
