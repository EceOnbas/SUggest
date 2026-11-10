import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_text_field.dart';
import 'field_error.dart';

/// A pick-one field (major, term, instructor…) with the same look as
/// [AppTextField]: label above, white box, error below.
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
    this.itemLabel,
    this.optional = false,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
  });

  final String label;
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;

  /// Text shown for an item; defaults to `item.toString()`.
  final String Function(T item)? itemLabel;
  final bool optional;
  final String? hintText;
  final String? helperText;
  final String? errorText;

  /// False locks the field, for example Term until a course is picked.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final labelOf = itemLabel ?? (T item) => item.toString();
    final active = enabled && onChanged != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(label, optional: optional),
        const SizedBox(height: AppSpacing.sm),
        FieldBox(
          hasError: errorText != null,
          enabled: active,
          padding: const EdgeInsets.only(left: 18, right: 10),
          child: Semantics(
            label: label,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                onChanged: active ? onChanged : null,
                hint: hintText == null
                    ? null
                    : Text(hintText!,
                        style: AppTextStyles.input
                            .copyWith(color: AppColors.muted)),
                disabledHint: hintText == null
                    ? null
                    : Text(hintText!,
                        style: AppTextStyles.input
                            .copyWith(color: AppColors.muted)),
                style: AppTextStyles.input,
                dropdownColor: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.input),
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    color: active ? AppColors.ink : AppColors.inputBorder),
                items: [
                  for (final item in items)
                    DropdownMenuItem<T>(
                      value: item,
                      child:
                          Text(labelOf(item), overflow: TextOverflow.ellipsis),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          FieldError(errorText!),
        ] else if (helperText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(helperText!, style: AppTextStyles.helper),
        ],
      ],
    );
  }
}
