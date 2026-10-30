import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart';
import '../domain/subject.dart';
import '../domain/subject_repository.dart';

class SupabaseSubjectRepository implements SubjectRepository {
  const SupabaseSubjectRepository(this._db);

  final SupabaseClient _db;

  @override
  Future<List<Subject>> getSubjects() {
    return guard(() async {
      final rows = await _db
          .from('subjects')
          .select('id, slug, name')
          .order('sort_order');
      return rows.map(_toSubject).toList();
    });
  }

  static Subject _toSubject(Map<String, dynamic> row) => Subject(
    id: (row['id'] as num).toInt(),
    slug: row['slug'] as String,
    name: row['name'] as String,
  );
}
