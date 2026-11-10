import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_chip.dart';
import '../../core/widgets/app_dropdown_field.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/note_box.dart';
import '../../core/widgets/password_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/secondary_button.dart';
import '../../core/widgets/step_progress_bar.dart';
import '../../core/widgets/su_email_field.dart';
import '../../core/widgets/text_link.dart';

/// Shows every shared widget on one page, so the team can see what
/// exists and check it on a device.
class WidgetGalleryScreen extends StatefulWidget {
  const WidgetGalleryScreen({super.key});

  @override
  State<WidgetGalleryScreen> createState() => _WidgetGalleryScreenState();
}

class _WidgetGalleryScreenState extends State<WidgetGalleryScreen> {
  final _email = TextEditingController();
  final _takenEmail = TextEditingController(text: 'beren.guler');
  String? _major;
  String _topic = 'All';

  @override
  void dispose() {
    _email.dispose();
    _takenEmail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.lg);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.pagePadding,
          children: [
            const Align(
                alignment: Alignment.centerLeft, child: AppBackButton()),
            Text('SUggest', style: AppTextStyles.wordmark),
            const SizedBox(height: AppSpacing.md),
            Text('Shared widgets', style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.sm),
            Text('Buttons and inputs used on every screen.',
                style: AppTextStyles.lead),
            const SizedBox(height: AppSpacing.xl),
            SuEmailField(controller: _email),
            gap,
            const PasswordField(),
            gap,
            SuEmailField(
              controller: _takenEmail,
              errorText: 'This email already has an account.',
              errorActionLabel: 'Log in instead',
              onErrorAction: () {},
            ),
            gap,
            const PasswordField(
              label: 'Repeat password',
              showToggle: false,
              errorText: "Passwords don't match.",
            ),
            gap,
            AppDropdownField<String>(
              label: 'Major',
              hintText: 'Choose your major',
              items: const [
                'Computer Science and Engineering',
                'Electronics Engineering',
                'Industrial Engineering',
              ],
              value: _major,
              onChanged: (value) => setState(() => _major = value),
            ),
            gap,
            const AppDropdownField<String>(
              label: 'Term',
              optional: true,
              hintText: 'Pick a course first',
              helperText: 'Term unlocks after you choose a course.',
              items: [],
              value: null,
              onChanged: null,
            ),
            gap,
            const AppTextField(label: 'Host university', optional: true),
            gap,
            const NoteBox.info(
                "Can't find it? Look in Junk or Spam. The email comes from SUggest."),
            gap,
            const NoteBox.error(
                'Not verified yet. Open the email from SUggest, tap the link, then try again.'),
            const SizedBox(height: AppSpacing.xl),
            Text('Chips and cards', style: AppTextStyles.heading),
            const SizedBox(height: AppSpacing.md),
            const StepProgressBar(step: 2, totalSteps: 4),
            gap,
            ChipFilterRow(
              options: const [
                'All',
                'Difficulty',
                'Instructor',
                'Attendance',
                'Workload'
              ],
              selected: _topic,
              onSelected: (value) => setState(() => _topic = value),
            ),
            gap,
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spring 2026, Instructor A',
                      style: AppTextStyles.helper),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                      'The team project is most of the grade, so pick your group early.',
                      style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.sm),
                  const Wrap(spacing: 6, runSpacing: 6, children: [
                    TagChip('Workload'),
                    TagChip('Attendance'),
                    TagChip.topic('Group project'),
                  ]),
                ],
              ),
            ),
            gap,
            Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: [
              AppChip(label: 'CS 204', compact: true, onTap: () {}),
              AppChip(
                label: 'Open sheet',
                onTap: () => showAppBottomSheet<void>(
                  context: context,
                  title: 'Filter reviews',
                  builder: (context) => PrimaryButton(
                      label: 'Show 4 reviews',
                      onPressed: () => Navigator.pop(context)),
                ),
              ),
              AppChip(
                label: 'Show toast',
                onTap: () => AppToast.show(
                    context, 'Review submitted successfully.'),
              ),
              AppChip(
                label: 'Error toast',
                onTap: () => AppToast.show(context, 'Failed to save changes.',
                    isError: true),
              ),
            ]),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: 'Create account', onPressed: () {}),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(label: 'Log in', onPressed: () {}),
            const SizedBox(height: AppSpacing.md),
            const PrimaryButton(label: 'Faded until valid', onPressed: null),
            PromptLink(
                prompt: 'New here?',
                linkLabel: 'Create account',
                onPressed: () {}),
            Center(child: TextLink(label: 'Skip for now', onPressed: () {})),
          ],
        ),
      ),
    );
  }
}
