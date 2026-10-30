import 'package:flutter/material.dart';

/// Mövzu mənimsənilməsi, cavab nəticəsi və fənn rəngləri.
abstract final class AppColors {
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF97316);
  static const danger = Color(0xFFE11D48);

  /// Seriya (alov) vurğusu.
  static const streak = Color(0xFFFFB020);

  /// Marka gradienti (seriya kartı, giriş ekranı).
  static const brandStart = Color(0xFF2F6FED);
  static const brandEnd = Color(0xFF1B3A8C);

  static const _subjectAccents = <String, Color>{
    'kimya': Color(0xFF7C4DFF),
    'biologiya': Color(0xFF12B76A),
  };
  static const _fallbackAccents = [
    Color(0xFF2F6FED),
    Color(0xFFFF7A45),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
  ];

  /// Hər fənn öz rəngini alır: tanınan fənlər sabit, qalanları id-yə görə.
  static Color subjectAccent(String slug, int id) =>
      _subjectAccents[slug] ??
      _fallbackAccents[id.abs() % _fallbackAccents.length];

  /// 0-49 qırmızı, 50-79 narıncı, 80-100 yaşıl.
  static Color forMastery(int pct) {
    if (pct < 50) return danger;
    if (pct < 80) return warning;
    return success;
  }
}
