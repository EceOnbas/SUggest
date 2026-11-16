import 'package:flutter/material.dart';

/// The layout most screens use: content at the top, actions at the
/// bottom of the screen.
///
/// On a tall phone the actions sit at the bottom edge; when the screen is
/// too short (small phone, large text, open keyboard) the whole page
/// scrolls instead of overflowing.
class FillScrollView extends StatelessWidget {
  const FillScrollView({
    super.key,
    required this.top,
    required this.bottom,
    this.padding = EdgeInsets.zero,
  });

  final Widget top;
  final Widget bottom;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = constraints.maxHeight - padding.vertical;
        return SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight.clamp(0, 1e9)),
            // spaceBetween pushes [bottom] down when there is room, without
            // measuring the children twice.
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [top, bottom],
            ),
          ),
        );
      },
    );
  }
}
