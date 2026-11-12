/// How a typed answer compares with the expected one.
enum TypedAnswerMatch {
  exact,

  /// Accepted with one typo: a letter missing, added, replaced, or two
  /// neighbouring letters swapped.
  oneTypo,
  wrong;

  bool get isAccepted => this != wrong;

  /// Compares [typed] with [expected], ignoring case, accents and spaces.
  /// Hyphens and apostrophes count as spaces: "Oulan Bator" is
  /// "Oulan-Bator".
  ///
  /// One typo is forgiven, except on answers shorter than
  /// [minLengthForTypo] characters, where it would accept another word, and
  /// on digits, where it would accept another number.
  static TypedAnswerMatch compare(String typed, String expected) {
    final given = _normalize(typed);
    final wanted = _normalize(expected);
    if (given == wanted) {
      return wanted.isEmpty ? wrong : exact;
    } else if (wanted.length >= minLengthForTypo &&
        _isOneTypoAway(given, wanted)) {
      return oneTypo;
    } else {
      return wrong;
    }
  }

  static const int minLengthForTypo = 4;

  static const Set<String> _spaceLike = {'-', '‐', "'", '’'};

  static String _normalize(String text) {
    final buffer = StringBuffer();
    for (final rune in text.toLowerCase().runes) {
      final character = String.fromCharCode(rune);
      if (character.trim().isNotEmpty && !_spaceLike.contains(character)) {
        buffer.write(_withoutAccents[character] ?? character);
      }
    }
    return buffer.toString();
  }

  static bool _isOneTypoAway(String given, String wanted) {
    final lengthGap = given.length - wanted.length;
    if (lengthGap.abs() > 1) {
      return false;
    }
    var start = 0;
    while (start < given.length &&
        start < wanted.length &&
        given[start] == wanted[start]) {
      start++;
    }
    if (lengthGap != 0) {
      // One letter added or missing at [start].
      final longer = lengthGap > 0 ? given : wanted;
      final shorter = lengthGap > 0 ? wanted : given;
      return !_isDigit(longer[start]) &&
          longer.substring(start + 1) == shorter.substring(start);
    }
    final replaced =
        !_isDigit(given[start]) &&
        !_isDigit(wanted[start]) &&
        given.substring(start + 1) == wanted.substring(start + 1);
    final swapped =
        start + 1 < given.length &&
        given[start] == wanted[start + 1] &&
        given[start + 1] == wanted[start] &&
        !_isDigit(given[start]) &&
        !_isDigit(given[start + 1]) &&
        given.substring(start + 2) == wanted.substring(start + 2);
    return replaced || swapped;
  }

  static bool _isDigit(String character) =>
      character.codeUnitAt(0) >= 0x30 && character.codeUnitAt(0) <= 0x39;

  static const Map<String, String> _withoutAccents = {
    'à': 'a', 'á': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', //
    'æ': 'ae', 'ç': 'c', //
    'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e', //
    'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i', //
    'ñ': 'n', //
    'ò': 'o', 'ó': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'œ': 'oe', //
    'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u', //
    'ý': 'y', 'ÿ': 'y', 'ß': 'ss', //
  };
}
