import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The segmented bar at the top of profile setup: one segment per step,
/// green up to the current one.
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.step,
    required this.totalSteps,
  }) : assert(step >= 1 && step <= totalSteps);

  /// The current step, starting at 1.
  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step $step of $totalSteps',
      child: Row(
        children: [
          for (var i = 1; i <= totalSteps; i++) ...[
            if (i > 1) const SizedBox(width: 6),
            Expanded(
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: i <= step ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
