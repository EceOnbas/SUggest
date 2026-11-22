/// Search helpers shared by the My Reviews search and the course picker.
library;

/// Letters with accents, mapped to plain ones so "Yılmaz" is found by
/// "yilmaz" and "Göteborg" by "goteborg".
const _plainLetters = {
  'ı': 'i', 'İ': 'i', 'ş': 's', 'Ş': 's', 'ğ': 'g', 'Ğ': 'g', //
  'ü': 'u', 'Ü': 'u', 'ö': 'o', 'Ö': 'o', 'ç': 'c', 'Ç': 'c',
  'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'é': 'e', 'è': 'e',
  'ê': 'e', 'ë': 'e', 'í': 'i', 'î': 'i', 'ó': 'o', 'ô': 'o',
  'ú': 'u', 'û': 'u', 'ñ': 'n',
};

final _nonAlphanumeric = RegExp(r'[^a-z0-9]+');

/// Lower case, no accents, and every run of symbols or spaces turned
/// into one space: "CS-310 · Mobile" → "cs 310 mobile".
String normalizeSearchText(String value) {
  final plain = value.split('').map((c) => _plainLetters[c] ?? c).join();
  return plain.toLowerCase().replaceAll(_nonAlphanumeric, ' ').trim();
}

/// Whether [query] is found in [searchable].
///
/// It matches when:
/// - the query is empty,
/// - the query appears as typed, also ignoring spaces ("cs310" finds
///   "CS 310"), or
/// - the query has several words and each word (two letters or more)
///   appears somewhere ("instructor fall" finds "Fall 2023 · Instructor A").
bool matchesSearch(String searchable, String query) {
  final text = normalizeSearchText(searchable);
  final q = normalizeSearchText(query);
  if (q.isEmpty) return true;
  if (text.contains(q)) return true;
  if (text.replaceAll(' ', '').contains(q.replaceAll(' ', ''))) return true;
  final words = q.split(' ');
  return words.length > 1 &&
      words.every((word) => word.length > 1 && text.contains(word));
}
