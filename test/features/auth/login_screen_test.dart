import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/routes/app_routes.dart';
import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/core/widgets/app_back_button.dart';
import 'package:suggest/features/auth/forgot_password_screen.dart';
import 'package:suggest/features/auth/login_screen.dart';
import 'package:suggest/features/auth/sign_up_screen.dart';
import 'package:suggest/features/profile_setup/profile_intro_screen.dart';
import 'package:suggest/services/auth_service.dart';
import 'package:suggest/services/fake_auth_service.dart';

final _demoName = FakeAuthService.demoAccounts.keys.first;
final _demoPassword = FakeAuthService.demoAccounts[_demoName]!;

Future<void> _open(WidgetTester tester, {Size size = const Size(390, 844)}) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    AuthScope(
      service: FakeAuthService(delay: Duration.zero),
      child: MaterialApp(
        theme: AppTheme.light,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.table,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    ),
  );
}

Finder _field(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
  matching: find.byType(TextField),
);

Future<void> _tapLogIn(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Log in');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty fields show inline errors', (tester) async {
    await _open(tester);
    await _tapLogIn(tester);
    expect(find.text('Enter your SU email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('an error clears when its field is edited', (tester) async {
    await _open(tester);
    await _tapLogIn(tester);
    await tester.enterText(_field('SU email'), 'beren');
    await tester.pump();
    expect(find.text('Enter your SU email.'), findsNothing);
    expect(find.text('Enter your password.'), findsOneWidget);
  });

  testWidgets('wrong password shows one message for both fields', (
    tester,
  ) async {
    await _open(tester);
    await tester.enterText(_field('SU email'), _demoName);
    await tester.enterText(_field('Password'), 'wrongpass1');
    await _tapLogIn(tester);
    expect(find.text(LoginScreen.wrongCredentialsMessage), findsOneWidget);
  });

  testWidgets('right details go on to the profile intro', (tester) async {
    await _open(tester);
    await tester.enterText(_field('SU email'), _demoName);
    await tester.enterText(_field('Password'), _demoPassword);
    await _tapLogIn(tester);
    expect(find.byType(ProfileIntroScreen), findsOneWidget);
  });

  testWidgets('links open Forgot password and Create account', (tester) async {
    await _open(tester);
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.textContaining('Create account', findRichText: true),
    );
    await tester.tapOnText(find.textRange.ofSubstring('Create account'));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);
  });

  testWidgets('fits a small phone without overflow', (tester) async {
    await _open(tester, size: const Size(320, 568));
    await _tapLogIn(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _open(tester, size: const Size(375, 667));
    await _tapLogIn(tester);
    expect(tester.takeException(), isNull);
  });
}
