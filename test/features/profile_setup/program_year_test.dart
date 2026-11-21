import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/widgets/app_back_button.dart';
import 'package:suggest/core/widgets/segmented_choice.dart';

import 'setup_flow_test.dart';

Future<void> _pick(WidgetTester tester, String current, String option) async {
  // Open the first dropdown that shows [current], then choose [option].
  // Tap the dropdown itself: its hint text does not take taps.
  final field = find
      .ancestor(
        of: find.text(current).first,
        matching: find.byType(DropdownButton<String>),
      )
      .first;
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('SegmentedChoice picks one option', (tester) async {
    String? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SegmentedChoice<String>(
              options: const ['Yes', 'Not yet'],
              value: picked,
              onChanged: (v) => setState(() => picked = v),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Not yet'));
    await tester.pump();
    expect(picked, 'Not yet');
  });

  testWidgets('program and year answers are saved at the end', (tester) async {
    final auth = await openSetup(tester);
    await tapText(tester, 'Start');

    expect(find.text('What do you study?'), findsOneWidget);
    await _pick(tester, 'Choose your major', 'Economics');
    await _pick(tester, 'None', 'Mathematics'); // first "None": double major
    await tapText(tester, 'Continue');

    expect(find.text('Where are you in your degree?'), findsOneWidget);
    await tapText(tester, '3');
    await _pick(tester, 'Choose a term', 'Fall 2024');
    await tapText(tester, 'Continue');
    expect(find.text('Step 3 of 4'), findsOneWidget);

    // Finish the remaining steps without answering.
    while (auth.profile == null) {
      await tapText(
        tester,
        find.text('Skip this step').evaluate().isNotEmpty
            ? 'Skip this step'
            : 'Start exploring',
      );
    }
    final profile = auth.profile!;
    expect(profile.major, 'Economics');
    expect(profile.doubleMajor, 'Mathematics');
    expect(profile.minor, isNull);
    expect(profile.classYear, '3');
    expect(profile.currentTerm, 'Fall 2026');
    expect(profile.startTerm, 'Fall 2024');
  });

  testWidgets('answers are still there after going back', (tester) async {
    await openSetup(tester);
    await tapText(tester, 'Start');
    await _pick(tester, 'Choose your major', 'Psychology');
    await tapText(tester, 'Continue');
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.text('Psychology'), findsOneWidget);
  });

  testWidgets('Skip this step leaves the answers empty', (tester) async {
    final auth = await openSetup(tester);
    await tapText(tester, 'Start');
    await _pick(tester, 'Choose your major', 'Economics');
    await tapText(tester, 'Skip this step');
    expect(find.text('Step 2 of 4'), findsOneWidget);
    while (auth.profile == null) {
      await tapText(
        tester,
        find.text('Skip this step').evaluate().isNotEmpty
            ? 'Skip this step'
            : 'Start exploring',
      );
    }
    expect(auth.profile!.major, isNull);
  });

  testWidgets('both steps fit a small phone with large text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await openSetup(tester, size: const Size(320, 568));
    await tapText(tester, 'Start');
    expect(tester.takeException(), isNull);
    await tapText(tester, 'Continue');
    expect(find.text('Step 2 of 4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
