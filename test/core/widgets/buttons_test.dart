import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/core/widgets/app_back_button.dart';
import 'package:suggest/core/widgets/primary_button.dart';
import 'package:suggest/core/widgets/secondary_button.dart';
import 'package:suggest/core/widgets/text_link.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('PrimaryButton calls onPressed and is 56 tall', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
        _host(PrimaryButton(label: 'Log in', onPressed: () => taps++)));
    await tester.tap(find.text('Log in'));
    expect(taps, 1);
    expect(tester.getSize(find.byType(FilledButton)).height, 56);
  });

  testWidgets('PrimaryButton with null onPressed is disabled', (tester) async {
    await tester.pumpWidget(
        _host(const PrimaryButton(label: 'Create account', onPressed: null)));
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).enabled,
        isFalse);
  });

  testWidgets('PrimaryButton ignores taps while loading', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(PrimaryButton(
        label: 'Log in', onPressed: () => taps++, loading: true)));
    await tester.tap(find.byType(FilledButton));
    expect(taps, 0);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Log in'), findsNothing);
  });

  testWidgets('SecondaryButton compact is 52 tall', (tester) async {
    await tester.pumpWidget(_host(SecondaryButton(
        label: 'Resend email', onPressed: () {}, compact: true)));
    expect(tester.getSize(find.byType(OutlinedButton)).height, 52);
  });

  testWidgets('TextLink and PromptLink call onPressed', (tester) async {
    var link = 0, prompt = 0;
    await tester.pumpWidget(_host(Column(children: [
      TextLink(label: 'Forgot password?', onPressed: () => link++),
      PromptLink(
          prompt: 'New here?',
          linkLabel: 'Create account',
          onPressed: () => prompt++),
    ])));
    await tester.tap(find.text('Forgot password?'));
    expect(link, 1);
    await tester.tapOnText(find.textRange.ofSubstring('Create account'));
    expect(prompt, 1);
  });

  testWidgets('AppBackButton pops the screen', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: AppBackButton()))),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
    expect(find.text('open'), findsOneWidget);
  });
}
