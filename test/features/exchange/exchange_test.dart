import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/core/widgets/app_chip.dart';
import 'package:suggest/core/widgets/state_views.dart';
import 'package:suggest/features/exchange/exchange_map.dart';
import 'package:suggest/features/exchange/exchange_models.dart';
import 'package:suggest/features/exchange/exchange_repository.dart';
import 'package:suggest/features/exchange/exchange_screen.dart';
import 'package:suggest/features/exchange/geo.dart';

const _instant = MockExchangeRepository(delay: Duration.zero);

class _Failing implements ExchangeRepository {
  @override
  Future<List<Destination>> fetchDestinations(MapRegion region) =>
      Future.error(Exception('offline'));

  @override
  Future<List<ExchangePost>> fetchPosts({String? school}) async => const [];
}

Widget _app([ExchangeRepository repo = _instant]) => MaterialApp(
  theme: AppTheme.light,
  home: ExchangeScreen(repository: repo),
);

void main() {
  group('geo', () {
    test('haversine: Istanbul to Munich is about 1,600 km', () {
      final km = haversineKm(sabanciLat, sabanciLon, 48.15, 11.57);
      expect(km, inInclusiveRange(1550, 1750));
    });

    test('europe projection is as wide as asked and puts north above south', () {
      final p = MapProjection(MapRegion.europe, 350);
      expect(p.project(-13, 50).dx, closeTo(0, 0.001));
      expect(p.project(42, 50).dx, closeTo(350, 0.001));
      expect(p.project(10, 60).dy, lessThan(p.project(10, 40).dy));
      expect(p.height, greaterThan(100));
    });

    test('world projection keeps every school inside the map', () {
      final p = MapProjection(MapRegion.world, 350);
      for (final (lon, lat) in [(144.96, -37.81), (-117.24, 32.88), (-46.73, -23.56)]) {
        final o = p.project(lon, lat);
        expect(o.dx, inInclusiveRange(0, 350));
        expect(o.dy, inInclusiveRange(0, p.height));
      }
    });
  });

  group('repository', () {
    test('never returns schools with fewer than 5 students', () async {
      for (final region in MapRegion.values) {
        final list = await _instant.fetchDestinations(region);
        expect(list, isNotEmpty);
        expect(list.every((d) => d.students >= minStudentsToShow), isTrue);
      }
      final europe = await _instant.fetchDestinations(MapRegion.europe);
      expect(europe.any((d) => d.school == 'University of Tartu'), isFalse);
    });

    test('lists the biggest school first', () async {
      final europe = await _instant.fetchDestinations(MapRegion.europe);
      expect(europe.first.school, 'TU Munich');
    });

    test('posts can be limited to one school', () async {
      final posts = await _instant.fetchPosts(school: 'TU Munich');
      expect(posts, isNotEmpty);
      expect(posts.every((p) => p.school == 'TU Munich'), isTrue);
    });
  });

  test('a tap near a dot finds the school, a tap far away finds none', () async {
    final europe = await _instant.fetchDestinations(MapRegion.europe);
    final p = MapProjection(MapRegion.europe, 350);
    final munich = europe.firstWhere((d) => d.school == 'TU Munich');
    final at = p.project(munich.lon, munich.lat);
    expect(nearestDestination(p, europe, at + const Offset(3, 3))?.school, 'TU Munich');
    expect(nearestDestination(p, europe, const Offset(5, 5)), isNull);
  });

  testWidgets('shows a skeleton, then the Europe map with its posts', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const MockExchangeRepository(delay: Duration(milliseconds: 200))),
    );
    expect(find.byType(ExchangeMap), findsNothing);
    expect(find.byType(LoadingList), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.byType(ExchangeMap), findsOneWidget);
    expect(find.text('Erasmus, Europe'), findsOneWidget);
    expect(find.textContaining('TU Munich · Fall 2026'), findsOneWidget);
  });

  testWidgets('picking a school shows only its posts; Show all resets', (
    tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(AppChip, 'Politecnico di Milano'));
    await tester.pumpAndSettle();
    expect(find.text('Showing Politecnico di Milano'), findsOneWidget);
    expect(find.textContaining('TU Munich · '), findsNothing);

    await tester.tap(find.text('Show all'));
    await tester.pumpAndSettle();
    expect(find.text('Showing Politecnico di Milano'), findsNothing);
    expect(find.textContaining('TU Munich · '), findsWidgets);
  });

  testWidgets('a topic with no posts shows the empty state', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(AppChip, 'Life abroad'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(AppChip, 'TU Wien'));
    await tester.pumpAndSettle();
    expect(find.text('No posts here yet'), findsOneWidget);
  });

  testWidgets('switching to the world map lists world schools', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Exchange, world'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppChip, 'University of Melbourne'), findsOneWidget);
    expect(find.widgetWithText(AppChip, 'TU Munich'), findsNothing);
  });

  testWidgets('an error offers Try again', (tester) async {
    await tester.pumpWidget(_app(_Failing()));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorState), findsOneWidget);
  });

  for (final size in const [Size(320, 568), Size(430, 932)]) {
    testWidgets('no overflow at ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Exchange, world'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
