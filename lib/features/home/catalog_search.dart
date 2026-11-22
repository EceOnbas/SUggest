import '../../models/course.dart';

/// Filter chip that shows every department.
const allDepartments = 'All';

/// "CS 310" -> "CS".
String departmentOf(Course course) => course.code.split(' ').first;

/// "All", then each department that has a course, in catalog order.
List<String> departmentsOf(List<Course> courses) => [
  allDepartments,
  ...{for (final c in courses) departmentOf(c)},
];

/// Courses matching [query] (code or title, ignoring case and spaces in the
/// code, so "cs310" finds "CS 310") inside [department].
List<Course> searchCourses(
  List<Course> courses,
  String query, {
  String department = allDepartments,
}) {
  String squash(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), '');
  final q = squash(query);
  return [
    for (final c in courses)
      if ((department == allDepartments || departmentOf(c) == department) &&
          (q.isEmpty ||
              squash(c.code).contains(q) ||
              squash(c.title).contains(q)))
        c,
  ];
}

/// Recent searches, newest first, no repeats (ignoring case), at most
/// [limit]. Blank queries are ignored.
List<String> addRecentSearch(
  List<String> recent,
  String query, {
  int limit = 5,
}) {
  final q = query.trim();
  if (q.isEmpty) return recent;
  return [
    q,
    for (final r in recent)
      if (r.toLowerCase() != q.toLowerCase()) r,
  ].take(limit).toList();
}
