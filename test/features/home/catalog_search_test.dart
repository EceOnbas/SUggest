import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/data/mock_data.dart';
import 'package:suggest/features/home/catalog_search.dart';

void main() {
  final courses = MockData.courses;

  test('finds a course by code, with or without the space', () {
    expect(searchCourses(courses, 'CS 310').map((c) => c.code), ['CS 310']);
    expect(searchCourses(courses, 'cs310').map((c) => c.code), ['CS 310']);
  });

  test('finds a course by part of its title, ignoring case', () {
    expect(searchCourses(courses, 'DATA').map((c) => c.code), ['CS 300']);
  });

  test('an empty query returns everything in the department', () {
    expect(searchCourses(courses, ''), courses);
    expect(
      searchCourses(courses, '', department: 'MATH').map((c) => c.code),
      ['MATH 102', 'MATH 201'],
    );
  });

  test('department and query work together', () {
    expect(searchCourses(courses, '201', department: 'MATH'), hasLength(1));
    expect(searchCourses(courses, 'zzz'), isEmpty);
  });

  test('departments start with All and have no repeats', () {
    expect(departmentsOf(courses), ['All', 'CS', 'MATH', 'HUM']);
  });

  group('recent searches', () {
    test('newest first, no repeats, at most five', () {
      var r = <String>[];
      for (final q in ['a', 'b', 'c', 'd', 'e', 'f']) {
        r = addRecentSearch(r, q);
      }
      expect(r, ['f', 'e', 'd', 'c', 'b']);
      expect(addRecentSearch(r, 'D'), ['D', 'f', 'e', 'c', 'b']);
    });

    test('ignores blank queries', () {
      expect(addRecentSearch(['x'], '   '), ['x']);
    });
  });
}
