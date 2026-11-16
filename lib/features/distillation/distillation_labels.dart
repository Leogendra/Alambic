import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_order.dart';
import '../../l10n/generated/app_localizations.dart';

/// Texts describing a distillation.
extension DistillationLabels on AppLocalizations {
  /// "1 card per day · group order".
  String distillationRhythm(Distillation distillation) =>
      '${distillationCardsPer(distillation.cardsPerBatch)} '
      '${distillationEveryDays(distillation.everyDays)} · '
      '${switch (distillation.introductionOrder) {
        DistillationOrder.groupOrder => distillationOrderGroup,
        DistillationOrder.random => distillationOrderRandom,
      }}';
}
