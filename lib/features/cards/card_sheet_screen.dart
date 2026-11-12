import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/cards/card_providers.dart';
import '../../application/groups/group_providers.dart';
import '../../application/presets/preset_providers.dart';
import '../../application/reminders/reminder_providers.dart';
import '../../application/reviews/session_item.dart';
import '../../data/repositories/card_with_directions.dart';
import '../../domain/cards/card_direction.dart';
import '../../domain/cards/direction_sense.dart';
import '../../domain/cards/direction_state.dart';
import '../../domain/presets/preset.dart';
import '../../l10n/generated/app_localizations.dart';
import '../session/session_launcher.dart';
import 'card_editor_screen.dart';
import 'card_status_formatter.dart';
import 'card_status_formatter_provider.dart';
import 'direction_progress_panel.dart';
import 'direction_selector.dart';
import 'review_history_list.dart';
import 'review_soon_sheet.dart';

/// Card sheet: both faces, then for each direction its step, next review,
/// reminders and history, with the actions on the card.
class CardSheetScreen extends ConsumerStatefulWidget {
  const CardSheetScreen({required this.cardId, super.key});

  final int cardId;

  @override
  ConsumerState<CardSheetScreen> createState() => _CardSheetScreenState();
}

class _CardSheetScreenState extends ConsumerState<CardSheetScreen> {
  DirectionSense _sense = DirectionSense.frontToBack;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final card = ref.watch(cardProvider(widget.cardId)).value;
    final catalog = ref.watch(presetCatalogProvider).value;
    final formatter = watchCardStatusFormatter(context, ref);
    if (card == null || catalog == null || formatter == null) {
      return Scaffold(appBar: AppBar());
    }
    final groupId = card.card.groupId;
    final groupName = groupId == null
        ? strings.noGroup
        : ref.watch(groupProvider(groupId)).value?.name ?? '';
    final preset = catalog.presetForCard(card.card);
    final direction = card.direction(_sense);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          groupName,
          style: TextStyle(
            fontSize: 15,
            color: AlambicColors.of(context).textSecondary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: strings.cardSheetEdit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                fullscreenDialog: true,
                builder: (context) => CardEditorScreen(cardId: widget.cardId),
              ),
            ),
          ),
          PopupMenuButton<void>(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _confirmDelete,
                child: Text(strings.cardSheetDelete),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        children: [
          _FacesPanel(card: card, onTap: () => _review(direction)),
          _hint(strings.cardSheetTapToReview),
          if (card.card.suspended) ...[
            const SizedBox(height: 8),
            _hint(strings.cardSheetSuspended),
          ],
          const SizedBox(height: 14),
          DirectionSelector(
            card: card,
            formatter: formatter,
            selected: _sense,
            onSelected: (sense) => setState(() => _sense = sense),
          ),
          const SizedBox(height: 14),
          DirectionProgressPanel(
            direction: direction,
            preset: preset,
            isDue: _isDue(card, direction, formatter),
            onStart: () =>
                ref.read(cardServiceProvider).startDirection(direction!.id),
          ),
          const SizedBox(height: 14),
          _actions(card, direction, preset),
          if (direction != null) _Reminders(directionId: direction.id),
          const SizedBox(height: 24),
          SectionLabel(strings.cardSheetHistory(_directionName(strings))),
          if (direction != null)
            ReviewHistoryList(directionId: direction.id, preset: preset),
        ],
      ),
    );
  }

  Widget _actions(
    CardWithDirections card,
    CardDirection? direction,
    Preset preset,
  ) {
    final strings = AppLocalizations.of(context);
    final isStarted =
        direction != null &&
        (direction.state == DirectionState.active ||
            direction.state == DirectionState.acquired);
    final suspended = card.card.suspended;
    return Row(
      spacing: 8,
      children: [
        _ActionButton(
          icon: Icons.schedule,
          label: strings.cardSheetReviewSoon,
          isAccent: true,
          onPressed: isStarted
              ? () => _reviewSoon(card, direction, preset)
              : null,
        ),
        _ActionButton(
          icon: suspended ? Icons.play_arrow : Icons.pause,
          label: suspended ? strings.cardSheetResume : strings.cardSheetSuspend,
          onPressed: () => ref
              .read(cardServiceProvider)
              .setSuspended(card.card.id, suspended: !suspended),
        ),
        _ActionButton(
          icon: Icons.restart_alt,
          label: strings.cardSheetReset,
          onPressed: _confirmReset,
        ),
      ],
    );
  }

  bool _isDue(
    CardWithDirections card,
    CardDirection? direction,
    CardStatusFormatter formatter,
  ) =>
      direction != null &&
      formatter.duePolicy.isDueToday(
        direction,
        cardSuspended: card.card.suspended,
        now: formatter.now,
      );

  String _directionName(AppLocalizations strings) => switch (_sense) {
    DirectionSense.frontToBack => strings.directionFrontToBack,
    DirectionSense.backToFront => strings.directionBackToFront,
  }.toLowerCase();

  /// Reviews the shown direction now; the answer is a bonus review unless the
  /// direction is due.
  Future<void> _review(CardDirection? direction) async {
    if (direction == null ||
        direction.state == DirectionState.inactive ||
        direction.state == DirectionState.unstarted ||
        direction.state == DirectionState.pending) {
      return;
    }
    await openSession(context, [
      SessionItem(cardId: widget.cardId, directionId: direction.id),
    ]);
  }

  Future<void> _reviewSoon(
    CardWithDirections card,
    CardDirection direction,
    Preset preset,
  ) async {
    final strings = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final remindAt = await showReviewSoonSheet(
      context,
      directionId: direction.id,
      front: card.card.promptFor(direction.sense).text ?? '',
      defaultTime: preset.dailySlot,
    );
    if (remindAt != null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.reviewSoonAdded(strings.dayDateTime(remindAt))),
        ),
      );
    }
  }

  Future<void> _confirmReset() async {
    final strings = AppLocalizations.of(context);
    final confirmed = await _confirm(
      strings.cardSheetResetConfirmTitle,
      strings.cardSheetResetConfirmBody,
      strings.cardSheetReset,
    );
    if (confirmed) {
      await ref.read(cardServiceProvider).resetProgress(widget.cardId);
    }
  }

  Future<void> _confirmDelete() async {
    final strings = AppLocalizations.of(context);
    final confirmed = await _confirm(
      strings.cardSheetDelete,
      strings.cardSheetDeleteConfirm,
      strings.commonDelete,
    );
    if (confirmed && mounted) {
      final navigator = Navigator.of(context);
      await ref.read(cardServiceProvider).delete(widget.cardId);
      navigator.pop();
    }
  }

  Future<bool> _confirm(String title, String body, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  Widget _hint(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: AlambicColors.of(context).textSecondary,
      ),
    ),
  );
}

