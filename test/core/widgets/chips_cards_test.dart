import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:suggest/core/theme/app_colors.dart';
import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/core/widgets/app_bottom_sheet.dart';
import 'package:suggest/core/widgets/app_card.dart';
import 'package:suggest/core/widgets/app_chip.dart';
import 'package:suggest/core/widgets/app_toast.dart';
import 'package:suggest/core/widgets/step_progress_bar.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
          body: Padding(padding: const EdgeInsets.all(24), child: child)),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('ChipFilterRow marks the picked chip', (tester) async {
    var selected = 'All';
    await tester.pumpWidget(_host(StatefulBuilder(
      builder: (context, setState) => ChipFilterRow(
        options: const ['All', 'Difficulty', 'Workload'],
        selected: selected,
        onSelected: (v) => setState(() => selected = v),
      ),
    )));
    AppChip chip(String label) =>
        tester.widget(find.widgetWithText(AppChip, label));
    expect(chip('All').selected, isTrue);
    await tester.tap(find.text('Difficulty'));
    await tester.pump();
    expect(selected, 'Difficulty');
    expect(chip('Difficulty').selected, isTrue);
    expect(chip('All').selected, isFalse);
  });

  testWidgets('AppChip is at least 44 tall, compact is 40', (tester) async {
    await tester.pumpWidget(_host(const Row(children: [
      AppChip(label: 'All'),
      AppChip(label: 'CS 204', compact: true),
    ])));
    expect(tester.getSize(find.widgetWithText(AppChip, 'All')).height, 44);
    expect(tester.getSize(find.widgetWithText(AppChip, 'CS 204')).height, 40);
  });

  testWidgets('TagChip is pink, TagChip.topic is yellow', (tester) async {
    await tester.pumpWidget(_host(const Row(children: [
      TagChip('Workload'),
      TagChip.topic('Group project'),
    ])));
    Color textColor(String t) => tester.widget<Text>(find.text(t)).style!.color!;
    expect(textColor('Workload'), AppColors.sakura5);
    expect(textColor('Group project'), AppColors.tagText);
  });

  testWidgets('AppCard calls onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
        _host(AppCard(onTap: () => taps++, child: const Text('Section A'))));
    await tester.tap(find.text('Section A'));
    expect(taps, 1);
  });

  testWidgets('StepProgressBar fills segments up to the step', (tester) async {
    await tester
        .pumpWidget(_host(const StepProgressBar(step: 2, totalSteps: 4)));
    final colors = tester
        .widgetList<Container>(find.descendant(
            of: find.byType(StepProgressBar), matching: find.byType(Container)))
        .map((c) => (c.decoration! as BoxDecoration).color)
        .toList();
    expect(colors, [
      AppColors.primary,
      AppColors.primary,
      AppColors.border,
      AppColors.border
    ]);
    expect(find.bySemanticsLabel('Step 2 of 4'), findsOneWidget);
  });

  testWidgets('showAppBottomSheet shows title and returns the result',
      (tester) async {
    String? result;
    await tester.pumpWidget(_host(Builder(
      builder: (context) => TextButton(
        onPressed: () async => result = await showAppBottomSheet<String>(
          context: context,
          title: 'Filter reviews',
          builder: (context) => TextButton(
              onPressed: () => Navigator.pop(context, 'Fall 2025'),
              child: const Text('Apply')),
        ),
        child: const Text('open'),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Filter reviews'), findsOneWidget);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(result, 'Fall 2025');
    expect(find.text('Filter reviews'), findsNothing);
  });

  testWidgets('AppToast shows, closes with ✕ and after 3.5 s', (tester) async {
    await tester.pumpWidget(_host(Builder(
      builder: (context) => TextButton(
        onPressed: () => AppToast.show(context, 'Review deleted.'),
        child: const Text('go'),
      ),
    )));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('Review deleted.'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Review deleted.'), findsNothing);

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('Review deleted.'), findsOneWidget);
    await tester.pump(AppToast.duration);
    await tester.pumpAndSettle();
    expect(find.text('Review deleted.'), findsNothing);
  });
}
