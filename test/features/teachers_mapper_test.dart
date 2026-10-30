import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/features/teachers/data/supabase_teacher_repository.dart';
import 'package:prep_az/features/teachers/domain/teacher.dart';

void main() {
  String url(String path) => 'https://x.supabase.co/storage/v1/object/public/teacher-photos/$path';

  test('maps a database row, the photo name becomes a public link', () {
    final t = teacherFromRow({
      'full_name': 'Aydın Əliyev',
      'subject_label': 'Kimya müəllimi',
      'lesson_mode': 'in_person',
      'phone': '+994501112233',
      'photo_path': 'a.png',
      'address': 'Bakı',
      'about': null,
      'offer': 'Qrup',
    }, photoUrl: url);
    expect(t.name, 'Aydın Əliyev');
    expect(t.lessonMode, LessonMode.inPerson);
    expect(t.photo, url('a.png'));
    expect(t.isNetworkPhoto, isTrue);
    expect(t.hasAbout, isFalse);
    expect(t.offer, 'Qrup');
  });

  test('no photo / empty photo name = no photo; online and both modes', () {
    Teacher make(String mode, String? photo) => teacherFromRow({
          'full_name': 'A',
          'subject_label': 'B',
          'lesson_mode': mode,
          'phone': '+994501112233',
          'photo_path': photo,
        }, photoUrl: url);
    expect(make('online', null).hasPhoto, isFalse);
    expect(make('online', ' ').hasPhoto, isFalse);
    expect(make('online', null).lessonMode, LessonMode.online);
    expect(make('both', null).lessonMode, LessonMode.both);
  });
}
