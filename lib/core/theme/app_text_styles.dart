import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Schibsted Grotesk everywhere: bold titles, regular body, semibold labels.
abstract final class AppTextStyles {
  static TextStyle _base(double size, FontWeight weight,
          {double? height, double? letterSpacing, Color color = AppColors.ink}) =>
      GoogleFonts.schibstedGrotesk(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
        color: color,
      );

  /// Welcome headline (36).
  static TextStyle get display =>
      _base(36, FontWeight.w800, height: 1.04, letterSpacing: -1.26);

  /// Screen title such as "Welcome back" (34).
  static TextStyle get title =>
      _base(34, FontWeight.w800, height: 1.05, letterSpacing: -1.19);

  /// Big course title, for example "CS 310" in the course header (30).
  static TextStyle get courseTitle =>
      _base(30, FontWeight.w800, height: 1.05, letterSpacing: -1.05);

  /// Section heading inside a screen, for example "Ratings" (20).
  static TextStyle get heading => _base(20, FontWeight.w800, height: 1.2);

  /// The "SUggest" wordmark (20).
  static TextStyle get wordmark =>
      _base(20, FontWeight.w800, letterSpacing: -0.4);

  /// Intro text under a title (17, grey).
  static TextStyle get lead =>
      _base(17, FontWeight.w400, height: 1.45, color: AppColors.muted);

  /// Text typed in inputs (17).
  static TextStyle get input => _base(17, FontWeight.w400);

  /// Text on pill buttons (17).
  static TextStyle get button => _base(17, FontWeight.w700);

  /// Normal body text (16).
  static TextStyle get body => _base(16, FontWeight.w400, height: 1.45);

  /// Bold body text, for example a list item title (16).
  static TextStyle get bodyStrong => _base(16, FontWeight.w700, height: 1.45);

  /// Links and small buttons (15).
  static TextStyle get link =>
      _base(15, FontWeight.w700, color: AppColors.primary);

  /// Secondary text (15, grey).
  static TextStyle get bodySmall =>
      _base(15, FontWeight.w400, height: 1.45, color: AppColors.muted);

  /// Field labels above inputs (14, semibold).
  static TextStyle get label => _base(14, FontWeight.w600);

  /// Help and error text under a field (14).
  static TextStyle get helper =>
      _base(14, FontWeight.w400, height: 1.45, color: AppColors.muted);

  /// Captions, footnotes and small chips (13).
  static TextStyle get caption =>
      _base(13, FontWeight.w400, height: 1.45, color: AppColors.muted);
}
