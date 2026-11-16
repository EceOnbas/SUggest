import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/su_email.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/fill_scroll_view.dart';
import '../../core/widgets/password_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/su_email_field.dart';
import '../../core/widgets/text_link.dart';
import '../../services/auth_service.dart';
import 'widgets/sprig_header.dart';

/// Log in with the SU email (only the name is typed) and the password.
///
/// A wrong email or password shows one message for both, so the app never
/// reveals which accounts exist. A verified user goes on to the profile
/// intro or Home; an unverified one to Check your inbox.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const wrongCredentialsMessage =
      "That email and password don't match. Try again, or reset your "
      'password.';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Checks the fields and shows any problem under its field.
  bool _validate() {
    final name = _email.text.trim();
    setState(() {
      _emailError = name.isEmpty
          ? 'Enter your SU email.'
          : SuEmail.isValidLocalPart(name)
          ? null
          : 'Use the part before the @, like name.surname.';
      _passwordError = _password.text.isEmpty ? 'Enter your password.' : null;
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;
    setState(() => _loading = true);
    try {
      await AuthScope.of(context)
          .logIn(localPart: _email.text, password: _password.text);
      if (mounted) await AppRoutes.restart(context);
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.error == AuthError.wrongCredentials) {
        setState(() => _passwordError = LoginScreen.wrongCredentialsMessage);
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
                // 264 on a tall phone, less on short ones.
                height: (screenHeight * 0.3).clamp(120.0, 264.0),
                sprig: SprigStyle.login,
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
                      child: Text('Welcome back', style: AppTextStyles.title),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Log in with your SU email.',
                      style: AppTextStyles.lead,
                    ),
                    const SizedBox(height: 28),
                    AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SuEmailField(
                            controller: _email,
                            errorText: _emailError,
                            onChanged: (_) {
                              if (_emailError != null) {
                                setState(() => _emailError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          PasswordField(
                            controller: _password,
                            errorText: _passwordError,
                            onChanged: (_) {
                              if (_passwordError != null) {
                                setState(() => _passwordError = null);
                              }
                            },
                            onSubmitted: (_) => _submit(),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextLink(
                        label: 'Forgot password?',
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.forgotPassword,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottom: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              AppSpacing.lg,
              AppSpacing.pageGutter,
              36,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(
                  label: 'Log in',
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 6),
                PromptLink(
                  prompt: 'New here?',
                  linkLabel: 'Create account',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.signUp),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
