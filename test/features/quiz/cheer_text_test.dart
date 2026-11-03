import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/core/constants/app_language.dart';
import 'package:prep_az/core/constants/app_strings.dart';
import 'package:prep_az/features/quiz/domain/cheer_policy.dart';
import 'package:prep_az/features/quiz/presentation/cheer_text.dart';

/// Hər dildə hər siyahı götürülür: (ad, siyahı).
Map<String, List<String> Function()> _lists() => {
  'three': () => AppStrings.cheerThree,
  'five': () => AppStrings.cheerFive,
  'big': () => AppStrings.cheerBig,
  'legend': () => AppStrings.cheerLegend,
  'comeback': () => AppStrings.cheerComeback,
  'kimya': () => AppStrings.cheerKimya,
  'kimyaComeback': () => AppStrings.cheerKimyaComeback,
  'biologiya': () => AppStrings.cheerBiologiya,
  'biologiyaComeback': () => AppStrings.cheerBiologiyaComeback,
};

void main() {
  tearDown(() => AppStrings.language = AppLanguage.az);

  test('every list has the same number of lines in all three languages', () {
    for (final entry in _lists().entries) {
      final counts = <AppLanguage, int>{};
      for (final language in AppLanguage.values) {
        AppStrings.language = language;
        counts[language] = entry.value().length;
      }
      expect(counts.values.toSet(), hasLength(1), reason: '${entry.key}: $counts');
    }
  });

  test('there are plenty of lines for every kind (the point is variety)', () {
    AppStrings.language = AppLanguage.az;
    expect(AppStrings.cheerThree.length, greaterThanOrEqualTo(6));
    expect(AppStrings.cheerFive.length, greaterThanOrEqualTo(6));
    expect(AppStrings.cheerBig.length, greaterThanOrEqualTo(6));
    expect(AppStrings.cheerComeback.length, greaterThanOrEqualTo(6));
    expect(AppStrings.cheerKimya.length, greaterThanOrEqualTo(6));
    expect(AppStrings.cheerBiologiya.length, greaterThanOrEqualTo(5));
  });

  test('no empty line and no line repeated inside a list, in any language', () {
    for (final language in AppLanguage.values) {
      AppStrings.language = language;
      for (final entry in _lists().entries) {
        final lines = entry.value();
        expect(lines.every((l) => l.trim().isNotEmpty), isTrue, reason: '${entry.key} $language');
        expect(lines.toSet().length, lines.length, reason: 'duplicates in ${entry.key} $language');
      }
    }
  });

  test('every streak line that mentions the number uses the {n} placeholder, never a stray digit', () {
    for (final language in AppLanguage.values) {
      AppStrings.language = language;
      for (final entry in _lists().entries) {
        for (final line in entry.value()) {
          expect(RegExp(r'[0-9]').hasMatch(line), isFalse, reason: 'hard-coded number in: $line');
        }
      }
    }
  });

  test('the number is filled in and no placeholder is left in the final text', () {
    final random = Random(7);
    for (final language in AppLanguage.values) {
      AppStrings.language = language;
      for (final cheer in const [
        Cheer(CheerKind.three, 3),
        Cheer(CheerKind.five, 5),
        Cheer(CheerKind.big, 10),
        Cheer(CheerKind.big, 20),
        Cheer(CheerKind.comeback, 8),
      ]) {
        for (final slug in ['kimya', 'biologiya', 'math']) {
          for (var i = 0; i < 40; i++) {
            final text = cheerText(cheer, subjectSlug: slug, random: random);
            expect(text.contains('{'), isFalse, reason: text);
            expect(text.trim(), isNotEmpty);
          }
        }
      }
    }
  });

  test('the same situation does not always give the same line', () {
    AppStrings.language = AppLanguage.az;
    final random = Random(3);
    final seen = {
      for (var i = 0; i < 60; i++)
        cheerText(const Cheer(CheerKind.three, 3), subjectSlug: 'math', random: random),
    };

    expect(seen.length, greaterThanOrEqualTo(5));
  });

  test('a 20-streak uses the legend lines, a 10-streak the big ones', () {
    AppStrings.language = AppLanguage.az;
    final random = Random(1);
    final legend = {for (final l in AppStrings.cheerLegend) l.replaceAll('{n}', '20')};
    final big = {for (final l in AppStrings.cheerBig) l.replaceAll('{n}', '10')};

    for (var i = 0; i < 30; i++) {
      expect(legend, contains(cheerText(const Cheer(CheerKind.big, 20), subjectSlug: 'math', random: random)));
      expect(big, contains(cheerText(const Cheer(CheerKind.big, 10), subjectSlug: 'math', random: random)));
    }
  });

  test('biology gets its own words after a mistake', () {
    AppStrings.language = AppLanguage.az;
    final own = AppStrings.cheerBiologiyaComeback.toSet();
    final random = Random(5);
    final said = {
      for (var i = 0; i < 200; i++)
        cheerText(const Cheer(CheerKind.comeback, 5), subjectSlug: 'biologiya', random: random),
    };

    expect(said.intersection(own), isNotEmpty);
  });
}
