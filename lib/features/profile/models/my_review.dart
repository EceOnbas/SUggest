import '../../../models/review_topic.dart';

/// How each [ReviewTopic] is shown when a student rates one course from
/// 1 to 5 on the Write Review screen.
extension RatingScale on ReviewTopic {
  /// The order the four ratings appear in on screen.
  static const order = [
    ReviewTopic.difficulty,
    ReviewTopic.workload,
    ReviewTopic.instructor,
    ReviewTopic.attendance,
  ];

  /// Title above the 1–5 picker, for example "Instructor Quality".
  String get ratingTitle => switch (this) {
    ReviewTopic.difficulty => 'Difficulty',
    ReviewTopic.workload => 'Workload',
    ReviewTopic.instructor => 'Instructor Quality',
    ReviewTopic.attendance => 'Attendance Requirement',
  };

  /// The word for [score], for example 4 difficulty is "Fairly hard".
  /// It is the course page's word ([ReviewTopic.wordFor]) with a capital
  /// letter, so both pages describe a score the same way.
  String wordForScore(int score) {
    final word = wordFor(score.clamp(1, 5).toDouble());
    return word[0].toUpperCase() + word.substring(1);
  }
}

/// One review written by the signed-in student, as listed under
/// "My Reviews". Only its owner sees the dates and the edit buttons.
class MyReview {
  const MyReview({
    required this.id,
    required this.courseCode,
    required this.courseTitle,
    required this.term,
    required this.instructor,
    required this.ratings,
    required this.posted,
    this.edited,
    this.tags = const [],
    this.feedback = '',
  });

  final String id;

  /// For example "CS 310".
  final String courseCode;
  final String courseTitle;
  final String term;
  final String instructor;

  /// A score from 1 to 5 for every [ReviewTopic].
  final Map<ReviewTopic, int> ratings;

  /// What the review talks about, the same topics the course page
  /// filters by.
  final List<ReviewTopic> tags;

  /// The written feedback; it may be empty.
  final String feedback;
  final DateTime posted;

  /// Null until the review is edited.
  final DateTime? edited;

  /// "CS 310 · Mobile Application Development".
  String get courseLabel => '$courseCode · $courseTitle';

  /// The newest of posted and edited; the list is sorted by it.
  DateTime get lastChanged => edited ?? posted;

  /// What the My Reviews search looks in: course, term and instructor.
  String get searchText => '$courseLabel $term $instructor';

  /// A copy after editing. The course cannot change.
  MyReview edit({
    required String term,
    required String instructor,
    required Map<ReviewTopic, int> ratings,
    required List<ReviewTopic> tags,
    required String feedback,
    required DateTime edited,
  }) => MyReview(
    id: id,
    courseCode: courseCode,
    courseTitle: courseTitle,
    term: term,
    instructor: instructor,
    ratings: ratings,
    tags: tags,
    feedback: feedback,
    posted: posted,
    edited: edited,
  );
}

/// "Oct 12, 2024".
String formatReviewDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final day = date.day.toString().padLeft(2, '0');
  return '${months[date.month - 1]} $day, ${date.year}';
}
