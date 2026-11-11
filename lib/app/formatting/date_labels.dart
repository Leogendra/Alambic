import 'package:intl/intl.dart';

import '../../domain/scheduling/clock_time.dart';
import '../../l10n/generated/app_localizations.dart';

/// Dates as the mockup writes them: "2 nov.", "ven. 13 nov.",
/// "ven. 13 nov., 12:00".
extension DateLabels on AppLocalizations {
  String shortDate(DateTime moment) =>
      DateFormat.MMMd(localeName).format(moment);

  String dayDate(DateTime moment) =>
      DateFormat.MMMEd(localeName).format(moment);

  String dayDateTime(DateTime moment) =>
      '${dayDate(moment)}, ${ClockTime(moment.hour, moment.minute)}';
}
