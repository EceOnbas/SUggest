/// A student's post on a program page, for example a question about
/// which courses to take first.
class ProgramPost {
  const ProgramPost({
    required this.id,
    required this.programName,
    required this.topic,
    required this.text,
    required this.term,
    this.authorHandle,
  });

  final String id;

  /// The program the post belongs to, for example "Mathematics".
  final String programName;

  /// One of [ProgramPost.topics].
  final String topic;
  final String text;

  /// When it was posted, for example "Fall 2026".
  final String term;

  /// The author's public handle without the "@". Null shows "Anonymous".
  final String? authorHandle;

  /// The topics a post can have.
  static const topics = ['Question', 'Advice', 'Course order', 'Experience'];
}
