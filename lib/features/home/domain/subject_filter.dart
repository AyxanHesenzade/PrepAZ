import 'subject.dart';

/// Ana ekranın fənn filtri: [hidden]-də olmayan fənlər, sıra dəyişmir.
/// Filtr bütün fənləri gizlədirsə (məs. köhnə id-lər), hamısı göstərilir: ana ekran boş qalmamalıdır.
List<Subject> visibleSubjects(List<Subject> all, Set<int> hidden) {
  final visible = [for (final s in all) if (!hidden.contains(s.id)) s];
  return visible.isEmpty ? all : visible;
}
