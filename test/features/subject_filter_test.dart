import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/features/home/domain/subject.dart';
import 'package:prep_az/features/home/domain/subject_filter.dart';

void main() {
  const all = [
    Subject(id: 1, slug: 'kimya', name: 'Kimya'),
    Subject(id: 2, slug: 'biologiya', name: 'Biologiya'),
    Subject(id: 3, slug: 'riyaziyyat', name: 'Riyaziyyat'),
  ];

  test('hidden subjects are left out, order stays', () {
    expect(visibleSubjects(all, {2}).map((s) => s.id), [1, 3]);
  });

  test('a new subject (not in the hidden set) shows up by itself', () {
    expect(visibleSubjects(all, {1}).map((s) => s.id), [2, 3]);
  });

  test('if the filter hides everything, everything is shown', () {
    expect(visibleSubjects(all, {1, 2, 3}), all);
  });
}
