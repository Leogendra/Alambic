import '../../application/distillation/distillation_refused.dart';
import '../../domain/cards/direction_sense.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_order.dart';
import '../../l10n/generated/app_localizations.dart';

/// Texts describing a distillation.
extension DistillationLabels on AppLocalizations {
  String directionName(DirectionSense sense) => switch (sense) {
    DirectionSense.frontToBack => directionFrontToBack,
    DirectionSense.backToFront => directionBackToFront,
  };

  /// What a distillation covers: its direction, or the whole collection.
  String distillationScope(Distillation distillation) =>
      switch (distillation.sense) {
        final sense? => directionName(sense),
        null => distillationGlobalScope,
      };

  /// "1 card per day · group order".
  String distillationRhythm(Distillation distillation) =>
      '${distillationCardsPer(distillation.cardsPerBatch)} '
      '${distillationEveryDays(distillation.everyDays)} · '
      '${switch (distillation.introductionOrder) {
        DistillationOrder.groupOrder => distillationOrderGroup,
        DistillationOrder.random => distillationOrderRandom,
      }}';

  String distillRefusal(DistillationRefusal reason) => switch (reason) {
    DistillationRefusal.globalInProgress => distillRefusedGlobal,
    DistillationRefusal.senseTaken => distillRefusedTaken,
    DistillationRefusal.nothingToDistill => distillRefusedNothing,
  };
}
