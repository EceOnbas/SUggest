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
            _DialogButtons(
              cancelLabel: cancelLabel,
              confirmLabel: confirmLabel,
              destructive: destructive,
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed ?? false;
}

/// The two dialog buttons: side by side with equal widths, or stacked
/// when the text is very large so neither label is cut.
class _DialogButtons extends StatelessWidget {
  const _DialogButtons({
    required this.cancelLabel,
    required this.confirmLabel,
    required this.destructive,
  });

  final String cancelLabel;
  final String confirmLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTextStyles.button.copyWith(fontSize: 16);
    final cancel = OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        textStyle: textStyle,
      ),
      onPressed: () => Navigator.pop(context, false),
      child: Text(cancelLabel),
    );
    final confirm = FilledButton(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: destructive ? AppColors.error : null,
        textStyle: textStyle,
      ),
      onPressed: () => Navigator.pop(context, true),
      child: Text(confirmLabel),
    );
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    if (largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [confirm, const SizedBox(height: 10), cancel],
      );
    }
    return Row(
      children: [
        Expanded(child: cancel),
        const SizedBox(width: 10),
        Expanded(child: confirm),
      ],
    );
  }
}
