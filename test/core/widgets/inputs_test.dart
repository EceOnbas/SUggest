import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:suggest/core/theme/app_colors.dart';
import 'package:suggest/core/theme/app_theme.dart';
import 'package:suggest/core/utils/su_email.dart';
import 'package:suggest/core/widgets/app_dropdown_field.dart';
import 'package:suggest/core/widgets/app_text_field.dart';
import 'package:suggest/core/widgets/field_error.dart';
import 'package:suggest/core/widgets/note_box.dart';
import 'package:suggest/core/widgets/password_field.dart';
import 'package:suggest/core/widgets/su_email_field.dart';

Widget _host(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
          body: Padding(padding: const EdgeInsets.all(24), child: child)),
    );

Color _outline(WidgetTester tester) {
  final box = tester.widget<Container>(find.descendant(
      of: find.byType(FieldBox), matching: find.byType(Container)));
  return ((box.decoration! as BoxDecoration).border! as Border).top.color;
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('SuEmail', () {
    test('builds the full address from the typed name', () {
      expect(SuEmail.full(' Beren.Guler '), 'beren.guler@sabanciuniv.edu');
    });

    test('checks the typed name', () {
      expect(SuEmail.isValidLocalPart('beren.guler'), isTrue);
      expect(SuEmail.isValidLocalPart('beren'), isTrue);
      expect(SuEmail.isValidLocalPart(''), isFalse);
      expect(SuEmail.isValidLocalPart('beren guler'), isFalse);
      expect(SuEmail.isValidLocalPart('.beren'), isFalse);
    });

    test('splits a pasted address', () {
      expect(SuEmail.split('beren@sabanciuniv.edu'),
          (localPart: 'beren', isSuDomain: true));
      expect(SuEmail.split('beren@gmail.com'),
          (localPart: 'beren', isSuDomain: false));
      expect(SuEmail.split('beren@sab'), (localPart: 'beren', isSuDomain: true));
    });
  });

  group('SuEmailField', () {
    testWidgets('shows the fixed ending', (tester) async {
      final c = TextEditingController();
      await tester.pumpWidget(_host(SuEmailField(controller: c)));
      expect(find.text('@sabanciuniv.edu'), findsOneWidget);
      expect(find.text('SU email'), findsOneWidget);
    });

    testWidgets('drops a pasted SU ending without an error', (tester) async {
      final c = TextEditingController();
      String? changed;
      await tester.pumpWidget(
          _host(SuEmailField(controller: c, onChanged: (v) => changed = v)));
      await tester.enterText(
          find.byType(TextField), 'beren.guler@sabanciuniv.edu');
      await tester.pump();
      expect(c.text, 'beren.guler');
      expect(changed, 'beren.guler');
      expect(find.byType(FieldError), findsNothing);
    });

    testWidgets('warns about another domain, then clears', (tester) async {
      final c = TextEditingController();
      await tester.pumpWidget(_host(SuEmailField(controller: c)));
      await tester.enterText(find.byType(TextField), 'beren@gmail.com');
      await tester.pump();
      expect(c.text, 'beren');
      expect(find.text(SuEmail.wrongDomainMessage), findsOneWidget);
      expect(_outline(tester), AppColors.error);

      await tester.enterText(find.byType(TextField), 'beren.g');
      await tester.pump();
      expect(find.byType(FieldError), findsNothing);
    });

    testWidgets('shows the screen error with its action', (tester) async {
      var taps = 0;
      final c = TextEditingController(text: 'beren.guler');
      await tester.pumpWidget(_host(SuEmailField(
        controller: c,
        errorText: 'This email already has an account.',
        errorActionLabel: 'Log in instead',
        onErrorAction: () => taps++,
      )));
      await tester
          .tapOnText(find.textRange.ofSubstring('Log in instead'));
      expect(taps, 1);
    });
  });

  group('PasswordField', () {
    testWidgets('Show / Hide toggles the text', (tester) async {
      await tester.pumpWidget(_host(const PasswordField()));
      bool hidden() =>
          tester.widget<TextField>(find.byType(TextField)).obscureText;
      expect(hidden(), isTrue);
      await tester.tap(find.text('Show'));
      await tester.pump();
      expect(hidden(), isFalse);
      await tester.tap(find.text('Hide'));
      await tester.pump();
      expect(hidden(), isTrue);
    });

    testWidgets('has no toggle when showToggle is false', (tester) async {
      await tester.pumpWidget(_host(const PasswordField(showToggle: false)));
      expect(find.text('Show'), findsNothing);
    });
  });

  group('AppTextField', () {
    testWidgets('is 56 tall, outline turns green on focus', (tester) async {
      await tester.pumpWidget(_host(const AppTextField(label: 'Name')));
      expect(tester.getSize(find.byType(FieldBox)).height, 56);
      expect(_outline(tester), AppColors.inputBorder);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(_outline(tester), AppColors.primary);
    });

    testWidgets('error replaces the helper text', (tester) async {
      await tester.pumpWidget(_host(const AppTextField(
          label: 'Course', helperText: 'Search by code or title.')));
      expect(find.text('Search by code or title.'), findsOneWidget);

      await tester.pumpWidget(_host(const AppTextField(
          label: 'Course',
          helperText: 'Search by code or title.',
          errorText: 'Choose a course.')));
      expect(find.text('Search by code or title.'), findsNothing);
      expect(find.text('Choose a course.'), findsOneWidget);
      expect(_outline(tester), AppColors.error);
    });

    testWidgets('optional adds "(optional)" to the label', (tester) async {
      await tester.pumpWidget(
          _host(const AppTextField(label: 'Minor', optional: true)));
      expect(find.textContaining('(optional)', findRichText: true),
          findsOneWidget);
    });
  });

  group('AppDropdownField', () {
    testWidgets('picks an item', (tester) async {
      String? picked;
      await tester.pumpWidget(_host(StatefulBuilder(
        builder: (context, setState) => AppDropdownField<String>(
          label: 'Major',
          hintText: 'Choose your major',
          items: const ['Computer Science', 'Economics'],
          value: picked,
          onChanged: (v) => setState(() => picked = v),
        ),
      )));
      expect(find.text('Choose your major'), findsOneWidget);
      await tester.tap(find.text('Choose your major'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Economics').last);
      await tester.pumpAndSettle();
      expect(picked, 'Economics');
    });

    testWidgets('locked field does not open', (tester) async {
      await tester.pumpWidget(_host(const AppDropdownField<String>(
        label: 'Term',
        hintText: 'Pick a course first',
        items: ['Fall 2025'],
        value: null,
        onChanged: null,
      )));
      await tester.tap(find.text('Pick a course first'));
      await tester.pumpAndSettle();
      expect(find.text('Fall 2025'), findsNothing);
    });
  });

  testWidgets('NoteBox uses grey for info and red for errors', (tester) async {
    await tester.pumpWidget(_host(const Column(children: [
      NoteBox.info('Look in Junk or Spam.'),
      NoteBox.error('Not verified yet.'),
    ])));
    expect(find.byIcon(Icons.info_outline), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
    expect(tester.widget<Text>(find.text('Not verified yet.')).style!.color,
        AppColors.error);
  });
}
