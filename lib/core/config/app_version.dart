import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tətbiqin versiyası. Mənbə: `assets/app.json` (pubspec.yaml-dakı `version: X.Y.Z+B` ilə eyni olmalıdır,
/// bunu test yoxlayır). Ana ekranda göstərilir ki, istifadəçi hansı versiyanı işlətdiyini desin.
class AppVersion {
  const AppVersion({required this.version, required this.build});

  factory AppVersion.fromJson(Map<String, dynamic> json) => AppVersion(
    version: json['version'] as String,
    build: (json['build'] as num).toInt(),
  );

  static const assetPath = 'assets/app.json';

  final String version;
  final int build;
}

final appVersionProvider = FutureProvider<AppVersion>((ref) async {
  final raw = await rootBundle.loadString(AppVersion.assetPath);
  return AppVersion.fromJson(jsonDecode(raw) as Map<String, dynamic>);
});
