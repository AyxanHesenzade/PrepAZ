/// Versiya: `0.0.1` və ya build ilə `0.0.1+2`. Build yazılmayıbsa 0 sayılır.
class VersionCode implements Comparable<VersionCode> {
  const VersionCode(this.major, this.minor, this.patch, [this.build = 0]);

  /// Səhv formatda null qaytarır (belə dəyər bazaya düşməməlidir, amma tətbiq çökməməlidir).
  static VersionCode? tryParse(String text) {
    final m = RegExp(r'^(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$').firstMatch(text.trim());
    if (m == null) return null;
    return VersionCode(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
      m.group(4) == null ? 0 : int.parse(m.group(4)!),
    );
  }

  final int major;
  final int minor;
  final int patch;
  final int build;

  @override
  int compareTo(VersionCode other) {
    for (final (a, b) in [
      (major, other.major),
      (minor, other.minor),
      (patch, other.patch),
      (build, other.build),
    ]) {
      if (a != b) return a.compareTo(b);
    }
    return 0;
  }

  bool operator <(VersionCode other) => compareTo(other) < 0;
}

/// Bazadakı yeniləmə tənzimləmələri (admin paneldən dəyişir).
class AppConfig {
  const AppConfig({required this.minVersion, required this.latestVersion, this.updateUrl});

  /// Bundan aşağı versiya məcburi yenilənməlidir.
  final String minVersion;

  /// Bundan aşağı versiyaya "yeni versiya var" xəbərdarlığı göstərilir.
  final String latestVersion;
  final String? updateUrl;

  bool get hasUrl => updateUrl != null && updateUrl!.trim().isNotEmpty;
}

enum UpdateKind { none, optional, required }

class UpdateInfo {
  const UpdateInfo(this.kind, {this.url});

  static const none = UpdateInfo(UpdateKind.none);

  final UpdateKind kind;
  final String? url;

  bool get hasUrl => url != null && url!.trim().isNotEmpty;

  /// [config] null (oxunmadı) və ya versiya oxunmursa heç nə bloklanmır: yeniləmə yoxlaması tətbiqi çökdürməməlidir.
  static UpdateInfo decide(VersionCode current, AppConfig? config) {
    if (config == null) return none;
    final min = VersionCode.tryParse(config.minVersion);
    final latest = VersionCode.tryParse(config.latestVersion);
    if (min != null && current < min) return UpdateInfo(UpdateKind.required, url: config.updateUrl);
    if (latest != null && current < latest) return UpdateInfo(UpdateKind.optional, url: config.updateUrl);
    return none;
  }
}
