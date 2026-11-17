import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/clock.dart';
import '../../application/scheduling/scheduling_providers.dart';
import '../../application/time/minute_ticker.dart';
import '../../l10n/generated/app_localizations.dart';
import 'card_status_formatter.dart';

/// Formatter for the current moment; `null` while it loads.
CardStatusFormatter? watchCardStatusFormatter(
  BuildContext context,
  WidgetRef ref,
) {
  final now = ref.watch(currentMomentProvider).value;
  if (now == null) {
    return null;
  } else {
    return CardStatusFormatter(
      strings: AppLocalizations.of(context),
      duePolicy: ref.watch(duePolicyProvider),
      calendar: ref.watch(schedulingCalendarProvider),
      now: now,
    );
  }
}
