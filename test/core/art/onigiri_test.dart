import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/art/onigiri.dart';

void main() {
  test('every pose has a PNG in all three sizes', () {
    for (final pose in OnigiriPose.values) {
      final path = Onigiri.assetFor(pose);
      final name = path.split('/').last;
      expect(File(path).existsSync(), isTrue, reason: path);
      expect(File('assets/images/2.0x/$name').existsSync(), isTrue);
      expect(File('assets/images/3.0x/$name').existsSync(), isTrue);
    }
  });

  testWidgets('shows the asset at the given size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: Onigiri(pose: OnigiriPose.done, size: 160)),
      ),
    );
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      (image.image as AssetImage).assetName,
      'assets/images/onigiri_done.png',
    );
    expect(tester.getSize(find.byType(Image)), const Size(160, 160));
  });

  testWidgets('a label makes it readable', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Onigiri(semanticLabel: 'Onigiri waving')),
    );
    expect(find.bySemanticsLabel('Onigiri waving'), findsOneWidget);
  });
}
