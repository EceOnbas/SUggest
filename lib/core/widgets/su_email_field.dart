import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/su_email.dart';
import 'app_text_field.dart';

/// The "SU email" input: only the name is typed, the `@sabanciuniv.edu`
/// ending is fixed inside the box.
///
/// If the user types or pastes a full address, the ending is dropped. A
/// different domain shows "Only @sabanciuniv.edu addresses can join."
/// The [controller] holds only the part before the @; use
/// `SuEmail.full(controller.text)` for the whole address.
class SuEmailField extends StatefulWidget {
  const SuEmailField({
    super.key,
    required this.controller,
    this.label = 'SU email',
    this.errorText,
    this.errorActionLabel,
    this.onErrorAction,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String? errorText;
  final String? errorActionLabel;
  final VoidCallback? onErrorAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;
  final bool enabled;

  @override
  State<SuEmailField> createState() => _SuEmailFieldState();
}

class _SuEmailFieldState extends State<SuEmailField> {
  bool _wrongDomain = false;

  void _handleChanged(String text) {
    var local = text;
    var wrongDomain = false;
    if (text.contains('@')) {
      final parts = SuEmail.split(text);
      local = parts.localPart;
      wrongDomain = !parts.isSuDomain;
      widget.controller.value = TextEditingValue(
        text: local,
        selection: TextSelection.collapsed(offset: local.length),
      );
    }
    if (wrongDomain != _wrongDomain) {
      setState(() => _wrongDomain = wrongDomain);
    }
    widget.onChanged?.call(local);
  }

  @override
  Widget build(BuildContext context) {
    // A wrong pasted domain is the most useful thing to say, so it wins
    // over the error passed in by the screen.
    final showOwnError = _wrongDomain;
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      hintText: 'name.surname',
      enabled: widget.enabled,
      errorText: showOwnError ? SuEmail.wrongDomainMessage : widget.errorText,
      errorActionLabel: showOwnError ? null : widget.errorActionLabel,
      onErrorAction: showOwnError ? null : widget.onErrorAction,
      keyboardType: TextInputType.emailAddress,
      textInputAction: widget.textInputAction,
      autocorrect: false,
      autofillHints: const [AutofillHints.username],
      onChanged: _handleChanged,
      onSubmitted: widget.onSubmitted,
      suffix: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(SuEmail.domain,
            style: AppTextStyles.input.copyWith(color: AppColors.muted)),
      ),
    );
  }
}
