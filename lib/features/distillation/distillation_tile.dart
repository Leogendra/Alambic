import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../application/distillation/distillation_progress.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'distill_screen.dart';
import 'distillation_labels.dart';

/// The distillation of a group: state, rhythm and waiting cards, with
/// "Adjust" and pause / resume.
class DistillationTile extends ConsumerWidget {
  const DistillationTile({required this.progress, super.key});

  final DistillationProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final distillation = progress.distillation;
    final service = ref.read(distillationServiceProvider);
    final lastArrival = progress.lastArrival;
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
            spacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  strings.groupDistillationSection,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  distillation.isRunning
                      ? strings.distillationRunning
                      : strings.distillationPaused,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: distillation.isRunning
                        ? colors.accentText
                        : colors.textSecondary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => DistillScreen(
                      groupId: distillation.groupId,
                      currentSettings: distillation.settings,
                    ),
                  ),
                ),
                child: Text(strings.distillationAdjust),
              ),
              IconButton.filledTonal(
                tooltip: distillation.isRunning
                    ? strings.distillationPause
                    : strings.distillationResume,
                icon: Icon(
                  distillation.isRunning ? Icons.pause : Icons.play_arrow,
                  size: 18,
                ),
                onPressed: () => distillation.isRunning
                    ? service.pause(distillation.groupId)
                    : service.resume(distillation.groupId),
              ),
            ],
          ),
          Text(
            strings.distillationRhythm(distillation),
            style: TextStyle(fontSize: 14, color: colors.textPrimary),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    strings.distillationWaiting(progress.remaining),
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ),
                if (lastArrival != null)
                  Text(
                    strings.distillationLastArrival(
                      strings.shortDate(lastArrival),
                    ),
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
