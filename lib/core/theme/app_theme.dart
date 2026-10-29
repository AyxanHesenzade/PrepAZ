import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seed = Color(0xFF1F4E78);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _seed,
      brightness: brightness,
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }
}
