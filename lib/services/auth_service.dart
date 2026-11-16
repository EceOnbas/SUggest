import 'package:flutter/widgets.dart';

import '../models/user_profile.dart';

/// Where the signed-in user is in the sign-in flow. The app picks the
/// first screen from this (design: "Which screen opens first").
enum AuthStatus {
  /// No one is signed in: open Welcome.
  signedOut,

  /// Signed in, email not verified yet: open Check your inbox.
  unverified,

  /// Verified, but profile setup not finished or skipped: open the
  /// profile intro.
  needsProfile,

  /// Verified and set up: open Home.
  ready,
}

/// Why an auth action failed. Screens turn these into messages.
enum AuthError {
  /// Email and password don't match. Deliberately the same error for an
  /// unknown email, so the app never reveals which accounts exist.
  wrongCredentials,

  /// Create account with an email that already has an account.
  emailInUse,

  /// No internet.
  network,
}

class AuthException implements Exception {
  const AuthException(this.error);
  final AuthError error;

  @override
  String toString() => 'AuthException($error)';
}

/// Sign-in, sign-up, verification and the private profile.
///
/// In Step 2 the app uses [FakeAuthService]; Step 3 adds a Firebase
/// version of this same class. Emails are always the part before the @,
/// because the @sabanciuniv.edu ending is fixed.
abstract class AuthService extends ChangeNotifier {
  AuthStatus get status;

  /// The full address of the signed-in user, or null.
  String? get email;

  /// The private profile, or null before setup.
  UserProfile? get profile;

  Future<void> logIn({required String localPart, required String password});

  Future<void> createAccount({
    required String localPart,
    required String password,
  });

  /// Sends the verification link again. The old link stops working.
  Future<void> resendVerificationEmail();

  /// Checks whether the link was tapped. Returns true when verified.
  Future<bool> checkEmailVerified();

  /// Sends a reset link. Succeeds whether or not the account exists, so
  /// the screen never reveals it.
  Future<void> sendPasswordReset({required String localPart});

  /// Saves the profile from setup, or an empty one after "Skip for now".
  Future<void> saveProfile(UserProfile profile);

  Future<void> logOut();
}

/// Gives every screen below it access to the [AuthService] and rebuilds
/// listeners when the status changes.
class AuthScope extends InheritedNotifier<AuthService> {
  const AuthScope({
    super.key,
    required AuthService service,
    required super.child,
  }) : super(notifier: service);

  static AuthService of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AuthScope>();
    assert(scope != null, 'No AuthScope above this widget.');
    return scope!.notifier!;
  }
}
