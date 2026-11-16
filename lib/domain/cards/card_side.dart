/// One of the two faces of a card, used to tell which one is asked.
enum CardSide {
  front,
  back;

  CardSide get opposite => switch (this) {
    CardSide.front => CardSide.back,
    CardSide.back => CardSide.front,
  };
}
