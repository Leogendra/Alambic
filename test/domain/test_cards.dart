import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';

/// A card as stored, active by default; every field can be set.
Flashcard testCard({
  int id = 1,
  int groupId = 1,
  String? frontText = 'Pérou',
  String? frontImagePath,
  String? backText = 'Lima',
  String? backImagePath,
  int? presetId,
  bool suspended = false,
  DateTime? createdAt,
  CardState state = CardState.active,
  int? step,
  DateTime? dueAt,
  DateTime? lastReviewedAt,
  DateTime? notifiedAt,
  int? queuePosition,
}) => Flashcard(
  id: id,
  groupId: groupId,
  frontText: frontText,
  frontImagePath: frontImagePath,
  backText: backText,
  backImagePath: backImagePath,
  presetId: presetId,
  suspended: suspended,
  createdAt: createdAt ?? DateTime(2026, 11, 1),
  state: state,
  step: step,
  dueAt: dueAt,
  lastReviewedAt: lastReviewedAt,
  notifiedAt: notifiedAt,
  queuePosition: queuePosition,
);
