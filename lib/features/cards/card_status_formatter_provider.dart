import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/clock.dart';
import '../../application/presets/preset_providers.dart';
import '../../application/scheduling/scheduling_providers.dart';
import '../../application/time/minute_ticker.dart';
import '../../l10n/generated/app_localizations.dart';
import 'card_status_formatter.dart';

/// Formatter for the current moment and presets; `null` while they load.
CardStatusFormatter? watchCardStatusFormatter(
  BuildContext context,
  WidgetRef ref,
) {
  final catalog = ref.watch(presetCatalogProvider).value;
  final now = ref.watch(currentMomentProvider).value;
  if (catalog == null || now == null) {
    return null;
  } else {
    return CardStatusFormatter(
      strings: AppLocalizations.of(context),
      catalog: catalog,
      duePolicy: ref.watch(duePolicyProvider),
      calendar: ref.watch(schedulingCalendarProvider),
      now: now,
    );
  }
}
