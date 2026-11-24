import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/layout/scroll_padding.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/section_label.dart';
import '../../application/cards/card_providers.dart';
import '../../application/groups/group_providers.dart';
import '../../application/presets/preset_providers.dart';
import '../../domain/cards/card_face.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/presets/preset.dart';
import '../../l10n/generated/app_localizations.dart';
import '../session/session_launcher.dart';
import 'card_editor_screen.dart';
import 'card_image.dart';
import 'card_progress_panel.dart';
import 'card_status_formatter_provider.dart';
import 'review_history_list.dart';

/// Card sheet: both faces, then its step, next review and history, with the
/// actions on the card.
class CardSheetScreen extends ConsumerStatefulWidget {
  const CardSheetScreen({required this.cardId, super.key});

  final int cardId;

  @override
  ConsumerState<CardSheetScreen> createState() => _CardSheetScreenState();
}

class _CardSheetScreenState extends ConsumerState<CardSheetScreen> {
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final card = ref.watch(cardProvider(widget.cardId)).value;
    final catalog = ref.watch(presetCatalogProvider).value;
    final formatter = watchCardStatusFormatter(context, ref);
    if (card == null || catalog == null || formatter == null) {
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
          const EdgeInsets.fromLTRB(20, 0, 20, 32),
        ),
        children: [
          _FacesPanel(card: card, onTap: () => _review(card)),
          _hint(strings.cardSheetTapToReview),
          if (card.suspended) ...[
            const SizedBox(height: 8),
            _hint(strings.cardSheetSuspended),
          ],
          const SizedBox(height: 14),
          CardProgressPanel(
            card: card,
            preset: preset,
            end: end,
            isDue: formatter.duePolicy.isDueToday(card, now: formatter.now),
          ),
          const SizedBox(height: 14),
          _actions(card, preset),
          const SizedBox(height: 24),
          SectionLabel(strings.cardSheetHistory),
          ReviewHistoryList(cardId: card.id, preset: preset, end: end),
        ],
      ),
    );
  }

  Widget _actions(Flashcard card, Preset preset) {
    final strings = AppLocalizations.of(context);
    final suspended = card.suspended;
    return Row(
      spacing: 8,
      children: [
        _ActionButton(
          icon: suspended ? Icons.play_arrow : Icons.pause,
          label: suspended ? strings.cardSheetResume : strings.cardSheetSuspend,
          onPressed: () => ref
              .read(cardServiceProvider)
              .setSuspended(card.id, suspended: !suspended),
        ),
        _ActionButton(
          icon: Icons.restart_alt,
          label: strings.cardSheetReset,
          onPressed: _confirmReset,
        ),
      ],
    );
  }

  /// Reviews the card now; the answer is a bonus review unless the card is
  /// due. A pending card waits for its distillation.
  Future<void> _review(Flashcard card) async {
    if (card.isPending) {
      return;
    }
    await openSession(context, ref, [card.id]);
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

  final Flashcard card;
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
            _face(strings.cardFront, card.front, colors),
            Divider(height: 1, color: colors.divider),
            _face(strings.cardBack, card.back, colors),
          ],
        ),
      ),
    );
  }

  Widget _face(String label, CardFace face, AlambicColors colors) => Padding(
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
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    final enabled = onPressed != null;
    final foreground = enabled
        ? colors.textPrimary
        : colors.textSecondary.withValues(alpha: 0.5);
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
