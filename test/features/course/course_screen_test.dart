import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/art/sakura_branch.dart';
import 'package:suggest/core/routes/app_routes.dart';
import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/data/course_repository.dart';
import 'package:suggest/features/course/course_screen.dart';
import 'package:suggest/models/course.dart';
import 'package:suggest/models/review.dart';

const _repo = MockCourseRepository(delay: Duration.zero);

/// A repository whose first call fails, like a dropped connection.
class _FlakyRepository implements CourseRepository {
  int calls = 0;

  @override
  Future<Course> fetchCourse(String code) {
    calls++;
    if (calls == 1) return Future.error(Exception('offline'));
    return _repo.fetchCourse(code);
  }

  @override
  Future<List<Review>> fetchReviews(String courseCode) =>
      _repo.fetchReviews(courseCode);
}

/// Opens the course page on a phone of the given size.
Future<void> openCourse(
  WidgetTester tester, {
  String code = 'CS 310',
  Size size = const Size(390, 844),
  double textScale = 1,
  CourseRepository repository = _repo,
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: CourseScreen(courseCode: code, repository: repository),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('header shows the code, title, credits and branch', (
    tester,
  ) async {
    await openCourse(tester);
    expect(find.text('CS 310'), findsOneWidget);
    expect(find.text('Mobile Application Development'), findsOneWidget);
    expect(find.text('3 SU credits, 6 ECTS, lecture and lab'), findsOneWidget);
    final branch = tester.widget<SakuraBranch>(find.byType(SakuraBranch));
    expect(branch.seed, 'CS 310');
    expect(branch.difficulty, 3.6);
    expect(find.text('Write a review'), findsOneWidget);
  });

  testWidgets('Overview shows ratings, about and who takes it', (tester) async {
    await openCourse(tester);
    expect(find.text('from 48 students'), findsOneWidget);
    for (final text in ['3.6', 'fairly hard', '4.0', 'good', '2.1', '4.2']) {
      expect(find.text(text), findsOneWidget);
    }
    expect(find.bySemanticsLabel('Difficulty 3.6 out of 5'), findsOneWidget);
    expect(find.text('Syllabus, Fall 2026'), findsOneWidget);
    expect(find.text('None'), findsOneWidget); // no corequisite
    expect(find.text('Computer Science 62%'), findsOneWidget);
    expect(find.text('Other 10%'), findsOneWidget);
  });

  testWidgets('a prerequisite chip opens that course', (tester) async {
    await openCourse(tester);
    await tapText(tester, 'CS 204');
    expect(find.text('Advanced Programming'), findsOneWidget);
    // CS 204 has no ratings in the placeholder data.
    expect(find.textContaining('Not enough ratings yet'), findsOneWidget);
    expect(find.text('Ratings'), findsNothing);
  });

  testWidgets('Save toggles and says so', (tester) async {
    await openCourse(tester);
    await tester.tap(find.byTooltip('Save course'));
    await tester.pump();
    expect(find.text('Course saved.'), findsOneWidget);
    expect(find.byTooltip('Remove from saved'), findsOneWidget);
  });

  testWidgets('an unknown code says the course was not found', (tester) async {
    await openCourse(tester, code: 'XX 999');
    expect(find.text('Course not found'), findsOneWidget);
    expect(find.text('XX 999 is not in the catalog.'), findsOneWidget);
  });

  testWidgets('a failed load can be tried again', (tester) async {
    final repository = _FlakyRepository();
    await openCourse(tester, repository: repository);
    expect(find.text("Couldn't load this"), findsOneWidget);
    await tapText(tester, 'Try again');
    expect(find.text('Mobile Application Development'), findsOneWidget);
    expect(repository.calls, 2);
  });

  testWidgets('the tab bar stays on screen while the page scrolls', (
    tester,
  ) async {
    await openCourse(tester);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(
      find.text('Mobile Application Development').hitTestable(),
      findsNothing,
    );
    expect(find.text('Sections').hitTestable(), findsOneWidget);
  });
}
