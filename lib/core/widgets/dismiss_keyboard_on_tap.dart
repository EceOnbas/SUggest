import 'package:flutter/widgets.dart';

/// Closes the keyboard when the user taps an empty part of the screen.
///
/// Wraps the whole app (see `MaterialApp.builder` in app.dart), so every
/// screen gets it. Only taps count: dragging to scroll keeps the keyboard
/// open. Taps on a text field, button or link still go to that widget,
/// because the deepest widget under the finger wins the tap.
class DismissKeyboardOnTap extends StatelessWidget {
  const DismissKeyboardOnTap({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Also catch taps on empty space, not only on painted widgets.
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
