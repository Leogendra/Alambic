import 'package:alambic/domain/groups/after_last_step.dart';
import 'package:alambic/domain/groups/card_group.dart';
import 'package:alambic/domain/groups/remanence_interval.dart';
import 'package:alambic/domain/groups/sequence_end.dart';

/// Remanence at [interval] after the last step.
SequenceEnd remanence([
  RemanenceInterval interval = RemanenceInterval.sixMonths,
]) => SequenceEnd(
  afterLastStep: AfterLastStep.remanence,
  remanenceInterval: interval,
);

/// Acquired after the last step.
const SequenceEnd acquiredEnd = SequenceEnd(
  afterLastStep: AfterLastStep.acquired,
  remanenceInterval: RemanenceInterval.sixMonths,
);

/// A group as stored, with the options of a new group by default.
CardGroup testGroup({
  int id = 1,
  String name = 'Capitales',
  bool reverseEnabled = false,
  AfterLastStep afterLastStep = AfterLastStep.remanence,
  RemanenceInterval remanenceInterval = RemanenceInterval.sixMonths,
  bool typedAnswer = false,
}) => CardGroup(
  id: id,
  name: name,
  presetId: null,
  createdAt: DateTime(2026, 11, 1),
  reverseEnabled: reverseEnabled,
  afterLastStep: afterLastStep,
  remanenceInterval: remanenceInterval,
  typedAnswer: typedAnswer,
);
