/// The private profile filled in during profile setup. Only its owner can
/// see it; the app adds it to anonymous totals only.
class UserProfile {
  const UserProfile({
    this.major,
    this.doubleMajor,
    this.minor,
    this.classYear,
    this.currentTerm,
    this.startTerm,
    this.coursesTaken = const [],
    this.exchange,
  });

  /// Every field is optional: each setup step can be skipped.
  final String? major;
  final String? doubleMajor;
  final String? minor;

  /// "1" to "4", or "5+".
  final String? classYear;
  final String? currentTerm;
  final String? startTerm;
  final List<TakenCourse> coursesTaken;

  /// Null when the student has not been on exchange.
  final ExchangeInfo? exchange;

  UserProfile copyWith({
    String? major,
    String? doubleMajor,
    String? minor,
    String? classYear,
    String? currentTerm,
    String? startTerm,
    List<TakenCourse>? coursesTaken,
    ExchangeInfo? exchange,
  }) => UserProfile(
    major: major ?? this.major,
    doubleMajor: doubleMajor ?? this.doubleMajor,
    minor: minor ?? this.minor,
    classYear: classYear ?? this.classYear,
    currentTerm: currentTerm ?? this.currentTerm,
    startTerm: startTerm ?? this.startTerm,
    coursesTaken: coursesTaken ?? this.coursesTaken,
    exchange: exchange ?? this.exchange,
  );
}

/// A course the student finished, with the term and instructor so their
/// reviews stay accurate. Shown as a card in "Courses you've taken".
class TakenCourse {
  const TakenCourse({
    required this.courseName,
    required this.term,
    required this.instructor,
  });

  /// For example "CS 204 Advanced Programming".
  final String courseName;
  final String term;
  final String instructor;
}

enum ExchangeProgram {
  erasmus('Erasmus+'),
  bilateral('Bilateral');

  const ExchangeProgram(this.label);
  final String label;
}

class ExchangeInfo {
  const ExchangeInfo({
    required this.hostUniversity,
    required this.term,
    required this.program,
  });

  final String hostUniversity;
  final String term;
  final ExchangeProgram program;
}
