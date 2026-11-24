import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../application/randomness.dart';
import '../../domain/cards/flashcard.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cards/card_list_tile.dart';
import '../cards/card_navigation.dart';
import '../cards/card_status_formatter.dart';
import 'section_title.dart';

/// "Waiting · N": the queue of a group, in its order, as a sliver. A long
/// press on a card drags it to another place. "Reorder" turns the rows
/// compact, with a handle and the buttons that send a card to the head or
/// the end, and offers to shuffle the whole queue; "Done" leaves. Each move
/// is written at once, and shown before the database answers.
class QueueSection extends ConsumerStatefulWidget {
  const QueueSection({
    required this.cards,
    required this.reordering,
    required this.onReorderingChanged,
    required this.formatter,
    required this.showBack,
    required this.distilling,
    this.reviewAll,
    super.key,
  });

  /// The waiting cards of the group, in queue order.
  final List<Flashcard> cards;

  /// Whether the reordering mode is on; the page keeps it, to take its
  /// "+" button away while it lasts.
  final bool reordering;
  final ValueChanged<bool> onReorderingChanged;
  final CardStatusFormatter formatter;
  final bool showBack;

  /// Whether the group distills; only then is the head of the queue marked
  /// "next", otherwise nothing comes out.
  final bool distilling;

  /// "Review all", beside the title outside of reordering.
  final Widget? reviewAll;

  @override
  ConsumerState<QueueSection> createState() => _QueueSectionState();
}

class _QueueSectionState extends ConsumerState<QueueSection> {
  /// The order of the last move, by card id, until the database gives it.
  List<int>? _order;

  @override
  void didUpdateWidget(QueueSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(_idsOf(oldWidget.cards), _idsOf(widget.cards))) {
      _order = null;
    }
  }

  static List<int> _idsOf(List<Flashcard> cards) => [
    for (final card in cards) card.id,
  ];

  List<Flashcard> get _cards {
    final order = _order;
    if (order == null) {
      return widget.cards;
    } else {
      final byId = {for (final card in widget.cards) card.id: card};
      return [for (final id in order) ?byId[id]];
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final cards = _cards;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SectionTitle(
            strings.groupWaitingSection(cards.length),
            actions: _actions(strings, cards),
          ),
        ),
        DecoratedSliver(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          sliver: SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverReorderableList(
              itemCount: cards.length,
              itemBuilder: (context, index) =>
                  _row(context, strings, cards, index),
              onReorderItem: (from, to) => _move(cards, cards[from], to),
              proxyDecorator: (child, index, animation) =>
                  _lifted(colors, child, animation),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _actions(AppLocalizations strings, List<Flashcard> cards) =>
      widget.reordering
      ? [
          SectionIconButton(
            icon: Icons.shuffle,
            tooltip: strings.groupShuffleQueue,
            onPressed: () => _shuffle(cards.first.groupId),
          ),
          SectionButton(
            icon: Icons.check,
            label: strings.groupReorderDone,
            onPressed: () => widget.onReorderingChanged(false),
          ),
        ]
      : [
          ?widget.reviewAll,
          if (cards.length > 1)
            SectionIconButton(
              icon: Icons.swap_vert,
              tooltip: strings.groupReorder,
              onPressed: () => widget.onReorderingChanged(true),
            ),
        ];

  /// A card of the queue, under a divider unless it is the first.
  Widget _row(
    BuildContext context,
    AppLocalizations strings,
    List<Flashcard> cards,
    int index,
  ) {
    final card = cards[index];
    return ReorderableDelayedDragStartListener(
      key: ValueKey(card.id),
      index: index,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (index > 0) const Divider(height: 1),
          if (widget.reordering)
            _CompactRow(
              card: card,
              index: index,
              onHead: index == 0 ? null : () => _move(cards, card, 0),
              onEnd: index == cards.length - 1
                  ? null
                  : () => _move(cards, card, cards.length - 1),
            )
          else
            CardListTile(
              card: card,
              formatter: widget.formatter,
              showBack: widget.showBack,
              mark: widget.distilling && index == 0
                  ? strings.groupNextCard
                  : null,
              showStanding: false,
              onTap: () => openCard(context, card.id),
            ),
        ],
      ),
    );
  }

  /// Puts [card] at [index] of [cards] on screen, then in the database.
  Future<void> _move(List<Flashcard> cards, Flashcard card, int index) async {
    final from = cards.indexOf(card);
    if (from != index) {
      setState(() {
        _order = _idsOf(cards)
          ..removeAt(from)
          ..insert(index, card.id);
      });
      await ref.read(queueServiceProvider).moveTo(card.id, index);
    }
  }

  Future<void> _shuffle(int groupId) async {
    final strings = AppLocalizations.of(context);
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.groupShuffleConfirmTitle),
            content: Text(strings.groupShuffleConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(strings.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(strings.groupShuffleConfirm),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) {
      await ref
          .read(queueServiceProvider)
          .shuffleQueue(groupId, ref.read(randomProvider));
    }
  }

  /// The card being dragged, raised above the list.
  Widget _lifted(
    AlambicColors colors,
    Widget child,
    Animation<double> animation,
  ) => AnimatedBuilder(
    animation: animation,
    builder: (context, child) => Material(
      color: colors.surface,
      elevation: lerpDouble(0, 6, Curves.easeInOut.transform(animation.value))!,
      borderRadius: BorderRadius.circular(12),
      child: child,
    ),
    child: child,
  );
}

/// A card of the queue while reordering: its front alone, the buttons that
/// send it to the head or the end, off where it already is, and the handle
/// that drags it at once.
class _CompactRow extends StatelessWidget {
  const _CompactRow({
    required this.card,
    required this.index,
    required this.onHead,
    required this.onEnd,
  });

  final Flashcard card;
  final int index;
  final VoidCallback? onHead;
  final VoidCallback? onEnd;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            card.frontText ?? strings.cardImageOnly,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        IconButton(
          tooltip: strings.cardSheetToHead,
          icon: const Icon(Icons.vertical_align_top, size: 20),
          onPressed: onHead,
        ),
        IconButton(
          tooltip: strings.cardSheetToEnd,
          icon: const Icon(Icons.vertical_align_bottom, size: 20),
          onPressed: onEnd,
        ),
        ReorderableDragStartListener(
          index: index,
          child: SizedBox(
            width: 40,
            height: 48,
            child: Icon(Icons.drag_handle, color: colors.textSecondary),
          ),
        ),
      ],
    );
  }
}
