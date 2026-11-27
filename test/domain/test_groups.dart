import 'package:alambic/domain/groups/after_last_step.dart';
import 'package:alambic/domain/groups/asked_sides.dart';
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
  String name = 'Capitals',
  AskedSides askedSides = AskedSides.front,
  AfterLastStep afterLastStep = AfterLastStep.remanence,
  RemanenceInterval remanenceInterval = RemanenceInterval.sixMonths,
  bool typedAnswer = false,
  bool backHidden = false,
}) => CardGroup(
  id: id,
  name: name,
  presetId: 1,
  createdAt: DateTime(2026, 11, 1),
  askedSides: askedSides,
  afterLastStep: afterLastStep,
  remanenceInterval: remanenceInterval,
  typedAnswer: typedAnswer,
  backHidden: backHidden,
);
