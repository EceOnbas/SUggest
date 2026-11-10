import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';

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
              Text('SUggest', style: AppTextStyles.wordmark),
              const SizedBox(height: AppSpacing.lg),
              Text('Know the course before you register.',
                  style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.md),
              Text('Ratings and reviews from Sabancı students.',
                  style: AppTextStyles.lead),
              const Spacer(),
              FilledButton(onPressed: () {}, child: const Text('Create account')),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton(onPressed: () {}, child: const Text('Log in')),
              const SizedBox(height: AppSpacing.sm),
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
