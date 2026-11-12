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

  /// About how long [days] days last: "12 jours", "5 semaines", "7 mois".
  String approximateSpan(int days) {
    if (days < 14) {
      return spanDays(days);
    } else if (days < 60) {
      return spanWeeks((days / 7).round());
    } else {
      return spanMonths((days / 30).round());
    }
  }

  String distillRefusal(DistillationRefusal reason) => switch (reason) {
    DistillationRefusal.globalInProgress => distillRefusedGlobal,
    DistillationRefusal.senseTaken => distillRefusedTaken,
    DistillationRefusal.nothingToDistill => distillRefusedNothing,
  };
}
