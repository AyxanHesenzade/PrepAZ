/// Yalnız DEBUG rejimdə (F5, ▶, flutter run) istifadə olunan TEST mühiti.
/// Beləcə tətbiq hər dəfə `--dart-define-from-file` tələb etmir.
///
/// Bu iki dəyər açıqdır: Project URL və publishable (anon) key tətbiqə yazıla bilər, bazanı RLS qoruyur.
/// `service_role` açarı və baza parolu buraya heç vaxt yazılmır.
/// Release build bunları ALMIR: orada `env/prod.json` verilməlidir (bax AppConfig).
/// Dəyərlər `env/test.json` ilə eyni olmalıdır, test bunu yoxlayır.
abstract final class DebugDefaults {
  static const supabaseUrl = 'https://ehaqunuwkccwosaorvgy.supabase.co';
  static const supabaseKey = 'sb_publishable__y6-m0NS2qXkFn_LOCld-g_SBFkFzIV';
}
