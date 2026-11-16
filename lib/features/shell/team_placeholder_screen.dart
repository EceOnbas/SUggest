import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';

/// A stand-in for a screen that is still being built, showing what it
/// will be and who builds it. Replace it with the real screen.
class TeamPlaceholderScreen extends StatelessWidget {
  const TeamPlaceholderScreen({
    super.key,
    required this.title,
    required this.owner,
    required this.description,
    this.actions = const [],
    this.showBackButton = false,
  });

  final String title;

  /// The team member who builds this screen.
  final String owner;
  final String description;

  /// Buttons for reaching screens that already exist.
  final List<Widget> actions;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showBackButton ? AppBar() : null,
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.pagePadding,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Coming soon · $owner', style: AppTextStyles.label),
                  const SizedBox(height: AppSpacing.sm),
                  Text(description, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            for (final action in actions) ...[
              const SizedBox(height: AppSpacing.md),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
