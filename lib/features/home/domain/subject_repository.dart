import 'subject.dart';

abstract interface class SubjectRepository {
  Future<List<Subject>> getSubjects();
}
