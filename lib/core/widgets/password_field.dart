import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_text_field.dart';

/// A password input. With [showToggle] it has the Show / Hide button
/// inside the box (Log in); without it, it is a plain hidden field
/// (Create account).
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    this.controller,
    this.label = 'Password',
    this.showToggle = true,
    this.isNewPassword = false,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.done,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String label;
  final bool showToggle;

  /// True on Create account, so the phone offers to save a new password
  /// instead of filling in an old one.
  final bool isNewPassword;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;
  final bool enabled;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      obscureText: !_shown,
      enabled: widget.enabled,
      errorText: widget.errorText,
      autocorrect: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      autofillHints: [
        widget.isNewPassword
            ? AutofillHints.newPassword
            : AutofillHints.password
      ],
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      boxPadding: widget.showToggle
          ? const EdgeInsets.only(left: 18, right: 6)
          : const EdgeInsets.symmetric(horizontal: 18),
      suffix: widget.showToggle
          ? Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Semantics(
                button: true,
                toggled: _shown,
                label: _shown ? 'Hide password' : 'Show password',
                excludeSemantics: true,
                child: TextButton(
                  onPressed: () => setState(() => _shown = !_shown),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(64, AppSpacing.minTap),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.ink,
                    shape: const StadiumBorder(),
                    textStyle: AppTextStyles.label
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                  child: Text(_shown ? 'Hide' : 'Show'),
                ),
              ),
            )
          : null,
    );
  }
}
