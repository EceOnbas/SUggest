import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/password_rules.dart';
import '../../core/utils/su_email.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/fill_scroll_view.dart';
import '../../core/widgets/password_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/su_email_field.dart';
import '../../core/widgets/text_link.dart';
import '../../services/auth_service.dart';
import 'widgets/password_rules_list.dart';
import 'widgets/sprig_header.dart';

/// Create an account with the SU email, a password and the community
/// rules. The button stays faded until every field is valid; problems
/// show under their field once the user leaves it.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static const emailTakenMessage = 'This email already has an account.';
  static const badEmailMessage =
      'Use letters, numbers and dots, like name.surname.';
  static const mismatchMessage = "Passwords don't match.";

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  // A field is "touched" once the user has left it; only then do its
  // problems show, so nothing turns red while they are still typing.
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _agreed = false;
  bool _loading = false;

  /// Set when the service says the email already has an account.
  String? _emailTakenError;

  @override
  void initState() {
    super.initState();
    for (final c in [_email, _password, _repeat]) {
      c.addListener(_refresh);
    }
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) setState(() => _emailTouched = true);
    });
    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) setState(() => _passwordTouched = true);
    });
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    for (final c in [_email, _password, _repeat]) {
      c.dispose();
    }
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool get _emailValid => SuEmail.isValidLocalPart(_email.text);
  bool get _passwordValid => PasswordRule.allMetBy(_password.text);
  bool get _mismatch =>
      _repeat.text.isNotEmpty && _repeat.text != _password.text;

  bool get _canSubmit =>
      _emailValid &&
      _passwordValid &&
      _repeat.text == _password.text &&
      _agreed &&
      _emailTakenError == null;

  String? get _emailError {
    if (_emailTakenError != null) return _emailTakenError;
    if (_emailTouched && _email.text.isNotEmpty && !_emailValid) {
      return SignUpScreen.badEmailMessage;
    }
    return null;
  }

  bool get _showRuleFailures =>
      _passwordTouched && _password.text.isNotEmpty && !_passwordValid;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await AuthScope.of(context)
          .createAccount(localPart: _email.text, password: _password.text);
      // The gate opens Check your inbox for the new, unverified account.
      if (mounted) await AppRoutes.restart(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.error == AuthError.emailInUse) {
        setState(() => _emailTakenError = SignUpScreen.emailTakenMessage);
      } else {
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

  Future<void> _showRules() async {
    final agreed = await showAppBottomSheet<bool>(
      context: context,
      title: 'Community rules',
      builder: (context) => const _CommunityRules(),
    );
    if (agreed == true) setState(() => _agreed = true);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: SafeArea(
        child: FillScrollView(
          top: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SprigHeader(
                height: (screenHeight * 0.165).clamp(96.0, 140.0),
                sprig: SprigStyle.signUp,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pageGutter,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Create your account',
                        style: AppTextStyles.title,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Use your SU email. We'll email you a link to check "
                      "it's yours.",
                      style: AppTextStyles.lead,
                    ),
                    const SizedBox(height: 28),
                    SuEmailField(
                      controller: _email,
                      focusNode: _emailFocus,
                      errorText: _emailError,
                      errorActionLabel: _emailTakenError == null
                          ? null
                          : 'Log in instead',
                      onErrorAction: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.login,
                      ),
                      onChanged: (_) {
                        if (_emailTakenError != null) {
                          setState(() => _emailTakenError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    PasswordField(
                      controller: _password,
                      focusNode: _passwordFocus,
                      showToggle: false,
                      isNewPassword: true,
                      textInputAction: TextInputAction.next,
                      errorOutline: _showRuleFailures,
                    ),
                    PasswordRulesList(
                      password: _password.text,
                      showFailures: _showRuleFailures,
                    ),
                    const SizedBox(height: 20),
                    PasswordField(
                      controller: _repeat,
                      label: 'Repeat password',
                      showToggle: false,
                      isNewPassword: true,
                      errorText: _mismatch
                          ? SignUpScreen.mismatchMessage
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _RulesCheckbox(
                      value: _agreed,
                      onChanged: (v) => setState(() => _agreed = v),
                      onOpenRules: _showRules,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottom: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              28,
              AppSpacing.pageGutter,
              36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(
                  label: 'Create account',
                  loading: _loading,
                  onPressed: _canSubmit ? _submit : null,
                ),
                const SizedBox(height: 6),
                PromptLink(
                  prompt: 'Already have an account?',
                  linkLabel: 'Log in',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The community rules checkbox. Tapping the sentence ticks the box;
/// tapping "community rules" opens the full rules.
class _RulesCheckbox extends StatefulWidget {
  const _RulesCheckbox({
    required this.value,
    required this.onChanged,
    required this.onOpenRules,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final VoidCallback onOpenRules;

  @override
  State<_RulesCheckbox> createState() => _RulesCheckboxState();
}

class _RulesCheckboxState extends State<_RulesCheckbox> {
  late final _link = TapGestureRecognizer()..onTap = () => widget.onOpenRules();

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.bodySmall.copyWith(color: AppColors.ink);
    return MergeSemantics(
      child: InkWell(
        onTap: () => widget.onChanged(!widget.value),
        borderRadius: BorderRadius.circular(AppRadius.input),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Checkbox(
                value: widget.value,
                onChanged: (v) => widget.onChanged(v ?? false),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text.rich(
                  TextSpan(
                    style: style,
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'community rules',
                        style: style.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: _link,
                      ),
                      const TextSpan(
                        text:
                            ': no names of students or TAs, no insults, '
                            'reviews only for courses I took.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The rules shown in the bottom sheet, with a button that agrees.
class _CommunityRules extends StatelessWidget {
  const _CommunityRules();

  static const _rules = [
    'Review only courses you took.',
    'Do not name students or TAs.',
    'No insults. Say what helped and what did not.',
    'Reviews and posts are checked before they go public.',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final rule in _rules)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(rule, style: AppTextStyles.body)),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        PrimaryButton(
          label: 'I agree',
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}
