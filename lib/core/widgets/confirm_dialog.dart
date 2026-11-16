import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Asks the user to confirm before something is saved or deleted.
///
/// Returns true when the confirm button is tapped, false when the user
/// cancels or taps outside. Set [destructive] for deleting, which makes
/// the confirm button red.
Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: AppColors.ink.withValues(alpha: 0.55),
    builder: (context) => Dialog(
      backgroundColor: AppColors.surfaceMuted,
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sheet),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: AppTextStyles.heading.copyWith(fontSize: 22),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.body.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            // The two buttons share the width; with very large text they
            // stack so neither label is cut.
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(120, 52),
                    textStyle: AppTextStyles.button.copyWith(fontSize: 16),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(cancelLabel),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(120, 52),
                    backgroundColor: destructive ? AppColors.error : null,
                    textStyle: AppTextStyles.button.copyWith(fontSize: 16),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed ?? false;
}