/// Front above back, separated by a dashed line as in the mockup.
class _FacesPanel extends StatelessWidget {
  const _FacesPanel({required this.card, required this.onTap});

  final CardWithDirections card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _face(strings.cardFront, card.card.frontText ?? '', colors),
            Divider(height: 1, color: colors.divider),
            _face(strings.cardBack, card.card.backText ?? '', colors),
          ],
        ),
      ),
    );
  }

  Widget _face(String label, String text, AlambicColors colors) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
            color: colors.textSecondary,
          ),
        ),
        Text(
          text,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isAccent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    final enabled = onPressed != null;
    final foreground = !enabled
        ? colors.textSecondary.withValues(alpha: 0.5)
        : isAccent
        ? colors.accentText
        : colors.textPrimary;
    return Expanded(
      child: Material(
        color: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Column(
              spacing: 6,
              children: [
                Icon(icon, size: 20, color: foreground),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Upcoming "Review soon" reminders of a direction, each removable.
class _Reminders extends ConsumerWidget {
  const _Reminders({required this.directionId});

  final int directionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final reminders =
        ref.watch(upcomingRemindersProvider(directionId)).value ?? const [];
    if (reminders.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SurfacePanel(
        children: [
          for (final reminder in reminders)
            Row(
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 18,
                  color: AlambicColors.of(context).textSecondary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.cardSheetReminder(
                      strings.dayDateTime(reminder.remindAt),
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                IconButton(
                  tooltip: strings.cardSheetReminderRemove,
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () =>
                      ref.read(reminderServiceProvider).remove(reminder.id),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
