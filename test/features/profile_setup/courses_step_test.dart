import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/services/fake_auth_service.dart';

import 'setup_flow_test.dart';

Future<FakeAuthService> _openCourses(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  final auth = await openSetup(tester, size: size);
  await tapText(tester, 'Start');
  await tapText(tester, 'Skip this step');
  await tapText(tester, 'Skip this step');
  expect(find.text("Courses you've taken"), findsOneWidget);
  return auth;
}

/// Opens the dropdown under [label] and picks [option].
Future<void> _pick(WidgetTester tester, String label, String option) async {
  final field = find.descendant(
    of: find
        .ancestor(of: find.text(label), matching: find.byType(Column))
        .first,
    matching: find.byType(DropdownButton<String>),
  );
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

Future<void> _add(
  WidgetTester tester, {
  String course = 'CS 204 Advanced Programming',
  String term = 'Fall 2025',
  String instructor = 'Instructor A',
}) async {
  await _pick(tester, 'Course', course);
  await _pick(tester, 'Term', term);
  await _pick(tester, 'Instructor', instructor);
  await tapText(tester, 'Add course');
}

void main() {
  testWidgets('Add course with gaps shows an error under each field', (
    tester,
  ) async {
    await _openCourses(tester);
    await tapText(tester, 'Add course');
    expect(find.text('Choose a course.'), findsOneWidget);
    expect(find.text('Pick a term.'), findsOneWidget);
    expect(find.text('Pick an instructor.'), findsOneWidget);
    expect(find.text('Added (0)'), findsOneWidget);

    // Fixing one field clears only its error.
    await _pick(tester, 'Term', 'Fall 2025');
    expect(find.text('Pick a term.'), findsNothing);
    expect(find.text('Choose a course.'), findsOneWidget);
  });

  testWidgets('a valid course becomes a card and the form clears', (
    tester,
  ) async {
    await _openCourses(tester);
    expect(find.textContaining('No courses yet.'), findsOneWidget);
    await _add(tester);
    expect(find.text('Added (1)'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2)); // the form + one course
    expect(find.text('CS 204 Advanced Programming'), findsOneWidget);
    expect(find.text('Fall 2025, Instructor A'), findsOneWidget);
    expect(find.text('Choose a course'), findsOneWidget);
    expect(find.textContaining('No courses yet.'), findsNothing);
  });

  testWidgets('the same course cannot be added twice', (tester) async {
    await _openCourses(tester);
    await _add(tester);
    await _add(tester, term: 'Spring 2025');
    expect(find.text('This course is already added.'), findsOneWidget);
    expect(find.text('Added (1)'), findsOneWidget);
  });

  testWidgets('the remove button takes a card off the list', (tester) async {
    await _openCourses(tester);
    await _add(tester);
    await _add(tester, course: 'MATH 201 Linear Algebra');
    expect(find.text('Added (2)'), findsOneWidget);

    final remove = find.byTooltip('Remove CS 204 Advanced Programming');
    await tester.ensureVisible(remove);
    await tester.tap(remove);
    await tester.pumpAndSettle();
    expect(find.text('Added (1)'), findsOneWidget);
    expect(find.text('CS 204 Advanced Programming'), findsNothing);
    expect(find.text('MATH 201 Linear Algebra'), findsOneWidget);
  });

  testWidgets('Continue asks to confirm; Go back stays, Save moves on', (
    tester,
  ) async {
    final auth = await _openCourses(tester);
    await _add(tester);
    await tapText(tester, 'Continue');
    expect(find.text('Save 1 course?'), findsOneWidget);
    await tapText(tester, 'Go back');
    expect(find.text('Save 1 course?'), findsNothing);
    expect(find.text('Step 3 of 4'), findsOneWidget);

    await _add(tester, course: 'CS 300 Data Structures');
    await tapText(tester, 'Continue');
    expect(find.text('Save 2 courses?'), findsOneWidget);
    await tapText(tester, 'Save');
    expect(find.text('Step 4 of 4'), findsOneWidget);

    while (auth.profile == null) {
      await tapText(
        tester,
        find.text('Skip this step').evaluate().isNotEmpty
            ? 'Skip this step'
            : 'Start exploring',
      );
    }
    expect(auth.profile!.coursesTaken.map((c) => c.courseName), [
      'CS 204 Advanced Programming',
      'CS 300 Data Structures',
    ]);
  });

  testWidgets('Continue with no courses moves on without asking', (
    tester,
  ) async {
    await _openCourses(tester);
    await tapText(tester, 'Continue');
    expect(find.textContaining('Save '), findsNothing);
    expect(find.text('Step 4 of 4'), findsOneWidget);
  });

  testWidgets('fits a small phone with large text, errors and a dialog', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _openCourses(tester, size: const Size(320, 568));
    await tapText(tester, 'Add course');
    expect(tester.takeException(), isNull);
    await _add(tester);
    await tapText(tester, 'Continue');
    expect(find.text('Save 1 course?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
