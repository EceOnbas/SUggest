import 'dart:math' as math;
import 'dart:ui';

import '../theme/app_colors.dart';

/// Builds the shape of a sakura branch from a course's ratings.
///
/// The shape comes from the generator in the SUggest design files, so the
/// same seed grows the same branch in the app as in the wireframes. The
/// blossom count was raised later so strict courses look full:
/// - the seed (usually the course code) decides the shape,
/// - difficulty decides how deep the pink is,
/// - workload decides how thick the wood is,
/// - attendance decides how many blossoms there are.
///
/// Every rating is on the 1–5 scale and is clamped to it.
class SakuraGenerator {
  SakuraGenerator._();

  /// How much thinner each level of the branch is than the trunk.
  static const _taper = [1.0, 0.62, 0.4, 0.26, 0.17];

  static double _clamp(double v) => v.clamp(1.0, 5.0).toDouble();

  /// The pink for a difficulty between 1 and 5: every decimal gets its
  /// own shade, mixed between the two nearest of [AppColors.blossomRamp].
  static Color blossomColor(double difficulty) {
    const stops = AppColors.blossomRamp;
    final t = _clamp(difficulty) - 1;
    final i = math.min(3, t.floor());
    return Color.lerp(stops[i], stops[i + 1], t - i)!;
  }

  /// Fewest blossoms, at attendance 1: about as many as CS 310 used to
  /// show, so no branch ever looks bare.
  static const minBlossoms = 15;

  /// Most blossoms, at attendance 5: a full tree.
  static const maxBlossoms = 120;

  /// Number of blossoms for an attendance rating, from [minBlossoms] at 1
  /// to [maxBlossoms] at 5.
  ///
  /// It changes with every decimal (4.34 and 4.6 differ by about 10
  /// blossoms) and grows faster at the top, so 4–5 looks really dense.
  static int blossomCount(double attendance) {
    final t = (_clamp(attendance) - 1) / 4; // 0 at 1, 1 at 5
    return (minBlossoms + (maxBlossoms - minBlossoms) * math.pow(t, 1.6))
        .round();
  }

  static SakuraGeometry generate({
    required String seed,
    required double difficulty,
    required double workload,
    required double attendance,
    required Size size,
    SakuraStart? start,
    double flowerScale = 1,
  }) {
    final rnd = _Mulberry32(_fnv1a(seed));
    final w = size.width, h = size.height;
    final mn = math.min(w, h);
    final scale = math.pow(mn / 300, 0.7).toDouble();
    final trunk = (1.6 + (_clamp(workload) - 1) * 1.6) * scale * 1.6;

    final branches = List.generate(5, (_) => Path());
    final tips = <Offset>[];
    final segments = <(Offset, Offset)>[];

    void grow(double x, double y, double angle, double length, int depth) {
      final ex = x + math.cos(angle) * length;
      final ey = y + math.sin(angle) * length;
      final bend = (rnd.next() - 0.5) * 0.3 * length;
      final mx = (x + ex) / 2 - math.sin(angle) * bend;
      final my = (y + ey) / 2 + math.cos(angle) * bend;
      branches[depth]
        ..moveTo(x, y)
        ..quadraticBezierTo(mx, my, ex, ey);
      if (depth >= 2) segments.add((Offset(x, y), Offset(ex, ey)));
      if (depth == 4) {
        tips.add(Offset(ex, ey));
        return;
      }
      final kids = rnd.next() < 0.3 ? 3 : 2;
      for (var k = 0; k < kids; k++) {
        final spread = 0.35 + rnd.next() * 0.4;
        final turn = kids == 2 ? (k == 1 ? spread : -spread) : (k - 1) * spread;
        final childAngle = angle + turn + (rnd.next() - 0.5) * 0.2;
        final childLength = length * (0.66 + rnd.next() * 0.14);
        grow(ex, ey, childAngle, childLength, depth + 1);
      }
    }

    // A missing start value is picked at random, in the same order as the
    // design files, so the random sequence stays the same.
    final sx = start?.x ?? w * (0.1 + rnd.next() * 0.12);
    final sy = start?.y ?? h * 1.03;
    final angle = start?.angle ?? -math.pi / 2 + 0.35 + rnd.next() * 0.25;
    final length = start?.length ?? h * 0.36;
    grow(sx, sy, angle, length, 0);

    // Blossoms sit on the tips first, then on random spots along twigs.
    final n = blossomCount(attendance);
    final spots = List<Offset>.of(tips);
    while (spots.length < n && segments.isNotEmpty) {
      final (a, b) = segments[(rnd.next() * segments.length).floor()];
      final t = 0.3 + rnd.next() * 0.7;
      spots.add(Offset.lerp(a, b, t)!);
    }
    for (var i = spots.length - 1; i > 0; i--) {
      final j = (rnd.next() * (i + 1)).floor();
      final tmp = spots[i];
      spots[i] = spots[j];
      spots[j] = tmp;
    }

    final front = Path(), back = Path(), centers = Path();
    for (final spot in spots.take(n)) {
      final r = math.max(2.2, mn * (0.028 + rnd.next() * 0.018)) * flowerScale;
      final rotation = rnd.next() * math.pi * 2;
      final flower = Path();
      for (var p = 0; p < 5; p++) {
        final a = rotation + p * math.pi * 2 / 5;
        flower.addOval(
          Rect.fromCircle(
            center: spot + Offset(math.cos(a), math.sin(a)) * (r * 0.6),
            radius: r * 0.52,
          ),
        );
      }
      (rnd.next() < 0.35 ? back : front).addPath(flower, Offset.zero);
      centers.addOval(Rect.fromCircle(center: spot, radius: r * 0.26));
    }

    return SakuraGeometry(
      branches: branches,
      branchWidths: [for (final t in _taper) math.max(0.6, trunk * t)],
      backBlossoms: back,
      frontBlossoms: front,
      centers: centers,
      blossomColor: blossomColor(difficulty),
      deepColor: AppColors.blossomCenter,
      petalOutlineWidth: math.max(0.5, mn / 400),
      blossomCount: math.min(n, spots.length),
    );
  }

