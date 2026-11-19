import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/art/sakura_branch.dart';
import 'package:suggest/core/art/sakura_generator.dart';
import 'package:suggest/core/theme/app_colors.dart';

SakuraGeometry _make({
  String seed = 'CS 310',
  double d = 3.6,
  double w = 4.2,
  double a = 2.1,
}) => SakuraGenerator.generate(
  seed: seed,
  difficulty: d,
  workload: w,
  attendance: a,
  size: const Size(390, 260),
);

void main() {
  test('same seed and ratings draw the same branch', () {
    final first = _make(), second = _make();
    expect(first.branches[0].getBounds(), second.branches[0].getBounds());
    expect(first.frontBlossoms.getBounds(), second.frontBlossoms.getBounds());
  });

  test('another course code draws another shape', () {
    expect(
      _make(seed: 'CS 310').branches[4].getBounds(),
      isNot(_make(seed: 'MATH 201').branches[4].getBounds()),
    );
  });

  test('stricter attendance means more blossoms', () {
    expect(SakuraGenerator.blossomCount(1), SakuraGenerator.minBlossoms);
    expect(SakuraGenerator.blossomCount(5), SakuraGenerator.maxBlossoms);
    // Every decimal counts: 4.34 and 4.6 look different.
    expect(
      SakuraGenerator.blossomCount(4.6) - SakuraGenerator.blossomCount(4.34),
      greaterThanOrEqualTo(8),
    );
    // A full tree really gets all its blossoms.
    expect(_make(a: 5).blossomCount, SakuraGenerator.maxBlossoms);
    expect(_make(a: 5).blossomCount, greaterThan(_make(a: 1).blossomCount));
  });

  test('more workload means a thicker trunk', () {
    expect(
      _make(w: 5).branchWidths[0],
      greaterThan(_make(w: 1).branchWidths[0]),
    );
  });

  test('every decimal of difficulty changes the pink', () {
    expect(
      SakuraGenerator.blossomColor(4.34),
      isNot(SakuraGenerator.blossomColor(4.6)),
    );
  });

  test('difficulty picks the pink from light to dark', () {
    expect(SakuraGenerator.blossomColor(1), AppColors.sakura1);
    expect(SakuraGenerator.blossomColor(5), AppColors.sakura5);
    expect(SakuraGenerator.blossomColor(9), AppColors.sakura5);
    expect(SakuraGenerator.blossomColor(3), AppColors.sakura3);
  });

  testWidgets('SakuraBranch paints and is hidden from screen readers', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 390,
            height: 260,
            child: SakuraBranch(seed: 'CS 310'),
          ),
        ),
      ),
    );
    expect(find.byType(CustomPaint), findsWidgets);
    expect(tester.takeException(), isNull);
    expect(find.bySemanticsLabel(RegExp('.')), findsNothing);
    handle.dispose();
  });

  testWidgets('a label makes the branch readable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SizedBox(
          width: 200,
          height: 200,
          child: SakuraBranch(
            seed: 'CS 310',
            semanticLabel: 'Course branch drawn from ratings',
          ),
        ),
      ),
    );
    expect(
      find.bySemanticsLabel('Course branch drawn from ratings'),
      findsOneWidget,
    );
  });
}
