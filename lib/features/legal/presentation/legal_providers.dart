import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/supabase_legal_repository.dart';
import '../domain/legal_repository.dart';

final legalRepositoryProvider = Provider<LegalRepository>(
  (ref) => SupabaseLegalRepository(ref.watch(supabaseClientProvider)),
);
