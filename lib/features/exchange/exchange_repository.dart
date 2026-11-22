import 'exchange_data.dart';
import 'exchange_models.dart';
import 'geo.dart';

/// Where the exchange screen gets its data. Step 3 adds a Firebase
/// implementation; the screen only knows this interface.
abstract interface class ExchangeRepository {
  /// Schools for one map. Never includes schools below [minStudentsToShow].
  Future<List<Destination>> fetchDestinations(MapRegion region);

  /// Posts, newest first. [school] null means every school.
  Future<List<ExchangePost>> fetchPosts({String? school});
}

class MockExchangeRepository implements ExchangeRepository {
  const MockExchangeRepository({
    this.delay = const Duration(milliseconds: 500),
  });

  final Duration delay;

  @override
  Future<List<Destination>> fetchDestinations(MapRegion region) async {
    await Future<void>.delayed(delay);
    return [
      for (final d in ExchangeMockData.destinations)
        if (d.region == region && d.students >= minStudentsToShow) d,
    ]..sort((a, b) => b.students.compareTo(a.students));
  }

  @override
  Future<List<ExchangePost>> fetchPosts({String? school}) async {
    await Future<void>.delayed(delay);
    return [
      for (final p in ExchangeMockData.posts)
        if (school == null || p.school == school) p,
    ];
  }
}
