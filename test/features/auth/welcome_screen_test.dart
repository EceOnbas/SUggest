import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/app.dart';
import 'package:suggest/core/art/sakura_branch.dart';
import 'package:suggest/features/auth/login_screen.dart';
import 'package:suggest/features/auth/sign_up_screen.dart';
import 'package:suggest/features/auth/welcome_screen.dart';
import 'package:suggest/services/fake_auth_service.dart';

Future<void> _open(WidgetTester tester, {Size size = const Size(390, 844)}) {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    SUggestApp(auth: FakeAuthService(delay: Duration.zero)),
  );
}

void main() {
  testWidgets('shows the promise, both actions and the domain note', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text('Know the course before you register.'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('For @sabanciuniv.edu accounts only.'), findsOneWidget);
  });

  testWidgets('without the photo the sakura branch stays', (tester) async {
    // Tests have no internet, so the photo fails like it would offline.
    await _open(tester);
    await tester.pumpAndSettle();
    expect(find.byType(SakuraBranch), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Create account and Log in open their screens', (tester) async {
    await _open(tester);
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Log in'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('fits a small phone without overflow', (tester) async {
    await _open(tester, size: const Size(320, 568));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(WelcomeScreen), findsOneWidget);
  });

  testWidgets('fits with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _open(tester, size: const Size(375, 667));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
