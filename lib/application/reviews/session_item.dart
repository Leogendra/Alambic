import '../../domain/cards/card_side.dart';

/// One card to answer in a session, with the face drawn for this display.
class SessionItem {
  const SessionItem({required this.cardId, required this.askedSide});

  final int cardId;
  final CardSide askedSide;
}
