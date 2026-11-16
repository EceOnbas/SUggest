import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/data/mock_data.dart';
import 'package:suggest/features/course/review_filter.dart';
import 'package:suggest/models/review_topic.dart';

void main() {
  final reviews = MockData.reviewsFor('CS 310');

  test('an empty filter keeps every review', () {
    const filter = ReviewFilter();
    expect(filter.isEmpty, isTrue);
    expect(filter.apply(reviews), reviews);
  });

  test('topic, term and instructor all have to match', () {
    const filter = ReviewFilter(
      topic: ReviewTopic.difficulty,
      term: 'Fall 2025',
      instructor: 'Instructor B',
    );
    expect(filter.apply(reviews).map((r) => r.id), ['r3']);
    expect(filter.sheetFilterCount, 2);
  });

  test('a null clears one field and keeps the others', () {
    const filter = ReviewFilter(
      topic: ReviewTopic.workload,
      term: 'Spring 2025',
    );
    final cleared = filter.withTerm(null);
    expect(cleared.term, isNull);
    expect(cleared.topic, ReviewTopic.workload);
    expect(cleared.apply(reviews).map((r) => r.id), ['r1', 'r4']);
  });
}
