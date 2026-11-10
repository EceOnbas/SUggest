import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// A text-only button, for example "Forgot password?" or "Skip for now".
///
/// Green and bold by default. [muted] is the quiet grey version used for
/// "Wrong email? Start over".
class TextLink extends StatelessWidget {
  const TextLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.muted = false,
    this.fontSize = 15,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool muted;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(AppSpacing.minTap, AppSpacing.minTap),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        foregroundColor: muted ? AppColors.muted : AppColors.primary,
        textStyle: AppTextStyles.link.copyWith(
          fontSize: fontSize,
          fontWeight: muted ? FontWeight.w600 : FontWeight.w700,
        ),
      ),
      child: Text(label),
    );
  }
}

/// A centered grey sentence that ends in a green link, for example
/// "New here? **Create account**".
class PromptLink extends StatefulWidget {
  const PromptLink({
    super.key,
    required this.prompt,
    required this.linkLabel,
    required this.onPressed,
  });

  final String prompt;
  final String linkLabel;
  final VoidCallback onPressed;

  @override
  State<PromptLink> createState() => _PromptLinkState();
}

class _PromptLinkState extends State<PromptLink> {
  late final TapGestureRecognizer _tap = TapGestureRecognizer()
    ..onTap = () => widget.onPressed();

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTap),
      child: Center(
        child: Text.rich(
          TextSpan(
            text: '${widget.prompt} ',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
            children: [
              TextSpan(
                text: widget.linkLabel,
                style: AppTextStyles.bodyStrong
                    .copyWith(color: AppColors.primary),
                recognizer: _tap,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
