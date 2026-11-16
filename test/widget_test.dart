import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/app.dart';
import 'package:suggest/features/shell/main_shell.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const SUggestApp());
    expect(find.byType(MainShell), findsOneWidget);
  });
}
