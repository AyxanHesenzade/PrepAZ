import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../data/supabase_auth_repository.dart';
import '../domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(ref.watch(supabaseClientProvider)),
);

/// true = istifadəçi daxil olub.
final isSignedInProvider = StreamProvider<bool>(
  (ref) => ref.watch(authRepositoryProvider).watchSignedIn(),
);
