import 'models/program_info.dart';
import 'models/program_post.dart';

/// Placeholder data for the program pages and admin screen.
/// Firebase replaces it in Step 3.
///
/// The program names come from `MockData.majors`, `MockData.doubleMajors`
/// and `MockData.minors`; this file only adds the routes and posts.
abstract final class ProgramMockData {
  /// The usual route for programs that have one written out.
  static const _routes = <String, List<RouteTerm>>{
    'Computer Science and Engineering': [
      RouteTerm(label: 'Year 1, Fall', courseCodes: ['CS 201']),
      RouteTerm(label: 'Year 1, Spring', courseCodes: ['CS 204', 'MATH 102']),
      RouteTerm(label: 'Year 2, Fall', courseCodes: ['CS 300', 'MATH 201']),
      RouteTerm(label: 'Year 2, Spring', courseCodes: ['HUM 201']),
      RouteTerm(label: 'Year 3, Fall', courseCodes: ['CS 310']),
      RouteTerm(label: 'Year 3, Spring', courseCodes: ['CS 408']),
      RouteTerm(label: 'Year 4, Fall', courseCodes: ['CS 412']),
    ],
    'Mathematics': [
      RouteTerm(label: 'First term', courseCodes: ['MATH 102']),
      RouteTerm(label: 'Second term', courseCodes: ['MATH 201']),
    ],
    'Business Analytics': [
      RouteTerm(label: 'First term', courseCodes: ['CS 201']),
      RouteTerm(label: 'Second term', courseCodes: ['MATH 201', 'CS 412']),
    ],
  };

  /// The route used when a program has none written out yet.
  static const _defaultRoute = [
    RouteTerm(label: 'Year 1, Fall', courseCodes: ['CS 201']),
    RouteTerm(label: 'Year 1, Spring', courseCodes: ['MATH 102']),
    RouteTerm(label: 'Year 2, Fall', courseCodes: ['MATH 201']),
    RouteTerm(label: 'Year 2, Spring', courseCodes: ['HUM 201']),
  ];

  static List<RouteTerm> routeFor(String programName) =>
      _routes[programName] ?? _defaultRoute;

  /// The posts every program page starts with.
  static const posts = <ProgramPost>[
    ProgramPost(
      id: 'p1',
      programName: 'Computer Science and Engineering',
      topic: 'Course order',
      term: 'Fall 2026',
      authorHandle: 'sakura_dev',
      text:
          'Take CS 204 before CS 300 even if the system lets you skip it. '
          'Data Structures assumes you are fast with pointers.',
    ),
    ProgramPost(
      id: 'p2',
      programName: 'Computer Science and Engineering',
      topic: 'Question',
      term: 'Fall 2026',
      authorHandle: 'night_owl',
      text:
          'Is it fine to leave HUM 201 to the last year, or does it fill '
          'up early?',
    ),
    ProgramPost(
      id: 'p3',
      programName: 'Mathematics',
      topic: 'Advice',
      term: 'Spring 2026',
      authorHandle: 'tulip_coder',
      text:
          'For the double major, start Linear Algebra in your second year '
          'so the proof courses do not pile up.',
    ),
    ProgramPost(
      id: 'p4',
      programName: 'Business Analytics',
      topic: 'Experience',
      term: 'Spring 2026',
      text:
          'The minor fits well with Industrial Engineering. Most of my '
          'courses counted as free electives too.',
    ),
  ];
}
