import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Personajın görünüşü: rəng və ölçülər. Dəyişmək üçün yalnız bu fayla baxmaq kifayətdir.
/// Bütün uzunluqlar widget ölçüsünə nisbətdir (0.5 = ölçünün yarısı).
class MascotStyle {
  const MascotStyle({
    this.bodyColors = const [AppColors.brandStart, AppColors.brandEnd],
    this.armColor = AppColors.brandStart,
    this.faceColor = Colors.white,
    this.bodyRadius = 0.42,
    this.armRadius = 0.08,
    this.eyeRadius = 0.075,
    this.eyeSpacing = 0.15,
    this.eyeHeight = -0.07,
    this.mouthWidth = 0.13,
    this.mouthHeight = 0.13,
  });

  final List<Color> bodyColors;
  final Color armColor;
  final Color faceColor;
  final double bodyRadius;
  final double armRadius;
  final double eyeRadius;
  final double eyeSpacing;
  final double eyeHeight;
  final double mouthWidth;
  final double mouthHeight;
}
