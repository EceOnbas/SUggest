import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'exchange_models.dart';
import 'geo.dart';
import 'map_outlines.dart';

/// A drawn map of one region with a dot per school.
///
/// Dot size follows the square root of the number of students. Tapping near
/// a dot calls [onSelected]; tapping empty sea or land clears nothing. The
/// selected school gets a green dot, a line to the campus and a name label.
/// The map is as wide as its parent and keeps its own aspect ratio, so it
/// never overflows.
class ExchangeMap extends StatelessWidget {
  const ExchangeMap({
    super.key,
    required this.region,
    required this.destinations,
    required this.selected,
    required this.onSelected,
  });

  final MapRegion region;
  final List<Destination> destinations;

  /// School name of the selected dot, or null.
  final String? selected;
  final ValueChanged<Destination> onSelected;

  @override
  Widget build(BuildContext context) {
    final label = region == MapRegion.europe
        ? 'Map of Erasmus destinations in Europe'
        : 'World map of exchange destinations';
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: LayoutBuilder(
        builder: (context, box) {
          final projection = MapProjection(region, box.maxWidth);
          return Semantics(
            label: label,
            image: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
                final hit = nearestDestination(
                  projection,
                  destinations,
                  details.localPosition,
                );
                if (hit != null) onSelected(hit);
              },
              child: CustomPaint(
                size: Size(box.maxWidth, projection.height),
                painter: ExchangeMapPainter(
                  projection: projection,
                  destinations: destinations,
                  selected: selected,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Radius of a school dot.
double dotRadius(int students) => 4 + math.sqrt(students) * 1.4;

/// The school whose dot is closest to [tap], within a 24 px reach (the dot's
/// own size counts, so big dots are easy to hit). Null when nothing is near.
Destination? nearestDestination(
  MapProjection projection,
  List<Destination> destinations,
  Offset tap,
) {
  Destination? best;
  var bestDistance = double.infinity;
  for (final d in destinations) {
    final distance = (projection.project(d.lon, d.lat) - tap).distance;
    final reach = math.max(24.0, dotRadius(d.students) + 8);
    if (distance <= reach && distance < bestDistance) {
      best = d;
      bestDistance = distance;
    }
  }
  return best;
}

class ExchangeMapPainter extends CustomPainter {
  ExchangeMapPainter({
    required this.projection,
    required this.destinations,
    required this.selected,
  });

  final MapProjection projection;
  final List<Destination> destinations;
  final String? selected;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.surfaceMuted,
    );
    final land = Paint()..color = AppColors.border;
    for (final ring in MapOutlines.land) {
      canvas.drawPath(projection.pathFor(ring), land);
    }
    final sea = Paint()..color = AppColors.surfaceMuted;
    for (final ring in MapOutlines.seas) {
      canvas.drawPath(projection.pathFor(ring), sea);
    }

    final campus = projection.project(sabanciLon, sabanciLat);
    Destination? chosen;
    for (final d in destinations) {
      if (d.school == selected) chosen = d;
    }

    // Line from campus to the selected school: straight in Europe, curved
    // on the world map.
    if (chosen != null) {
      final to = projection.project(chosen.lon, chosen.lat);
      final line = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      final path = Path()..moveTo(campus.dx, campus.dy);
      if (projection.region == MapRegion.europe) {
        path.lineTo(to.dx, to.dy);
      } else {
        final mid = Offset(
          (campus.dx + to.dx) / 2,
          (campus.dy + to.dy) / 2 - (to.dx - campus.dx).abs() * 0.22,
        );
        path.quadraticBezierTo(mid.dx, mid.dy, to.dx, to.dy);
      }
      canvas.drawPath(path, line);
    }

    final outline = Paint()
      ..color = AppColors.surfaceMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final d in destinations) {
      if (d.school == selected) continue;
      final p = projection.project(d.lon, d.lat);
      final r = dotRadius(d.students);
      canvas.drawCircle(p, r, Paint()..color = AppColors.ink.withValues(alpha: 0.85));
      canvas.drawCircle(p, r, outline);
    }
    if (chosen != null) {
      final p = projection.project(chosen.lon, chosen.lat);
      final r = dotRadius(chosen.students);
      canvas.drawCircle(p, r + 5, Paint()..color = AppColors.primary.withValues(alpha: 0.22));
      canvas.drawCircle(p, r, Paint()..color = AppColors.primary);
      canvas.drawCircle(p, r, outline);
      final y = p.dy > 34 ? p.dy - r - 14 : p.dy + r + 4;
      _label(canvas, size, chosen.city, Offset(p.dx, y), AppColors.ink);
    }

    // Campus marker.
    canvas.drawCircle(campus, 11, Paint()..color = AppColors.primary.withValues(alpha: 0.22));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: campus, width: 10, height: 10),
        const Radius.circular(2.5),
      ),
      Paint()..color = AppColors.primary,
    );
    final europe = projection.region == MapRegion.europe;
    _label(
      canvas,
      size,
      'Sabancı',
      europe ? Offset(campus.dx - 40, campus.dy - 8) : Offset(campus.dx, campus.dy - 28),
      AppColors.primary,
    );
  }

  /// Draws text centred on [at] (top edge), kept inside the map, with a
  /// light halo so it reads over land.
  void _label(Canvas canvas, Size size, String text, Offset at, Color color) {
    final style = AppTextStyles.label.copyWith(
      color: color,
      fontWeight: FontWeight.w700,
    );
    final halo = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(
          foreground: Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeJoin = StrokeJoin.round
            ..color = AppColors.surfaceMuted,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final fill = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = (at.dx - fill.width / 2)
        .clamp(
          AppSpacing.xs,
          math.max(AppSpacing.xs, size.width - fill.width - AppSpacing.xs),
        )
        .toDouble();
    final y = at.dy
        .clamp(0.0, math.max(0.0, size.height - fill.height))
        .toDouble();
    halo.paint(canvas, Offset(x, y));
    fill.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(ExchangeMapPainter old) =>
      old.projection.region != projection.region ||
      old.projection.width != projection.width ||
      old.selected != selected ||
      old.destinations != destinations;
}
