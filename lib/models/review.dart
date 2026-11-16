import 'review_topic.dart';

/// A student's review of a course, as shown on the course page.
/// Reviews are anonymous, so there is no author.
class Review {
  const Review({
    required this.id,
    required this.courseCode,
    required this.term,
    required this.instructor,
    required this.text,
    this.topics = const [],
  });

  final String id;
  final String courseCode;
  final String term;
  final String instructor;
  final String text;

  /// What the review talks about; used by the topic chips.
  final List<ReviewTopic> topics;
}
