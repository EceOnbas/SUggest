import '../core/utils/su_email.dart';
import '../models/user_profile.dart';
import 'auth_service.dart';

/// An in-memory [AuthService] for Step 2, where sign-in is UI-only.
///
/// Demo rules, so every screen state can be shown:
/// - The accounts in [demoAccounts] exist from the start. Logging in
///   with a wrong password shows the error.
/// - A new account starts unverified. The first "I've verified" check
///   says "Not verified yet"; the second one passes, as if the link had
///   been tapped in between.
/// - Nothing is saved when the app closes.
class FakeAuthService extends AuthService {
  FakeAuthService({
    this.delay = const Duration(milliseconds: 500),
    Map<String, String>? accounts,
  }) : _passwords = {...(accounts ?? demoAccounts)};

  /// Placeholder test accounts (name before the @ → password).
  static const demoAccounts = {'demo.student': 'sakura2026'};

  /// How long each action pretends to take on the network.
  final Duration delay;

  final Map<String, String> _passwords;
  final Set<String> _verified = {...demoAccounts.keys};
  final Map<String, UserProfile> _profiles = {};
  final Map<String, int> _checks = {};

  String? _user;

  @override
  String? get email => _user == null ? null : SuEmail.full(_user!);

  @override
  UserProfile? get profile => _user == null ? null : _profiles[_user];

  @override
  AuthStatus get status {
    final user = _user;
    if (user == null) return AuthStatus.signedOut;
    if (!_verified.contains(user)) return AuthStatus.unverified;
    if (!_profiles.containsKey(user)) return AuthStatus.needsProfile;
    return AuthStatus.ready;
  }

  Future<void> _wait() => Future<void>.delayed(delay);

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
  }) async {
    await _wait();
    final user = SuEmail.clean(localPart);
    if (_passwords.containsKey(user)) {
      throw const AuthException(AuthError.emailInUse);
    }
    _passwords[user] = password;
    _user = user;
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