  /// FNV-1a hash of the seed: the same text always gives the same number.
  static int _fnv1a(String text) {
    var h = 2166136261;
    for (final unit in text.codeUnits) {
      h ^= unit;
      h = _imul(h, 16777619);
    }
    return h;
  }
}

/// Where the trunk starts, pointing which way and how long. Leave a value
/// null to let the seed pick it. Used to grow a branch in from a screen edge.
class SakuraStart {
  const SakuraStart({this.x, this.y, this.angle, this.length});

  final double? x;
  final double? y;

  /// In radians; 0 points right, -π/2 points up.
  final double? angle;
  final double? length;

  @override
  bool operator ==(Object other) =>
      other is SakuraStart &&
      other.x == x &&
      other.y == y &&
      other.angle == angle &&
      other.length == length;

  @override
  int get hashCode => Object.hash(x, y, angle, length);
}

/// The ready-to-paint parts of one branch.
class SakuraGeometry {
  const SakuraGeometry({
    required this.branches,
    required this.branchWidths,
    required this.backBlossoms,
    required this.frontBlossoms,
    required this.centers,
    required this.blossomColor,
    required this.deepColor,
    required this.petalOutlineWidth,
    required this.blossomCount,
  });

  /// One path per level, trunk first.
  final List<Path> branches;
  final List<double> branchWidths;
  final Path backBlossoms;
  final Path frontBlossoms;
  final Path centers;
  final Color blossomColor;
  final Color deepColor;
  final double petalOutlineWidth;
  final int blossomCount;
}

/// Low 32 bits of a × b, like JavaScript's Math.imul (as an unsigned value).
/// Split into 16-bit halves so it is exact on every platform.
int _imul(int a, int b) {
  a &= 0xFFFFFFFF;
  b &= 0xFFFFFFFF;
  final ah = a >> 16, al = a & 0xFFFF;
  final bh = b >> 16, bl = b & 0xFFFF;
  return (al * bl + (((ah * bl + al * bh) & 0xFFFF) << 16)) & 0xFFFFFFFF;
}

/// Mulberry32: a tiny seeded random number generator. Same seed, same
/// numbers, on every device.
class _Mulberry32 {
  _Mulberry32(int seed) : _state = seed & 0xFFFFFFFF;

  int _state;

  /// A number in [0, 1).
  double next() {
    _state = (_state + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _imul(_state ^ (_state >> 15), 1 | _state);
    t = ((t + _imul(t ^ (t >> 7), 61 | t)) & 0xFFFFFFFF) ^ t;
    return ((t ^ (t >> 14)) & 0xFFFFFFFF) / 4294967296;
  }
}
