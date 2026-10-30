/// Dərsin keçirilmə formatı.
enum LessonMode { inPerson, online, both }

/// Suallara kömək etmiş, tövsiyə olunan müəllim.
class Teacher {
  const Teacher({
    required this.name,
    required this.subject,
    required this.lessonMode,
    required this.phone,
    this.photo,
    this.address,
    this.about,
    this.offer,
  });

  /// Ad Soyad.
  final String name;

  /// Məs. "Kimya müəllimi".
  final String subject;

  /// Əyani, online və ya hər ikisi.
  final LessonMode lessonMode;

  /// Beynəlxalq formatda: +994501234567
  final String phone;

  /// Foto (istəyə görə): `assets/teachers/ad.jpg` kimi tətbiq faylı və ya `https://...` linki.
  final String? photo;

  /// Dərs keçdiyi yer (istəyə görə), məs. "Bakı, Nərimanov rayonu". Əyani dərs üçün yazılır.
  final String? address;

  /// Müəllim haqqında qısa məlumat (istəyə görə).
  final String? about;

  /// Hazırlıq təklifi: qrup, vaxt, qiymət və s. (istəyə görə).
  final String? offer;

  bool get hasPhoto => photo != null && photo!.trim().isNotEmpty;
  bool get hasAddress => address != null && address!.trim().isNotEmpty;
  bool get hasAbout => about != null && about!.trim().isNotEmpty;
  bool get hasOffer => offer != null && offer!.trim().isNotEmpty;
  bool get isNetworkPhoto => hasPhoto && photo!.trim().startsWith('http');

  /// WhatsApp linki üçün yalnız rəqəmlər.
  String get phoneDigits => phone.replaceAll(RegExp(r'\D'), '');
}
