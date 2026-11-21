import 'dart:math';

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

  /// Create account or change handle with a handle someone else has.
  handleInUse,

  /// No internet.
  network,
}

class AuthException implements Exception {
  const AuthException(this.error);
  final AuthError error;

  @override
  String toString() => 'AuthException($error)';
}

/// The public handle shown on a student's reviews instead of their name,
/// for example "bosphorus_coder" (shown as "@bosphorus_coder").
abstract final class HandleRules {
  static final _pattern = RegExp(r'^[a-z0-9_]{3,20}$');

  /// The message shown under the field when [isValid] fails.
  static const formatMessage =
      'Use 3–20 lowercase letters, numbers or underscores.';

  /// The message shown when someone else has the handle.
  static const takenMessage = 'That handle is already taken. Try another one.';

  /// Lower case with no "@" or spaces around, so "@Deniz " is "deniz".
  static String clean(String handle) {
    final text = handle.trim().toLowerCase();
    return text.startsWith('@') ? text.substring(1) : text;
  }

  static bool isValid(String handle) => _pattern.hasMatch(clean(handle));

  static const _words = [
    'sakura',
    'tulip',
    'bosphorus',
    'ferry',
    'simit',
    'campus',
    'maple',
    'harbor',
  ];
  static const _animals = ['owl', 'fox', 'heron', 'lynx', 'otter', 'gull'];

  /// A random handle such as "tulip_heron42". Pass [random] for a
  /// repeatable result.
  static String generate([Random? random]) {
    final r = random ?? Random();
    final word = _words[r.nextInt(_words.length)];
    final animal = _animals[r.nextInt(_animals.length)];
    return '${word}_$animal${10 + r.nextInt(90)}';
  }
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

  /// The public handle of the signed-in user, without the "@", or null.
  String? get handle;

  Future<void> logIn({required String localPart, required String password});

  /// Creates the account. [handle] is the public handle the student
  /// chose; when it is null or empty, a free one is made up. Fails with
  /// [AuthError.handleInUse] when the handle is taken.
  Future<void> createAccount({
    required String localPart,
    required String password,
    String? handle,
  });

  /// Changes the public handle. Fails with [AuthError.handleInUse] when
  /// another student has it.
  Future<void> changeHandle(String handle);

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
