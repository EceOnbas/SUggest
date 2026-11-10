import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// The one ThemeData of the app. Material widgets (buttons, inputs, sheets,
/// dialogs, tabs, snack bars) pick up the SUggest look from here, so plain
/// `FilledButton`, `OutlinedButton`, `TextField` and `TabBar` already match
/// the design.
abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
    final textTheme = GoogleFonts.schibstedGroteskTextTheme(base.textTheme)
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink);

    const pillShape = StadiumBorder();
    final buttonSize =
        WidgetStateProperty.all(const Size.fromHeight(AppSpacing.buttonHeight));

    OutlineInputBorder inputBorder(Color color, double width) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: color, width: width),
        );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.ink,
        error: AppColors.error,
        onError: AppColors.onPrimary,
        outline: AppColors.inputBorder,
        outlineVariant: AppColors.border,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.heading,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: buttonSize,
          shape: WidgetStateProperty.all(pillShape),
          textStyle: WidgetStateProperty.all(AppTextStyles.button),
          foregroundColor: WidgetStateProperty.all(AppColors.onPrimary),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            // Faded until the form is valid (design: "button stays faded").
            if (states.contains(WidgetState.disabled)) {
              return AppColors.primary.withValues(alpha: 0.45);
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.primaryPressed;
            }
            return AppColors.primary;
          }),
          elevation: WidgetStateProperty.all(0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: buttonSize,
          shape: WidgetStateProperty.all(pillShape),
          textStyle: WidgetStateProperty.all(AppTextStyles.button),
          foregroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.disabled)
                  ? AppColors.ink.withValues(alpha: 0.45)
                  : AppColors.ink),
          side: WidgetStateProperty.resolveWith((states) => BorderSide(
                color: states.contains(WidgetState.disabled)
                    ? AppColors.ink.withValues(alpha: 0.45)
                    : AppColors.ink,
                width: 1.5,
              )),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStateProperty.all(
              const Size(AppSpacing.minTap, AppSpacing.minTap)),
          foregroundColor: WidgetStateProperty.all(AppColors.primary),
          textStyle: WidgetStateProperty.all(AppTextStyles.link),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
        hintStyle: AppTextStyles.input.copyWith(color: AppColors.muted),
        border: inputBorder(AppColors.inputBorder, 1.5),
        enabledBorder: inputBorder(AppColors.inputBorder, 1.5),
        focusedBorder: inputBorder(AppColors.primary, 2),
        errorBorder: inputBorder(AppColors.error, 2),
        focusedErrorBorder: inputBorder(AppColors.error, 2),
        disabledBorder: inputBorder(AppColors.border, 1.5),
        errorStyle: AppTextStyles.helper
            .copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.surface),
        side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.ink,
        unselectedLabelColor: AppColors.muted,
        labelStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTextStyles.label,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.borderStrong,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceMuted,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card)),
        titleTextStyle: AppTextStyles.heading,
        contentTextStyle: AppTextStyles.body,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) =>
            AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.muted,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppColors.primary
                  : AppColors.muted,
            )),
      ),
      dividerTheme: const DividerThemeData(
          color: AppColors.border, thickness: 1, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
      ),
    );
  }
}
