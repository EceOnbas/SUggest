import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/data/mock_data.dart';
import 'package:suggest/models/review_topic.dart';
import 'package:suggest/models/user_profile.dart';

void main() {
  test('rating words match the course page design', () {
    final r = MockData.cs310.ratings!;
    expect(ReviewTopic.difficulty.wordFor(r.difficulty), 'fairly hard');
    expect(ReviewTopic.instructor.wordFor(r.instructor), 'good');
    expect(ReviewTopic.attendance.wordFor(r.attendance), 'rarely taken');
    expect(ReviewTopic.workload.wordFor(r.workload), 'heavy');
  });

  test('rating words cover the whole 1–5 scale', () {
    expect(ReviewTopic.difficulty.wordFor(1), 'very easy');
    expect(ReviewTopic.difficulty.wordFor(5), 'hard');
    expect(ReviewTopic.workload.wordFor(0), 'very light');
  });

  test('course lines are built from its fields', () {
    expect(MockData.cs310.fullName, 'CS 310 Mobile Application Development');
    expect(MockData.cs310.creditsLine, '3 SU credits, 6 ECTS, lecture and lab');
  });

  test('every course code in the mock data is unique', () {
    final codes = MockData.courses.map((c) => c.code).toList();
    expect(codes.toSet().length, codes.length);
  });

  test('major shares of a course add up to 100', () {
    final total = MockData.cs310.majorShares.fold(
      0,
      (sum, s) => sum + s.percent,
    );
    expect(total, 100);
  });

  test('UserProfile.copyWith keeps fields it does not change', () {
    const profile = UserProfile(major: 'Economics', classYear: '3');
    final updated = profile.copyWith(minor: 'Physics');
    expect(updated.major, 'Economics');
    expect(updated.classYear, '3');
    expect(updated.minor, 'Physics');
  });
}
