import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

/// The outlined pill: the second action next to a [PrimaryButton].
///
/// [compact] is the slightly shorter version used under a main button,
/// for example "Resend email".
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: compact
          ? OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              textStyle: AppTextStyles.button.copyWith(fontSize: 16),
            )
          : null,
      child: Text(label),
    );
  }
}
