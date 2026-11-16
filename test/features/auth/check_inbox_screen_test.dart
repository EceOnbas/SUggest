import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/app.dart';
import 'package:suggest/features/auth/check_inbox_screen.dart';
import 'package:suggest/features/auth/sign_up_screen.dart';
import 'package:suggest/features/profile_setup/profile_intro_screen.dart';
import 'package:suggest/services/fake_auth_service.dart';

Future<FakeAuthService> _open(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final auth = FakeAuthService(delay: Duration.zero);
  await auth.createAccount(localPart: 'new.student', password: 'abcdefg1');
  await tester.pumpWidget(SUggestApp(auth: auth));
  await tester.pump();
  return auth;
}

Future<void> _tapVerified(WidgetTester tester) async {
  await tester.ensureVisible(find.text("I've verified"));
  await tester.tap(find.text("I've verified"));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('shows the address the link was sent to', (tester) async {
    await _open(tester);
    expect(
      find.textContaining('new.student@sabanciuniv.edu', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('Junk or Spam'), findsOneWidget);
  });

  testWidgets('first check says not verified, second goes on', (tester) async {
    await _open(tester);
    await _tapVerified(tester);
    expect(find.text(CheckInboxScreen.notVerifiedMessage), findsOneWidget);

    await _tapVerified(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(ProfileIntroScreen), findsOneWidget);
  });

  testWidgets('Resend counts down 60 seconds, then works again', (
    tester,
  ) async {
    await _open(tester);
    OutlinedButton resend() => tester.widget(find.byType(OutlinedButton));
    expect(find.text('Resend email in 1:00'), findsOneWidget);
    expect(resend().enabled, isFalse);

    await tester.pump(const Duration(seconds: 18));
    expect(find.text('Resend email in 0:42'), findsOneWidget);

    await tester.pump(const Duration(seconds: 42));
    expect(find.text('Resend email'), findsOneWidget);
    expect(resend().enabled, isTrue);

    await tester.ensureVisible(find.text('Resend email'));
    await tester.tap(find.text('Resend email'));
    await tester.pump();
    expect(find.text('Resend email in 1:00'), findsOneWidget);
    expect(find.text('Verification email sent.'), findsOneWidget);
    // Let the toast finish so no timer is left running.
    await tester.pump(const Duration(seconds: 61));
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('Start over signs out and opens Create account', (tester) async {
    final auth = await _open(tester);
    await tester.ensureVisible(find.text('Wrong email? Start over'));
    await tester.tap(find.text('Wrong email? Start over'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(auth.email, isNull);
    expect(find.byType(SignUpScreen), findsOneWidget);
  });

  testWidgets('fits a small phone with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _open(tester, size: const Size(320, 568));
    await _tapVerified(tester);
    expect(tester.takeException(), isNull);
  });
}
