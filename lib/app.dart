import 'package:flutter/material.dart';

import 'core/theme/app_spacing.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_back_button.dart';
import 'core/widgets/app_dropdown_field.dart';
import 'core/widgets/app_text_field.dart';
import 'core/widgets/note_box.dart';
import 'core/widgets/password_field.dart';
import 'core/widgets/primary_button.dart';
import 'core/widgets/secondary_button.dart';
import 'core/widgets/su_email_field.dart';
import 'core/widgets/text_link.dart';

class SUggestApp extends StatelessWidget {
  const SUggestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUggest',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Temporary start screen until the routes are added.
      home: const _WidgetPreview(),
    );
  }
}

/// Shows the shared widgets on one page so they can be checked on a
/// device. Removed when the real screens and routes arrive.
class _WidgetPreview extends StatefulWidget {
  const _WidgetPreview();

  @override
  State<_WidgetPreview> createState() => _WidgetPreviewState();
}

class _WidgetPreviewState extends State<_WidgetPreview> {
  final _email = TextEditingController();
  final _takenEmail = TextEditingController(text: 'beren.guler');
  String? _major;

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
