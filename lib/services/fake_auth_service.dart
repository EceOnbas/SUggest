import 'dart:math';

import '../core/utils/su_email.dart';
import '../models/user_profile.dart';
import 'auth_service.dart';

/// An in-memory [AuthService] for Step 2, where sign-in is UI-only.
///
/// Demo rules, so every screen state can be shown:
/// - The accounts in [demoAccounts] exist from the start. Logging in
///   with a wrong password shows the error.
/// - [showcaseAccount] is already set up with a full profile, so the
///   whole My Profile page can be shown. The other demo account still
///   needs profile setup.
/// - A new account starts unverified. The first "I've verified" check
///   says "Not verified yet"; the second one passes, as if the link had
///   been tapped in between.
/// - The handles in [takenHandles] belong to other students, so the
///   "already taken" error can be shown.
/// - Nothing is saved when the app closes.
class FakeAuthService extends AuthService {
  FakeAuthService({
    this.delay = const Duration(milliseconds: 500),
    Map<String, String>? accounts,
    Random? random,
  }) : _passwords = {...(accounts ?? demoAccounts)},
       _random = random ?? Random();

  /// Placeholder test accounts (name before the @ → password).
  static const demoAccounts = {
    'demo.student': 'sakura2026',
    showcaseAccount: 'sakura2026',
  };

  /// The demo account with a finished profile, for showing the app.
  static const showcaseAccount = 'deniz.yilmaz';

  /// The showcase student's setup answers.
  static const showcaseProfile = UserProfile(
    major: 'Computer Science and Engineering',
    doubleMajor: 'Industrial Engineering',
    classYear: '3',
    currentTerm: 'Fall 2026',
    startTerm: 'Fall 2024',
    coursesTaken: [
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
      TakenCourse(
        courseName: 'CS 204 Advanced Programming',
        term: 'Spring 2025',
        instructor: 'Instructor C',
      ),
      TakenCourse(
        courseName: 'CS 300 Data Structures',
        term: 'Fall 2025',
        instructor: 'Instructor B',
      ),
      TakenCourse(
        courseName: 'CS 310 Mobile Application Development',
        term: 'Fall 2025',
        instructor: 'Instructor A',
      ),
      TakenCourse(
        courseName: 'MATH 201 Linear Algebra',
        term: 'Fall 2025',
        instructor: 'Instructor B',
      ),
    ],
    exchanges: [
      ExchangeInfo(
        hostUniversity: 'National University of Singapore',
        term: 'Spring 2026',
        program: ExchangeProgram.exchange,
      ),
    ],
  );

  /// Handles of the demo accounts (name before the @ → handle).
  static const demoHandles = {
    'demo.student': 'campus_sakura',
    showcaseAccount: 'bosphorus_coder',
  };

  /// Handles other students already use; reviews on the course page
  /// show them.
  static const takenHandles = {
    'sakura_dev',
    'night_owl',
    'tulip_coder',
    'ferry_commuter',
  };

  /// How long each action pretends to take on the network.
  final Duration delay;

  final Random _random;
  final Map<String, String> _passwords;
  final Set<String> _verified = {...demoAccounts.keys};
  final Map<String, UserProfile> _profiles = {showcaseAccount: showcaseProfile};
  final Map<String, String> _handles = {...demoHandles};
  final Map<String, int> _checks = {};

  String? _user;

  @override
  String? get email => _user == null ? null : SuEmail.full(_user!);

  @override
  UserProfile? get profile => _user == null ? null : _profiles[_user];

  @override
  String? get handle => _user == null ? null : _handles[_user];

  @override
  AuthStatus get status {
    final user = _user;
    if (user == null) return AuthStatus.signedOut;
    if (!_verified.contains(user)) return AuthStatus.unverified;
    if (!_profiles.containsKey(user)) return AuthStatus.needsProfile;
    return AuthStatus.ready;
  }

  /// Pretends to wait for the network. A zero delay (used in tests)
  /// returns at once without starting a timer.
  Future<void> _wait() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
  }

  /// Whether anyone other than [exceptUser] has [handle].
  bool _handleTaken(String handle, {String? exceptUser}) {
    if (takenHandles.contains(handle)) return true;
    return _handles.entries.any(
      (e) => e.value == handle && e.key != exceptUser,
    );
  }

  /// A made-up handle that no one has yet.
  String _freeHandle() {
    while (true) {
      final handle = HandleRules.generate(_random);
      if (!_handleTaken(handle)) return handle;
    }
  }

  @override
  Future<void> logIn({
    required String localPart,
    required String password,
  }) async {
    await _wait();
    final user = SuEmail.clean(localPart);
    if (_passwords[user] != password) {
      throw const AuthException(AuthError.wrongCredentials);
    }
    _user = user;
    notifyListeners();
  }

  @override
  Future<void> createAccount({
    required String localPart,
    required String password,
    String? handle,
  }) async {
    await _wait();
    final user = SuEmail.clean(localPart);
    if (_passwords.containsKey(user)) {
      throw const AuthException(AuthError.emailInUse);
    }
    final chosen = HandleRules.clean(handle ?? '');
    if (chosen.isNotEmpty && _handleTaken(chosen)) {
      throw const AuthException(AuthError.handleInUse);
    }
    _passwords[user] = password;
    _handles[user] = chosen.isEmpty ? _freeHandle() : chosen;
    _user = user;
    notifyListeners();
  }

  @override
  Future<void> changeHandle(String handle) async {
    await _wait();
    final user = _user;
    if (user == null) return;
    final chosen = HandleRules.clean(handle);
    if (_handles[user] == chosen) return;
    if (_handleTaken(chosen, exceptUser: user)) {
      throw const AuthException(AuthError.handleInUse);
    }
    _handles[user] = chosen;
    notifyListeners();
  }

  @override
  Future<void> resendVerificationEmail() => _wait();

  @override
  Future<bool> checkEmailVerified() async {
    await _wait();
    final user = _user;
    if (user == null) return false;
    if (_verified.contains(user)) return true;
    final checks = (_checks[user] ?? 0) + 1;
    _checks[user] = checks;
    if (checks < 2) return false;
    _verified.add(user);
    notifyListeners();
    return true;
  }

  @override
  Future<void> sendPasswordReset({required String localPart}) => _wait();

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _wait();
    final user = _user;
    if (user == null) return;
    _profiles[user] = profile;
    notifyListeners();
  }

  @override
  Future<void> logOut() async {
    _user = null;
    notifyListeners();
  }
}
