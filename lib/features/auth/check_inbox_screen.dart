import 'package:flutter/material.dart';

import '../../core/art/onigiri.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/cooldown_button.dart';
import '../../core/widgets/fill_scroll_view.dart';
import '../../core/widgets/note_box.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/text_link.dart';
import '../../services/auth_service.dart';

/// Shown after Create account: a verification link was emailed.
///
/// "I've verified" checks again; the app also checks on its own when it
/// is opened again. If the email is still not verified, a red note says
/// what to do. Resend waits 60 seconds between sends.
class CheckInboxScreen extends StatefulWidget {
  const CheckInboxScreen({super.key});

  static const notVerifiedMessage =
      'Not verified yet. Open the email from SUggest, tap the link, then '
      'try again.';

  @override
  State<CheckInboxScreen> createState() => _CheckInboxScreenState();
}

class _CheckInboxScreenState extends State<CheckInboxScreen>
    with WidgetsBindingObserver {
  bool _checking = false;
  bool _notVerified = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Coming back from the mail app: check quietly, without an error.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _check(showError: false);
  }

  Future<void> _check({required bool showError}) async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      final verified = await AuthScope.of(context).checkEmailVerified();
      if (!mounted) return;
      if (verified) {
        await AppRoutes.restart(context);
      } else if (showError) {
        setState(() => _notVerified = true);
      }
    } on AuthException {
      if (mounted && showError) {
        AppToast.show(
          context,
          'No connection. Check your internet and try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _resend() async {
    await AuthScope.of(context).resendVerificationEmail();
    if (mounted) AppToast.show(context, 'Verification email sent.');
  }

  /// Signs out of the half-made account and opens Create account again.
  Future<void> _startOver() async {
    final navigator = Navigator.of(context);
    await AuthScope.of(context).logOut();
    navigator
      ..pushNamedAndRemoveUntil(AppRoutes.start, (_) => false)
      ..pushNamed(AppRoutes.signUp);
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthScope.of(context).email ?? 'your SU email';
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: SafeArea(
        child: FillScrollView(
          padding: AppSpacing.pagePadding,
          top: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: (screenHeight * 0.1).clamp(24.0, 88.0)),
              const Onigiri(pose: OnigiriPose.hello, size: 112),
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: Text('Check your inbox', style: AppTextStyles.title),
              ),
              const SizedBox(height: AppSpacing.md),
              Text.rich(
                TextSpan(
                  style: AppTextStyles.lead,
                  children: [
                    const TextSpan(text: 'We sent a link to '),
                    TextSpan(
                      text: email,
                      style: AppTextStyles.lead.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '. Tap it to verify your email, then come back '
                          'here.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _notVerified
                  ? const NoteBox.error(CheckInboxScreen.notVerifiedMessage)
                  : const NoteBox.info(
                      "Can't find it? Look in Junk or Spam. The email "
                      'comes from SUggest.',
                    ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _notVerified
                    ? 'Link not working or too old? Send a new email below; '
                          'the old link stops working.'
                    : 'When you come back to the app we check again '
                          'automatically.',
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
                  label: "I've verified",
                  loading: _checking,
                  onPressed: () => _check(showError: true),
                ),
                const SizedBox(height: 6),
                CooldownButton(label: 'Resend email', onPressed: _resend),
                Center(
                  child: TextLink(
                    label: 'Wrong email? Start over',
                    muted: true,
                    onPressed: _startOver,
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
