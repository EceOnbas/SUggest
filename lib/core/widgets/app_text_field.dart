import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'field_error.dart';

/// The label above an input. [optional] adds a grey "(optional)".
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.optional = false});

  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(text: text, style: AppTextStyles.label, children: [
        if (optional)
          TextSpan(
            text: ' (optional)',
            style: AppTextStyles.label
                .copyWith(fontWeight: FontWeight.w400, color: AppColors.muted),
          ),
      ]),
    );
  }
}

/// The white rounded box every input sits in: grey outline, green when
/// focused, red when there is an error.
class FieldBox extends StatelessWidget {
  const FieldBox({
    super.key,
    required this.child,
    this.focused = false,
    this.hasError = false,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 18),
  });

  final Widget child;
  final bool focused;
  final bool hasError;
  final bool enabled;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final color = hasError
        ? AppColors.error
        : focused
            ? AppColors.primary
            : enabled
                ? AppColors.inputBorder
                : AppColors.border;
    final width = (hasError || focused) ? 2.0 : 1.5;
    return Container(
      height: AppSpacing.inputHeight,
      // Keep the content still when the outline gets thicker.
      padding: padding - EdgeInsets.symmetric(horizontal: width - 1.5),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: enabled ? AppColors.surface : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: color, width: width),
      ),
      child: child,
    );
  }
}

/// A text input with its label above and its error below.
///
/// The error appears under the field in red with an icon; pass
/// [errorText] as null to hide it. [helperText] is the grey hint that says
/// what to do next. [suffix] sits inside the box on the right.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.optional = false,
    this.controller,
    this.focusNode,
    this.hintText,
    this.helperText,
    this.errorText,
    this.errorActionLabel,
    this.onErrorAction,
    this.suffix,
    this.boxPadding = const EdgeInsets.symmetric(horizontal: 18),
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autocorrect = true,
    this.autofillHints,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final bool optional;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? errorActionLabel;
  final VoidCallback? onErrorAction;
  final Widget? suffix;
  final EdgeInsets boxPadding;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  FocusNode? _ownNode;
  FocusNode get _node => widget.focusNode ?? (_ownNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _node.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(AppTextField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownNode)?.removeListener(_onFocus);
      _node.addListener(_onFocus);
    }
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _node.removeListener(_onFocus);
    _ownNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.errorText;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(widget.label, optional: widget.optional),
        const SizedBox(height: AppSpacing.sm),
        FieldBox(
          focused: _node.hasFocus,
          hasError: error != null,
          enabled: widget.enabled,
          padding: widget.boxPadding,
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  label: widget.label,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _node,
                    enabled: widget.enabled,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    textCapitalization: widget.textCapitalization,
                    autocorrect: widget.autocorrect,
                    enableSuggestions: widget.autocorrect,
                    autofillHints: widget.autofillHints,
                    inputFormatters: widget.inputFormatters,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    style: AppTextStyles.input,
                    cursorColor: AppColors.primary,
                    // The outline is drawn by FieldBox, so the TextField
                    // itself has no border or fill.
                    decoration: InputDecoration(
                      isCollapsed: true,
                      contentPadding: EdgeInsets.zero,
                      filled: false,
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              if (widget.suffix != null) widget.suffix!,
            ],
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: AppSpacing.sm),
          FieldError(
            error,
            actionLabel: widget.errorActionLabel,
            onAction: widget.onErrorAction,
          ),
        ] else if (widget.helperText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(widget.helperText!, style: AppTextStyles.helper),
        ],
      ],
    );
  }
}
