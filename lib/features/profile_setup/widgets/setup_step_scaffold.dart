import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/fill_scroll_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/step_progress_bar.dart';
import '../../../core/widgets/text_link.dart';

/// The frame every profile setup step shares: back arrow and progress
/// bar, "Step n of 4", the question, the step's own fields, then the main
/// button and "Skip this step".
class SetupStepScaffold extends StatelessWidget {
  const SetupStepScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.child,
    required this.onBack,
    required this.onPrimary,
    required this.onSkip,
    this.subtitle,
    this.primaryLabel = 'Continue',
  });

  static const totalSteps = 4;

  /// 1 to [totalSteps].
  final int step;
  final String title;
  final String? subtitle;

  /// The step's fields.
  final Widget child;
  final VoidCallback onBack;
  final VoidCallback onPrimary;
  final VoidCallback onSkip;
  final String primaryLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FillScrollView(
          padding: AppSpacing.pagePadding,
          top: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  AppBackButton(onPressed: onBack),
                  Expanded(
                    child: StepProgressBar(step: step, totalSteps: totalSteps),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                'Step $step of $totalSteps',
                style: AppTextStyles.label.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 6),
              Semantics(
                header: true,
                child: Text(title, style: AppTextStyles.stepTitle),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 10),
                Text(
                  subtitle!,
                  style: AppTextStyles.body.copyWith(color: AppColors.muted),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              child,
            ],
          ),
          bottom: Padding(
            padding: const EdgeInsets.only(top: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrimaryButton(label: primaryLabel, onPressed: onPrimary),
                const SizedBox(height: 6),
                Center(
                  child: TextLink(
                    label: 'Skip this step',
                    fontSize: 16,
                    onPressed: onSkip,
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
