/// Cədvəldə bir sətir. Başqalarına yalnız nik-ad görünür.
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.rank,
    required this.nickname,
    required this.score,
    required this.isMe,
  });

  final int rank;
  final String nickname;

  /// Ən azı bir dəfə düz həll edilmiş fərqli testlərin sayı (təkrar xal vermir).
  final int score;
  final bool isMe;
}

/// Serverdən gələn siyahı: ilk N nəfər + (cədvəldən kənardadırsa) şagirdin öz sətri.
class Leaderboard {
  const Leaderboard(this.entries);

  final List<LeaderboardEntry> entries;

  LeaderboardEntry? get me {
    for (final e in entries) {
      if (e.isMe) return e;
    }
    return null;
  }

  List<LeaderboardEntry> get podium => entries.take(3).toList();
}

/// Yarışa qoşulmuş şagird. Ad və soyad başqalarına göstərilmir.
class Player {
  const Player({
    required this.nickname,
    required this.firstName,
    required this.lastName,
  });

  final String nickname;
  final String firstName;
  final String lastName;
}
