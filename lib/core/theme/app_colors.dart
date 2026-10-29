import 'package:flutter/material.dart';

/// Mövzu mənimsənilməsi və cavab nəticəsi üçün ortaq rənglər.
abstract final class AppColors {
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFEF6C00);
  static const danger = Color(0xFFC62828);

  /// 0-49 qırmızı, 50-79 narıncı, 80-100 yaşıl.
  static Color forMastery(int pct) {
    if (pct < 50) return danger;
    if (pct < 80) return warning;
    return success;
  }
}
