import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/art/onigiri.dart';
import 'package:suggest/features/profile_setup/all_set_screen.dart';
import 'package:suggest/features/shell/main_shell.dart';
import 'package:suggest/models/user_profile.dart';
import 'package:suggest/services/auth_service.dart';
import 'package:suggest/services/fake_auth_service.dart';

import 'setup_flow_test.dart';

Future<FakeAuthService> _openExchange(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  final auth = await openSetup(tester, size: size);
  await tapText(tester, 'Start');
  for (var i = 0; i < 3; i++) {
    await tapText(tester, 'Skip this step');
  }
  expect(find.text('Have you been on exchange?'), findsOneWidget);
  return auth;
}

Future<void> _pick(WidgetTester tester, String hint, String option) async {
  await tapText(tester, hint);
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('"Not yet" finishes with no exchange', (tester) async {
    final auth = await _openExchange(tester);
    expect(find.textContaining('No problem.'), findsOneWidget);
    await tapText(tester, 'Finish');
    expect(find.byType(AllSetScreen), findsOneWidget);
    await tapText(tester, 'Start exploring');
    expect(auth.status, AuthStatus.ready);
    expect(auth.profile!.exchange, isNull);
    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('"Yes" needs a host university and a term', (tester) async {
    await _openExchange(tester);
    await tapText(tester, 'Yes');
    await tapText(tester, 'Finish');
    expect(find.text('Choose your host university.'), findsOneWidget);
    expect(find.text('Pick a term.'), findsOneWidget);
    expect(find.byType(AllSetScreen), findsNothing);
  });

  testWidgets('"Yes" saves host, term and program', (tester) async {
    final auth = await _openExchange(tester);
    await tapText(tester, 'Yes');
    await _pick(tester, 'Choose a university', 'KU Leuven, Belgium');
    await _pick(tester, 'Choose a term', 'Spring 2026');
    await tapText(tester, 'Bilateral');
    await tapText(tester, 'Finish');

    expect(find.byType(AllSetScreen), findsOneWidget);
    expect(find.text("You're all set"), findsOneWidget);
    expect(tester.widget<Onigiri>(find.byType(Onigiri)).pose, OnigiriPose.done);

    await tapText(tester, 'Start exploring');
    final exchange = auth.profile!.exchange!;
    expect(exchange.hostUniversity, 'KU Leuven, Belgium');
    expect(exchange.term, 'Spring 2026');
    expect(exchange.program, ExchangeProgram.bilateral);
  });

  testWidgets('both screens fit a small phone with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _openExchange(tester, size: const Size(320, 568));
    await tapText(tester, 'Yes');
    await tapText(tester, 'Finish');
    expect(tester.takeException(), isNull);
    await tapText(tester, 'Not yet');
    await tapText(tester, 'Finish');
    expect(find.byType(AllSetScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
