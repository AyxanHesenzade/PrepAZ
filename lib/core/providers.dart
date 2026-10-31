import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-ə yeganə giriş nöqtəsi. Testlərdə override olunur.
/// Başlıqdakı köməkçi daim hərəkət edir, bu isə `pumpAndSettle`-i bitirməz.
/// Ona görə defolt false-dur, `main.dart` tətbiqdə true edir.
final mascotMotionProvider = Provider<bool>((ref) => false);

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
