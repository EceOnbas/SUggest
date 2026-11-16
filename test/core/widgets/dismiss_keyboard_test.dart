import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:suggest/app.dart';
import 'package:suggest/core/widgets/dismiss_keyboard_on_tap.dart';
import 'package:suggest/features/auth/login_screen.dart';
import 'package:suggest/services/fake_auth_service.dart';

/// True when any text field has focus, which is when the keyboard shows.
bool _anyFieldFocused(WidgetTester tester) => tester
    .widgetList<EditableText>(find.byType(EditableText))
    .any((field) => field.focusNode.hasFocus);

Widget _host({VoidCallback? onButton}) => MaterialApp(
  builder: (context, child) => DismissKeyboardOnTap(child: child!),
  home: Scaffold(
    body: Column(
      children: [
        const TextField(key: Key('field')),
        TextButton(onPressed: onButton, child: const Text('button')),
        const SizedBox(height: 300, child: Text('empty space')),
      ],
    ),
  ),
);

void main() {
  testWidgets('tapping empty space closes the keyboard', (tester) async {
    await tester.pumpWidget(_host());
    await tester.tap(find.byKey(const Key('field')));
    await tester.pump();
    expect(_anyFieldFocused(tester), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.text('empty space'));
    await tester.pump();
    expect(_anyFieldFocused(tester), isFalse);
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('tapping the field itself keeps the keyboard open', (
    tester,
  ) async {
    await tester.pumpWidget(_host());
    await tester.tap(find.byKey(const Key('field')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('field')));
    await tester.pump();
    expect(_anyFieldFocused(tester), isTrue);
  });

  testWidgets('buttons still work while the keyboard is open', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(onButton: () => taps++));
    await tester.tap(find.byKey(const Key('field')));
    await tester.pump();
    await tester.tap(find.text('button'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('dragging to scroll keeps the keyboard open', (tester) async {
    await tester.pumpWidget(_host());
    await tester.tap(find.byKey(const Key('field')));
    await tester.pump();
    await tester.drag(find.text('empty space'), const Offset(0, -100));
    await tester.pump();
    expect(_anyFieldFocused(tester), isTrue);
  });

  testWidgets('works in the real app: Log in title closes the keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844) * 3;
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      SUggestApp(auth: FakeAuthService(delay: Duration.zero)),
    );
    await tester.ensureVisible(find.text('Log in'));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    expect(_anyFieldFocused(tester), isTrue);

    await tester.tap(find.text('Welcome back'));
    await tester.pump();
    expect(_anyFieldFocused(tester), isFalse);
  });
}
