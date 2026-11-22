import 'package:intl/intl.dart';

import '../../domain/scheduling/clock_time.dart';
import '../../l10n/generated/app_localizations.dart';

/// Dates as the mockup writes them: "Nov 2", "Fri, Nov 13",
/// "Fri, Nov 13, 12:00", "December 23", and the weekday alone, "Fri".
extension DateLabels on AppLocalizations {
  /// Abbreviated weekday, without the full stop some languages add.
  String weekdayShort(DateTime moment) =>
      DateFormat.E(localeName).format(moment).replaceAll('.', '');

  String shortDate(DateTime moment) =>
      DateFormat.MMMd(localeName).format(moment);

  String longDate(DateTime moment) =>
      DateFormat.MMMMd(localeName).format(moment);

  String dayDate(DateTime moment) =>
      DateFormat.MMMEd(localeName).format(moment);

  String dayDateTime(DateTime moment) =>
      '${dayDate(moment)}, ${ClockTime(moment.hour, moment.minute)}';
}
