import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/su_email.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/cooldown_button.dart';
import '../../core/widgets/fill_scroll_view.dart';
import '../../core/widgets/primary_button.dart';
import '../../services/auth_service.dart';

/// Shown after Send reset link: three steps to follow. The new password
/// is chosen on a web page opened from the email, not in the app.
class ResetLinkSentScreen extends StatelessWidget {
  const ResetLinkSentScreen({super.key, required this.email});

  /// The full address the link was sent to.
  final String email;

  static const steps = [
    'Open the email and tap the link.',
    'Choose a new password on the page that opens in your browser.',
    'Come back and log in with it.',
  ];

  Future<void> _resend(BuildContext context) async {
    final localPart = email.replaceAll(SuEmail.domain, '');
    await AuthScope.of(context).sendPasswordReset(localPart: localPart);
    if (context.mounted) AppToast.show(context, 'Reset link sent.');
  }

  /// Goes back to Log in, which is under Forgot password in the stack.
  void _backToLogIn(BuildContext context) {
    var foundLogin = false;
    Navigator.popUntil(context, (route) {
      if (route.settings.name == AppRoutes.login) foundLogin = true;
      return foundLogin || route.isFirst;
    });
    if (!foundLogin) Navigator.pushNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FillScrollView(
          padding: AppSpacing.pagePadding,
          top: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: AppBackButton(),
              ),
              const SizedBox(height: 40),
              Semantics(
                header: true,
                child: Text('Check your inbox', style: AppTextStyles.title),
              ),
              const SizedBox(height: AppSpacing.md),
              Text.rich(
                TextSpan(
                  style: AppTextStyles.lead,
                  children: [
                    const TextSpan(text: 'If '),
                    TextSpan(
                      text: email,
                      style: AppTextStyles.lead.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' has an account, we sent a link to reset the '
                          'password.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              for (final (i, step) in steps.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: _NumberedStep(number: i + 1, text: step),
                ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Nothing yet? Look in Junk or Spam.',
                style: AppTextStyles.helper,
              ),
            ],
          ),
          bottom: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(
                  label: 'Back to log in',
                  onPressed: () => _backToLogIn(context),
                ),
                const SizedBox(height: 6),
                CooldownButton(
                  label: 'Resend link',
                  onPressed: () => _resend(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.ink,
            shape: BoxShape.circle,
          ),
          child: ExcludeSemantics(
            child: Text(
              '$number',
              style: AppTextStyles.label.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w800,
              ),
              textScaler: TextScaler.noScaling,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: AppTextStyles.body,
              semanticsLabel: 'Step $number. $text',
            ),
          ),
        ),
      ],
    );
  }
}
