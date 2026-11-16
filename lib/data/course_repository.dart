import '../models/course.dart';
import '../models/review.dart';
import 'mock_data.dart';

/// Where screens get courses and reviews from.
///
/// Screens only talk to this interface, so in Step 3 a Firebase version
/// can replace [MockCourseRepository] without changing any screen.
abstract interface class CourseRepository {
  Future<Course> fetchCourse(String code);
  Future<List<Review>> fetchReviews(String courseCode);
}

/// Thrown when a course code is not in the catalog.
class CourseNotFoundException implements Exception {
  const CourseNotFoundException(this.code);
  final String code;

  @override
  String toString() => 'Course $code was not found.';
}

/// Serves [MockData] after a short delay, like a real network call, so
/// the loading states can be seen.
class MockCourseRepository implements CourseRepository {
  const MockCourseRepository({this.delay = const Duration(milliseconds: 600)});

  final Duration delay;

  @override
  Future<Course> fetchCourse(String code) async {
    await Future<void>.delayed(delay);
    final course = MockData.courseByCode(code);
    if (course == null) throw CourseNotFoundException(code);
    return course;
  }

  @override
  Future<List<Review>> fetchReviews(String courseCode) async {
    await Future<void>.delayed(delay);
    return MockData.reviewsFor(courseCode);
  }
}
