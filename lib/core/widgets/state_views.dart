import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'primary_button.dart';
import 'secondary_button.dart';

/// Every list in the app has three extra states besides its content:
/// a loading skeleton, an empty message and an error with "Try again".
/// The widgets in this file are those three states.

/// A grey placeholder block that gently pulses while content loads.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 8,
  });

  /// Null fills the available width.
  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect "Reduce Motion": show a still block instead of pulsing.
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 1.0, end: 0.45).animate(_pulse),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// A list of placeholder cards shown while a list loads, in the same
/// layout as the real cards so the screen does not jump.
class LoadingList extends StatelessWidget {
  const LoadingList({super.key, this.itemCount = 3, this.label = 'Loading'});

  final int itemCount;

  /// Read by screen readers, for example "Loading reviews".
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: ExcludeSemantics(
        child: Column(
          children: [
            for (var i = 0; i < itemCount; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 140, height: 14),
                    SizedBox(height: AppSpacing.md),
                    SkeletonBox(),
                    SizedBox(height: AppSpacing.sm),
                    SkeletonBox(),
                    SizedBox(height: AppSpacing.sm),
                    SkeletonBox(width: 200),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown when a list has nothing in it yet, for example "No reviews yet".
/// [actionLabel] adds a button that helps fill it ("Write a review").
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return _StateMessage(
      icon: icon,
      iconColor: AppColors.muted,
      title: title,
      message: message,
      action: actionLabel == null
          ? null
          : SecondaryButton(
              label: actionLabel!, onPressed: onAction, compact: true),
    );
  }
}

/// Shown when loading failed. Says what went wrong and offers "Try again".
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = "Couldn't load this",
    this.message = 'No connection. Check your internet and try again.',
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _StateMessage(
      icon: Icons.wifi_off_rounded,
      iconColor: AppColors.error,
      title: title,
      message: message,
      action: PrimaryButton(label: 'Try again', onPressed: onRetry),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(icon, size: 36, color: iconColor),
          const SizedBox(height: AppSpacing.md),
          Text(title,
              style: AppTextStyles.heading, textAlign: TextAlign.center),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(message!,
                style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}
