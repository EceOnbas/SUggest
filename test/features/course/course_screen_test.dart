import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/art/sakura_branch.dart';
import 'package:suggest/core/routes/app_routes.dart';
import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/core/widgets/app_chip.dart';
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
  // Also finds text that is below the visible part of the page.
  await tester.ensureVisible(find.text(text, skipOffstage: false).first);
  await tester.pumpAndSettle();
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
}

/// Taps a topic chip, scrolling the chip row to it first.
Future<void> tapChip(WidgetTester tester, String label) async {
  final chip = find.widgetWithText(AppChip, label);
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
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
    // The share bar is drawn: four 16 px slices, widest first.
    final slices = find.descendant(
      of: find.byKey(const ValueKey('major-shares-bar')),
      matching: find.byType(DecoratedBox),
    );
    expect(slices, findsNWidgets(4));
    final sizes = [
      for (final e in slices.evaluate())
        tester.getSize(find.byWidget(e.widget)),
    ];
    expect(sizes.every((s) => s.height == 16), isTrue);
    expect(sizes.first.width, greaterThan(sizes.last.width * 5));
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

  testWidgets('Sections shows each section and its linked lab', (tester) async {
    await openCourse(tester);
    await tapText(tester, 'Sections');
    expect(find.text('Fall 2026 sections'), findsOneWidget);
    expect(find.text('Section A'), findsOneWidget);
    expect(find.text('Section B'), findsOneWidget);
    expect(
      find.text('Lecture Mon 10:40, Wed 10:40', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Lab B1 Fri 10:40', findRichText: true), findsOneWidget);
    expect(find.textContaining('CRN 10234.'), findsOneWidget);
    // The Overview is gone.
    expect(find.text('Who takes it'), findsNothing);
  });

  testWidgets('Sections lists instructor ratings by term', (tester) async {
    await openCourse(tester);
    await tapText(tester, 'Sections');
    expect(find.text('Instructor rating by term'), findsOneWidget);
    expect(find.text('Spring 2026, 12 ratings'), findsOneWidget);
    expect(find.text('Spring 2025, 7 ratings'), findsOneWidget);
    expect(find.text('3.4'), findsOneWidget);
  });

  testWidgets('a course with no sections says so', (tester) async {
    await openCourse(tester, code: 'CS 204');
    await tapText(tester, 'Sections');
    expect(find.text('No sections this term'), findsOneWidget);
  });

  group('Reviews', () {
    Future<void> openReviews(
      WidgetTester tester, {
      String code = 'CS 310',
    }) async {
      await openCourse(tester, code: code);
      await tapText(tester, code == 'CS 310' ? 'Reviews (4)' : 'Reviews (0)');
    }

    testWidgets('shows every review with its tags', (tester) async {
      await openReviews(tester);
      expect(find.text('4 shown'), findsOneWidget);
      expect(find.text('Spring 2026, Instructor A'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(4));
      expect(find.byType(TagChip), findsNWidgets(7));
    });

    testWidgets('a topic chip narrows the list', (tester) async {
      await openReviews(tester);
      await tapChip(tester, 'Difficulty');
      expect(find.text('2 shown about difficulty'), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(2));
      await tapChip(tester, 'All');
      expect(find.text('4 shown'), findsOneWidget);
    });

    testWidgets('the sheet filters by term and instructor', (tester) async {
      await openReviews(tester);
      await tapText(tester, 'Term and instructor');
      expect(find.text('Filter reviews'), findsOneWidget);
      expect(find.text('Show 4 reviews'), findsOneWidget);
      await tapText(tester, 'Fall 2025');
      expect(find.text('Show 2 reviews'), findsOneWidget);
      await tapText(tester, 'Instructor B');
      await tapText(tester, 'Show 1 review');
      expect(find.text('Filter reviews'), findsNothing);
      expect(find.text('1 shown'), findsOneWidget);
      expect(find.text('Filters (2)'), findsOneWidget);
      expect(find.text('Fall 2025, Instructor B'), findsOneWidget);
    });

    testWidgets('closing the sheet without the button changes nothing', (
      tester,
    ) async {
      await openReviews(tester);
      await tapText(tester, 'Term and instructor');
      await tapText(tester, 'Spring 2025');
      await tester.tapAt(const Offset(195, 60)); // the dark area above
      await tester.pumpAndSettle();
      expect(find.text('Filter reviews'), findsNothing);
      expect(find.text('4 shown'), findsOneWidget);
      expect(find.text('Term and instructor'), findsOneWidget);
    });

    testWidgets('filters that match nothing can be cleared', (tester) async {
      await openReviews(tester);
      await tapChip(tester, 'Instructor');
      await tapText(tester, 'Term and instructor');
      await tapText(tester, 'Spring 2025');
      await tapText(tester, 'Show 0 reviews');
      expect(find.text('No reviews match'), findsOneWidget);
      await tapText(tester, 'Clear filters');
      expect(find.text('4 shown'), findsOneWidget);
    });

    testWidgets('the filter survives a visit to another tab', (tester) async {
      await openReviews(tester);
      await tapChip(tester, 'Workload');
      await tapText(tester, 'Overview');
      await tapText(tester, 'Reviews (4)');
      expect(find.text('2 shown about workload'), findsOneWidget);
    });

    testWidgets('a course with no reviews says so', (tester) async {
      await openReviews(tester, code: 'CS 204');
      expect(find.text('No reviews yet'), findsOneWidget);
    });
  });

  group('no overflow', () {
    Future<void> visitEveryTab(WidgetTester tester) async {
      expect(tester.takeException(), isNull);
      await tapText(tester, 'Sections');
      expect(tester.takeException(), isNull);
      await tapText(tester, 'Reviews (4)');
      expect(tester.takeException(), isNull);
      await tapChip(tester, 'Attendance');
      expect(tester.takeException(), isNull);
      await tapText(tester, 'Term and instructor');
      expect(find.text('Filter reviews'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    testWidgets('on a small phone', (tester) async {
      await openCourse(tester, size: const Size(320, 568));
      await visitEveryTab(tester);
    });

    testWidgets('on a large phone', (tester) async {
      await openCourse(tester, size: const Size(430, 932));
      await visitEveryTab(tester);
    });

    testWidgets('with large text on a small phone', (tester) async {
      await openCourse(tester, size: const Size(320, 568), textScale: 1.6);
      await visitEveryTab(tester);
    });

    testWidgets('with a long course code', (tester) async {
      await openCourse(
        tester,
        code: 'MATH 102',
        size: const Size(320, 568),
        textScale: 1.6,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
