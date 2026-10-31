import 'dart:math' as math;

import 'mascot_pose.dart';

/// Hərəkət ssenarisi: vaxta görə vəziyyəti verir. Yeni hərəkət üçün bu interfeysin
/// yeni implementasiyası yazılır, personaj və boyama kodu dəyişmir.
abstract interface class MascotBehavior {
  /// Bir tam dövrün uzunluğu.
  Duration get cycle;

  /// [t] dövrün içindəki yerdir: 0..1. t=0 və t=1 eyni vəziyyət olmalıdır, yoxsa hərəkət sıçrayır.
  MascotPose poseAt(double t);
}

double _wave(double t, int cycles) => math.sin(2 * math.pi * t * cycles);

/// [from]..[to] aralığında 0-dan 1-ə qalxıb 0-a enir, kənarda 0-dır.
double _bump(double t, double from, double to) {
  if (t <= from || t >= to) return 0;
  return math.sin(math.pi * (t - from) / (to - from));
}

/// [from]..[to] aralığında yumşaq qalxır, 1-də durur və yumşaq enir.
double _hold(double t, double from, double to) {
  const edge = 0.2;
  return (_bump(t, from, to) / math.sin(math.pi * edge)).clamp(0.0, 1.0);
}

double _blinkAt(double t, double moment) => _bump(t, moment, moment + 0.02);

/// Danışan köməkçi (öyrədici turda): yırğalanır, ağzı açılıb-yumulur, əl yelləyir.
class TalkingMascot implements MascotBehavior {
  const TalkingMascot();

  @override
  Duration get cycle => const Duration(seconds: 6);

  @override
  MascotPose poseAt(double t) => MascotPose(
    lookX: _wave(t, 1) * 0.4,
    blink: _blinkAt(t, 0.3) + _blinkAt(t, 0.62) + _blinkAt(t, 0.93),
    mouthOpen: (_wave(t, 8) + 1) / 2,
    armWave: _wave(t, 6),
    lift: _wave(t, 3) * 0.03,
    tilt: _wave(t, 2) * 0.06,
  );
}

/// Boş dayanan köməkçi (ana ekranın başlığında): sola-sağa baxır, tullanıb düşür, sevinir, əl yelləyir.
class IdleMascot implements MascotBehavior {
  const IdleMascot();

  static const _leftGlance = (0.03, 0.2);
  static const _rightGlance = (0.24, 0.41);
  static const _crouch = (0.44, 0.48);
  static const _jump = (0.48, 0.6);
  static const _landing = (0.6, 0.65);
  static const _joy = (0.6, 0.76);
  static const _hello = (0.8, 0.94);

  @override
  Duration get cycle => const Duration(seconds: 9);

  @override
  MascotPose poseAt(double t) {
    final lookX =
        _hold(t, _rightGlance.$1, _rightGlance.$2) -
        _hold(t, _leftGlance.$1, _leftGlance.$2);
    final air = _bump(t, _jump.$1, _jump.$2);
    final ground =
        _bump(t, _crouch.$1, _crouch.$2) + _bump(t, _landing.$1, _landing.$2);
    final hello = t > _hello.$1 && t < _hello.$2
        ? math.sin(2 * math.pi * 3 * (t - _hello.$1) / (_hello.$2 - _hello.$1))
        : 0.0;
    return MascotPose(
      lookX: lookX,
      blink: _blinkAt(t, 0.21) + _blinkAt(t, 0.77),
      mouthOpen: _bump(t, _joy.$1, _joy.$2) * 0.8,
      armWave: hello,
      lift: air * 0.2,
      tilt: lookX * 0.1,
      squash: ground * 0.14 - air * 0.06,
    );
  }
}
