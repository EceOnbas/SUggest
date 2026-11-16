import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/routes/app_routes.dart';
import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/features/auth/forgot_password_screen.dart';
import 'package:suggest/features/auth/login_screen.dart';
import 'package:suggest/features/auth/reset_link_sent_screen.dart';
import 'package:suggest/services/auth_service.dart';
import 'package:suggest/services/fake_auth_service.dart';

/// Opens Log in, then Forgot password on top of it, like a real user.
Future<void> _open(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
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
  await tester.ensureVisible(find.text('Forgot password?'));
  await tester.tap(find.text('Forgot password?'));
  await tester.pumpAndSettle();
}

FilledButton _send(WidgetTester tester) =>
    tester.widget(find.widgetWithText(FilledButton, 'Send reset link'));

Future<void> _sendLink(WidgetTester tester, String name) async {
  await tester.enterText(find.byType(TextField), name);
  await tester.pump();
  await tester.ensureVisible(find.text('Send reset link'));
  await tester.tap(find.text('Send reset link'));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('Send reset link stays faded until an email is typed', (
    tester,
  ) async {
    await _open(tester);
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(_send(tester).enabled, isFalse);
    await tester.enterText(find.byType(TextField), 'beren.guler');
    await tester.pump();
    expect(_send(tester).enabled, isTrue);
  });

  testWidgets('the sent screen never says whether the account exists', (
    tester,
  ) async {
    await _open(tester);
    await _sendLink(tester, 'nobody.here');
    expect(find.byType(ResetLinkSentScreen), findsOneWidget);
    expect(
      find.textContaining(
        'If nobody.here@sabanciuniv.edu has an account',
        findRichText: true,
      ),
      findsOneWidget,
    );
    for (final step in ResetLinkSentScreen.steps) {
      expect(find.text(step), findsOneWidget);
    }
    expect(find.textContaining('Resend link in 0:5'), findsOneWidget);
  });

  testWidgets('Back to log in returns to the Log in screen', (tester) async {
    await _open(tester);
    await _sendLink(tester, 'beren.guler');
    await tester.ensureVisible(find.text('Back to log in'));
    await tester.tap(find.text('Back to log in'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ResetLinkSentScreen), findsNothing);
    expect(find.byType(ForgotPasswordScreen), findsNothing);
  });

  testWidgets('both screens fit a small phone with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _open(tester, size: const Size(320, 568));
    expect(tester.takeException(), isNull);
    await _sendLink(tester, 'beren.guler');
    expect(tester.takeException(), isNull);
  });
}
