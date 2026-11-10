import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A rounded box with an icon and a short message.
///
/// `NoteBox.info` is the quiet grey hint ("Can't find it? Look in Junk or
/// Spam."). `NoteBox.error` is the red note for a problem with the whole
/// screen ("Not verified yet…"); it is announced by screen readers.
class NoteBox extends StatelessWidget {
  const NoteBox.info(this.message, {super.key}) : _isError = false;

  const NoteBox.error(this.message, {super.key}) : _isError = true;

  final String message;
  final bool _isError;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: _isError,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              _isError ? AppColors.errorBackground : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.note),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                _isError ? Icons.error_outline : Icons.info_outline,
                size: 20,
                color: _isError ? AppColors.error : AppColors.muted,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodySmall.copyWith(
                  color: _isError ? AppColors.error : AppColors.inkSoft,
                  fontWeight: _isError ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
