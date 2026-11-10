import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_back_button.dart';
import 'core/widgets/primary_button.dart';
import 'core/widgets/secondary_button.dart';
import 'core/widgets/text_link.dart';

class SUggestApp extends StatelessWidget {
  const SUggestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUggest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Temporary start screen until the routes are added.
      home: const _ThemePreview(),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.pagePadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBackButton(),
              Text('SUggest', style: AppTextStyles.wordmark),
              const SizedBox(height: AppSpacing.lg),
              Text('Know the course before you register.',
                  style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.md),
              Text('Ratings and reviews from Sabancı students.',
                  style: AppTextStyles.lead),
              const Spacer(),
              PrimaryButton(label: 'Create account', onPressed: () {}),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(label: 'Log in', onPressed: () {}),
              PromptLink(
                  prompt: 'New here?',
                  linkLabel: 'Create account',
                  onPressed: () {}),
              Center(child: TextLink(label: 'Skip for now', onPressed: () {})),
              Center(
                child: Text('For @sabanciuniv.edu accounts only.',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.muted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
