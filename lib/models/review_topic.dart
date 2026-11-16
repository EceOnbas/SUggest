/// The four things students rate a course on. Also used as review tags
/// and as the topic chips on the Reviews tab.
enum ReviewTopic {
  difficulty('Difficulty'),
  instructor('Instructor'),
  attendance('Attendance'),
  workload('Workload');

  const ReviewTopic(this.label);

  /// Text shown on screen.
  final String label;

  /// A short word for an average rating, for example 3.6 difficulty is
  /// "fairly hard". Ratings are on the 1–5 scale.
  String wordFor(double average) {
    final words = switch (this) {
      ReviewTopic.difficulty => const [
        'very easy',
        'easy',
        'moderate',
        'fairly hard',
        'hard',
      ],
      ReviewTopic.instructor => const [
        'poor',
        'weak',
        'okay',
        'good',
        'excellent',
      ],
      ReviewTopic.attendance => const [
        'not taken',
        'rarely taken',
        'sometimes taken',
        'often taken',
        'always taken',
      ],
      ReviewTopic.workload => const [
        'very light',
        'light',
        'moderate',
        'fairly heavy',
        'heavy',
      ],
    };
    // Five equal steps between 1 and 5.
    final step = ((average - 1) / 0.8).floor().clamp(0, 4);
    return words[step];
  }
}
