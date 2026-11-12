import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../application/distillation/distillation_progress.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'distillation_labels.dart';

/// A distillation in progress: direction, state, rhythm and progress, with
/// pause / resume and stop.
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
                  strings.distillationScope(distillation),
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
              IconButton.filledTonal(
                tooltip: distillation.isRunning
                    ? strings.distillationPause
                    : strings.distillationResume,
                icon: Icon(
                  distillation.isRunning ? Icons.pause : Icons.play_arrow,
                  size: 18,
                ),
                onPressed: () => distillation.isRunning
                    ? service.pause(distillation.id)
                    : service.resume(distillation.id),
              ),
              IconButton.filledTonal(
                tooltip: strings.distillationStop,
                icon: const Icon(Icons.stop, size: 18),
                onPressed: () => _confirmStop(context, ref),
              ),
            ],
          ),
          Text(
            strings.distillationRhythm(distillation),
            style: TextStyle(fontSize: 14, color: colors.textPrimary),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: progress.total == 0
                    ? 0
                    : progress.introduced / progress.total,
                backgroundColor: colors.segmentBackground,
                color: colors.accent,
                semanticsLabel: strings.distillationIntroduced(
                  progress.introduced,
                  progress.total,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    strings.distillationIntroduced(
                      progress.introduced,
                      progress.total,
                    ),
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

  Future<void> _confirmStop(BuildContext context, WidgetRef ref) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.distillationStopTitle),
        content: Text(strings.distillationStopBody(progress.remaining)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.distillationStopConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref
          .read(distillationServiceProvider)
          .stop(progress.distillation.id);
    }
  }
}
