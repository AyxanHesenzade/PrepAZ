import '../../../core/error/app_exception.dart';
import '../../home/domain/subject.dart';
import '../../home/domain/subject_repository.dart';
import '../domain/offline_store.dart';

/// Fənlər siyahısı: internet işləyirsə serverdən (və telefona yazılır), işləmirsə telefondakı son surətdən.
/// Beləcə ana ekran internetsiz də fənn kartlarını göstərir və yüklənmiş mövzulara çatmaq olur.
///
/// [onReachability] hər cavabdan sonra çağırılır: `true` = server cavab verdi, `false` = telefondakı surət göstərildi
/// (ana ekranda "Hazırda oflayn rejimdəsən" üçün). Surət həm də yüklənmiş mövzuların fənn adını verir.
class OfflineSubjectRepository implements SubjectRepository {
  const OfflineSubjectRepository({
    required this.remote,
    required this.store,
    required this.onReachability,
  });

  final SubjectRepository remote;
  final OfflineStore store;
  final void Function(bool online) onReachability;

  @override
  Future<List<Subject>> getSubjects() async {
    try {
      final subjects = await remote.getSubjects();
      onReachability(true);
      try {
        await store.cacheSubjects(subjects);
      } on Object {
        // surət yazılmasa da siyahı düzgündür: növbəti dəfə yenə cəhd olunacaq
      }
      return subjects;
    } on AppException {
      final cached = await store.cachedSubjects();
      if (cached.isEmpty) rethrow; // heç vaxt yüklənməyib: xəta göstərilir
      onReachability(false);
      return cached;
    }
  }
}
