import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Opens a bottom sheet for quick edits and filters.
///
/// The sheet has a grab handle and a [title]; [builder] returns what goes
/// under them. A tap outside or a swipe down closes it. Close it from
/// inside with `Navigator.pop(context, result)`; that result is returned
/// here.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required String title,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: false,
    backgroundColor: AppColors.surfaceMuted,
    barrierColor: AppColors.ink.withValues(alpha: 0.55),
    builder: (context) => Padding(
      // Lift the sheet above the keyboard.
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.track,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(title,
                  style: AppTextStyles.heading.copyWith(fontSize: 22)),
            ),
            const SizedBox(height: 16),
            builder(context),
          ],
        ),
      ),
    ),
  );
}
