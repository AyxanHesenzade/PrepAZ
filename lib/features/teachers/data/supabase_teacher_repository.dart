import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/app_exception.dart';
import '../domain/teacher.dart';
import '../domain/teacher_repository.dart';

class SupabaseTeacherRepository implements TeacherRepository {
  const SupabaseTeacherRepository(this._db);

  final SupabaseClient _db;

  static const photoBucket = 'teacher-photos';

  @override
  Future<List<Teacher>> getTeachers() {
    return guard(() async {
      // RLS yalnız aktiv və razılığı olan müəllimləri qaytarır
      final rows = await _db.from('teachers').select().order('sort_order').order('full_name');
      return rows.map((row) => teacherFromRow(row, photoUrl: (path) => _db.storage.from(photoBucket).getPublicUrl(path))).toList();
    });
  }
}

Teacher teacherFromRow(Map<String, dynamic> row, {required String Function(String path) photoUrl}) {
  final photoPath = row['photo_path'] as String?;
  return Teacher(
    name: row['full_name'] as String,
    subject: row['subject_label'] as String,
    lessonMode: switch (row['lesson_mode']) {
      'online' => LessonMode.online,
      'in_person' => LessonMode.inPerson,
      _ => LessonMode.both,
    },
    phone: row['phone'] as String,
    photo: photoPath == null || photoPath.trim().isEmpty ? null : photoUrl(photoPath),
    address: row['address'] as String?,
    about: row['about'] as String?,
    offer: row['offer'] as String?,
  );
}
