import 'geo.dart';

/// A partner school students go to, with how many Sabancı students went.
class Destination {
  const Destination({
    required this.school,
    required this.city,
    required this.lat,
    required this.lon,
    required this.students,
    required this.region,
  });

  final String school;
  final String city;
  final double lat;
  final double lon;
  final int students;
  final MapRegion region;

  /// Distance from the Sabancı campus in kilometres.
  double get distanceKm => haversineKm(sabanciLat, sabanciLon, lat, lon);

  /// "1,850 km from campus".
  String get distanceLabel {
    final km = distanceKm.round();
    final digits = km.toString();
    final grouped = digits.length > 3
        ? '${digits.substring(0, digits.length - 3)},${digits.substring(digits.length - 3)}'
        : digits;
    return '$grouped km from campus';
  }
}

/// A moderated experience post about one school. Posts are anonymous.
class ExchangePost {
  const ExchangePost({
    required this.id,
    required this.school,
    required this.term,
    required this.text,
    this.topics = const [],
  });

  final String id;
  final String school;
  final String term;
  final String text;
  final List<String> topics;
}

/// Topic filters on the posts list. The first entry means "no filter".
const exchangeTopics = [
  'All topics',
  'Application',
  'Courses',
  'Housing',
  'Costs',
  'Life abroad',
];

/// Schools with fewer students than this are never shown, so nobody can be
/// recognised from a very small group.
const minStudentsToShow = 5;
