import 'package:drift/drift.dart';

import '../../../domain/groups/after_last_step.dart';
import '../../../domain/groups/card_group.dart';
import '../../../domain/groups/remanence_interval.dart';
import 'presets.dart';

@UseRowClass(CardGroup)
class CardGroups extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get presetId => integer().nullable().references(Presets, #id)();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get reverseEnabled =>
      boolean().withDefault(const Constant(false))();
  TextColumn get afterLastStep => textEnum<AfterLastStep>().withDefault(
    Constant(AfterLastStep.remanence.name),
  )();
  TextColumn get remanenceInterval => textEnum<RemanenceInterval>().withDefault(
    Constant(RemanenceInterval.sixMonths.name),
  )();
  BoolColumn get typedAnswer => boolean().withDefault(const Constant(false))();
}
