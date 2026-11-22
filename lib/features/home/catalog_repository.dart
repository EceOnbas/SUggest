import '../../data/mock_data.dart';
import '../../models/course.dart';
import '../../models/review.dart';
import '../../models/review_topic.dart';

/// Where Home and Search get the course list and latest reviews.
/// Step 3 adds a Firebase implementation; the screens only know this
/// interface.
abstract interface class CatalogRepository {
  Future<List<Course>> fetchCourses();

  /// Newest first.
  Future<List<Review>> fetchLatestReviews();
}

/// Placeholder catalog. Reuses the shared [MockData] courses and adds ratings
/// to the short entries, so every shelf cover can draw its branch.
class MockCatalogRepository implements CatalogRepository {
  const MockCatalogRepository({
    this.delay = const Duration(milliseconds: 600),
  });

  final Duration delay;

  static const _ratings = <String, CourseRatings>{
    'CS 201': CourseRatings(difficulty: 2.4, instructor: 3.8, attendance: 3.5, workload: 2.8, count: 120),
    'CS 204': CourseRatings(difficulty: 3.2, instructor: 3.9, attendance: 3.0, workload: 3.6, count: 95),
    'CS 300': CourseRatings(difficulty: 3.9, instructor: 3.5, attendance: 3.2, workload: 3.9, count: 88),
    'CS 408': CourseRatings(difficulty: 3.3, instructor: 3.6, attendance: 2.8, workload: 3.2, count: 41),
    'CS 412': CourseRatings(difficulty: 3.8, instructor: 4.0, attendance: 2.5, workload: 3.7, count: 36),
    'MATH 102': CourseRatings(difficulty: 3.5, instructor: 3.2, attendance: 3.8, workload: 3.3, count: 150),
    'MATH 201': CourseRatings(difficulty: 3.0, instructor: 3.4, attendance: 3.6, workload: 2.9, count: 110),
    'HUM 201': CourseRatings(difficulty: 2.0, instructor: 4.1, attendance: 3.9, workload: 2.6, count: 64),
  };

  static const _extraReviews = <Review>[
    Review(
      id: 'h1',
      courseCode: 'CS 300',
      term: 'Fall 2026',
      instructor: 'Instructor C',
      topics: [ReviewTopic.workload],
      text:
          'Homework is weekly and each one takes a full evening. '
          'Start before the weekend.',
    ),
    Review(
      id: 'h2',
      courseCode: 'MATH 201',
      term: 'Fall 2026',
      instructor: 'Instructor D',
      topics: [ReviewTopic.difficulty, ReviewTopic.instructor],
      text:
          'Proofs are the hard part. The instructor repeats every key '
          'idea twice and posts worked examples.',
    ),
  ];

  @override
  Future<List<Course>> fetchCourses() async {
    await Future<void>.delayed(delay);
    return [
      for (final c in MockData.courses)
        if (c.ratings != null || !_ratings.containsKey(c.code))
          c
        else
          Course(
            code: c.code,
            title: c.title,
            suCredits: c.suCredits,
            ects: c.ects,
            format: c.format,
            faculty: c.faculty,
            about: c.about,
            ratings: _ratings[c.code],
          ),
    ];
  }

  @override
  Future<List<Review>> fetchLatestReviews() async {
    await Future<void>.delayed(delay);
    return [..._extraReviews, ...MockData.reviews];
  }
}
