import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../exchange/exchange_screen.dart';

/// Community tab: exchange maps and program pages.
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.pagePadding,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text('Community', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Learn from other Sabancı students.',
              style: AppTextStyles.lead,
            ),
            const SizedBox(height: AppSpacing.xl),
            _CommunityLink(
              icon: Icons.public_rounded,
              title: 'Exchange',
              subtitle: 'Erasmus and world maps, with posts.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ExchangeScreen()),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _CommunityLink(
              icon: Icons.school_outlined,
              title: 'Programs',
              subtitle: 'Major, minor, double major and usual route.',
              onTap: () => Navigator.pushNamed(context, AppRoutes.programs),
            ),
            const SizedBox(height: AppSpacing.md),
            _CommunityLink(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Admin panel',
              subtitle: 'Check posts before they go public.',
              onTap: () => Navigator.pushNamed(context, AppRoutes.admin),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityLink extends StatelessWidget {
  const _CommunityLink({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyStrong),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
        ],
      ),
    );
  }
}
