/// New cards a group receives on a day of Home's timeline: the cards its
/// distillation introduced and that were never answered, and those its
/// rhythm should still introduce.
class TimelineArrival {
  const TimelineArrival({required this.groupId, required this.count});

  final int groupId;
  final int count;
}
