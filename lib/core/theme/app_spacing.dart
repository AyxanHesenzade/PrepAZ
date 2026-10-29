import 'package:flutter/widgets.dart';

/// Bütün boşluqlar bir cədvəldən götürülür, ekranlarda "sehrli rəqəm" olmur.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;

  static const pagePadding = EdgeInsets.all(m);

  static const gapXs = SizedBox(height: xs, width: xs);
  static const gapS = SizedBox(height: s, width: s);
  static const gapM = SizedBox(height: m, width: m);
  static const gapL = SizedBox(height: l, width: l);
  static const gapXl = SizedBox(height: xl, width: xl);
}
