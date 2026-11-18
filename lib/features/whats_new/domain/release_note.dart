/// Bir buraxılışın yenilikləri. Mətnlər üç dildə: [items] hər dəfə cari dildə qurulur.
class ReleaseNote {
  const ReleaseNote({
    required this.build,
    required this.version,
    required this.items,
  });

  final int build;
  final String version;

  /// Boş siyahı = bu buraxılışda şagirdə göstəriləcək yenilik yoxdur (məs. yalnız xəta düzəlişi).
  final List<String> Function() items;
}

/// Hansı qeydlər göstərilməlidir (ən yenisi birinci).
///
/// - Yeni istifadəçiyə ([isNewUser]) heç nə göstərilmir: onun üçün öyrədici tur var.
/// - [lastSeenBuild] 0-dırsa, amma istifadəçi köhnədirsə (funksiya ondan sonra gəlib),
///   yalnız cari buraxılış göstərilir.
/// - Bir neçə versiya atlanıbsa, aradakıların hamısı (ən çox [maxVersions]).
List<ReleaseNote> notesToShow({
  required int currentBuild,
  required int lastSeenBuild,
  required bool isNewUser,
  required List<ReleaseNote> all,
  int maxVersions = 3,
}) {
  if (isNewUser || lastSeenBuild >= currentBuild) return const [];
  final from = lastSeenBuild == 0 ? currentBuild - 1 : lastSeenBuild;
  final notes = [
    for (final n in all)
      if (n.build > from && n.build <= currentBuild && n.items().isNotEmpty) n,
  ]..sort((a, b) => b.build.compareTo(a.build));
  return notes.take(maxVersions).toList();
}
