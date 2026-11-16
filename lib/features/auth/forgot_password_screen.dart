import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/su_email.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/fill_scroll_view.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/su_email_field.dart';
import '../../core/widgets/text_link.dart';
import '../../services/auth_service.dart';

/// Asks for the SU email and sends a password reset link.
///
/// The wording never says whether the account exists ("If an account
/// uses it…"). Send reset link stays faded until an email is typed.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _email.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await AuthScope.of(context).sendPasswordReset(localPart: _email.text);
      if (!mounted) return;
      await Navigator.pushNamed(
        context,
        AppRoutes.resetLinkSent,
        arguments: SuEmail.full(_email.text),
      );
    } on AuthException {
      if (mounted) {
        AppToast.show(
          context,
          'No connection. Check your internet and try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSend = SuEmail.isValidLocalPart(_email.text);
    return Scaffold(
      body: SafeArea(
        child: FillScrollView(
          padding: AppSpacing.pagePadding,
          top: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: AppBackButton(tooltip: 'Back to log in'),
              ),
              const SizedBox(height: 40),
              Semantics(
                header: true,
                child: Text('Reset your password', style: AppTextStyles.title),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Enter your SU email. If an account uses it, we send a link '
                'to reset your password.',
                style: AppTextStyles.lead,
              ),
              const SizedBox(height: AppSpacing.xxl),
              SuEmailField(
                controller: _email,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (canSend) _send();
                },
              ),
            ],
          ),
          bottom: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(
                  label: 'Send reset link',
                  loading: _loading,
                  onPressed: canSend ? _send : null,
                ),
                const SizedBox(height: 6),
                Center(
                  child: TextLink(
                    label: 'Back to log in',
                    fontSize: 16,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
