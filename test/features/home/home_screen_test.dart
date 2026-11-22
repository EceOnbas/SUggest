import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/routes/app_routes.dart';
import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/core/widgets/state_views.dart';
import 'package:suggest/features/exchange/exchange_screen.dart';
import 'package:suggest/features/home/catalog_repository.dart';
import 'package:suggest/features/home/home_screen.dart';
import 'package:suggest/models/course.dart';
import 'package:suggest/models/review.dart';

class _FailingOnce implements CatalogRepository {
  _FailingOnce();

  var _calls = 0;
  final _ok = const MockCatalogRepository(delay: Duration.zero);

  @override
  Future<List<Course>> fetchCourses() async {
    if (_calls++ == 0) throw Exception('offline');
    return _ok.fetchCourses();
  }

  @override
  Future<List<Review>> fetchLatestReviews() => _ok.fetchLatestReviews();
}

Widget _app(CatalogRepository repo, {List<Object?>? opened}) => MaterialApp(
  theme: AppTheme.light,
  home: HomeScreen(repository: repo),
  onGenerateRoute: (settings) {
    if (settings.name == AppRoutes.course) {
      opened?.add(settings.arguments);
      return MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('course page')),
      );
    }
    return null;
  },
);

const _instant = MockCatalogRepository(delay: Duration.zero);

/// A tall phone, so the whole scrolling page is built and on screen.
void _tallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(430, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('shows a loading skeleton, then the shelf and reviews', (
    tester,
  ) async {
    _tallScreen(tester);
    await tester.pumpWidget(
      _app(const MockCatalogRepository(delay: Duration(milliseconds: 300))),
    );
    expect(find.byType(LoadingList), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(LoadingList), findsNothing);
    expect(find.text('Browse courses'), findsOneWidget);
    expect(find.byKey(const Key('shelf-CS 310')), findsOneWidget);
    expect(find.text('Latest reviews'), findsOneWidget);
  });

  testWidgets('a shelf cover opens the course by code', (tester) async {
    final opened = <Object?>[];
    await tester.pumpWidget(_app(_instant, opened: opened));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('shelf-CS 310')));
    await tester.pumpAndSettle();
    expect(opened, ['CS 310']);
    expect(find.text('course page'), findsOneWidget);
  });

  testWidgets('an error offers Try again, which loads the courses', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_FailingOnce()));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorState), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorState), findsNothing);
    expect(find.text('Browse courses'), findsOneWidget);
  });

  testWidgets('the Exchange card opens the exchange screen', (tester) async {
    _tallScreen(tester);
    await tester.pumpWidget(_app(_instant));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open-exchange')));
    await tester.pumpAndSettle();
    expect(find.byType(ExchangeScreen), findsOneWidget);
  });

  group('search', () {
    Future<void> openSearch(WidgetTester tester) async {
      await tester.pumpWidget(_app(_instant));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('search-bar')));
      await tester.pumpAndSettle();
    }

    testWidgets('typing filters the results', (tester) async {
      await openSearch(tester);
      expect(find.text('All courses'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'calculus');
      await tester.pumpAndSettle();
      expect(find.text('1 result'), findsOneWidget);
      expect(find.text('MATH 102'), findsOneWidget);
    });

    testWidgets('no match shows the empty state', (tester) async {
      await openSearch(tester);
      await tester.enterText(find.byType(TextField), 'zzzz');
      await tester.pumpAndSettle();
      expect(find.text('No courses found'), findsOneWidget);
    });

    testWidgets('a submitted search is remembered and can be removed', (
      tester,
    ) async {
      await openSearch(tester);
      await tester.enterText(find.byType(TextField), 'data');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      // Clear the box: the recent search card appears.
      await tester.tap(find.byTooltip('Clear'));
      await tester.pumpAndSettle();
      expect(find.text('Recent searches'), findsOneWidget);
      expect(find.text('data'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove "data" from recent searches'));
      await tester.pumpAndSettle();
      expect(find.text('Recent searches'), findsNothing);
    });

    testWidgets('the system back button closes search first', (tester) async {
      await openSearch(tester);
      expect(find.text('Course code or title'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Course code or title'), findsNothing);
      expect(find.text('Browse courses'), findsOneWidget);
    });

    testWidgets('a result opens its course', (tester) async {
      final opened = <Object?>[];
      await tester.pumpWidget(_app(_instant, opened: opened));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('search-bar')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'cs310');
      await tester.pumpAndSettle();
      await tester.tap(find.text('CS 310'));
      await tester.pumpAndSettle();
      expect(opened, ['CS 310']);
    });
  });

  for (final size in const [Size(320, 568), Size(430, 932)]) {
    testWidgets('no overflow at ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(_instant));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('search-bar')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
