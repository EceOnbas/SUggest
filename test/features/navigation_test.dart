import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/routes/app_routes.dart';
import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/features/shell/main_shell.dart';

Widget _app() => MaterialApp(
  theme: AppTheme.light,
  initialRoute: AppRoutes.home,
  routes: AppRoutes.table,
  onGenerateRoute: AppRoutes.onGenerateRoute,
);

void main() {
  testWidgets('bottom bar switches between the three tabs', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('Courses'), findsWidgets);

    await tester.tap(find.text('Community'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Exchange maps'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);
  });

  testWidgets('a course opens by code and goes back', (tester) async {
    await tester.pumpWidget(_app());
    await tester.tap(find.text('Open CS 310'));
    await tester.pumpAndSettle();
    expect(find.text('CS 310'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(MainShell), findsOneWidget);
  });
}
