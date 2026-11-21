import '../../../data/mock_data.dart';
import '../../../models/user_profile.dart';

/// The private account and contact details on My Profile.
///
/// Only [handle] is ever shown to other students (on reviews); the rest
/// stays private. Empty strings mean "not given".
class AccountDetails {
  const AccountDetails({
    required this.fullName,
    required this.handle,
    required this.institutionalEmail,
    this.backupEmail = '',
    this.phone = '',
  });

  /// Not asked at sign-up, so it starts empty.
  final String fullName;

  /// The public handle without the "@". It comes from sign-up and is
  /// saved through the auth service.
  final String handle;

  /// The @sabanciuniv.edu address. It comes from sign-in and cannot be
  /// edited.
  final String institutionalEmail;
  final String backupEmail;
  final String phone;

  AccountDetails copyWith({
    String? fullName,
    String? handle,
    String? institutionalEmail,
    String? backupEmail,
    String? phone,
  }) => AccountDetails(
    fullName: fullName ?? this.fullName,
    handle: handle ?? this.handle,
    institutionalEmail: institutionalEmail ?? this.institutionalEmail,
    backupEmail: backupEmail ?? this.backupEmail,
    phone: phone ?? this.phone,
  );
}

/// The four optional programs and universities on the academic card.
/// Each one shows as a row when filled and as a "+ Add" button when not.
enum AcademicExtra {
  doubleMajor('Double Major'),
  minor('Minor'),
  erasmus('Erasmus University'),
  exchange('Exchange University');

  const AcademicExtra(this.label);

  /// Text shown on screen, for example "Double Major".
  final String label;

  /// The exchange program of [erasmus] and [exchange]; null for the
  /// other two.
  ExchangeProgram? get program => switch (this) {
    AcademicExtra.erasmus => ExchangeProgram.erasmus,
    AcademicExtra.exchange => ExchangeProgram.exchange,
    _ => null,
  };

  /// The only values the field accepts.
  List<String> get options => switch (this) {
    AcademicExtra.doubleMajor => MockData.doubleMajors,
    AcademicExtra.minor => MockData.minors,
    AcademicExtra.erasmus => MockData.erasmusUniversities,
    AcademicExtra.exchange => MockData.hostUniversities,
  };
}

/// The academic information on My Profile.
///
/// Everything except graduation comes from the profile setup answers
/// ([fromProfile]) and is saved back to them ([applyTo]). Empty strings
/// mean "not given".
class AcademicDetails {
  const AcademicDetails({
    this.major = '',
    this.graduated = false,
    this.classYear,
    this.currentTerm,
    this.startTerm,
    this.graduationYear = '2026',
    this.extras = const {},
    this.exchangeTerms = const {},
  });

  /// Builds the details from the setup answers. [graduated] and
  /// [graduationYear] are not asked in setup, so My Profile keeps them.
  factory AcademicDetails.fromProfile(
    UserProfile profile, {
    bool graduated = false,
    String graduationYear = '2026',
  }) {
    final erasmus = profile.exchangeFor(ExchangeProgram.erasmus);
    final exchange = profile.exchangeFor(ExchangeProgram.exchange);
    return AcademicDetails(
      major: profile.major ?? '',
      graduated: graduated,
      classYear: profile.classYear,
      currentTerm: profile.currentTerm,
      startTerm: profile.startTerm,
      graduationYear: graduationYear,
      extras: {
        if (profile.doubleMajor != null)
          AcademicExtra.doubleMajor: profile.doubleMajor!,
        if (profile.minor != null) AcademicExtra.minor: profile.minor!,
        if (erasmus != null) AcademicExtra.erasmus: erasmus.hostUniversity,
        if (exchange != null) AcademicExtra.exchange: exchange.hostUniversity,
      },
      exchangeTerms: {
        if (erasmus != null) AcademicExtra.erasmus: erasmus.term,
        if (exchange != null) AcademicExtra.exchange: exchange.term,
      },
    );
  }

  final String major;
  final bool graduated;

  /// "1" to "4" or "5+", as in [MockData.classYears]. Null when not set.
  final String? classYear;

  /// One of [MockData.currentTerms], or null when not set.
  final String? currentTerm;

  /// One of [MockData.startTerms], or null when not set.
  final String? startTerm;

  /// For example "2024"; used only when [graduated].
  final String graduationYear;

  /// The filled optional fields. A missing key means "not given".
  final Map<AcademicExtra, String> extras;

  /// The term of the Erasmus and Exchange experiences, by field.
  final Map<AcademicExtra, String> exchangeTerms;

  /// The value of an optional field, or '' when it is not given.
  String extra(AcademicExtra field) => extras[field] ?? '';

  /// The term of an Erasmus or Exchange field, or ''.
  String exchangeTerm(AcademicExtra field) => exchangeTerms[field] ?? '';

  /// The lines of an optional field's row: the university and its term
  /// for Erasmus and Exchange, otherwise just the value.
  List<String> linesOf(AcademicExtra field) => [
    extra(field),
    if (exchangeTerm(field).isNotEmpty) exchangeTerm(field),
  ];

  /// "3" → "3rd Year", "5+" → "5th Year or later".
  static String yearLabel(String classYear) => switch (classYear) {
    '1' => '1st Year',
    '2' => '2nd Year',
    '3' => '3rd Year',
    '4' => '4th Year',
    _ => '5th Year or later',
  };

  /// The lines under "Academic Status & Timeline", for example
  /// ["3rd Year Student", "Current term: Fall 2026",
  /// "Started in Fall 2024"].
  List<String> get timelineLines {
    final start = startTerm;
    final started = start == null ? null : 'Started in $start';
    if (graduated) {
      return ['Graduated (Class of $graduationYear)', ?started];
    }
    final year = classYear;
    final term = currentTerm;
    return [
      year == null ? 'Class year not set' : '${yearLabel(year)} Student',
      if (term != null) 'Current term: $term',
      ?started,
    ];
  }

  /// [profile] with these details saved into it. Courses taken are kept.
  UserProfile applyTo(UserProfile profile) {
    String? orNull(String value) => value.isEmpty ? null : value;
    return profile
        .withProgram(
          major: orNull(major),
          doubleMajor: orNull(extra(AcademicExtra.doubleMajor)),
          minor: orNull(extra(AcademicExtra.minor)),
        )
        .withYear(
          classYear: classYear,
          currentTerm: currentTerm,
          startTerm: startTerm,
        )
        .withExchanges([
          for (final field in [AcademicExtra.erasmus, AcademicExtra.exchange])
            if (extra(field).isNotEmpty)
              ExchangeInfo(
                hostUniversity: extra(field),
                term: exchangeTerm(field),
                program: field.program!,
              ),
        ]);
  }

  AcademicDetails copyWith({
    String? major,
    bool? graduated,
    String? classYear,
    String? currentTerm,
    String? startTerm,
    String? graduationYear,
    Map<AcademicExtra, String>? extras,
    Map<AcademicExtra, String>? exchangeTerms,
  }) => AcademicDetails(
    major: major ?? this.major,
    graduated: graduated ?? this.graduated,
    classYear: classYear ?? this.classYear,
    currentTerm: currentTerm ?? this.currentTerm,
    startTerm: startTerm ?? this.startTerm,
    graduationYear: graduationYear ?? this.graduationYear,
    extras: extras ?? this.extras,
    exchangeTerms: exchangeTerms ?? this.exchangeTerms,
  );
}
