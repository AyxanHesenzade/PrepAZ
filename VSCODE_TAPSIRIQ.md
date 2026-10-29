# VS Code-dakı Claude Code üçün tapşırıq

Aşağıdakı mətni olduğu kimi Claude Code-a yapışdırın.

---

Bu layihədə ilk dəfə işləyirsən. Əvvəlcə `CLAUDE.md` faylını oxu: layihənin məqsədi, qərarlar və qaydalar oradadır.

`app/` qovluğundakı Flutter kodu internetsiz mühitdə yazılıb. Orada nə Flutter SDK var idi, nə də pub.dev. Ona görə kod heç vaxt **kompilyasiya olunmayıb və işə salınmayıb**. Bazaya gedən bütün sorğular isə real PostgreSQL-də, istifadəçi hüquqları ilə yoxlanılıb və işləyir.

Sənin tapşırığın bu kodu sənin kompüterində işlək hala gətirməkdir:

1. `flutter --version` əmrini işlət. Flutter 3.27 və ya daha yenisi lazımdır. Yoxdursa, mənə de və quraşdırmaqda kömək et.
2. `app/` qovluğunda platforma qovluqlarını yarat: `flutter create . --org az --platforms android,ios,web`. Bu əmr mövcud `lib/` və `pubspec.yaml` fayllarını dəyişməməlidir. Dəyişsə, onları git ilə geri qaytar.
3. `android/app/src/main/AndroidManifest.xml` faylına `<uses-permission android:name="android.permission.INTERNET"/>` əlavə et. Bu olmasa, release versiya internetə qoşula bilmir. Tətbiqin görünən adı hər yerdə **PrepAZ** olmalıdır: Android-də `android:label`, iOS-da `CFBundleDisplayName` və `CFBundleName`, web-də `<title>` və `manifest.json`. Paket identifikatoru `az.prepaz` olmalıdır.
4. `flutter pub get`, sonra `flutter analyze`, sonra `flutter test` işlət. Bütün xətaları və xəbərdarlıqları düzəlt. Paket versiyaları uyğun gəlmirsə, ən yaxın işlək versiyanı seç.
5. Tətbiqi işə sal: `flutter run --dart-define-from-file=env/test.json` (əvvəlcə Chrome-da, sonra Android emulyatorunda və ya telefonda).
6. Bu ssenarini başdan sona yoxla:
   - Qeydiyyat
   - Ana səhifədə 3 fənn görünür
   - Riyaziyyat üzrə "Bugünkü məşqə başla"
   - 3 sual gəlir və düsturlar düzgün göstərilir
   - Bir sualı səhv, birini düz cavabla, birində "Bilmirəm" bas
   - Nəticə ekranı açılır
   - Ana səhifədə seriya "1 gün" olur və zəif mövzular görünür
7. Bazaya (`db/schema.sql`) **toxunma**. Orada dəyişiklik lazım olduğunu düşünsən, əvvəl mənə de. Dəyişikliklər `db/migrations/` qovluğunda ayrıca fayl kimi yazılır.
8. Sonda commit et və mənə qısa hesabat ver: nə düzəldildi, nə işləyir, ekran görüntüləri.
