import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'sakura_generator.dart';

export 'sakura_generator.dart' show SakuraStart;

/// A sakura branch drawn from a course's ratings.
///
/// Darker pink means a harder course, more blossoms mean stricter
/// attendance, and a thicker branch means more workload. The [seed]
/// (usually the course code) gives each course its own shape; the same
/// seed always draws the same branch.
///
/// The branch fills the space its parent gives it, so wrap it in a
/// `SizedBox` or an `AspectRatio`.
class SakuraBranch extends StatelessWidget {
  const SakuraBranch({
    super.key,
    required this.seed,
    this.difficulty = 3,
    this.workload = 3,
    this.attendance = 3.5,
    this.start,
    this.flowerScale = 1,
    this.semanticLabel,
  });

  final String seed;
  final double difficulty;
  final double workload;
  final double attendance;

  /// Where the trunk starts; null grows it up from the lower left.
  final SakuraStart? start;

  /// Bigger or smaller blossoms; 1 is the design size.
  final double flowerScale;

  /// Read by screen readers. Null hides the branch from them, which is
  /// right when it is only decoration.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final painting = CustomPaint(
      size: Size.infinite,
      painter: _SakuraPainter(
        seed: seed,
        difficulty: difficulty,
        workload: workload,
        attendance: attendance,
        start: start,
        flowerScale: flowerScale,
      ),
    );
    return semanticLabel == null
        ? ExcludeSemantics(child: painting)
        : Semantics(label: semanticLabel, image: true, child: painting);
  }
}

class _SakuraPainter extends CustomPainter {
  _SakuraPainter({
    required this.seed,
    required this.difficulty,
    required this.workload,
    required this.attendance,
    required this.start,
    required this.flowerScale,
  });

  final String seed;
  final double difficulty;
  final double workload;
  final double attendance;
  final SakuraStart? start;
  final double flowerScale;

  SakuraGeometry? _cache;
  Size? _cacheSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    // Building the branch is the slow part, so do it once per size.
    if (_cache == null || _cacheSize != size) {
      _cache = SakuraGenerator.generate(
        seed: seed,
        difficulty: difficulty,
        workload: workload,
        attendance: attendance,
        size: size,
        start: start,
        flowerScale: flowerScale,
      );
      _cacheSize = size;
    }
    final g = _cache!;

    canvas.drawPath(g.backBlossoms, Paint()..color = g.blossomColor);

    final wood = Paint()
      ..color = AppColors.bark
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < g.branches.length; i++) {
      canvas.drawPath(g.branches[i], wood..strokeWidth = g.branchWidths[i]);
    }

    canvas
      ..drawPath(g.frontBlossoms, Paint()..color = g.blossomColor)
      ..drawPath(
        g.frontBlossoms,
        Paint()
          ..color = g.deepColor.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = g.petalOutlineWidth,
      )
      ..drawPath(g.centers, Paint()..color = g.deepColor);
  }

  @override
  bool shouldRepaint(_SakuraPainter old) =>
      old.seed != seed ||
      old.difficulty != difficulty ||
      old.workload != workload ||
      old.attendance != attendance ||
      old.start != start ||
      old.flowerScale != flowerScale;
}
