import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';

/// An [AppTextField] that lists matching suggestions under it while the
/// user types, like a search box. Tapping a suggestion fills the field.
///
/// [suggestionsFor] returns the suggestions for the typed text.
/// [onChanged] runs both when the user types and when a suggestion is
/// picked. [onClear] adds a ✕ button inside the field.
class SuggestionField extends StatefulWidget {
  const SuggestionField({
    super.key,
    required this.label,
    required this.controller,
    required this.suggestionsFor,
    this.focusNode,
    this.optional = false,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.onChanged,
    this.onClear,
  });

  final String label;
  final TextEditingController controller;
  final Iterable<String> Function(String text) suggestionsFor;
  final FocusNode? focusNode;
  final bool optional;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  @override
  State<SuggestionField> createState() => _SuggestionFieldState();
}

class _SuggestionFieldState extends State<SuggestionField> {
  FocusNode? _ownNode;
  FocusNode get _node => widget.focusNode ?? (_ownNode ??= FocusNode());

  @override
  void dispose() {
    _ownNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      // The suggestion list is as wide as the field.
      builder: (context, box) => RawAutocomplete<String>(
        textEditingController: widget.controller,
        focusNode: _node,
        optionsBuilder: (value) => widget.suggestionsFor(value.text),
        onSelected: (choice) => widget.onChanged?.call(choice),
        fieldViewBuilder: (context, controller, focusNode, onSubmitted) =>
            AppTextField(
              label: widget.label,
              optional: widget.optional,
              controller: controller,
              focusNode: focusNode,
              hintText: widget.hintText,
              helperText: widget.helperText,
              errorText: widget.errorText,
              enabled: widget.enabled,
              autocorrect: false,
              textCapitalization: TextCapitalization.words,
              onChanged: widget.onChanged,
              onSubmitted: (_) => onSubmitted(),
              boxPadding: widget.onClear == null
                  ? const EdgeInsets.symmetric(horizontal: 18)
                  : const EdgeInsets.only(left: 18, right: 4),
              suffix: widget.onClear == null || !widget.enabled
                  ? null
                  : IconButton(
                      tooltip: 'Clear ${widget.label}',
                      onPressed: widget.onClear,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.muted,
                      ),
                    ),
            ),
        optionsViewBuilder: (context, onSelected, options) => _SuggestionList(
          width: box.maxWidth,
          options: options.toList(),
          onSelected: onSelected,
        ),
      ),
    );
  }
}

/// The floating list of suggestions under a [SuggestionField].
class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.width,
    required this.options,
    required this.onSelected,
  });

  final double width;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xs),
        child: Material(
          color: AppColors.surface,
          elevation: 4,
          borderRadius: BorderRadius.circular(AppRadius.input),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width, maxHeight: 240),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, i) => InkWell(
                onTap: () => onSelected(options[i]),
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: AppSpacing.minTap,
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Text(options[i], style: AppTextStyles.body),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
