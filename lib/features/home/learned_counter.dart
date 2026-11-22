import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/dashed_divider.dart';
import '../../l10n/generated/app_localizations.dart';

/// Home's easter egg, uncovered by pulling the timeline down: how many cards
/// have been notified so far, as one more row of the agenda, in the past.
class LearnedCounter extends StatelessWidget {
  const LearnedCounter({required this.count, super.key});

  /// Height of the counter at the default text size.
  static const double height = 112;

  final int count;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Expanded(
            child: Row(
              spacing: 16,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.well,
                    border: Border.all(color: colors.border),
                  ),
                  child: Icon(
                    Icons.history,
                    size: 24,
                    color: colors.accentText,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        NumberFormat.decimalPattern(strings.localeName)
                            .format(count),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          height: 1,
                          color: colors.accentText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        strings.homeLearned(count),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        strings.homeLearnedCaption,
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const DashedDivider(),
        ],
      ),
    );
  }
}
