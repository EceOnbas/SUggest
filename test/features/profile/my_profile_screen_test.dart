import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/features/profile/edit_academic_screen.dart';
import 'package:suggest/features/profile/models/my_review.dart';
import 'package:suggest/features/profile/my_courses_screen.dart';
import 'package:suggest/features/profile/my_profile_store.dart';
import 'package:suggest/features/profile/widgets/my_review_card.dart';
import 'package:suggest/features/profile/widgets/profile_widgets.dart';
import 'package:suggest/features/profile/write_review_screen.dart';
import 'package:suggest/models/review_topic.dart';
import 'package:suggest/models/user_profile.dart';
import 'package:suggest/services/auth_service.dart';
import 'package:suggest/services/fake_auth_service.dart';

import 'profile_test_utils.dart';

const _cs310 = 'CS 310 · Mobile Application Development';
const _math201 = 'MATH 201 · Linear Algebra';
const _cs300 = 'CS 300 · Data Structures';

/// The [value] shown under [label] in the account card ('—' when empty).
Finder _rowValue(String label, [String value = '—']) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(InfoRow)),
  matching: find.text(value),
);

void main() {
  group('My Profile', () {
    testWidgets('the showcase account shows a full profile', (tester) async {
      await openProfile(tester);
      expect(find.text('My Profile'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Log out'), findsOneWidget);
      expect(find.text('Deniz Yılmaz'), findsOneWidget);
      expect(find.text('@bosphorus_coder'), findsOneWidget);
      // The institutional email is the signed-in account's.
      expect(find.text('deniz.yilmaz@sabanciuniv.edu'), findsOneWidget);
      expect(find.text('Computer Science and Engineering'), findsOneWidget);
      expect(find.text('Industrial Engineering'), findsOneWidget);
      expect(find.text('3rd Year Student'), findsOneWidget);
      expect(find.text('Current term: Fall 2026'), findsOneWidget);
      expect(find.text('Started in Fall 2024'), findsOneWidget);
      expect(find.text('National University of Singapore'), findsOneWidget);
      expect(find.text('+ Add Minor'), findsOneWidget);
      expect(find.text('+ Add Erasmus University'), findsOneWidget);
      expect(find.text('+ Add Double Major'), findsNothing);
      expect(find.text('6 courses · 4 not reviewed yet'), findsOneWidget);
      expect(find.text('Most Recent Term: Fall 2025'), findsOneWidget);
      expect(find.byType(MyReviewCard), findsNWidgets(2));
      expect(find.text('Posted as @bosphorus_coder'), findsNWidgets(2));
    });

    testWidgets('a new account starts empty', (tester) async {
      await openProfile(tester, showcase: false);
      // Empty contact rows all show a dash, like Backup Email.
      for (final label in ['Full Name', 'Backup Email', 'Phone Number']) {
        expect(_rowValue(label), findsOneWidget);
      }
      expect(find.text('+ Add Full Name'), findsNothing);
      expect(find.text('@campus_sakura'), findsOneWidget);
      expect(find.text('demo.student@sabanciuniv.edu'), findsOneWidget);
      expect(
        find.text('Add the courses you finished to review them.'),
        findsOneWidget,
      );
      expect(find.text('+ Add Courses'), findsOneWidget);
      expect(find.text('No reviews yet'), findsOneWidget);
      expect(find.byType(MyReviewCard), findsNothing);
    });

    testWidgets('an empty full name is added from Edit', (tester) async {
      await openProfile(tester, showcase: false);
      await tapOn(tester, editAccountLink);
      await tester.enterText(fieldLabelled('Full Name (optional)'), 'Ada Kaya');
      await tapText(tester, 'Save Changes');
      expect(_rowValue('Full Name', 'Ada Kaya'), findsOneWidget);
    });

    testWidgets('the academic card follows the profile setup answers', (
      tester,
    ) async {
      await openProfile(
        tester,
        profile: const UserProfile(major: 'Economics', classYear: '1'),
      );
      expect(find.text('Economics'), findsOneWidget);
      expect(find.text('1st Year Student'), findsOneWidget);
      for (final label in [
        'Double Major',
        'Minor',
        'Erasmus University',
        'Exchange University',
      ]) {
        expect(find.text('+ Add $label'), findsOneWidget);
      }
    });

    testWidgets('the privacy note opens and closes', (tester) async {
      await openProfile(tester);
      expect(find.textContaining('Only your handle'), findsNothing);
      await tapText(tester, 'Your privacy is our priority.');
      expect(find.textContaining('Only your handle'), findsOneWidget);
      await tapText(tester, 'Your privacy is our priority.');
      expect(find.textContaining('Only your handle'), findsNothing);
    });

    testWidgets('reviews are newest first, counting edits', (tester) async {
      await openProfile(tester);
      // MATH 201 was edited after CS 310 was posted.
      final first = tester.getTopLeft(inReviews(_math201));
      final second = tester.getTopLeft(inReviews(_cs310));
      expect(first.dy, lessThan(second.dy));
    });

    testWidgets('Manage and Settings open My Courses', (tester) async {
      await openProfile(tester);
      await tapOn(tester, manageCoursesLink);
      expect(find.byType(MyCoursesScreen), findsOneWidget);
      await tapOn(tester, find.byTooltip('Back'));
      expect(find.byType(MyCoursesScreen), findsNothing);

      await tapOn(tester, find.byTooltip('Settings'));
      await tapText(tester, 'My Courses');
      expect(find.byType(MyCoursesScreen), findsOneWidget);
    });
  });

  group('search', () {
    testWidgets('filters by course, term or instructor and clears', (
      tester,
    ) async {
      await openProfile(tester);
      final search = fieldLabelled('Search my reviews');

      await tester.enterText(search, 'linear');
      await tester.pumpAndSettle();
      expect(find.byType(MyReviewCard), findsOneWidget);
      expect(inReviews(_math201), findsOneWidget);

      await tester.enterText(search, 'cs310');
      await tester.pumpAndSettle();
      expect(inReviews(_cs310), findsOneWidget);
      expect(find.byType(MyReviewCard), findsOneWidget);

      await tester.enterText(search, 'instructor b');
      await tester.pumpAndSettle();
      expect(inReviews(_math201), findsOneWidget);
      expect(find.byType(MyReviewCard), findsOneWidget);

      await tester.enterText(search, 'no such course');
      await tester.pumpAndSettle();
      expect(find.byType(MyReviewCard), findsNothing);
      expect(find.text('No reviews found'), findsOneWidget);

      await tapOn(tester, find.byTooltip('Clear search'));
      expect(find.byType(MyReviewCard), findsNWidgets(2));
    });
  });

  group('review card', () {
    testWidgets('show more opens ratings and actions; show less closes', (
      tester,
    ) async {
      await openProfile(tester);
      expect(find.text('Edit Review'), findsNothing);
      await tapOn(tester, find.text('...show more').first);
      expect(find.text('Edit Review'), findsOneWidget);
      expect(find.text('Delete Review'), findsOneWidget);
      expect(find.text('Instructor Quality'), findsOneWidget);
      expect(find.text('Attendance Requirement'), findsOneWidget);
      await tapText(tester, 'show less');
      expect(find.text('Edit Review'), findsNothing);
    });

    testWidgets('delete asks first; Cancel keeps, Delete removes', (
      tester,
    ) async {
      final auth = await openProfile(tester);
      await tapOn(tester, find.text('...show more').first);
      await tapText(tester, 'Delete Review');
      expect(find.text('Delete Review?'), findsOneWidget);

      await tapText(tester, 'Cancel');
      expect(find.byType(MyReviewCard), findsNWidgets(2));

      await tapText(tester, 'Delete Review');
      await tapOn(tester, find.widgetWithText(FilledButton, 'Delete'));
      expect(find.byType(MyReviewCard), findsOneWidget);
      expect(find.text('Review deleted.'), findsOneWidget);
      expect(MyProfileStore.instance.reviewsOf(auth.email!), hasLength(1));
      // The course stays in My Courses, now waiting for a review.
      expect(find.text('6 courses · 5 not reviewed yet'), findsOneWidget);
    });

    testWidgets('deleting every review shows the empty state', (tester) async {
      await openProfile(tester);
      for (var i = 0; i < 2; i++) {
        await tapOn(tester, find.text('...show more').first);
        await tapText(tester, 'Delete Review');
        await tapOn(tester, find.widgetWithText(FilledButton, 'Delete'));
        // Let the "Review deleted." toast close so it hides nothing.
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
      }
      expect(find.text('No reviews yet'), findsOneWidget);
      expect(find.text('Search my reviews'), findsNothing);
      await tapText(tester, 'Write a review');
      expect(find.byType(WriteReviewScreen), findsOneWidget);
      expect(find.text('Select one of your courses'), findsOneWidget);
    });
  });

  group('Edit Account Details', () {
    testWidgets('shows errors inline and saves valid details', (tester) async {
      final auth = await openProfile(tester);
      await tapOn(tester, editAccountLink);
      expect(find.text('Edit Account Details'), findsOneWidget);

      await tester.enterText(fieldLabelled('Full Name (optional)'), '123');
      await tester.enterText(fieldLabelled('Handle'), 'Bad Handle!');
      await tester.enterText(
        fieldLabelled('Backup Email (optional)'),
        'not-an-email',
      );
      await tester.enterText(fieldLabelled('Phone Number (optional)'), '12');
      await tapText(tester, 'Save Changes');
      expect(
        find.text('Enter your name with letters, or leave it empty.'),
        findsOneWidget,
      );
      expect(find.text(HandleRules.formatMessage), findsOneWidget);
      expect(find.text('Enter a valid backup email.'), findsOneWidget);
      expect(find.text('Enter a valid phone number.'), findsOneWidget);

      // Errors clear as the fields are fixed.
      await tester.enterText(fieldLabelled('Full Name (optional)'), 'Ada');
      await tester.pump();
      expect(
        find.text('Enter your name with letters, or leave it empty.'),
        findsNothing,
      );
      await tester.enterText(fieldLabelled('Handle'), 'ada_l');
      await tester.enterText(fieldLabelled('Backup Email (optional)'), '');
      await tester.enterText(
        fieldLabelled('Phone Number (optional)'),
        '+90 555 123 45 67',
      );
      await tapText(tester, 'Save Changes');

      expect(find.text('Edit Account Details'), findsNothing);
      expect(find.text('Ada'), findsOneWidget);
      expect(find.text('@ada_l'), findsOneWidget);
      expect(auth.handle, 'ada_l');
      expect(find.text('+90 555 123 45 67'), findsOneWidget);
      expect(find.text('—'), findsOneWidget); // empty backup email
      expect(find.text('Account details updated successfully.'), findsOne);
      // The reviews show the new handle too.
      expect(find.text('Posted as @ada_l'), findsNWidgets(2));
    });

    testWidgets('the full name can be left empty', (tester) async {
      await openProfile(tester);
      await tapOn(tester, editAccountLink);
      await tester.enterText(fieldLabelled('Full Name (optional)'), '');
      await tapText(tester, 'Save Changes');
      expect(find.text('Edit Account Details'), findsNothing);
      expect(_rowValue('Full Name'), findsOneWidget);
    });

    testWidgets("another student's handle is refused", (tester) async {
      final auth = await openProfile(tester);
      await tapOn(tester, editAccountLink);
      await tester.enterText(
        fieldLabelled('Handle'),
        FakeAuthService.takenHandles.first,
      );
      await tapText(tester, 'Save Changes');
      expect(find.text(HandleRules.takenMessage), findsOneWidget);
      expect(find.text('Edit Account Details'), findsOneWidget);
      expect(auth.handle, 'bosphorus_coder');
    });

    testWidgets('the institutional email cannot be edited', (tester) async {
      await openProfile(tester);
      await tapOn(tester, editAccountLink);
      final email = tester.widget<TextField>(
        fieldLabelled('Institutional Email'),
      );
      expect(email.enabled, isFalse);
    });
  });

  group('Edit Academic Info', () {
    testWidgets('+ Add Minor opens the editor and saves the minor', (
      tester,
    ) async {
      final auth = await openProfile(tester);
      await tapText(tester, '+ Add Minor');
      expect(find.byType(EditAcademicScreen), findsOneWidget);

      await tester.enterText(fieldLabelled('Minor (optional)'), 'Philosophy');
      await tester.pumpAndSettle();
      await tapText(tester, 'Save Changes');

      expect(find.byType(EditAcademicScreen), findsNothing);
      expect(find.text('Philosophy'), findsOneWidget);
      expect(find.text('+ Add Minor'), findsNothing);
      expect(
        find.text('Academic information updated successfully.'),
        findsOneWidget,
      );
      // Saved to the profile, and the courses are kept.
      expect(auth.profile!.minor, 'Philosophy');
      expect(auth.profile!.coursesTaken, hasLength(6));
    });

    testWidgets('only listed programs can be saved', (tester) async {
      await openProfile(tester);
      await tapText(tester, '+ Add Minor');
      await tester.enterText(fieldLabelled('Minor (optional)'), 'Juggling');
      await tester.pumpAndSettle();
      await tapText(tester, 'Save Changes');
      expect(
        find.text('Choose a program from the list, or clear the field.'),
        findsOneWidget,
      );
      expect(find.byType(EditAcademicScreen), findsOneWidget);
    });

    testWidgets('an Erasmus university needs its term', (tester) async {
      final auth = await openProfile(tester);
      await tapText(tester, '+ Add Erasmus University');
      await tester.enterText(
        fieldLabelled('Erasmus University (optional)'),
        'delft',
      );
      await tester.pumpAndSettle();
      await tapText(tester, 'TU Delft, Netherlands');
      await tapText(tester, 'Save Changes');
      expect(
        find.text('Pick the term of your Erasmus experience.'),
        findsOneWidget,
      );
      // Let the "fix the fields" toast close so it hides nothing.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await pickFromDropdown(tester, 'Erasmus Term (optional)', 'Fall 2025');
      await tapText(tester, 'Save Changes');
      expect(find.byType(EditAcademicScreen), findsNothing);
      expect(find.text('TU Delft, Netherlands'), findsOneWidget);
      final erasmus = auth.profile!.exchangeFor(ExchangeProgram.erasmus)!;
      expect(erasmus.hostUniversity, 'TU Delft, Netherlands');
      expect(erasmus.term, 'Fall 2025');
      // The Exchange from setup is kept.
      expect(auth.profile!.exchanges, hasLength(2));
    });

    testWidgets('clearing a field removes it from the profile', (tester) async {
      await openProfile(tester);
      await tapOn(tester, editAcademicLink);
      await tapOn(tester, find.byTooltip('Clear Double Major'));
      await tapText(tester, 'Save Changes');
      expect(find.text('Industrial Engineering'), findsNothing);
      expect(find.text('+ Add Double Major'), findsOneWidget);
    });

    testWidgets('the major is required', (tester) async {
      await openProfile(tester);
      await tapOn(tester, editAcademicLink);
      await tester.enterText(fieldLabelled('Primary Program (Major)'), '');
      await tester.pumpAndSettle();
      await tapText(tester, 'Save Changes');
      expect(find.text('A primary program is required.'), findsOneWidget);
      expect(find.byType(EditAcademicScreen), findsOneWidget);
    });

    testWidgets('the current term can be changed', (tester) async {
      final auth = await openProfile(tester);
      await tapOn(tester, editAcademicLink);
      await pickFromDropdown(tester, 'Current Term', 'Spring 2027');
      await tapText(tester, 'Save Changes');
      expect(find.text('Current term: Spring 2027'), findsOneWidget);
      expect(auth.profile!.currentTerm, 'Spring 2027');
    });

    testWidgets('graduated students pick a graduation year', (tester) async {
      await openProfile(tester);
      await tapOn(tester, editAcademicLink);
      expect(find.text('Class Year'), findsOneWidget);
      await tapText(tester, 'Graduated');
      expect(find.text('Class Year'), findsNothing);
      await pickFromDropdown(tester, 'Graduation Year', 'Class of 2024');
      await tapText(tester, 'Save Changes');
      expect(find.text('Graduated (Class of 2024)'), findsOneWidget);
    });

    testWidgets('exchange terms follow the start term', (tester) async {
      final auth = await openProfile(tester);
      await tapOn(tester, editAcademicLink);
      // The Exchange (Spring 2026) was before this new start term.
      await pickFromDropdown(tester, 'Start Term', 'Fall 2026');
      expect(find.text('No finished terms yet'), findsOneWidget);
      await tapText(tester, 'Save Changes');
      expect(
        find.text('Pick the term of your Exchange experience.'),
        findsOneWidget,
      );
      expect(find.byType(EditAcademicScreen), findsOneWidget);
      expect(auth.profile!.startTerm, 'Fall 2024');
    });

    testWidgets('going back keeps the old details', (tester) async {
      await openProfile(tester);
      await tapOn(tester, editAcademicLink);
      await tapText(tester, 'Graduated');
      await tapText(tester, '← Back to Profile');
      expect(find.byType(EditAcademicScreen), findsNothing);
      expect(find.text('3rd Year Student'), findsOneWidget);
    });
  });

  group('Write Review', () {
    testWidgets('the back arrow returns to My Profile', (tester) async {
      await openProfile(tester);
      await tapText(tester, '+ Write Review');
      expect(find.byTooltip('Close'), findsNothing);
      await tapOn(tester, find.byTooltip('Back'));
      expect(find.byType(WriteReviewScreen), findsNothing);
      expect(find.text('My Profile'), findsOneWidget);
    });

    testWidgets('only courses not reviewed yet are offered', (tester) async {
      await openProfile(tester);
      await tapText(tester, '+ Write Review');
      expect(find.text('Write Review'), findsOneWidget);
      expect(find.text('Not rated'), findsNWidgets(4));
      expect(lockedValue(tester, 'Term Taken'), isEmpty);

      await tapOn(tester, find.byType(DropdownButton<String>));
      for (final label in [
        _cs300,
        'CS 201 · Introduction to Computing',
        'CS 204 · Advanced Programming',
        'MATH 102 · Calculus II',
      ]) {
        expect(find.text(label), findsWidgets);
      }
      expect(find.text(_cs310), findsNothing);
      expect(find.text(_math201), findsNothing);
    });

    testWidgets('Submit with nothing filled shows the problems', (
      tester,
    ) async {
      await openProfile(tester);
      await tapText(tester, '+ Write Review');
      await tapText(tester, 'Submit');
      expect(find.text('Choose one of your courses to review.'), findsWidgets);
      expect(
        find.text('Please rate all four course criteria before submitting.'),
        findsOneWidget,
      );
      expect(find.byType(WriteReviewScreen), findsOneWidget);
    });

    testWidgets('the course fills the locked term and instructor', (
      tester,
    ) async {
      await openProfile(tester);
      await tapText(tester, '+ Write Review');
      await pickFromDropdown(tester, 'Course', 'MATH 102 · Calculus II');
      expect(lockedValue(tester, 'Term Taken'), 'Spring 2025');
      expect(lockedValue(tester, 'Instructor'), 'Instructor D');
      expect(
        tester.widget<TextField>(lockedField('Term Taken')).enabled,
        isFalse,
      );

      await pickFromDropdown(tester, 'Course', _cs300);
      expect(lockedValue(tester, 'Term Taken'), 'Fall 2025');
      expect(lockedValue(tester, 'Instructor'), 'Instructor B');
    });

    testWidgets('a full review is added to My Reviews', (tester) async {
      final auth = await openProfile(tester);
      await tapText(tester, '+ Write Review');
      await pickFromDropdown(tester, 'Course', _cs300);

      await rate(tester, ReviewTopic.difficulty, 4);
      expect(find.text('Fairly hard (4)'), findsOneWidget);
      await rate(tester, ReviewTopic.workload, 3);
      await rate(tester, ReviewTopic.instructor, 5);
      await rate(tester, ReviewTopic.attendance, 1);
      await tapText(tester, ReviewTopic.workload.label);
      expect(
        find.text('Posted as @bosphorus_coder. Your name stays private.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byType(TextField).last,
        'Weekly labs keep you on track.',
      );
      await tapText(tester, 'Submit');

      expect(find.byType(WriteReviewScreen), findsNothing);
      expect(find.text('Review submitted successfully.'), findsOneWidget);
      expect(find.byType(MyReviewCard), findsNWidgets(3));
      expect(find.text('6 courses · 3 not reviewed yet'), findsOneWidget);
      // The new review is the newest, so it comes first.
      final first = find.byType(MyReviewCard).first;
      expect(
        find.descendant(of: first, matching: find.text(_cs300)),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: first,
          matching: find.text('Fall 2025 · Instructor B'),
        ),
        findsOneWidget,
      );
      final saved = MyProfileStore.instance.reviewFor(auth.email!, 'CS 300')!;
      expect(saved.tags, [ReviewTopic.workload]);
      expect(saved.feedback, 'Weekly labs keep you on track.');
    });

    testWidgets('editing locks the course and marks the review edited', (
      tester,
    ) async {
      await openProfile(tester);
      // The CS 310 review, which was never edited.
      await tapOn(tester, find.text('...show more').last);
      await tapText(tester, 'Edit Review');

      expect(find.text('Edit Review'), findsOneWidget);
      expect(find.textContaining('locked while editing'), findsOneWidget);
      expect(
        tester
            .widget<DropdownButton<String>>(find.byType(DropdownButton<String>))
            .onChanged,
        isNull,
      );
      expect(
        find.text('Course not listed? Add it in My Courses'),
        findsNothing,
      );
      // The old ratings are already picked.
      expect(find.text('Fairly hard (4)'), findsOneWidget);

      await rate(tester, ReviewTopic.difficulty, 2);
      await tapText(tester, 'Save Changes');

      expect(find.byType(WriteReviewScreen), findsNothing);
      expect(find.text('Review changes saved successfully.'), findsOneWidget);
      final today = formatReviewDate(DateTime.now());
      expect(find.text('Edited: $today'), findsOneWidget);
      expect(find.byType(MyReviewCard), findsNWidgets(2));
    });

    testWidgets('Cancel leaves the review unchanged', (tester) async {
      await openProfile(tester);
      await tapOn(tester, find.text('...show more').last);
      await tapText(tester, 'Edit Review');
      await rate(tester, ReviewTopic.difficulty, 1);
      await tapText(tester, 'Cancel');
      expect(find.byType(WriteReviewScreen), findsNothing);
      expect(find.textContaining('Edited:'), findsOneWidget); // only MATH 201
    });

    testWidgets('with no courses it points to My Courses', (tester) async {
      await openProfile(tester, showcase: false);
      await tapText(tester, '+ Write Review');
      expect(find.text('Add a course first'), findsOneWidget);
      await tapText(tester, 'Go to My Courses');
      expect(find.byType(MyCoursesScreen), findsOneWidget);
    });

    testWidgets('"Course not listed?" opens My Courses', (tester) async {
      await openProfile(tester);
      await tapText(tester, '+ Write Review');
      await tapText(tester, 'Course not listed? Add it in My Courses');
      expect(find.byType(MyCoursesScreen), findsOneWidget);
    });
  });

  group('small phone with large text', () {
    const small = Size(320, 568);

    testWidgets('My Profile with an open review fits', (tester) async {
      await openProfile(tester, size: small, textScale: 1.6);
      await tapOn(tester, find.text('...show more').first);
      await tapText(tester, 'Your privacy is our priority.');
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty My Profile fits', (tester) async {
      await openProfile(tester, size: small, textScale: 1.6, showcase: false);
      await tapText(tester, '+ Add Courses');
      expect(tester.takeException(), isNull);
    });

    testWidgets('Edit Account Details fits with errors', (tester) async {
      await openProfile(tester, size: small, textScale: 1.6);
      await tapOn(tester, editAccountLink);
      await tester.enterText(fieldLabelled('Handle'), '');
      // Close the keyboard, as a user would before scrolling down.
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tapText(tester, 'Save Changes');
      expect(find.text('Enter a handle.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Edit Academic Info fits', (tester) async {
      await openProfile(tester, size: small, textScale: 1.6);
      await tapOn(tester, editAcademicLink);
      await tapText(tester, 'Graduated');
      expect(tester.takeException(), isNull);
    });

    testWidgets('Write Review fits with errors', (tester) async {
      await openProfile(tester, size: small, textScale: 1.6);
      await tapText(tester, '+ Write Review');
      await tapText(tester, 'Submit');
      await rate(tester, ReviewTopic.attendance, 5);
      expect(tester.takeException(), isNull);
    });
  });
}
