import '../../l10n/generated/app_localizations.dart';

/// "Environ 3 min": the rough time needed to review some cards. Shared by
/// Home and the grouped reminders.
extension ReviewDurationLabels on AppLocalizations {
  /// Rough time per card used for the estimate.
  static const Duration timePerCard = Duration(seconds: 30);

  String reviewDuration(int cardCount) => homeDuration(
    (cardCount * timePerCard.inSeconds / Duration.secondsPerMinute).ceil(),
  );
}
