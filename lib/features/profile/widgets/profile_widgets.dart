import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/note_box.dart';
import '../../../core/widgets/text_link.dart';

/// The style of the small outlined pills on My Profile ("Log out",
/// "Edit Review", "Delete Review"). [color] tints the text and outline,
/// for example red for deleting.
ButtonStyle compactPillStyle({Color? color}) => OutlinedButton.styleFrom(
  minimumSize: const Size(AppSpacing.minTap, AppSpacing.minTap),
  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
  foregroundColor: color ?? AppColors.ink,
  side: BorderSide(color: color ?? AppColors.inputBorder, width: 1.5),
  textStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
);

/// A card on My Profile with a title, a link such as "Edit" and its
/// rows.
class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.onEdit,
    required this.child,
    this.actionLabel = 'Edit',
  });

  final String title;
  final VoidCallback onEdit;
  final Widget child;

  /// The link's text, for example "Manage".
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      outlined: true,
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(title, style: AppTextStyles.bodyStrong),
                ),
              ),
              Semantics(
                label: '$actionLabel $title',
                excludeSemantics: true,
                button: true,
                child: TextLink(label: actionLabel, onPressed: onEdit),
              ),
            ],
          ),
          const Divider(color: AppColors.borderStrong),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

/// A label on the left and its value on the right, for example
/// "Handle   bosphorus_coder". When there is not enough room (small
/// phone or large text) the value goes under the label instead, so words
/// are not broken.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.lines});

  final String label;

  /// The value, one line per entry.
  final List<String> lines;

  /// Narrower than this (at normal text size), the row is stacked.
  static const _minSideBySideWidth = 240.0;

  @override
  Widget build(BuildContext context) {
    final labelText = Text(label, style: AppTextStyles.helper);
    final minWidth = MediaQuery.textScalerOf(context)
        .scale(_minSideBySideWidth);
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: LayoutBuilder(
          builder: (context, box) {
            if (box.maxWidth < minWidth) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [labelText, ..._values(TextAlign.left)],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: labelText),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: _values(TextAlign.right),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _values(TextAlign align) => [
    for (final line in lines)
      Text(
        line,
        textAlign: align,
        style: AppTextStyles.label.copyWith(height: 1.45),
      ),
  ];
}

/// A wide button with a dashed outline that invites the user to fill an
/// empty field, for example "+ Add Minor".
class AddFieldButton extends StatelessWidget {
  const AddFieldButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.input);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: CustomPaint(
        painter: const _DashedOutlinePainter(AppColors.inputBorder),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onPressed,
            child: Container(
              constraints: const BoxConstraints(minHeight: AppSpacing.minTap),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.label.copyWith(color: AppColors.muted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws a rounded rectangle with a dashed line around its child.
class _DashedOutlinePainter extends CustomPainter {
  const _DashedOutlinePainter(this.color);

  final Color color;

  static const _dash = 6.0;
  static const _gap = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.75),
          const Radius.circular(AppRadius.input),
        ),
      );
    // Walk along the outline, drawing a dash and skipping a gap.
    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += _dash + _gap) {
        canvas.drawPath(metric.extractPath(d, d + _dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedOutlinePainter old) => old.color != color;
}

/// "Your privacy is our priority." Tapping it shows who can see what.
class PrivacyNote extends StatefulWidget {
  const PrivacyNote({super.key});

  static const message =
      'Only your handle is public: it appears on the reviews you post. '
      'Your name, emails, phone number and academic details stay '
      'private.';

  @override
  State<PrivacyNote> createState() => _PrivacyNoteState();
}

class _PrivacyNoteState extends State<PrivacyNote> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(color: AppColors.border),
        Semantics(
          button: true,
          expanded: _open,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.input),
            onTap: () => setState(() => _open = !_open),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppSpacing.minTap),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Your privacy is our priority.',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_open) const NoteBox.info(PrivacyNote.message),
      ],
    );
  }
}
