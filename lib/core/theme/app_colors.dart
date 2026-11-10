import 'package:flutter/material.dart';

/// Every color used in SUggest. Use these instead of hex values in widgets.
///
/// Rules from the design (Step 2.1, "One visual system on every screen"):
/// grey background, dark text, green for the main action, red only for
/// errors and deleting, warm yellow for topic tags.
abstract final class AppColors {
  // Surfaces
  static const background = Color(0xFFEDEFF2); // grey page background
  static const surface = Color(0xFFFFFFFF); // inputs, chips, cards
  static const surfaceMuted = Color(0xFFF9FAFB); // info notes, soft cards

  // Text
  static const ink = Color(0xFF101828); // titles and body text
  static const inkSoft = Color(0xFF344054); // text inside notes
  static const muted = Color(0xFF475467); // secondary text, captions

  // Lines
  static const border = Color(0xFFDDE2E8); // card outlines, dividers
  static const borderStrong = Color(0xFFD0D5DD); // tab bar and list lines
  static const inputBorder = Color(0xFF98A2B3); // input outlines

  // Main action (green)
  static const primary = Color(0xFF0F5E4A);
  static const primaryPressed = Color(0xFF0A4536);
  static const onPrimary = Color(0xFFFFFFFF);

  // Errors and deleting (red)
  static const error = Color(0xFFB42318);
  static const errorBackground = Color(0xFFFDECEA);

  // Topic tags (warm yellow)
  static const tagBackground = Color(0xFFFCEFC7);
  static const tagText = Color(0xFF7A4F01);

  // Sakura pinks: light to dark, used by the branch art and the Easy–Hard bar.
  static const sakura1 = Color(0xFFFBE3E8);
  static const sakura2 = Color(0xFFF5B8C6);
  static const sakura3 = Color(0xFFE58AA3);
  static const sakura4 = Color(0xFFB85475);
  static const sakura5 = Color(0xFF6E2443);
  static const sakuraRamp = [sakura1, sakura2, sakura3, sakura4, sakura5];

  /// Wood color of the sakura branch.
  static const bark = Color(0xFF3A2A30);

  /// Neutral bar fill for "Other" shares and empty tracks.
  static const track = Color(0xFFC3CCD8);
}
