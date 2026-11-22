import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/app.dart';
import 'package:suggest/core/widgets/app_back_button.dart';
import 'package:suggest/core/widgets/step_progress_bar.dart';
import 'package:suggest/features/profile_setup/profile_intro_screen.dart';
import 'package:suggest/features/shell/main_shell.dart';
import 'package:suggest/services/auth_service.dart';
import 'package:suggest/services/fake_auth_service.dart';

/// Opens the app signed in with the demo account, which has no profile.
Future<FakeAuthService> openSetup(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final auth = FakeAuthService(delay: Duration.zero);
  final name = FakeAuthService.demoAccounts.keys.first;
  await auth.logIn(
    localPart: name,
    password: FakeAuthService.demoAccounts[name]!,
  );
  await tester.pumpWidget(SUggestApp(auth: auth));
  await tester.pumpAndSettle();
  return auth;
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('intro explains privacy and time', (tester) async {
    await openSetup(tester);
    expect(find.byType(ProfileIntroScreen), findsOneWidget);
    expect(find.text('Set up your private profile'), findsOneWidget);
    expect(
      find.textContaining('Only your handle is public.', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('About two minutes.', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('Start opens step 1 and back returns to the intro', (
    tester,
  ) async {
    await openSetup(tester);
    await tapText(tester, 'Start');
    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(
      tester.widget<StepProgressBar>(find.byType(StepProgressBar)).step,
      1,
    );
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileIntroScreen), findsOneWidget);
  });

  testWidgets('Skip for now saves an empty profile and opens Home', (
    tester,
  ) async {
    final auth = await openSetup(tester);
    await tapText(tester, 'Skip for now');
    expect(auth.status, AuthStatus.ready);
    expect(auth.profile!.major, isNull);
    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('intro fits a small phone with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openSetup(tester, size: const Size(320, 568));
    expect(tester.takeException(), isNull);
  });
}
