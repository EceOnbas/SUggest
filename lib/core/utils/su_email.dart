/// Helpers for Sabancı University email addresses.
///
/// Users only type the part before the @; the ending is fixed, so a wrong
/// domain cannot be entered.
abstract final class SuEmail {
  static const domain = '@sabanciuniv.edu';

  static const wrongDomainMessage = 'Only @sabanciuniv.edu addresses can join.';

  static final _localPart = RegExp(r'^[a-z0-9]+([._-][a-z0-9]+)*$');

  /// The full address for a typed name: `beren.guler` → `beren.guler@sabanciuniv.edu`.
  static String full(String localPart) => '${clean(localPart)}$domain';

  /// Trims and lowercases what the user typed.
  static String clean(String localPart) => localPart.trim().toLowerCase();

  /// True when the typed name can be the start of an SU address.
  static bool isValidLocalPart(String localPart) =>
      _localPart.hasMatch(clean(localPart));

  /// Splits typed or pasted text that contains an @.
  ///
  /// Returns the part before the @ and whether the part after it is the SU
  /// domain, so the field can drop the ending and warn about a wrong one.
  static ({String localPart, bool isSuDomain}) split(String text) {
    final at = text.indexOf('@');
    if (at < 0) return (localPart: text, isSuDomain: true);
    final typedDomain = text.substring(at).trim().toLowerCase();
    return (
      localPart: text.substring(0, at),
      // While the user is still typing the ending, do not call it wrong.
      isSuDomain: domain.startsWith(typedDomain),
    );
  }
}
