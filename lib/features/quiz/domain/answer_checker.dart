import 'question.dart';

/// Cavabın düzgünlüyünü telefonda yoxlayır. YALNIZ oflayn rejim üçündür: internet yoxdur, nəticə dərhal göstərilməlidir.
/// Əsl qərarı yenə server verir: cavab sonra göndəriləndə `check_answer` trigger-i onu yenidən hesablayır.
///
/// Qayda `db/migrations/014_open_question_types.sql`-dəki `check_answer` ilə EYNİ olmalıdır.
/// Bunu `test/fixtures/check_answer_cases.json` təmin edir: həm Dart testi, həm real PostgreSQL testi
/// (`tools/dim/test_check_answer_parity.py`) eyni halları yoxlayır. Qayda dəyişəndə hər üçü birlikdə dəyişir.
abstract final class AnswerChecker {
  static bool isCorrect(Question question, String? given) {
    final g = _normalize(given ?? '');
    final right = _normalize(question.correctAnswer);
    switch (question.type) {
      case QuestionType.yazili:
        return false; // sonradan insan yoxlayır
      case QuestionType.aciqEded:
        final key = _numberKey(g.replaceAll(',', '.'));
        return key != null && key == _numberKey(right.replaceAll(',', '.'));
      case QuestionType.coxluSecim:
        final a = _sortedChars(g.replaceAll(RegExp(r'[^0-9]'), ''));
        final b = _sortedChars(right.replaceAll(RegExp(r'[^0-9]'), ''));
        return a.isNotEmpty && a == b;
      case QuestionType.uygunlasdirma:
        return RegExp(r'[A-Z]').hasMatch(g) &&
            _matching(g) == _matching(right);
      case QuestionType.qapali:
        return g.isNotEmpty && g == right;
    }
  }

  /// Boşluqlar atılır, hərflər böyüdülür.
  static String _normalize(String s) =>
      s.replaceAll(RegExp(r'\s'), '').toUpperCase();

  /// Təkrarsız simvollar, sıralanmış.
  static String _sortedChars(String s) =>
      (s.split('').where((c) => c.isNotEmpty).toSet().toList()..sort()).join();

  /// `C;BE` → hər sətirin hərfləri sıralanıb təkrarsız, sətirlərin sırası saxlanır.
  static String _matching(String s) => s
      .split(';')
      .map((row) => _sortedChars(row.replaceAll(RegExp(r'[^A-Z]'), '')))
      .join(';');

  /// Ədədin kanonik forması: `012.50` və `12.5` eyni, `-0` və `0` eyni. Ədəd deyilsə `null`.
  static String? _numberKey(String s) {
    final m = RegExp(r'^(-?)([0-9]+)(?:\.([0-9]+))?$').firstMatch(s);
    if (m == null) return null;
    var whole = m.group(2)!.replaceFirst(RegExp(r'^0+(?=[0-9])'), '');
    final fraction = (m.group(3) ?? '').replaceFirst(RegExp(r'0+$'), '');
    final negative = m.group(1) == '-' && !(whole == '0' && fraction.isEmpty);
    whole = whole.isEmpty ? '0' : whole;
    return '${negative ? '-' : ''}$whole${fraction.isEmpty ? '' : '.$fraction'}';
  }
}
