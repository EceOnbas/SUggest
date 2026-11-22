import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/field_error.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../services/auth_service.dart';
import '../models/program_post.dart';

/// What the form returns when the student shares a post.
class PostDraft {
  const PostDraft({required this.topic, required this.text});

  final String topic;
  final String text;
}

/// The "Write a post" form, shown inside a bottom sheet.
///
/// Two fields: the topic (required) and the post text (at least
/// [minLength] characters). Errors show under each field after the first
/// "Share" tap and update while typing. A valid form asks for
/// confirmation, then closes the sheet with a [PostDraft].
class WritePostForm extends StatefulWidget {
  const WritePostForm({super.key});

  static const minLength = 20;
  static const topicError = 'Choose a topic.';
  static const emptyError = 'Write your post.';
  static const shortError =
      'Write at least ${WritePostForm.minLength} characters.';

  @override
  State<WritePostForm> createState() => _WritePostFormState();
}

class _WritePostFormState extends State<WritePostForm> {
  final _text = TextEditingController();
  String? _topic;

  /// Errors only show after the first "Share" tap.
  bool _triedToShare = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  String? get _topicError =>
      _triedToShare && _topic == null ? WritePostForm.topicError : null;

  String? get _textError {
    if (!_triedToShare) return null;
    final text = _text.text.trim();
    if (text.isEmpty) return WritePostForm.emptyError;
    if (text.length < WritePostForm.minLength) return WritePostForm.shortError;
    return null;
  }

  Future<void> _share() async {
    setState(() => _triedToShare = true);
    if (_topicError != null || _textError != null) return;

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Share this post?',
      message:
          'Everyone who opens this program page will see it with your '
          'handle.',
      confirmLabel: 'Share',
    );
    if (!confirmed || !mounted) return;
    Navigator.pop(
      context,
      PostDraft(topic: _topic!, text: _text.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textError = _textError;
    final handle = AuthScope.of(context).handle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDropdownField<String>(
          label: 'Topic',
          hintText: 'Choose a topic',
          items: ProgramPost.topics,
          value: _topic,
          errorText: _topicError,
          onChanged: (value) => setState(() => _topic = value),
        ),
        const SizedBox(height: AppSpacing.lg),
        const FieldLabel('Post'),
        const SizedBox(height: AppSpacing.sm),
        Semantics(
          label: 'Post',
          child: TextField(
            controller: _text,
            minLines: 4,
            maxLines: 8,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            style: AppTextStyles.input,
            cursorColor: AppColors.primary,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Ask a question or share what helped you...',
              hintMaxLines: 2,
              enabledBorder: textError == null
                  ? null
                  : OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.input),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
            ),
          ),
        ),
        if (textError != null) ...[
          const SizedBox(height: AppSpacing.sm),
          FieldError(textError),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (handle != null) ...[
          Text(
            'Posted as @$handle. Your name stays private.',
            style: AppTextStyles.helper,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        PrimaryButton(label: 'Share', onPressed: _share),
      ],
    );
  }
}
