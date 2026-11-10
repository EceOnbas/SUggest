import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// The short message shown after an action, for example
/// "Review submitted successfully."
///
/// It closes after about 3.5 seconds or with the ✕. A new toast replaces
/// the one on screen. Use [isError] for failures such as
/// "Failed to save changes."
abstract final class AppToast {
  static const duration = Duration(milliseconds: 3500);

  static void show(BuildContext context, String message,
      {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: isError ? AppColors.error : AppColors.ink,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.note)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.only(left: 16),
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                size: 20,
                color: AppColors.onPrimary,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onPrimary, fontWeight: FontWeight.w600),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: messenger.hideCurrentSnackBar,
                icon: const Icon(Icons.close,
                    size: 20, color: AppColors.onPrimary),
              ),
            ],
          ),
        ),
      );
  }
}
