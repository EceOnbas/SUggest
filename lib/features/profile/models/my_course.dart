import '../../../data/mock_data.dart';
import '../../../models/course.dart';
import '../../../models/user_profile.dart';

/// A course on My Courses: what the student saved ([taken]) and the
/// team's catalog entry it belongs to ([course]).
///
/// [TakenCourse] stores the course as its full name ("CS 310 Mobile
/// Application Development"), so this finds the catalog entry by that
/// name.
class MyCourse {
  MyCourse(this.taken) : course = _catalogCourse(taken.courseName);

  final TakenCourse taken;

  /// Null only for an old entry whose course left the catalog.
  final Course? course;

  static Course? _catalogCourse(String fullName) {
    for (final c in MockData.courses) {
      if (c.fullName == fullName) return c;
    }
    return null;
  }

  /// "CS 310". For a course not in the catalog, the first two words.
  String get code =>
      course?.code ?? taken.courseName.split(' ').take(2).join(' ');

  /// "Mobile Application Development", or '' when unknown.
  String get title => course?.title ?? '';

  /// "CS 310 · Mobile Application Development".
  String get label => course == null ? taken.courseName : courseLabel(course!);

  String get term => taken.term;
  String get instructor => taken.instructor;

  /// The text a student picks for [course], for example
  /// "CS 310 · Mobile Application Development".
  static String courseLabel(Course course) =>
      '${course.code} · ${course.title}';

  /// The student's courses from their profile, newest term first and by
  /// code within a term.
  static List<MyCourse> allOf(UserProfile? profile) {
    final courses = [
      for (final taken in profile?.coursesTaken ?? const <TakenCourse>[])
        MyCourse(taken),
    ];
    courses.sort((a, b) {
      final byTerm = compareTerms(b.term, a.term);
      return byTerm != 0 ? byTerm : a.code.compareTo(b.code);
    });
    return courses;
  }
}

/// A number that puts terms in time order: "Spring 2026" comes after
/// "Fall 2025". Unknown text sorts first.
int termOrder(String term) {
  final parts = term.split(' ');
  final year = parts.length == 2 ? int.tryParse(parts[1]) : null;
  if (year == null) return -1;
  return year * 2 + (parts[0] == 'Fall' ? 1 : 0);
}

/// Negative when [a] is earlier than [b].
int compareTerms(String a, String b) => termOrder(a).compareTo(termOrder(b));

/// The finished terms a student can add a course from, newest first:
/// before today's term ([MockData.currentTerm]) and the student's
/// current term, and from their start term on when it is set. A
/// graduate's current term is ignored.
List<String> finishedTermsFor(UserProfile? profile, {bool graduated = false}) {
  final current = profile?.currentTerm;
  final start = profile?.startTerm;
  return [
    for (final term in MockData.terms)
      if (compareTerms(term, MockData.currentTerm) < 0 &&
          (graduated || current == null || compareTerms(term, current) < 0) &&
          (start == null || compareTerms(term, start) >= 0))
        term,
  ];
}
