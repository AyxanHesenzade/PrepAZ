import 'package:flutter/material.dart';

import 'mascot_behavior.dart';
import 'mascot_pose.dart';
import 'mascot_style.dart';

/// Yalnız boyayır: vəziyyəti [behavior]-dan, görünüşü [style]-dan alır.
class MascotPainter extends CustomPainter {
  MascotPainter({
    required this.animation,
    required this.behavior,
    required this.style,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final MascotBehavior behavior;
  final MascotStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final pose = behavior.poseAt(animation.value);
    final s = size.width;

    canvas.save();
    canvas.translate(s / 2, s / 2 - pose.lift * s);
    canvas.rotate(pose.tilt);
    canvas.scale(1 + pose.squash, 1 - pose.squash);

    _paintArms(canvas, s, pose);
    _paintBody(canvas, s);
    _paintEyes(canvas, s, pose);
    _paintMouth(canvas, s, pose);

    canvas.restore();
  }

  void _paintArms(Canvas canvas, double s, MascotPose pose) {
    final paint = Paint()..color = style.armColor;
    final radius = s * style.armRadius;
    canvas.drawCircle(Offset(-s * 0.42, s * 0.1), radius, paint);
    canvas.drawCircle(
      Offset(s * 0.43, s * (-0.05 + pose.armWave * 0.05)),
      radius,
      paint,
    );
  }

  void _paintBody(Canvas canvas, double s) {
    final radius = s * style.bodyRadius;
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: style.bodyColors,
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius)),
    );
  }

  void _paintEyes(Canvas canvas, double s, MascotPose pose) {
    final paint = Paint()..color = style.faceColor;
    final diameter = s * style.eyeRadius * 2;
    final openness = (1 - pose.blink).clamp(0.1, 1.0);
    for (final side in const [-1, 1]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(
            s * (side * style.eyeSpacing + pose.lookX * 0.07),
            s * style.eyeHeight,
          ),
          width: diameter,
          height: diameter * openness,
        ),
        paint,
      );
    }
  }

  void _paintMouth(Canvas canvas, double s, MascotPose pose) {
    final width = s * style.mouthWidth;
    final top = s * style.mouthHeight;
    final shift = s * pose.lookX * 0.04;
    final path = Path()
      ..moveTo(shift - width, top)
      ..quadraticBezierTo(
        shift,
        top + s * (0.1 + 0.08 * pose.mouthOpen),
        shift + width,
        top,
      )
      ..quadraticBezierTo(shift, top + s * 0.05, shift - width, top);
    canvas.drawPath(
      path,
      Paint()
        ..color = style.faceColor
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(MascotPainter oldDelegate) =>
      oldDelegate.animation != animation ||
      oldDelegate.behavior != behavior ||
      oldDelegate.style != style;
}
