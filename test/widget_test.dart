import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/app.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const SUggestApp());
    expect(find.text('SUggest'), findsOneWidget);
  });
}
