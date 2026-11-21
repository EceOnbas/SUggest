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
    this.exchanges = const [],
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

  /// The student's outgoing exchange experiences, at most one for each
  /// [ExchangeProgram]. Empty when they have not been on exchange.
  final List<ExchangeInfo> exchanges;

  /// The experience for [program], or null when there is none.
  ExchangeInfo? exchangeFor(ExchangeProgram program) {
    for (final e in exchanges) {
      if (e.program == program) return e;
    }
    return null;
  }

  /// A copy with the program step's answers. Unlike [copyWith], a null
  /// here clears the field (the user picked "None").
  UserProfile withProgram({
    String? major,
    String? doubleMajor,
    String? minor,
  }) => UserProfile(
    major: major,
    doubleMajor: doubleMajor,
    minor: minor,
    classYear: classYear,
    currentTerm: currentTerm,
    startTerm: startTerm,
    coursesTaken: coursesTaken,
    exchanges: exchanges,
  );

  /// A copy with the year step's answers.
  UserProfile withYear({
    String? classYear,
    String? currentTerm,
    String? startTerm,
  }) => UserProfile(
    major: major,
    doubleMajor: doubleMajor,
    minor: minor,
    classYear: classYear,
    currentTerm: currentTerm,
    startTerm: startTerm,
    coursesTaken: coursesTaken,
    exchanges: exchanges,
  );

  /// A copy with the exchange step's answers; an empty list means
  /// "Not yet".
  UserProfile withExchanges(List<ExchangeInfo> exchanges) => UserProfile(
    major: major,
    doubleMajor: doubleMajor,
    minor: minor,
    classYear: classYear,
    currentTerm: currentTerm,
    startTerm: startTerm,
    coursesTaken: coursesTaken,
    exchanges: exchanges,
  );

  UserProfile copyWith({
    String? major,
    String? doubleMajor,
    String? minor,
    String? classYear,
    String? currentTerm,
    String? startTerm,
    List<TakenCourse>? coursesTaken,
    List<ExchangeInfo>? exchanges,
  }) => UserProfile(
    major: major ?? this.major,
    doubleMajor: doubleMajor ?? this.doubleMajor,
    minor: minor ?? this.minor,
    classYear: classYear ?? this.classYear,
    currentTerm: currentTerm ?? this.currentTerm,
    startTerm: startTerm ?? this.startTerm,
    coursesTaken: coursesTaken ?? this.coursesTaken,
    exchanges: exchanges ?? this.exchanges,
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

/// The two kinds of outgoing exchange. A student may have done both.
enum ExchangeProgram {
  erasmus('Erasmus'),
  exchange('Exchange');

  const ExchangeProgram(this.label);
  final String label;
}

/// One outgoing exchange experience: where and when.
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
