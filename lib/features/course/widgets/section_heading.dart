import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// A heading inside a course tab, for example "Ratings", with an optional
/// grey note on the right ("from 48 students").
class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final heading = Semantics(
      header: true,
      child: Text(title, style: AppTextStyles.heading),
    );
    if (trailing == null) return heading;
    // A Wrap moves the note under the title when they do not fit side by
    // side (narrow screen or large text).
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: AppSpacing.md,
      children: [
        heading,
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(trailing!, style: AppTextStyles.helper),
        ),
      ],
    );
  }
}
