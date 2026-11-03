import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/features/quiz/domain/answer_checker.dart';
import 'package:prep_az/features/quiz/domain/question.dart';

const _types = {
  'qapali': QuestionType.qapali,
  'aciq_eded': QuestionType.aciqEded,
  'coxlu_secim': QuestionType.coxluSecim,
  'uygunlasdirma': QuestionType.uygunlasdirma,
};

Question _question(QuestionType type, String right) => Question(
  id: 'q',
  code: 'C',
  topicId: 1,
  type: type,
  body: '',
  imagePath: null,
  options: const {},
  correctAnswer: right,
  difficulty: 1,
  solution: null,
);

void main() {
  final cases =
      (jsonDecode(File('test/fixtures/check_answer_cases.json').readAsStringSync())['cases'] as List)
          .cast<Map<String, dynamic>>();

  // Eyni halları real PostgreSQL trigger-i də yoxlayır: tools/dim/test_check_answer_parity.py
  test('the shared fixture has every question type', () {
    expect(cases.map((c) => c['type']).toSet(), _types.keys.toSet());
    expect(cases.length, greaterThan(40));
  });

  for (final c in cases) {
    final type = c['type'] as String;
    test('$type right=${c['right']} given=${c['given']} -> ${c['correct']}', () {
      final q = _question(_types[type]!, c['right'] as String);

      expect(AnswerChecker.isCorrect(q, c['given'] as String?), c['correct']);
    });
  }

  test('a written (yazili) question is never marked correct by the phone', () {
    expect(AnswerChecker.isCorrect(_question(QuestionType.yazili, 'x'), 'x'), isFalse);
  });
}
