import 'package:flutter/widgets.dart';

/// Spacing, sizes and corner radii shared by every screen.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Side padding of every screen.
  static const pageGutter = 24.0;

  /// Padding of a full screen: 24 on the sides, 12 on top, 36 at the bottom.
  static const pagePadding = EdgeInsets.fromLTRB(24, 12, 24, 36);

  /// Height of the main pill buttons.
  static const buttonHeight = 56.0;

  /// Height of text inputs.
  static const inputHeight = 56.0;

  /// Smallest tap target for icons and links.
  static const minTap = 44.0;
}

abstract final class AppRadius {
  static const input = 14.0;
  static const note = 16.0;
  static const card = 20.0;
  static const sheet = 24.0;
  static const pill = 999.0;
}
