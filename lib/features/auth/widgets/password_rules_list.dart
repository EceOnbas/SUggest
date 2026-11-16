import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/password_rules.dart';

/// The password rules under the password field.
///
/// A met rule turns green with a tick. An unmet rule stays grey with an
/// empty circle while the user is typing; once [showFailures] is true
/// (the user left the field) it turns red with a cross and a hint.
class PasswordRulesList extends StatelessWidget {
  const PasswordRulesList({
    super.key,
    required this.password,
    this.showFailures = false,
  });

  final String password;
  final bool showFailures;

  String _hintFor(PasswordRule rule) {
    if (rule == PasswordRule.hasNumber &&
        password.isNotEmpty &&
        password.length <= 16) {
      return '. Add a digit, like ${password}7.';
    }
    return '.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final rule in PasswordRule.all)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: _RuleRow(
              rule: rule,
              met: rule.isMetBy(password),
              failed: showFailures && !rule.isMetBy(password),
              hint: _hintFor(rule),
            ),
          ),
      ],
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({
    required this.rule,
    required this.met,
    required this.failed,
    required this.hint,
  });

  final PasswordRule rule;
  final bool met;
  final bool failed;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final color = met
        ? AppColors.primary
        : failed
        ? AppColors.error
        : AppColors.muted;
    final icon = met
        ? Icons.check_rounded
        : failed
        ? Icons.close_rounded
        : Icons.radio_button_unchecked;
    final status = met ? 'met' : 'not met';
    return Semantics(
      label: '${rule.label}, $status',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              failed ? '${rule.label}$hint' : rule.label,
              style: AppTextStyles.label.copyWith(color: color, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
