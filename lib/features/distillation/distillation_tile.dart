import 'package:material_ui/material_ui.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../application/distillation/distillation_progress.dart';
import '../../l10n/generated/app_localizations.dart';
import 'distill_screen.dart';
import 'distillation_labels.dart';

/// The distillation of a group: state and rhythm, with a
/// single settings button that opens the "Distill" screen.
class DistillationTile extends StatelessWidget {
  const DistillationTile({required this.progress, super.key});

  final DistillationProgress progress;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final distillation = progress.distillation;
    final pausedAt = distillation.pausedAt;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceRaised,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 6,
                      children: [
                        if (pausedAt != null) const Icon(Icons.pause, size: 14),
                        Flexible(
                          child: Text(
                            pausedAt == null
                                ? strings.groupDistillationSection
                                : strings.pausedSince(
                                    strings.shortDate(pausedAt),
                                  ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton.filledTonal(
                tooltip: strings.distillAdjustTitle,
                icon: const Icon(Icons.settings_outlined, size: 18),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => DistillScreen(
                      groupId: distillation.groupId,
                      currentSettings: distillation.settings,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            strings.distillationRhythm(distillation),
            style: TextStyle(fontSize: 13, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}
