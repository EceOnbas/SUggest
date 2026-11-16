import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/routes/app_routes.dart';
import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/core/utils/password_rules.dart';
import 'package:suggest/features/auth/check_inbox_screen.dart';
import 'package:suggest/features/auth/login_screen.dart';
import 'package:suggest/features/auth/sign_up_screen.dart';
import 'package:suggest/services/auth_service.dart';
import 'package:suggest/services/fake_auth_service.dart';

Future<void> _open(WidgetTester tester, {Size size = const Size(390, 844)}) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    AuthScope(
      service: FakeAuthService(delay: Duration.zero),
      child: MaterialApp(
        theme: AppTheme.light,
        initialRoute: AppRoutes.signUp,
        routes: AppRoutes.table,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    ),
  );
}

Finder _field(String label) => find
    .descendant(
      of: find
          .ancestor(of: find.text(label), matching: find.byType(Column))
          .first,
      matching: find.byType(TextField),
    )
    .first;

FilledButton _button(WidgetTester tester) =>
    tester.widget(find.widgetWithText(FilledButton, 'Create account'));

Future<void> _fill(
  WidgetTester tester, {
  String email = 'new.student',
  String password = 'sakura-time7',
  String? repeat,
  bool agree = true,
}) async {
  await tester.enterText(_field('SU email'), email);
  await tester.enterText(_field('Password'), password);
  await tester.enterText(_field('Repeat password'), repeat ?? password);
  if (agree) {
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
  }
  await tester.pump();
}

void main() {
  test('password rules', () {
    expect(PasswordRule.allMetBy('sakura-time7'), isTrue);
    expect(PasswordRule.minLength.isMetBy('short1'), isFalse);
    expect(PasswordRule.hasNumber.isMetBy('sakura-time'), isFalse);
  });

  testWidgets('button stays faded until every field is valid', (tester) async {
    await _open(tester);
    expect(_button(tester).enabled, isFalse);
    await _fill(tester, agree: false);
    expect(_button(tester).enabled, isFalse);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(_button(tester).enabled, isTrue);
  });

  testWidgets('a rule that is not met turns red after leaving the field', (
    tester,
  ) async {
    await _open(tester);
    await tester.enterText(_field('Password'), 'sakura-time');
    await tester.pump();
    expect(find.textContaining('Add a digit'), findsNothing);
    // Leave the field.
    await tester.tap(_field('Repeat password'));
    await tester.pump();
    expect(
      find.text('At least one number. Add a digit, like sakura-time7.'),
      findsOneWidget,
    );
  });

  testWidgets('different passwords show the mismatch error', (tester) async {
    await _open(tester);
    await _fill(tester, repeat: 'sakura-tim');
    expect(find.text(SignUpScreen.mismatchMessage), findsOneWidget);
    expect(_button(tester).enabled, isFalse);
  });

  testWidgets('a badly formed email shows an error after leaving it', (
    tester,
  ) async {
    await _open(tester);
    await tester.enterText(_field('SU email'), 'beren guler');
    await tester.tap(_field('Password'));
    await tester.pump();
    expect(find.text(SignUpScreen.badEmailMessage), findsOneWidget);
  });

  testWidgets('a taken email offers Log in instead', (tester) async {
    await _open(tester);
    await _fill(tester, email: FakeAuthService.demoAccounts.keys.first);
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Create account'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining(SignUpScreen.emailTakenMessage, findRichText: true),
      findsOneWidget,
    );

    await tester.ensureVisible(
      find.textContaining(SignUpScreen.emailTakenMessage, findRichText: true),
    );
    await tester.tapOnText(find.textRange.ofSubstring('Log in instead'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('a valid form creates the account and opens the inbox screen', (
    tester,
  ) async {
    await _open(tester);
    await _fill(tester);
    await tester.ensureVisible(
      find.widgetWithText(FilledButton, 'Create account'),
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
    await tester.pumpAndSettle();
    expect(find.byType(CheckInboxScreen), findsOneWidget);
  });

  testWidgets('community rules sheet can agree for you', (tester) async {
    await _open(tester);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tapOnText(find.textRange.ofSubstring('community rules'));
    await tester.pumpAndSettle();
    expect(find.text('Community rules'), findsOneWidget);
    await tester.tap(find.text('I agree'));
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('fits a small phone without overflow', (tester) async {
    await _open(tester, size: const Size(320, 568));
    await _fill(tester, repeat: 'other1234');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
