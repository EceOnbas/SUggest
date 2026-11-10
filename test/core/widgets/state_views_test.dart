import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/core/widgets/state_views.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
          body: SingleChildScrollView(
              padding: const EdgeInsets.all(24), child: child)),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('LoadingList shows placeholder cards with a label',
      (tester) async {
    await tester.pumpWidget(
        _host(const LoadingList(itemCount: 2, label: 'Loading reviews')));
    expect(find.byType(SkeletonBox), findsNWidgets(8));
    expect(find.bySemanticsLabel('Loading reviews'), findsOneWidget);
  });

  testWidgets('SkeletonBox stays still when animations are disabled',
      (tester) async {
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: _host(const SkeletonBox()),
    ));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('EmptyState shows its action', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(EmptyState(
      title: 'No reviews yet',
      message: 'Be the first to write one.',
      actionLabel: 'Write a review',
      onAction: () => taps++,
    )));
    expect(find.text('No reviews yet'), findsOneWidget);
    await tester.tap(find.text('Write a review'));
    expect(taps, 1);
  });

  testWidgets('ErrorState offers Try again', (tester) async {
    var retries = 0;
    await tester.pumpWidget(_host(ErrorState(
        title: "Couldn't load this course", onRetry: () => retries++)));
    expect(find.text('No connection. Check your internet and try again.'),
        findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });
}
