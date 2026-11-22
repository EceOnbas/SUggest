import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/routes/app_routes.dart';
import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/features/program/program_post_store.dart';
import 'package:suggest/services/auth_service.dart';
import 'package:suggest/services/fake_auth_service.dart';

Future<void> _openAdmin(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  ProgramPostStore.instance.reset();
  addTearDown(ProgramPostStore.instance.reset);
  await tester.pumpWidget(
    AuthScope(
      service: FakeAuthService(delay: Duration.zero),
      child: MaterialApp(
        theme: AppTheme.light,
        initialRoute: AppRoutes.admin,
        routes: AppRoutes.table,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// The count line under the chips. Tapping a card scrolls the list, so
/// the line can be above the screen; still look for it there.
Finder _count(String text) => find.text(text, skipOffstage: false);

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('admin deletes a post after confirming', (tester) async {
    await _openAdmin(tester);
    expect(_count('4 posts'), findsOneWidget);

    // Cancel keeps the post.
    await _tap(tester, find.byTooltip('Delete post').first);
    expect(find.text('Delete this post?'), findsOneWidget);
    await _tap(tester, find.text('Cancel'));
    expect(_count('4 posts'), findsOneWidget);

    await _tap(tester, find.byTooltip('Delete post').first);
    await _tap(tester, find.text('Delete'));
    expect(_count('3 posts'), findsOneWidget);
    expect(ProgramPostStore.instance.all.length, 3);
  });

  testWidgets('admin deletes a review after confirming', (tester) async {
    await _openAdmin(tester);
    await _tap(tester, find.text('Reviews'));
    expect(_count('4 reviews'), findsOneWidget);

    await _tap(tester, find.byTooltip('Delete review').first);
    expect(find.text('Delete this review?'), findsOneWidget);
    await _tap(tester, find.text('Delete'));
    expect(_count('3 reviews'), findsOneWidget);
  });
}
