import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/data/course_repository.dart';

void main() {
  const repo = MockCourseRepository(delay: Duration.zero);

  test('finds a course by code', () async {
    final course = await repo.fetchCourse('CS 310');
    expect(course.title, 'Mobile Application Development');
  });

  test('throws for an unknown code', () {
    expect(repo.fetchCourse('XX 999'), throwsA(isA<CourseNotFoundException>()));
  });

  test('returns only that course\'s reviews', () async {
    final reviews = await repo.fetchReviews('CS 310');
    expect(reviews, isNotEmpty);
    expect(reviews.every((r) => r.courseCode == 'CS 310'), isTrue);
    expect(await repo.fetchReviews('CS 201'), isEmpty);
  });
}
