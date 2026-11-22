import 'review_topic.dart';

/// A student's review of a course, as shown on the course page.
/// Reviews show no name: only the author's public handle, if any.
class Review {
  const Review({
    required this.id,
    required this.courseCode,
    required this.term,
    required this.instructor,
    required this.text,
    this.topics = const [],
    this.authorHandle,
  });

  final String id;
  final String courseCode;
  final String term;
  final String instructor;
  final String text;

  /// What the review talks about; used by the topic chips.
  final List<ReviewTopic> topics;

  /// The author's public handle without the "@", for example
  /// "bosphorus_coder". Null for reviews that show no handle.
  final String? authorHandle;
}
