import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/widgets/app_bottom_sheet.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../services/auth_service.dart';
import 'models/profile_details.dart';

/// Opens the "Edit Account Details" sheet. Returns the saved details, or
/// null when the sheet is closed without saving.
Future<AccountDetails?> showEditAccountSheet(
  BuildContext context,
  AccountDetails current,
) {
  return showAppBottomSheet<AccountDetails>(
    context: context,
    title: 'Edit Account Details',
    builder: (context) => EditAccountForm(initial: current),
  );
}

/// The account form. The handle is required and must be free; full name,
/// backup email and phone are optional but must look right when filled.
/// The institutional email cannot be changed.
///
/// A new handle is saved through the auth service before the sheet
/// closes. Errors appear under the fields after the first Save, then
/// update as the user types.
class EditAccountForm extends StatefulWidget {
  const EditAccountForm({super.key, required this.initial});

  final AccountDetails initial;

  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _phone = RegExp(r'^[+0-9 ()-]{7,20}$');

  /// The name is optional, but it cannot be only symbols or numbers.
  static String? nameError(String value) {
    final name = value.trim();
    if (name.isEmpty || RegExp(r'\p{L}', unicode: true).hasMatch(name)) {
      return null;
    }
    return 'Enter your name with letters, or leave it empty.';
  }

  static String? handleError(String value) {
    if (HandleRules.clean(value).isEmpty) return 'Enter a handle.';
    return HandleRules.isValid(value) ? null : HandleRules.formatMessage;
  }

  static String? backupEmailError(String value) {
    final email = value.trim();
    if (email.isEmpty || _email.hasMatch(email)) return null;
    return 'Enter a valid backup email.';
  }

  static String? phoneError(String value) {
    final phone = value.trim();
    if (phone.isEmpty || _phone.hasMatch(phone)) return null;
    return 'Enter a valid phone number.';
  }

  @override
  State<EditAccountForm> createState() => _EditAccountFormState();
}

class _EditAccountFormState extends State<EditAccountForm> {
  late final _name = TextEditingController(text: widget.initial.fullName);
  late final _handle = TextEditingController(text: widget.initial.handle);
  late final _schoolEmail = TextEditingController(
    text: widget.initial.institutionalEmail,
  );
  late final _backupEmail = TextEditingController(
    text: widget.initial.backupEmail,
  );
  late final _phone = TextEditingController(text: widget.initial.phone);

  /// Errors only show once the user has tried to save.
  bool _triedToSave = false;
  bool _saving = false;

  /// Set when the auth service says the handle is taken.
  String? _handleTaken;

  @override
  void dispose() {
    for (final c in [_name, _handle, _schoolEmail, _backupEmail, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _errorIfTried(String? Function(String) check, String value) =>
      _triedToSave ? check(value) : null;

  Future<void> _save() async {
    final hasError = [
      EditAccountForm.nameError(_name.text),
      EditAccountForm.handleError(_handle.text),
      EditAccountForm.backupEmailError(_backupEmail.text),
      EditAccountForm.phoneError(_phone.text),
    ].any((error) => error != null);
    if (hasError) {
      setState(() => _triedToSave = true);
      return;
    }
    final handle = HandleRules.clean(_handle.text);
    if (handle != widget.initial.handle) {
      setState(() => _saving = true);
      try {
        await AuthScope.of(context).changeHandle(handle);
      } on AuthException catch (e) {
        if (!mounted) return;
        setState(() {
          _saving = false;
          _triedToSave = true;
          _handleTaken = e.error == AuthError.handleInUse
              ? HandleRules.takenMessage
              : 'Could not save your handle. Try again.';
        });
        return;
      }
      if (!mounted) return;
    }
    Navigator.pop(
      context,
      widget.initial.copyWith(
        fullName: _name.text.trim(),
        handle: handle,
        backupEmail: _backupEmail.text.trim(),
        phone: _phone.text.trim(),
      ),
    );
  }

  /// Rebuilds so the errors follow what the user types.
  void _changed(String _) {
    if (_triedToSave) setState(() {});
  }

  void _handleChanged(String _) => setState(() => _handleTaken = null);

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.lg);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: 'Full Name',
          optional: true,
          controller: _name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          errorText: _errorIfTried(EditAccountForm.nameError, _name.text),
          onChanged: _changed,
        ),
        gap,
        AppTextField(
          label: 'Handle',
          controller: _handle,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          helperText:
              'Shown on your reviews instead of your name. '
              '${HandleRules.formatMessage}',
          errorText:
              _handleTaken ??
              _errorIfTried(EditAccountForm.handleError, _handle.text),
          onChanged: _handleChanged,
        ),
        gap,
        AppTextField(
          label: 'Institutional Email',
          controller: _schoolEmail,
          enabled: false,
        ),
        gap,
        AppTextField(
          label: 'Backup Email',
          optional: true,
          controller: _backupEmail,
          autocorrect: false,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          errorText: _errorIfTried(
            EditAccountForm.backupEmailError,
            _backupEmail.text,
          ),
          onChanged: _changed,
        ),
        gap,
        AppTextField(
          label: 'Phone Number',
          optional: true,
          controller: _phone,
          hintText: '+90 5XX XXX XX XX',
          helperText: 'Format: +90 5XX XXX XX XX',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.telephoneNumber],
          errorText: _errorIfTried(EditAccountForm.phoneError, _phone.text),
          onChanged: _changed,
          onSubmitted: (_) => _save(),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: 'Save Changes',
          loading: _saving,
          onPressed: _save,
        ),
      ],
    );
  }
}
