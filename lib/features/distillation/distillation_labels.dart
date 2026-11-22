import '../../domain/distillation/distillation.dart';
import '../../l10n/generated/app_localizations.dart';

/// Texts describing a distillation.
extension DistillationLabels on AppLocalizations {
  /// "1 card per day".
  String distillationRhythm(Distillation distillation) =>
      distillationCardsPerDay(distillation.cardsPerBatch);
}
