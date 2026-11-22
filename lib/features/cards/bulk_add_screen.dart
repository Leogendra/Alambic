import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/layout/bottom_action_area.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/segment_option.dart';
import '../../app/widgets/segmented_choice.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/cards/card_draft.dart';
import '../../application/cards/card_providers.dart';
import '../../application/randomness.dart';
import '../../domain/cards/bulk/bulk_card_draft.dart';
import '../../domain/cards/bulk/bulk_card_parser.dart';
import '../../domain/cards/bulk/bulk_line_error.dart';
import '../../domain/cards/bulk/bulk_line_error_kind.dart';
import '../../domain/cards/bulk/bulk_order.dart';
import '../../domain/cards/bulk/bulk_parse_result.dart';
import '../../domain/distillation/distillation_queue.dart';
import '../../l10n/generated/app_localizations.dart';
import 'group_field.dart';

/// Pastes "front ; back" lines to create many cards in a group at once. The
/// group is the one the user came from, if any, and can be chosen, changed or
/// created here. The batch joins the end of the queue of the group, in the
/// order of the list or shuffled; the card that will come first is shown.
class BulkAddScreen extends ConsumerStatefulWidget {
  const BulkAddScreen({this.initialGroupId, super.key});

  final int? initialGroupId;

  @override
  ConsumerState<BulkAddScreen> createState() => _BulkAddScreenState();
}

class _BulkAddScreenState extends ConsumerState<BulkAddScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _separatorController = TextEditingController(
    text: BulkCardParser.defaultSeparator,
  );
  late int? _groupId = widget.initialGroupId;
  BulkOrder _order = const BulkOrder.listed();

  @override
  void dispose() {
    _textController.dispose();
    _separatorController.dispose();
    super.dispose();
  }

  BulkParseResult get _result =>
      BulkCardParser.parse(_textController.text, _separatorController.text);

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final result = _result;
    final batch = _order.apply(result.drafts);
    return Scaffold(
      appBar: AppBar(title: Text(strings.bulkTitle)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              children: [
                _settingsPanel(strings),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  minLines: 8,
                  maxLines: 16,
                  decoration: InputDecoration(hintText: strings.bulkTextHint),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _report(strings, result),
                const SizedBox(height: 20),
                SectionLabel(strings.bulkOrder),
                _orderChoice(strings),
                if (batch.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _firstCard(strings, batch.first),
                ],
              ],
            ),
          ),
          BottomActionArea(
            child: FilledButton(
              onPressed: batch.isEmpty ? null : () => _add(batch),
              child: Text(strings.bulkAddButton(batch.length)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsPanel(AppLocalizations strings) => SurfacePanel(
    children: [
      GroupField(
        groupId: _groupId,
        onChanged: (groupId) => setState(() => _groupId = groupId),
      ),
      PanelRow(
        title: strings.bulkSeparator,
        subtitle: strings.bulkSeparatorHint,
        trailing: SizedBox(
          width: 64,
          child: TextField(
            controller: _separatorController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ),
    ],
  );

  Widget _report(AppLocalizations strings, BulkParseResult result) {
    final colors = AlambicColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        SectionLabel(strings.bulkReady(result.drafts.length)),
        for (final error in result.errors)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              _errorText(strings, error),
              style: TextStyle(fontSize: 13, color: colors.againForeground),
            ),
          ),
      ],
    );
  }

  /// Choosing "Shuffle", even again, draws a new order.
  Widget _orderChoice(AppLocalizations strings) => SegmentedChoice<bool>(
    options: [
      SegmentOption(false, strings.bulkOrderListed),
      SegmentOption(true, strings.bulkOrderShuffled),
    ],
    selected: _order.isShuffled,
    onSelected: (shuffled) => setState(
      () => _order = shuffled
          ? BulkOrder.shuffled(ref.read(randomProvider).nextInt(1 << 32))
          : const BulkOrder.listed(),
    ),
  );

  /// The card of the batch that will come out first, after the cards already
  /// waiting in the group.
  Widget _firstCard(AppLocalizations strings, BulkCardDraft first) {
    final colors = AlambicColors.of(context);
    final cards = switch (_groupId) {
      final groupId? => ref.watch(groupCardsProvider(groupId)).value,
      null => null,
    } ?? const [];
    final waiting = DistillationQueue.remaining(cards);
    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Text(
              strings.bulkFirst.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: colors.accentText,
              ),
            ),
            Text(
              '${first.front} → ${first.back}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (waiting > 0)
              Text(
                strings.bulkAfterPending(waiting),
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
              ),
          ],
        ),
      ],
    );
  }

  String _errorText(AppLocalizations strings, BulkLineError error) =>
      switch (error.kind) {
        BulkLineErrorKind.missingSeparator => strings.bulkErrorMissingSeparator(
          error.lineNumber,
          _separatorController.text,
        ),
        BulkLineErrorKind.emptyFace => strings.bulkErrorEmptyFace(
          error.lineNumber,
        ),
      };

  Future<void> _add(List<BulkCardDraft> batch) async {
    final strings = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final groupId = _groupId;
    if (groupId == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(strings.cardGroupMissing)),
      );
      return;
    }
    final count = await ref.read(cardServiceProvider).createAll([
      for (final draft in batch)
        CardDraft(
          frontText: draft.front,
          backText: draft.back,
          groupId: groupId,
        ),
    ]);
    messenger.showSnackBar(SnackBar(content: Text(strings.bulkAdded(count))));
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
