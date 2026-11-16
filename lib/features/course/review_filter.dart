import '../../models/review.dart';
import '../../models/review_topic.dart';

/// Which reviews the Reviews tab shows. A null field means "any".
///
/// The topic comes from the chips above the list; the term and the
/// instructor come from the filter sheet.
class ReviewFilter {
  const ReviewFilter({this.topic, this.term, this.instructor});

  final ReviewTopic? topic;
  final String? term;
  final String? instructor;

  /// How many of the sheet's two filters are set, for "Filters (2)".
  int get sheetFilterCount =>
      (term == null ? 0 : 1) + (instructor == null ? 0 : 1);

  bool get isEmpty => topic == null && sheetFilterCount == 0;

  bool matches(Review review) =>
      (topic == null || review.topics.contains(topic)) &&
      (term == null || review.term == term) &&
      (instructor == null || review.instructor == instructor);

  /// The reviews that pass every filter, in the same order.
  List<Review> apply(List<Review> reviews) => reviews.where(matches).toList();

  // Each of these returns a copy with one field replaced; null clears it.
  ReviewFilter withTopic(ReviewTopic? topic) =>
      ReviewFilter(topic: topic, term: term, instructor: instructor);

  ReviewFilter withTerm(String? term) =>
      ReviewFilter(topic: topic, term: term, instructor: instructor);

  ReviewFilter withInstructor(String? instructor) =>
      ReviewFilter(topic: topic, term: term, instructor: instructor);
}
