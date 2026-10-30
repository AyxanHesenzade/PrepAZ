import 'teacher.dart';

abstract interface class TeacherRepository {
  /// Göstərilən müəllimlər (aktiv və razılığı olan), admin panelindəki sıra ilə.
  Future<List<Teacher>> getTeachers();
}
