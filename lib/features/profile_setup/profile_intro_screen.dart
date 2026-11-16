import 'package:flutter/material.dart';

import '../../core/art/onigiri.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/fill_scroll_view.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/text_link.dart';

/// The first screen of profile setup: why the profile exists, that only
/// its owner sees it, and how long it takes. Start opens step 1; Skip
/// for now goes straight to Home.
class ProfileIntroScreen extends StatelessWidget {
  const ProfileIntroScreen({
    super.key,
    required this.onStart,
    required this.onSkip,
    this.skipping = false,
  });

  final VoidCallback onStart;
  final VoidCallback onSkip;

  /// True while "Skip for now" is being saved.
  final bool skipping;

  static const _points = [
    (
      Icons.lock_outline,
      'Only you can see it.',
      ' No one can open your profile, not even other students in your '
          'major.',
    ),
    (
      Icons.bar_chart_rounded,
      'It counts anonymously.',
      ' Your major and courses add to totals like "who takes CS 310", '
          'never with your name.',
    ),
    (
      Icons.schedule,
      'About two minutes.',
      ' Four short steps, and you can skip any of them.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: SafeArea(
        child: FillScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
          top: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: (screenHeight * 0.085).clamp(24.0, 72.0)),
              const Onigiri(pose: OnigiriPose.hello, size: 120),
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: Text(
                  'Set up your private profile',
                  style: AppTextStyles.title,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'It makes course stats more useful for everyone.',
                style: AppTextStyles.lead,
              ),
              const SizedBox(height: 28),
              for (final (icon, lead, rest) in _points)
                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 24, color: AppColors.primary),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            style: AppTextStyles.body,
                            children: [
                              TextSpan(
                                text: lead,
                                style: AppTextStyles.bodyStrong,
                              ),
                              TextSpan(text: rest),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          bottom: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(label: 'Start', onPressed: onStart),
                const SizedBox(height: 6),
                Center(
                  child: TextLink(
                    label: 'Skip for now',
                    fontSize: 16,
                    onPressed: skipping ? null : onSkip,
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
