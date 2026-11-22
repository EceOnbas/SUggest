import 'dart:math' as math;
import 'dart:ui';

/// Which map is shown.
enum MapRegion { europe, world }

/// Turns longitude and latitude into points on a map of a given width.
///
/// Europe uses a flat projection squeezed by cos(50°); the world map uses a
/// gently damped Mercator so the far north and south do not stretch too much.
class MapProjection {
  MapProjection._(this.region, this.width, this._project, this.height);

  factory MapProjection(MapRegion region, double width) {
    switch (region) {
      case MapRegion.europe:
        const lo0 = -13.0, lo1 = 42.0, la0 = 34.5, la1 = 65.0;
        final k = math.cos(50 * math.pi / 180);
        final scale = width / ((lo1 - lo0) * k);
        return MapProjection._(
          region,
          width,
          (lon, lat) => Offset((lon - lo0) * k * scale, (la1 - lat) * scale),
          (la1 - la0) * scale,
        );
      case MapRegion.world:
        const lo0 = -128.0, lo1 = 158.0, la0 = -56.0, la1 = 72.0;
        double merc(double lat) =>
            1.25 * math.log(math.tan(math.pi / 4 + 0.4 * lat * math.pi / 180));
        final sx = width / (lo1 - lo0);
        final sy =
            width * (merc(la1) - merc(la0)) / ((lo1 - lo0) * math.pi / 180);
        return MapProjection._(
          region,
          width,
          (lon, lat) => Offset(
            (lon - lo0) * sx,
            (merc(la1) - merc(lat)) / (merc(la1) - merc(la0)) * sy,
          ),
          sy,
        );
    }
  }

  final MapRegion region;
  final double width;
  final double height;
  final Offset Function(double lon, double lat) _project;

  Offset project(double lon, double lat) => _project(lon, lat);

  Path pathFor(List<(double, double)> ring) {
    final path = Path();
    for (final (i, (lon, lat)) in ring.indexed) {
      final p = project(lon, lat);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }
}

/// Great-circle distance in kilometres.
double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLon = rad(lon2 - lon1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) * math.cos(rad(lat2)) * math.pow(math.sin(dLon / 2), 2);
  return 6371 * 2 * math.asin(math.sqrt(a));
}

/// Sabancı University, Tuzla.
const sabanciLat = 40.8913;
const sabanciLon = 29.3789;
