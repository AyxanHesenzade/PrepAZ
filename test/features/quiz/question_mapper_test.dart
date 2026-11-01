import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/features/quiz/data/supabase_quiz_repository.dart';
import 'package:prep_az/features/quiz/domain/question.dart';

Map<String, dynamic> row({String type = 'qapali', Object? options, String? imagePath, String? solutionImage}) => {
      'id': 'uuid-1',
      'code': 'KIM-0001',
      'topic_id': 7,
      'type': type,
      'body': r'$\mathrm{H_{2}O}$',
      'image_path': imagePath,
      'options': options,
      'correct_answer': 'C',
      'difficulty': 3,
      'solution': 'izah',
      'solution_image_path': solutionImage,
    };

void main() {
  test('closed question: options are ordered by letter regardless of JSON order', () {
    final q = questionFromRow(row(options: {'C': 'c', 'A': 'a', 'E': 'e', 'B': 'b', 'D': 'd'}, imagePath: 'KIM-0001.png'));
    expect(q.type, QuestionType.qapali);
    expect(q.options.keys.toList(), ['A', 'B', 'C', 'D', 'E']);
    expect(q.hasImage, isTrue);
    expect(q.imagePath, 'KIM-0001.png');
    expect(q.topicId, 7);
  });

  test('numeric open question has no options and no image', () {
    final q = questionFromRow(row(type: 'aciq_eded'));
    expect(q.type, QuestionType.aciqEded);
    expect(q.options, isEmpty);
    expect(q.isClosed, isFalse);
    expect(q.hasImage, isFalse);
  });

  test('empty image path counts as no image', () {
    expect(questionFromRow(row(options: {'A': 'a'}, imagePath: '')).hasImage, isFalse);
  });

  test('numbers coming as num are converted', () {
    final q = questionFromRow({...row(options: {'A': 1}), 'difficulty': 4.0, 'topic_id': 2.0});
    expect(q.difficulty, 4);
    expect(q.options['A'], '1');
  });

  test('explanation image path is read; a missing column (before migration 003) means no image', () {
    expect(questionFromRow(row(options: {'A': 'a'}, solutionImage: 'KIM-0001_izah.png')).hasSolutionImage, isTrue);
    final withoutColumn = row(options: {'A': 'a'})..remove('solution_image_path');
    final q = questionFromRow(withoutColumn);
    expect(q.hasSolutionImage, isFalse);
    expect(q.hasSolutionText, isTrue);
  });

  test('new open types are parsed and answers are shown readably', () {
    expect(questionFromRow(row(type: 'coxlu_secim')).type, QuestionType.coxluSecim);
    final matching = questionFromRow(row(
      type: 'uygunlasdirma',
      options: {'2': 'ABCDE', '1': 'ABCDE', '3': 'ABCDE'},
    ));
    expect(matching.type, QuestionType.uygunlasdirma);
    expect(matching.formatAnswer('E;A;BC'), '1-e, 2-a, 3-bc');
    expect(matching.formatAnswer('E;;'), '1-e, 2-?, 3-?');
    expect(matching.formatAnswer(null), '-');
    expect(questionFromRow(row(type: 'coxlu_secim')).formatAnswer('135'), '1,3,5');
    expect(questionFromRow(row(type: 'coxlu_secim')).formatAnswer('1,3,5'), '1,3,5');
    expect(questionFromRow(row(type: 'aciq_eded')).formatAnswer('12,5'), '12,5');
  });
}
