/// Personajın bir andakı vəziyyəti. Davranış bunu hesablayır, boyayan isə yalnız bunu oxuyur.
class MascotPose {
  const MascotPose({
    this.lookX = 0,
    this.blink = 0,
    this.mouthOpen = 0,
    this.armWave = 0,
    this.lift = 0,
    this.tilt = 0,
    this.squash = 0,
  });

  /// -1 sola, 1 sağa baxır.
  final double lookX;

  /// 0 göz açıq, 1 bağlı.
  final double blink;

  /// 0 sakit təbəssüm, 1 ağız tam açıq.
  final double mouthOpen;

  /// -1..1, sağ əlin hərəkəti.
  final double armWave;

  /// Yerdən hündürlük, ölçüyə nisbətlə.
  final double lift;

  /// Radianla əyilmə.
  final double tilt;

  /// Müsbət yastılaşır (yerə enəndə), mənfi uzanır (havada).
  final double squash;
}
