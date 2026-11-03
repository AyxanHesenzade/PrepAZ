/// Köməkçinin nə vaxt nə deyəcəyi: ardıcıl düz cavablara görə. Yalnız qayda; mətn və görünüş burada deyil.
enum CheerKind {
  /// 3 ardıcıl düz.
  three,

  /// 5 ardıcıl düz.
  five,

  /// 10, 15, 20... ardıcıl düz (hər 5-də bir).
  big,

  /// Ən azı 5 ardıcıl düzdən sonra bir səhv: ruhlandırır, qınamır.
  comeback,
}

class Cheer {
  const Cheer(this.kind, this.streak);

  final CheerKind kind;

  /// `three/five/big` üçün: ardıcıl düz sayı. `comeback` üçün: qırılan seriyanın uzunluğu.
  final int streak;

  @override
  bool operator ==(Object other) =>
      other is Cheer && other.kind == kind && other.streak == streak;

  @override
  int get hashCode => Object.hash(kind, streak);

  @override
  String toString() => 'Cheer($kind, $streak)';
}

abstract final class CheerPolicy {
  /// Bu uzunluqda seriyadan sonra səhv olarsa, köməkçi ruhlandırır.
  static const comebackFrom = 5;

  /// [results] cavab sırası ilə: `true` = düz. Sonuncu cavabdan sonra deyiləcək söz, yoxsa `null`.
  ///
  /// Ardıcıl SƏHVLƏRƏ heç vaxt heç nə deyilmir: ikinci səhvdə qırılacaq seriya qalmır, ona görə `null`.
  static Cheer? after(List<bool> results) {
    if (results.isEmpty) return null;
    if (results.last) {
      final n = _trailingCorrect(results);
      if (n == 3) return Cheer(CheerKind.three, n);
      if (n == 5) return Cheer(CheerKind.five, n);
      if (n >= 10 && n % 5 == 0) return Cheer(CheerKind.big, n);
      return null;
    }
    final broken = _trailingCorrect(results.sublist(0, results.length - 1));
    return broken >= comebackFrom ? Cheer(CheerKind.comeback, broken) : null;
  }

  static int _trailingCorrect(List<bool> results) {
    var n = 0;
    for (var i = results.length - 1; i >= 0 && results[i]; i--) {
      n++;
    }
    return n;
  }
}
