import 'package:flutter/material.dart';

import '../../core/art/onigiri.dart';
import '../../core/art/sakura_branch.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/fill_scroll_view.dart';
import '../../core/widgets/primary_button.dart';

/// The end of profile setup: Onigiri celebrates under a sakura branch.
/// Start exploring saves the profile and opens Home.
class AllSetScreen extends StatelessWidget {
  const AllSetScreen({super.key, required this.onStart, this.saving = false});

  final VoidCallback onStart;

  /// True while the profile is being saved.
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // A branch growing in from the top left corner.
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 300,
              child: IgnorePointer(
                child: SakuraBranch(
                  seed: 'SU all set',
                  workload: 2.6,
                  attendance: 4.2,
                  start: SakuraStart(x: -12, y: 40, angle: 0.25, length: 96),
                  flowerScale: 0.62,
                ),
              ),
            ),
            FillScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
              top: Column(
                children: [
                  SizedBox(height: (screenHeight * 0.31).clamp(120.0, 260.0)),
                  const Onigiri(pose: OnigiriPose.done, size: 160),
                  const SizedBox(height: AppSpacing.xl),
                  Semantics(
                    header: true,
                    child: Text(
                      "You're all set",
                      style: AppTextStyles.title,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      'Welcome to SUggest. Find a course, read what students '
                      "say, and add your own review when you're ready.",
                      style: AppTextStyles.lead,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              bottom: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: PrimaryButton(
                  label: 'Start exploring',
                  loading: saving,
                  onPressed: onStart,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
