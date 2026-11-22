import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/models/user_profile.dart';
import 'package:suggest/services/auth_service.dart';
import 'package:suggest/services/fake_auth_service.dart';

void main() {
  late FakeAuthService auth;
  const demoName = 'demo.student';
  final demoPassword = FakeAuthService.demoAccounts[demoName]!;

  setUp(() => auth = FakeAuthService(delay: Duration.zero));

  test('starts signed out', () {
    expect(auth.status, AuthStatus.signedOut);
    expect(auth.email, isNull);
  });

  test('wrong password and unknown email give the same error', () async {
    Future<void> attempt(String name) =>
        auth.logIn(localPart: name, password: 'nope1234');
    for (final name in [demoName, 'nobody.here']) {
      await expectLater(
        attempt(name),
        throwsA(
          isA<AuthException>().having(
            (e) => e.error,
            'error',
            AuthError.wrongCredentials,
          ),
        ),
      );
    }
    expect(auth.status, AuthStatus.signedOut);
  });

  test('demo account logs in and needs a profile', () async {
    await auth.logIn(localPart: demoName, password: demoPassword);
    expect(auth.email, '$demoName@sabanciuniv.edu');
    expect(auth.status, AuthStatus.needsProfile);
  });

  test('creating an existing account fails', () {
    expect(
      auth.createAccount(localPart: demoName, password: 'another12'),
      throwsA(
        isA<AuthException>().having(
          (e) => e.error,
          'error',
          AuthError.emailInUse,
        ),
      ),
    );
  });

  test('new account: unverified, first check fails, second passes', () async {
    var notified = 0;
    auth.addListener(() => notified++);
    await auth.createAccount(localPart: 'New.Student', password: 'abcdefg1');
    expect(auth.email, 'new.student@sabanciuniv.edu');
    expect(auth.status, AuthStatus.unverified);

    expect(await auth.checkEmailVerified(), isFalse);
    expect(auth.status, AuthStatus.unverified);
    expect(await auth.checkEmailVerified(), isTrue);
    expect(auth.status, AuthStatus.needsProfile);

    await auth.saveProfile(const UserProfile(major: 'Economics'));
    expect(auth.status, AuthStatus.ready);
    expect(auth.profile!.major, 'Economics');
    expect(notified, 3);
  });

  test('a reset link is "sent" even for an unknown email', () async {
    await auth.sendPasswordReset(localPart: 'nobody.here');
  });

  test('log out returns to signed out', () async {
    await auth.logIn(localPart: demoName, password: demoPassword);
    await auth.logOut();
    expect(auth.status, AuthStatus.signedOut);
  });

  group('showcase account', () {
    test('is ready with a full profile and a handle', () async {
      const name = FakeAuthService.showcaseAccount;
      await auth.logIn(
        localPart: name,
        password: FakeAuthService.demoAccounts[name]!,
      );
      expect(auth.status, AuthStatus.ready);
      expect(auth.profile, FakeAuthService.showcaseProfile);
      expect(auth.handle, FakeAuthService.demoHandles[name]);
    });
  });

  group('handles', () {
    Matcher handleInUse() => isA<AuthException>().having(
      (e) => e.error,
      'error',
      AuthError.handleInUse,
    );

    test('a chosen handle is cleaned and kept', () async {
      await auth.createAccount(
        localPart: 'new.student',
        password: 'abcdefg1',
        handle: ' @Maple_Fox ',
      );
      expect(auth.handle, 'maple_fox');
    });

    test('an empty handle is made up, valid and free', () async {
      await auth.createAccount(localPart: 'new.student', password: 'abcdefg1');
      final handle = auth.handle!;
      expect(HandleRules.isValid(handle), isTrue);
      expect(FakeAuthService.takenHandles, isNot(contains(handle)));
      expect(FakeAuthService.demoHandles.values, isNot(contains(handle)));
    });

    test("another student's handle cannot be used", () {
      expect(
        auth.createAccount(
          localPart: 'new.student',
          password: 'abcdefg1',
          handle: FakeAuthService.takenHandles.first,
        ),
        throwsA(handleInUse()),
      );
    });

    test('changeHandle saves a free handle and refuses a taken one', () async {
      await auth.logIn(localPart: demoName, password: demoPassword);
      await auth.changeHandle('simit_gull12');
      expect(auth.handle, 'simit_gull12');
      // Keeping your own handle is fine.
      await auth.changeHandle('simit_gull12');

      await expectLater(
        auth.changeHandle(FakeAuthService.demoHandles.values.last),
        throwsA(handleInUse()),
      );
      expect(auth.handle, 'simit_gull12');
    });
  });

  test('HandleRules', () {
    expect(HandleRules.clean(' @Deniz '), 'deniz');
    expect(HandleRules.isValid('tulip_heron42'), isTrue);
    expect(HandleRules.isValid('ab'), isFalse);
    expect(HandleRules.isValid('has space'), isFalse);
    expect(HandleRules.isValid('a' * 21), isFalse);
    expect(HandleRules.isValid(HandleRules.generate()), isTrue);
  });
}
