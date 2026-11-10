import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The red message shown under a field, with an icon so the error is not
/// carried by color alone.
///
/// [actionLabel] adds a green link at the end, for example
/// "This email already has an account. **Log in instead**".
class FieldError extends StatefulWidget {
  const FieldError(
    this.message, {
    super.key,
    this.showIcon = true,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final bool showIcon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<FieldError> createState() => _FieldErrorState();
}

class _FieldErrorState extends State<FieldError> {
  late final TapGestureRecognizer _tap = TapGestureRecognizer()
    ..onTap = () => widget.onAction?.call();

  @override
  void dispose() {
    _tap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.helper.copyWith(
        color: AppColors.error, fontWeight: FontWeight.w600, height: 1.4);
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showIcon) ...[
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child:
                  Icon(Icons.error_outline, size: 18, color: AppColors.error),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text.rich(
              TextSpan(text: widget.message, style: style, children: [
                if (widget.actionLabel != null)
                  TextSpan(
                    text: ' ${widget.actionLabel}',
                    style: style.copyWith(
                        color: AppColors.primary, fontWeight: FontWeight.w700),
                    recognizer: _tap,
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
