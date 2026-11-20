import 'package:intl/intl.dart';

import '../../domain/scheduling/clock_time.dart';
import '../../l10n/generated/app_localizations.dart';

/// Dates as the mockup writes them: "Nov 2", "Fri, Nov 13",
/// "Fri, Nov 13, 12:00", "December 23".
extension DateLabels on AppLocalizations {
  String shortDate(DateTime moment) =>
      DateFormat.MMMd(localeName).format(moment);

  String longDate(DateTime moment) =>
      DateFormat.MMMMd(localeName).format(moment);

  String dayDate(DateTime moment) =>
      DateFormat.MMMEd(localeName).format(moment);

  String dayDateTime(DateTime moment) =>
      '${dayDate(moment)}, ${ClockTime(moment.hour, moment.minute)}';
}
