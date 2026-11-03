import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../domain/cheer_policy.dart';

/// [Cheer] üçün köməkçinin deyəcəyi söz. Ümumi sözlərə fənnə aid olanlar da qarışdırılır (kimya, biologiya).
/// [random] verilir ki, testdə nəticə sabit olsun.
String cheerText(Cheer cheer, {required String subjectSlug, required Random random}) {
  final pool = <String>[
    ...switch (cheer.kind) {
      CheerKind.three => AppStrings.cheerThree,
      CheerKind.five => AppStrings.cheerFive,
      CheerKind.big => cheer.streak >= 20 ? AppStrings.cheerLegend : AppStrings.cheerBig,
      CheerKind.comeback => AppStrings.cheerComeback,
    },
    ...switch ((subjectSlug, cheer.kind)) {
      ('kimya', CheerKind.comeback) => AppStrings.cheerKimyaComeback,
      ('kimya', _) => AppStrings.cheerKimya,
      ('biologiya', CheerKind.comeback) => const <String>[],
      ('biologiya', _) => AppStrings.cheerBiologiya,
      _ => const <String>[],
    },
  ];
  return pool[random.nextInt(pool.length)].replaceAll('{n}', '${cheer.streak}');
}
