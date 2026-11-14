import 'package:flutter_test/flutter_test.dart';
import 'package:prep_az/features/stats/data/supabase_stats_repository.dart';
import 'package:prep_az/features/stats/domain/subject_stats.dart';

List<DayStat> days(List<int> answered) => [
  for (final (i, n) in answered.indexed)
    DayStat(day: DateTime(2026, 11, 1 + i), answered: n, correct: n ~/ 2),
];

SubjectStats stats(List<int> answered) => SubjectStats(
  answered: 10,
  correct: 7,
  questionsTried: 8,
  questionsSolved: 5,
  questionsTotal: 20,
  topicsTotal: 3,
  bestStreak: 4,
  days: days(answered),
);

void main() {
  test('splits 14 days into this week and last week', () {
    final s = stats([1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2]);
    expect(s.thisWeek, hasLength(7));
    expect(s.thisWeek.first.day, DateTime(2026, 11, 8));
    expect(s.thisWeekAnswered, 14);
    expect(s.lastWeekAnswered, 7);
    expect(s.weekDelta, 7);
  });

  test('a short history has no last week', () {
    final s = stats([3, 0, 4]);
    expect(s.thisWeek, hasLength(3));
    expect(s.lastWeek, isEmpty);
    expect(s.weekDelta, 7);
  });

  test('percentages', () {
    final s = stats(const []);
    expect(s.accuracyPct, 70);
    expect(s.coverage, 0.25);
    expect(SubjectStats.empty.accuracyPct, 0);
    expect(SubjectStats.empty.coverage, 0);
    expect(SubjectStats.empty.isEmpty, isTrue);
  });

  test('parses the get_my_stats json', () {
    final s = statsFromJson({
      'answered': 9,
      'correct': 6,
      'questions_tried': 5,
      'questions_solved': 3,
      'questions_total': 6,
      'topics_total': 2,
      'best_streak': 3,
      'days': [
        {'day': '2026-11-13', 'answered': 1, 'correct': 0},
        {'day': '2026-11-14', 'answered': 4, 'correct': 3},
      ],
    });
    expect(
      (s.answered, s.correct, s.questionsSolved, s.bestStreak),
      (9, 6, 3, 3),
    );
    expect(s.days.last.day, DateTime(2026, 11, 14));
    expect(s.days.last.correct, 3);
  });

  test('missing fields become zero', () {
    final s = statsFromJson({});
    expect(s.isEmpty, isTrue);
    expect(s.days, isEmpty);
  });
}
