/// The rules a new password must meet. Create account shows each one and
/// ticks it green as the user types.
class PasswordRule {
  const PasswordRule(this.label, this._test);

  final String label;
  final bool Function(String password) _test;

  bool isMetBy(String password) => _test(password);

  static final minLength = PasswordRule(
    'At least 8 characters',
    (p) => p.length >= 8,
  );

  static final hasNumber = PasswordRule(
    'At least one number',
    (p) => p.contains(RegExp(r'\d')),
  );

  static final all = [minLength, hasNumber];

  static bool allMetBy(String password) =>
      all.every((rule) => rule.isMetBy(password));
}
