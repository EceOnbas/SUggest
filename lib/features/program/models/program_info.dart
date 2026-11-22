/// The three kinds of program a student can be in.
enum ProgramType {
  major('Major'),
  doubleMajor('Double major'),
  minor('Minor');

  const ProgramType(this.label);

  /// Text shown on screen.
  final String label;
}

/// Which program page to open: the program's name and its type.
///
/// Passed as the argument of `AppRoutes.program`.
class ProgramRef {
  const ProgramRef({required this.name, required this.type});

  /// For example "Computer Science and Engineering".
  final String name;
  final ProgramType type;
}

/// One term of a program's usual route, for example
/// "Year 2, Fall" with the courses most students take then.
class RouteTerm {
  const RouteTerm({required this.label, required this.courseCodes});

  final String label;

  /// Course codes, for example "CS 204".
  final List<String> courseCodes;
}
