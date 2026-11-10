import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// The back arrow at the top left of a screen.
///
/// Goes back one screen by default; pass [onPressed] to do something else.
/// It is shifted 12 px to the left so the arrow lines up with the page text.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed, this.tooltip = 'Back'});

  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(-12, 0),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
        constraints: const BoxConstraints.tightFor(
            width: AppSpacing.minTap, height: AppSpacing.minTap),
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.chevron_left_rounded,
            size: 30, color: AppColors.ink),
      ),
    );
  }
}
