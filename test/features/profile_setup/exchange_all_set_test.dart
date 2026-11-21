import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/art/onigiri.dart';
import 'package:suggest/core/widgets/app_chip.dart';
import 'package:suggest/features/profile_setup/all_set_screen.dart';
import 'package:suggest/features/profile_setup/exchange_step.dart';
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
  expect(find.text(ExchangeStep.title), findsOneWidget);
  return auth;
}

/// Taps the program chip, for example "Erasmus".
Future<void> _tickProgram(WidgetTester tester, String program) async {
  final chip = find.widgetWithText(AppChip, program);
  await tester.ensureVisible(chip);
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

/// Opens the first dropdown still showing [hint] and picks [option].
Future<void> _pick(WidgetTester tester, String hint, String option) async {
  final field = find
      .ancestor(
        of: find.text(hint).first,
        matching: find.byType(DropdownButton<String>),
      )
      .first;
  // Mid-screen, so the Finish bar does not cover it.
  await Scrollable.ensureVisible(tester.element(field), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(field);
  await tester.pumpAndSettle();
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
    expect(auth.profile!.exchanges, isEmpty);
    expect(find.byType(MainShell), findsOneWidget);
  });

  testWidgets('"Yes" needs a program', (tester) async {
    await _openExchange(tester);
    await tapText(tester, 'Yes');
    expect(find.text('Choose a university'), findsNothing);
    await tapText(tester, 'Finish');
    expect(find.text(ExchangeStep.noProgramMessage), findsOneWidget);
    expect(find.byType(AllSetScreen), findsNothing);
  });

  testWidgets('a picked program needs a host university and a term', (
    tester,
  ) async {
    await _openExchange(tester);
    await tapText(tester, 'Yes');
    await _tickProgram(tester, 'Erasmus');
    await tapText(tester, 'Finish');
    expect(find.text('Choose your host university.'), findsOneWidget);
    expect(find.text('Pick a term.'), findsOneWidget);
    expect(find.byType(AllSetScreen), findsNothing);
  });

  testWidgets('Erasmus lists only European partners', (tester) async {
    await _openExchange(tester);
    await tapText(tester, 'Yes');
    await _tickProgram(tester, 'Erasmus');
    await tester.tap(
      find.ancestor(
        of: find.text('Choose a university'),
        matching: find.byType(DropdownButton<String>),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('KU Leuven, Belgium').hitTestable(), findsWidgets);
    expect(find.text('National University of Singapore'), findsNothing);
  });

  testWidgets('"Yes" saves both an Erasmus and an Exchange', (tester) async {
    final auth = await _openExchange(tester);
    await tapText(tester, 'Yes');
    await _tickProgram(tester, 'Erasmus');
    await _tickProgram(tester, 'Exchange');
    await _pick(tester, 'Choose a university', 'KU Leuven, Belgium');
    await _pick(tester, 'Choose a term', 'Fall 2025');
    await _pick(
      tester,
      'Choose a university',
      'National University of Singapore',
    );
    await _pick(tester, 'Choose a term', 'Spring 2026');
    await tapText(tester, 'Finish');

    expect(find.byType(AllSetScreen), findsOneWidget);
    expect(find.text("You're all set"), findsOneWidget);
    expect(tester.widget<Onigiri>(find.byType(Onigiri)).pose, OnigiriPose.done);

    await tapText(tester, 'Start exploring');
    final profile = auth.profile!;
    expect(profile.exchanges, hasLength(2));
    final erasmus = profile.exchangeFor(ExchangeProgram.erasmus)!;
    expect(erasmus.hostUniversity, 'KU Leuven, Belgium');
    expect(erasmus.term, 'Fall 2025');
    final exchange = profile.exchangeFor(ExchangeProgram.exchange)!;
    expect(exchange.hostUniversity, 'National University of Singapore');
    expect(exchange.term, 'Spring 2026');
  });

  testWidgets('both screens fit a small phone with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _openExchange(tester, size: const Size(320, 568));
    await tapText(tester, 'Yes');
    await _tickProgram(tester, 'Erasmus');
    await _tickProgram(tester, 'Exchange');
    await tapText(tester, 'Finish');
    expect(tester.takeException(), isNull);
    await tapText(tester, 'Not yet');
    await tapText(tester, 'Finish');
    expect(find.byType(AllSetScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exchange terms start at the start term', (tester) async {
    await openSetup(tester);
    await tapText(tester, 'Start');
    await tapText(tester, 'Skip this step');
    await tapText(tester, '3');
    await _pick(tester, 'Choose a term', 'Spring 2026');
    await tapText(tester, 'Continue');
    await tapText(tester, 'Skip this step');
    expect(find.text(ExchangeStep.title), findsOneWidget);
    await tapText(tester, 'Yes');
    await _tickProgram(tester, 'Erasmus');
    await tester.tap(
      find.ancestor(
        of: find.text('Choose a term'),
        matching: find.byType(DropdownButton<String>),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Spring 2026').hitTestable(), findsWidgets);
    expect(find.text('Fall 2025'), findsNothing);
  });
}
