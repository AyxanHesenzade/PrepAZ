import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart';
import '../domain/legal_repository.dart';

class SupabaseLegalRepository implements LegalRepository {
  const SupabaseLegalRepository(this._db);

  final SupabaseClient _db;

  @override
  Future<void> recordAcceptance(int version) {
    return guard(() async {
      await _db.from('legal_acceptances').upsert({
        'user_id': _db.auth.currentUser!.id,
        'version': version,
      }, ignoreDuplicates: true);
    });
  }
}
