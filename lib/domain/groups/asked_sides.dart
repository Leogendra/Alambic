/// Which face each display of a card of a group asks.
enum AskedSides {
  /// Always the front.
  front,

  /// Always the back, answered with the front.
  back,

  /// The front or the back, one chance in two, drawn at every display.
  random,
}
