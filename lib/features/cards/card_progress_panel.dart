import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../application/distillation/queue_standing.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/groups/sequence_end.dart';
import '../../domain/presets/preset.dart';
import '../../domain/scheduling/step_target.dart';
import '../../l10n/generated/app_localizations.dart';
import 'card_status_formatter.dart';
import 'step_track.dart';

/// Where a card stands: when it comes back, or where it waits in the queue
/// of its group with the buttons that move it there, or that it is learned;
/// then the track of its steps. The settings button of the header and the
/// track both call [onChangeStep] to change them.
class CardProgressPanel extends ConsumerWidget {
  const CardProgressPanel({
    required this.card,
    required this.preset,
    required this.end,
    required this.formatter,
    required this.onChangeStep,
    super.key,
  });

  final Flashcard card;
  final Preset preset;
  final SequenceEnd end;
  final CardStatusFormatter formatter;
  final VoidCallback onChangeStep;

  static const double _buttonSize = 40;

  /// Height of the title line of the header, which the button centres on.
  static const double _titleHeight = 22;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = formatter.strings;
    final colors = AlambicColors.of(context);
    final standing = card.isPending
        ? ref.watch(queueStandingProvider(card.id))
        : null;
    final panel = Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: _buttonSize),
            child: _header(strings, colors, standing),
          ),
          if (standing != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _queueButtons(ref, strings, standing),
            ),
          Tooltip(
            message: strings.stepSheetTitle,
            child: InkWell(
              onTap: onChangeStep,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                child: StepTrack(
                  preset: preset,
                  end: end,
                  current: StepTarget.of(card, preset),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    // The settings button sits on the line of the title, outside the flow
    // so that it neither makes the header taller nor narrows the track.
    return Stack(
      children: [
        panel,
        Positioned(
          top: 16 + _titleHeight / 2 - _buttonSize / 2,
          right: 8,
          child: IconButton(
            onPressed: onChangeStep,
            tooltip: strings.stepSheetTitle,
            icon: Icon(Icons.tune, size: 20, color: colors.accentText),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(
              width: _buttonSize,
              height: _buttonSize,
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(
    AppLocalizations strings,
    AlambicColors colors,
    QueueStanding? standing,
  ) {
    final dueAt = card.dueAt;
    final (icon, title, detail, isAccent) = switch (card) {
      Flashcard(isPending: true) => (
        Icons.hourglass_empty,
        standing == null
            ? ''
            : strings.cardSheetQueueStanding(standing.rank, standing.size),
        standing == null ? null : _arrival(strings, standing.arrival),
        false,
      ),
      Flashcard(isAcquired: true) => (
        Icons.check_circle_outline,
        strings.cardSheetLearned,
        strings.cardSheetLearnedDetail,
        false,
      ),
      _ when formatter.isDue(card) => (
        Icons.notifications_active_outlined,
        strings.cardSheetDueNow,
        null,
        true,
      ),
      _ => (
        Icons.calendar_today_outlined,
        strings.cardSheetNextReviewIn(formatter.nextDueLabel(dueAt!)),
        strings.dayDateTime(dueAt),
        false,
      ),
    };
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Icon(
          icon,
          size: 20,
          color: isAccent ? colors.accentText : colors.textSecondary,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isAccent ? colors.accentText : colors.textPrimary,
                ),
              ),
              if (detail != null)
                Text(
                  detail,
                  style: TextStyle(fontSize: 14, color: colors.textSecondary),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _arrival(AppLocalizations strings, QueueArrival arrival) =>
      switch (arrival) {
        ExpectedArrival(:final day) => strings.cardSheetArrivesAround(
          strings.longDate(day),
        ),
        ArrivalBeyondHorizon() => strings.cardSheetArrivesFar,
        DistillationPaused() => strings.cardSheetQueuePaused,
        NoDistillation() => strings.cardSheetNotDistilling,
      };

  /// "To the head" and "To the end", each off where the card already is.
  Widget _queueButtons(
    WidgetRef ref,
    AppLocalizations strings,
    QueueStanding standing,
  ) {
    final queue = ref.read(queueServiceProvider);
    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: standing.rank == 1
                ? null
                : () => queue.moveToHead(card.id),
            icon: const Icon(Icons.vertical_align_top, size: 18),
            label: Text(strings.cardSheetToHead),
          ),
        ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: standing.rank == standing.size
                ? null
                : () => queue.moveToEnd(card.id),
            icon: const Icon(Icons.vertical_align_bottom, size: 18),
            label: Text(strings.cardSheetToEnd),
          ),
        ),
      ],
    );
  }
}
