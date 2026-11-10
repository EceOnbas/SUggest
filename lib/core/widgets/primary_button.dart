import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The filled green pill: the one main action of a screen.
///
/// Pass `onPressed: null` to fade it until the form is valid.
/// Set [loading] while a request is running; taps are ignored meanwhile.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? () {} : onPressed,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppColors.onPrimary),
            )
          : Text(label),
    );
  }
}
