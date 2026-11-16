import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/app.dart';
import 'package:suggest/features/auth/check_inbox_screen.dart';
import 'package:suggest/features/auth/welcome_screen.dart';
import 'package:suggest/features/profile_setup/profile_intro_screen.dart';
import 'package:suggest/features/shell/main_shell.dart';
import 'package:suggest/models/user_profile.dart';
import 'package:suggest/services/fake_auth_service.dart';

void main() {
  late FakeAuthService auth;
  setUp(() => auth = FakeAuthService(delay: Duration.zero));

  Future<void> start(WidgetTester tester) async {
    await tester.pumpWidget(SUggestApp(auth: auth));
    await tester.pumpAndSettle();
  }

  testWidgets('not signed in: Welcome', (tester) async {
    await start(tester);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('email not verified: Check your inbox', (tester) async {
    await auth.createAccount(localPart: 'new.student', password: 'abcdefg1');
    await start(tester);
    expect(find.byType(CheckInboxScreen), findsOneWidget);
  });

  testWidgets('verified, no profile: Profile intro', (tester) async {
    final name = FakeAuthService.demoAccounts.keys.first;
    await auth.logIn(
      localPart: name,
      password: FakeAuthService.demoAccounts[name]!,
    );
    await start(tester);
    expect(find.byType(ProfileIntroScreen), findsOneWidget);
  });

  testWidgets('verified with profile: Home; log out returns to Welcome', (
    tester,
  ) async {
    final name = FakeAuthService.demoAccounts.keys.first;
    await auth.logIn(
      localPart: name,
      password: FakeAuthService.demoAccounts[name]!,
    );
    await auth.saveProfile(const UserProfile());
    await start(tester);
    expect(find.byType(MainShell), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Log out'));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });
}
