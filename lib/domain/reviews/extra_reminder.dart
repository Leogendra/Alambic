/// One-off reminder added with "Review soon". Answering it is a bonus review.
class ExtraReminder {
  const ExtraReminder({
    required this.id,
    required this.directionId,
    required this.remindAt,
    required this.notifiedAt,
  });

  final int id;
  final int directionId;
  final DateTime remindAt;
  final DateTime? notifiedAt;
}
