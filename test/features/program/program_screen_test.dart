import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/core/routes/app_routes.dart';
import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/features/program/program_post_store.dart';
import 'package:suggest/features/program/widgets/write_post_form.dart';
import 'package:suggest/services/auth_service.dart';
import 'package:suggest/services/fake_auth_service.dart';

/// Opens [route] on a phone of [size], starting from the mock posts.
Future<void> _open(
  WidgetTester tester,
  String route, {
  Object? arguments,
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  ProgramPostStore.instance.reset();
  addTearDown(ProgramPostStore.instance.reset);
  await tester.pumpWidget(
    AuthScope(
      service: FakeAuthService(delay: Duration.zero),
      child: MaterialApp(
        theme: AppTheme.light,
        initialRoute: route,
        routes: AppRoutes.table,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('programs list switches type and opens a program', (
    tester,
  ) async {
    await _open(tester, AppRoutes.programs);
    expect(find.text('Computer Science and Engineering'), findsOneWidget);

    await _tap(tester, find.text('Minor'));
    expect(find.text('Business Analytics'), findsOneWidget);

    await _tap(tester, find.text('Business Analytics'));
    expect(find.text('Usual route'), findsOneWidget);
    expect(find.text('First term'), findsOneWidget);
  });

  testWidgets('write a post shows inline errors', (tester) async {
    await _open(tester, AppRoutes.program);
    await _tap(tester, find.text('Posts (2)'));
    await _tap(tester, find.text('Write a post'));

    await _tap(tester, find.text('Share'));
    expect(find.text(WritePostForm.topicError), findsOneWidget);
    expect(find.text(WritePostForm.emptyError), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'Too short');
    await tester.pumpAndSettle();
    expect(find.text(WritePostForm.shortError), findsOneWidget);
  });

  testWidgets('program pages have no overflow on a small phone', (
    tester,
  ) async {
    await _open(tester, AppRoutes.program, size: const Size(320, 568));
    await _tap(tester, find.text('Posts (2)'));
    expect(tester.takeException(), isNull);
  });
}
