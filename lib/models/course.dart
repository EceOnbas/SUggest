import 'review_topic.dart';

/// A course in the catalog, with everything the course page shows.
class Course {
  const Course({
    required this.code,
    required this.title,
    required this.suCredits,
    required this.ects,
    this.format = '',
    this.faculty = '',
    this.about = '',
    this.syllabusTerm,
    this.prerequisites = const [],
    this.corequisites = const [],
    this.unlocks = const [],
    this.ratings,
    this.majorShares = const [],
    this.sections = const [],
    this.instructorRatings = const [],
  });

  /// For example "CS 310". Also the seed of the course's sakura branch.
  final String code;
  final String title;
  final int suCredits;
  final int ects;

  /// For example "lecture and lab".
  final String format;
  final String faculty;
  final String about;

  /// The term of the linked syllabus, for example "Fall 2026".
  final String? syllabusTerm;

  /// Course codes.
  final List<String> prerequisites;
  final List<String> corequisites;
  final List<String> unlocks;

  /// Null while the course has too few ratings to show.
  final CourseRatings? ratings;

  /// Who takes the course, as anonymous shares.
  final List<MajorShare> majorShares;

  /// This term's sections.
  final List<CourseSection> sections;
  final List<InstructorTermRating> instructorRatings;

  /// "CS 310 Mobile Application Development".
  String get fullName => '$code $title';

  /// "3 SU credits, 6 ECTS, lecture and lab".
  String get creditsLine => [
    '$suCredits SU credits',
    '$ects ECTS',
    if (format.isNotEmpty) format,
  ].join(', ');
}

/// The average of each rating, from 1 to 5, and how many students rated.
class CourseRatings {
  const CourseRatings({
    required this.difficulty,
    required this.instructor,
    required this.attendance,
    required this.workload,
    required this.count,
  });

  final double difficulty;
  final double instructor;
  final double attendance;
  final double workload;

  /// Number of students who rated.
  final int count;

  double valueOf(ReviewTopic topic) => switch (topic) {
    ReviewTopic.difficulty => difficulty,
    ReviewTopic.instructor => instructor,
    ReviewTopic.attendance => attendance,
    ReviewTopic.workload => workload,
  };
}

/// One slice of "Who takes it": a major and its share of students.
class MajorShare {
  const MajorShare(this.major, this.percent);

  final String major;
  final int percent;
}

/// A section offered this term, with its linked lab.
class CourseSection {
  const CourseSection({
    required this.id,
    required this.instructor,
    required this.lectureTimes,
    required this.crn,
    this.labId,
    this.labTimes,
  });

  /// For example "A".
  final String id;
  final String instructor;

  /// For example "Mon 10:40, Wed 10:40".
  final String lectureTimes;
  final String crn;

  /// For example "A1". Null when the course has no lab.
  final String? labId;
  final String? labTimes;
}

/// An instructor's rating in one term, shown on the Sections tab.
class InstructorTermRating {
  const InstructorTermRating({
    required this.instructor,
    required this.term,
    required this.rating,
    required this.count,
  });

  final String instructor;
  final String term;
  final double rating;
  final int count;
}
