import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/routes/app_routes.dart';
import 'package:suggest/features/profile/my_courses_screen.dart';
import 'package:suggest/features/profile/widgets/my_review_card.dart';
import 'package:suggest/features/profile/write_review_screen.dart';
import 'package:suggest/models/user_profile.dart';

import 'profile_test_utils.dart';

const _cs310 = 'CS 310 · Mobile Application Development';
const _cs300 = 'CS 300 · Data Structures';
const _cs201 = 'CS 201 · Introduction to Computing';
const _cs408 = 'CS 408 · Computer Networks';

Future<void> _openMyCourses(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  double textScale = 1,
}) async {
  await openProfile(tester, size: size, textScale: textScale);
  await tapOn(tester, manageCoursesLink);
  expect(find.byType(MyCoursesScreen), findsOneWidget);
}

Future<void> _typeCourse(WidgetTester tester, String text) async {
  await tester.enterText(fieldLabelled('Course'), text);
  await tester.pumpAndSettle();
}

void main() {
  group('the course list', () {
    testWidgets('is grouped by term, newest first', (tester) async {
      await _openMyCourses(tester);
      expect(find.text('6 courses · 4 not reviewed yet'), findsOneWidget);
      final fall25 = find.text('Fall 2025  ·  3 courses');
      final spring25 = find.text('Spring 2025  ·  2 courses');
      final fall24 = find.text('Fall 2024  ·  1 course');
      for (final heading in [fall25, spring25, fall24]) {
        await tester.ensureVisible(heading);
        expect(heading, findsOneWidget);
      }
      // Headings are far apart, so compare their place in the list.
      final order = [
        for (final heading in [fall25, spring25, fall24])
          tester.getTopLeft(heading).dy +
              tester
                  .state<ScrollableState>(find.byType(Scrollable).first)
                  .position
                  .pixels,
      ];
      expect(order, [...order]..sort());
    });

    testWidgets('reviewed courses open their review', (tester) async {
      await _openMyCourses(tester);
      expect(inCourseTile(_cs310, find.text('Reviewed')), findsOneWidget);
      expect(inCourseTile(_cs300, find.text('Write review')), findsOneWidget);

      await tapOn(tester, inCourseTile(_cs310, find.text('Reviewed')));
      expect(find.text('My review of CS 310'), findsOneWidget);
      expect(find.byType(MyReviewCard), findsOneWidget);
      expect(find.text('Edit Review'), findsOneWidget);
    });

    testWidgets('editing from the review sheet opens the review', (
      tester,
    ) async {
      await _openMyCourses(tester);
      await tapOn(tester, inCourseTile(_cs310, find.text('Reviewed')));
      await tapText(tester, 'Edit Review');
      expect(find.byType(WriteReviewScreen), findsOneWidget);
      expect(find.text('Edit Review'), findsOneWidget);
    });

    testWidgets('"Write review" opens the form with the course filled in', (
      tester,
    ) async {
      await _openMyCourses(tester);
      await tapOn(tester, inCourseTile(_cs300, find.text('Write review')));
      expect(find.byType(WriteReviewScreen), findsOneWidget);
      expect(find.text('Write Review'), findsOneWidget);
      expect(lockedValue(tester, 'Term Taken'), 'Fall 2025');
      expect(lockedValue(tester, 'Instructor'), 'Instructor B');
    });
  });

  group('removing', () {
    testWidgets('a course without a review asks, then goes', (tester) async {
      final auth = await openProfile(tester);
      await tapOn(tester, manageCoursesLink);
      await tapOn(tester, find.byTooltip('Remove CS 201'));
      expect(find.text('Remove CS 201?'), findsOneWidget);
      await tapText(tester, 'Cancel');
      expect(find.text(_cs201), findsOneWidget);

      await tapOn(tester, find.byTooltip('Remove CS 201'));
      await tapText(tester, 'Remove');
      expect(find.text(_cs201), findsNothing);
      expect(find.text('CS 201 removed from My Courses.'), findsOneWidget);
      expect(find.text('Fall 2024  ·  1 course'), findsNothing);
      expect(auth.profile!.coursesTaken, hasLength(5));
    });

    testWidgets('a reviewed course asks to delete the review first', (
      tester,
    ) async {
      final auth = await openProfile(tester);
      await tapOn(tester, manageCoursesLink);
      await tapOn(tester, find.byTooltip('Remove CS 310'));
      expect(find.text('Delete the review first'), findsOneWidget);
      await tapText(tester, 'Open review');
      expect(find.text('My review of CS 310'), findsOneWidget);
      expect(auth.profile!.coursesTaken, hasLength(6));
    });
  });

  group('adding', () {
    testWidgets('a course from the pool is added under its term', (
      tester,
    ) async {
      final auth = await openProfile(tester);
      await tapOn(tester, manageCoursesLink);
      await _typeCourse(tester, 'networks');
      await tapText(tester, _cs408);
      await pickFromDropdown(tester, 'Term Taken', 'Spring 2026');
      await pickFromDropdown(tester, 'Instructor', 'Instructor C');
      await tapText(tester, 'Add Course');

      expect(find.text('CS 408 added to My Courses.'), findsOneWidget);
      expect(find.text('Spring 2026  ·  1 course'), findsOneWidget);
      expect(inCourseTile(_cs408, find.text('Instructor C')), findsOneWidget);
      expect(find.text('7 courses · 5 not reviewed yet'), findsOneWidget);
      final added = auth.profile!.coursesTaken.last;
      expect(added.courseName, 'CS 408 Computer Networks');
      expect(added.term, 'Spring 2026');
      expect(added.instructor, 'Instructor C');
      // The form is empty again.
      expect(
        tester.widget<TextField>(fieldLabelled('Course')).controller!.text,
        isEmpty,
      );
    });

    testWidgets('each field is required', (tester) async {
      await _openMyCourses(tester);
      await tapText(tester, 'Add Course');
      expect(
        find.text(
          'Choose a course from the course list. Only listed courses can '
          'be added.',
        ),
        findsOneWidget,
      );
      expect(find.text('Pick the term you took it.'), findsOneWidget);
      expect(find.text('Pick the instructor.'), findsOneWidget);
    });

    testWidgets('a course outside the pool cannot be added', (tester) async {
      final auth = await openProfile(tester);
      await tapOn(tester, manageCoursesLink);
      await _typeCourse(tester, 'PHYS 999');
      await pickFromDropdown(tester, 'Term Taken', 'Fall 2024');
      await pickFromDropdown(tester, 'Instructor', 'Instructor A');
      await tapText(tester, 'Add Course');
      expect(
        find.textContaining('Only listed courses can be added.'),
        findsOneWidget,
      );
      expect(auth.profile!.coursesTaken, hasLength(6));
    });

    testWidgets('courses already taken are not suggested', (tester) async {
      await _openMyCourses(tester);
      await _typeCourse(tester, 'cs 3');
      // Only the card in the list shows CS 310; no retakes are offered.
      expect(find.text(_cs310), findsOneWidget);
      expect(find.text(_cs300), findsOneWidget);
    });

    testWidgets('only finished terms since the start term are offered', (
      tester,
    ) async {
      await _openMyCourses(tester);
      await tapOn(tester, find.byType(DropdownButton<String>).first);
      for (final term in [
        'Spring 2026',
        'Fall 2025',
        'Spring 2025',
        'Fall 2024',
      ]) {
        expect(find.text(term), findsWidgets);
      }
      expect(find.text('Fall 2026'), findsNothing);
      expect(find.text('Spring 2024'), findsNothing);
    });

    testWidgets('a first-term student has no finished terms yet', (
      tester,
    ) async {
      await openProfile(
        tester,
        profile: const UserProfile(
          major: 'Economics',
          classYear: '1',
          currentTerm: 'Fall 2026',
          startTerm: 'Fall 2026',
        ),
      );
      await tapText(tester, '+ Add Courses');
      expect(find.text('No courses yet'), findsOneWidget);
      expect(find.text('No finished terms yet'), findsOneWidget);
      expect(
        find.text('Courses can be added once their term is over.'),
        findsOneWidget,
      );
    });
  });

  group('from a course page', () {
    testWidgets('a reviewed course opens the review for editing', (
      tester,
    ) async {
      await openProfile(tester);
      await pushRoute(tester, AppRoutes.writeReview, arguments: 'CS 310');
      expect(find.text('Edit Review'), findsOneWidget);
      expect(find.text('Fairly hard (4)'), findsOneWidget);
    });

    testWidgets('a taken course opens the form filled in', (tester) async {
      await openProfile(tester);
      await pushRoute(tester, AppRoutes.writeReview, arguments: 'CS 300');
      expect(find.text('Write Review'), findsOneWidget);
      expect(lockedValue(tester, 'Term Taken'), 'Fall 2025');
    });

    testWidgets('a course not taken is added first, then reviewed', (
      tester,
    ) async {
      final auth = await openProfile(tester);
      await pushRoute(tester, AppRoutes.writeReview, arguments: 'CS 408');
      expect(find.text('Add CS 408 to My Courses first'), findsOneWidget);

      await tapText(tester, 'Add CS 408 to My Courses');
      expect(find.byType(MyCoursesScreen), findsOneWidget);
      expect(
        tester.widget<TextField>(fieldLabelled('Course')).controller!.text,
        _cs408,
      );
      await pickFromDropdown(tester, 'Term Taken', 'Spring 2026');
      await pickFromDropdown(tester, 'Instructor', 'Instructor A');
      await tapText(tester, 'Add Course');

      // Back on the form, with the new course picked.
      expect(find.byType(MyCoursesScreen), findsNothing);
      expect(find.text('Write Review'), findsOneWidget);
      expect(lockedValue(tester, 'Term Taken'), 'Spring 2026');
      expect(lockedValue(tester, 'Instructor'), 'Instructor A');
      expect(auth.profile!.coursesTaken, hasLength(7));
    });
  });

  group('screen sizes with large text', () {
    for (final size in const [Size(320, 568), Size(430, 932)]) {
      final name = '${size.width.toInt()}×${size.height.toInt()}';

      testWidgets('My Courses with errors fits $name', (tester) async {
        await _openMyCourses(tester, size: size, textScale: 1.6);
        await tapText(tester, 'Add Course');
        await tester.ensureVisible(find.text('Fall 2025  ·  3 courses'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('the review sheet fits $name', (tester) async {
        await _openMyCourses(tester, size: size, textScale: 1.6);
        await tapOn(tester, inCourseTile(_cs310, find.text('Reviewed')));
        expect(tester.takeException(), isNull);
      });

      testWidgets('the "add it first" screen fits $name', (tester) async {
        await openProfile(tester, size: size, textScale: 1.6);
        await pushRoute(tester, AppRoutes.writeReview, arguments: 'CS 408');
        expect(tester.takeException(), isNull);
      });

      testWidgets('My Profile fits $name', (tester) async {
        await openProfile(tester, size: size, textScale: 1.6);
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
