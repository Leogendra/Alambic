import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/layout/scroll_padding.dart';
import '../../app/theme/alambic_colors.dart';
import '../../application/cards/card_providers.dart';
import '../../application/groups/group_providers.dart';
import '../../application/notifications/guard_providers.dart';
import '../../application/presets/preset_providers.dart';
import '../../application/scheduling/scheduling_providers.dart';
import '../../domain/cards/card_face.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/groups/sequence_end.dart';
import '../../domain/presets/preset.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../domain/scheduling/step_target.dart';
import '../../l10n/generated/app_localizations.dart';
import '../session/session_launcher.dart';
import 'card_editor_screen.dart';
import 'card_image.dart';
import 'card_progress_panel.dart';
import 'card_status_formatter.dart';
import 'card_status_formatter_provider.dart';
import 'last_answers.dart';
import 'step_sheet.dart';

/// Card sheet: its front, its back once revealed, where it stands with the
/// track of its steps, and its last answers; "Review now" stays at the
/// bottom.
class CardSheetScreen extends ConsumerStatefulWidget {
  const CardSheetScreen({required this.cardId, super.key});

  final int cardId;

  @override
  ConsumerState<CardSheetScreen> createState() => _CardSheetScreenState();
}

class _CardSheetScreenState extends ConsumerState<CardSheetScreen> {
  /// The back shows once asked, until the sheet is left.
  bool _backRevealed = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final card = ref.watch(cardProvider(widget.cardId)).value;
    final catalog = ref.watch(presetCatalogProvider).value;
    final formatter = watchCardStatusFormatter(context, ref);
    final dailySlot = ref.watch(reminderSettingsProvider).value?.dailySlot;
    if (card == null ||
        catalog == null ||
        formatter == null ||
        dailySlot == null) {
      return Scaffold(appBar: AppBar());
    }
    final groupName = ref.watch(groupProvider(card.groupId)).value?.name ?? '';
    final preset = catalog.presetForGroup(card.groupId);
    final end = catalog.sequenceEndForGroup(card.groupId);
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
        padding: scrollPadding(
          context,
          const EdgeInsets.fromLTRB(20, 0, 20, 24),
        ),
        children: [
          _FacesPanel(
            card: card,
            backRevealed: _backRevealed,
            onReveal: () => setState(() => _backRevealed = true),
          ),
          const SizedBox(height: 14),
          CardProgressPanel(
            card: card,
            preset: preset,
            end: end,
            formatter: formatter,
            onChangeStep: () =>
                _changeStep(card, preset, end, formatter, dailySlot),
          ),
          const SizedBox(height: 28),
          LastAnswers(cardId: card.id, formatter: formatter),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => openSession(context, ref, [card.id]),
            icon: const Icon(Icons.play_arrow),
            label: Text(
              strings.cardSheetReviewNow,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }

  /// Offers every step with the date it would give. The queue asks for a
  /// confirmation, since the card loses its progression; any other step
  /// applies at once and tells its date.
  Future<void> _changeStep(
    Flashcard card,
    Preset preset,
    SequenceEnd end,
    CardStatusFormatter formatter,
    ClockTime dailySlot,
  ) async {
    final strings = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final scheduler = ref.read(reviewSchedulerProvider);
    final current = StepTarget.of(card, preset);
    final target = await showStepSheet(
      context,
      preset: preset,
      end: end,
      current: current,
      offersQueue: !card.isPending,
      dueAtOf: (target) => switch (target.reachedIn(preset, end)) {
        null => null,
        final reached =>
          scheduler
              .atStep(reached, from: formatter.now, dailySlot: dailySlot)
              .dueAt,
      },
    );
    if (target == null || target == current) {
      return;
    } else if (target is PendingTarget) {
      final confirmed = await _confirm(
        strings.stepSheetPendingConfirmTitle,
        strings.stepSheetPendingConfirmBody,
        strings.stepSheetPendingConfirm,
      );
      if (confirmed) {
        await ref.read(cardServiceProvider).setStep(card.id, target);
      }
    } else {
      final dueAt = await ref
          .read(cardServiceProvider)
          .setStep(card.id, target);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            dueAt == null
                ? strings.nextReviewLearned
                : strings.cardSheetNextReviewIn(strings.dayDateTime(dueAt)),
          ),
        ),
      );
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
}

/// The front, then the back under a divider, hidden behind "Show the
/// answer" until [backRevealed].
class _FacesPanel extends StatelessWidget {
  const _FacesPanel({
    required this.card,
    required this.backRevealed,
    required this.onReveal,
  });

  final Flashcard card;
  final bool backRevealed;
  final VoidCallback onReveal;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _face(strings.cardFront, card.front, colors),
          Divider(height: 1, color: colors.divider),
          if (backRevealed)
            _face(strings.cardBack, card.back, colors)
          else
            InkWell(
              onTap: onReveal,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    _label(strings.cardBack, colors),
                    Row(
                      spacing: 8,
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          size: 20,
                          color: colors.accentText,
                        ),
                        Flexible(
                          child: Text(
                            strings.sessionShowAnswer,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colors.accentText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _face(String label, CardFace face, AlambicColors colors) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        _label(label, colors),
        if (face.hasText)
          Text(
            face.text!,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        if (face.imagePath case final image?)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: CardImage.stored(image, height: 140),
          ),
      ],
    ),
  );

  Widget _label(String label, AlambicColors colors) => Text(
    label.toUpperCase(),
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.7,
      color: colors.textSecondary,
    ),
  );
}
