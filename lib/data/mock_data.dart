import '../models/course.dart';
import '../models/review.dart';
import '../models/review_topic.dart';
import '../models/user_profile.dart';

/// Placeholder data for Step 2. Firebase replaces it in Step 3.
///
/// Instructor names are placeholders ("Instructor A") on purpose: the app
/// shows no real people until it reads the university schedule.
abstract final class MockData {
  static const currentTerm = 'Fall 2026';

  /// Terms students pick from, newest first.
  static const terms = [
    'Fall 2026',
    'Spring 2026',
    'Fall 2025',
    'Spring 2025',
    'Fall 2024',
    'Spring 2024',
    'Fall 2023',
  ];

  static const classYears = ['1', '2', '3', '4', '5+'];

  /// Terms a student can be in right now.
  static const currentTerms = ['Fall 2026', 'Spring 2027'];

  /// Terms a current student may have started in, newest first.
  static const startTerms = [
    'Fall 2026',
    'Spring 2026',
    'Fall 2025',
    'Spring 2025',
    'Fall 2024',
    'Spring 2024',
    'Fall 2023',
    'Fall 2022',
    'Fall 2021',
  ];

  static const majors = [
    'Computer Science and Engineering',
    'Electronics Engineering',
    'Industrial Engineering',
    'Mechatronics Engineering',
    'Molecular Biology, Genetics and Bioengineering',
    'Economics',
    'Management',
    'Psychology',
    'Political Science',
    'Visual Arts and Visual Communication Design',
  ];

  static const doubleMajors = [
    'Mathematics',
    'Economics',
    'Industrial Engineering',
    'Computer Science and Engineering',
  ];

  static const minors = [
    'Business Analytics',
    'Mathematics',
    'Physics',
    'Visual Arts',
    'Philosophy',
  ];

  static const hostUniversities = [
    'TU Delft, Netherlands',
    'KU Leuven, Belgium',
    'Politecnico di Milano, Italy',
    'TU Munich, Germany',
    'National University of Singapore',
  ];

  static const instructors = [
    'Instructor A',
    'Instructor B',
    'Instructor C',
    'Instructor D',
  ];

  static const cs310 = Course(
    code: 'CS 310',
    title: 'Mobile Application Development',
    suCredits: 3,
    ects: 6,
    format: 'lecture and lab',
    faculty: 'Faculty of Engineering and Natural Sciences',
    about:
        'Design and development of mobile applications: platform '
        'architecture, UI components, state management, local storage, '
        'networking and cloud back-ends, with a team project built across '
        'the term.',
    syllabusTerm: 'Fall 2026',
    prerequisites: ['CS 204'],
    unlocks: ['CS 408', 'CS 412'],
    ratings: CourseRatings(
      difficulty: 3.6,
      instructor: 4.0,
      attendance: 2.1,
      workload: 4.2,
      count: 48,
    ),
    majorShares: [
      MajorShare('Computer Science', 62),
      MajorShare('Industrial Eng.', 16),
      MajorShare('Electronics Eng.', 12),
      MajorShare('Other', 10),
    ],
    sections: [
      CourseSection(
        id: 'A',
        instructor: 'Instructor A',
        lectureTimes: 'Mon 10:40, Wed 10:40',
        labId: 'A1',
        labTimes: 'Thu 14:40',
        crn: '10234',
      ),
      CourseSection(
        id: 'B',
        instructor: 'Instructor B',
        lectureTimes: 'Tue 13:40, Thu 13:40',
        labId: 'B1',
        labTimes: 'Fri 10:40',
        crn: '10236',
      ),
    ],
    instructorRatings: [
      InstructorTermRating(
        instructor: 'Instructor A',
        term: 'Spring 2026',
        rating: 4.2,
        count: 12,
      ),
      InstructorTermRating(
        instructor: 'Instructor A',
        term: 'Fall 2025',
        rating: 4.0,
        count: 9,
      ),
      InstructorTermRating(
        instructor: 'Instructor B',
        term: 'Spring 2025',
        rating: 3.4,
        count: 7,
      ),
    ],
  );

  /// Short catalog entries for the other courses.
  static const courses = <Course>[
    cs310,
    Course(
      code: 'CS 201',
      title: 'Introduction to Computing',
      suCredits: 3,
      ects: 6,
    ),
    Course(
      code: 'CS 204',
      title: 'Advanced Programming',
      suCredits: 3,
      ects: 6,
    ),
    Course(code: 'CS 300', title: 'Data Structures', suCredits: 3, ects: 6),
    Course(code: 'CS 408', title: 'Computer Networks', suCredits: 3, ects: 6),
    Course(code: 'CS 412', title: 'Machine Learning', suCredits: 3, ects: 6),
    Course(code: 'MATH 102', title: 'Calculus II', suCredits: 3, ects: 6),
    Course(code: 'MATH 201', title: 'Linear Algebra', suCredits: 3, ects: 6),
    Course(
      code: 'HUM 201',
      title: 'Major Works of Western Literature',
      suCredits: 3,
      ects: 5,
    ),
  ];

  static Course? courseByCode(String code) {
    for (final c in courses) {
      if (c.code == code) return c;
    }
    return null;
  }

  static const reviews = <Review>[
    Review(
      id: 'r1',
      courseCode: 'CS 310',
      term: 'Spring 2026',
      instructor: 'Instructor A',
      topics: [ReviewTopic.workload, ReviewTopic.attendance],
      text:
          'The team project is most of the grade, so pick your group '
          'early. Labs are weekly and attendance is only taken in labs.',
    ),
    Review(
      id: 'r2',
      courseCode: 'CS 310',
      term: 'Fall 2025',
      instructor: 'Instructor A',
      topics: [ReviewTopic.instructor, ReviewTopic.difficulty],
      text:
          'Clear lectures and fast answers on the forum. The exam asks you '
          'to reason about state, not memorise widgets.',
    ),
    Review(
      id: 'r3',
      courseCode: 'CS 310',
      term: 'Fall 2025',
      instructor: 'Instructor B',
      topics: [ReviewTopic.difficulty],
      text:
          'Hard if you have never built a UI. Start each project step the '
          'week it is posted.',
    ),
    Review(
      id: 'r4',
      courseCode: 'CS 310',
      term: 'Spring 2025',
      instructor: 'Instructor B',
      topics: [ReviewTopic.attendance, ReviewTopic.workload],
      text:
          'Attendance counted in lectures too in this section. Workload '
          'peaks in the last two project steps.',
    ),
  ];

  static List<Review> reviewsFor(String courseCode) =>
      reviews.where((r) => r.courseCode == courseCode).toList();

  /// Courses already on the list when "Courses you've taken" opens.
  static const sampleTakenCourses = [
    TakenCourse(
      courseName: 'CS 201 Introduction to Computing',
      term: 'Fall 2024',
      instructor: 'Instructor B',
    ),
    TakenCourse(
      courseName: 'MATH 102 Calculus II',
      term: 'Spring 2025',
      instructor: 'Instructor D',
    ),
  ];
}
