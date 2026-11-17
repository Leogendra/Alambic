import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/preset_labels.dart';
import '../../app/layout/scroll_padding.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/cards/card_providers.dart';
import '../../application/groups/group_providers.dart';
import '../../application/groups/group_summary.dart';
import '../../application/pauses/pause_providers.dart';
import '../../application/clock.dart';
import '../../application/reviews/review_providers.dart';
import '../../application/reviews/whole_group_review.dart';
import '../../application/scheduling/scheduling_providers.dart';
import '../../domain/cards/card_state.dart';
import '../../domain/cards/flashcard.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cards/bulk_add_screen.dart';
import '../cards/card_list_tile.dart';
import '../cards/card_navigation.dart';
import '../cards/card_status_formatter.dart';
import '../cards/card_status_formatter_provider.dart';
import '../distillation/group_distillation_section.dart';
import '../pauses/paused_banner.dart';
import '../session/session_launcher.dart';
import 'group_settings_screen.dart';
import 'group_stat_tile.dart';
import 'reverse_button.dart';

/// A group page: its counts, "Distill" or the tracking of its distillation,
/// the back option, then its cards with "Review all", the acquired ones in a
/// folded section.
class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({
    required this.groupId,
    this.highlightDistill = false,
    super.key,
  });

  final int groupId;

  /// Points out "Distill", for the group created by the onboarding.
  final bool highlightDistill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final summary = ref.watch(groupSummaryProvider(groupId));
    return Scaffold(
      appBar: AppBar(
        title: Text(summary?.group.name ?? ''),
        actions: [
          IconButton(
            tooltip: strings.bulkTooltip,
            icon: const Icon(Icons.playlist_add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => BulkAddScreen(initialGroupId: groupId),
              ),
            ),
          ),
          IconButton(
            tooltip: strings.groupSettingsTooltip,
            icon: const Icon(Icons.tune),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => GroupSettingsScreen(groupId: groupId),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: strings.addCardTooltip,
        onPressed: () => openNewCard(context, groupId: groupId),
        child: const Icon(Icons.add),
      ),
      body: summary == null
          ? const SizedBox.shrink()
          : _GroupBody(summary: summary, highlightDistill: highlightDistill),
    );
  }
}

class _GroupBody extends ConsumerWidget {
  const _GroupBody({required this.summary, required this.highlightDistill});

  final GroupSummary summary;
  final bool highlightDistill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return ListView(
      padding: scrollPadding(context, const EdgeInsets.fromLTRB(20, 0, 20, 96)),
      children: [
        Text(
          '${strings.cardCount(summary.cardCount)} · ${strings.presetName(summary.preset)}',
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
        if (summary.group.pausedAt case final pausedAt?) ...[
          const SizedBox(height: 16),
          PausedBanner(
            since: pausedAt,
            onResume: () =>
                ref.read(pauseServiceProvider).resumeGroup(summary.groupId),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          spacing: 10,
          children: [
            GroupStatTile(value: summary.dueCount, label: strings.groupStatDue),
            GroupStatTile(
              value: summary.introducedCount,
              label: strings.groupStatActive,
            ),
            GroupStatTile(
              value: summary.pendingCount,
              label: strings.groupStatWaiting,
            ),
          ],
        ),
        if (summary.dueCount > 0) ...[
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => openSession(context, ref, [
              for (final item in ref.read(dueItemsProvider))
                if (item.groupId == summary.groupId) item.card.id,
            ]),
            child: Text(strings.groupReviewDue(summary.dueCount)),
          ),
        ],
        const SizedBox(height: 16),
        GroupDistillationSection(
          groupId: summary.groupId,
          highlighted: highlightDistill,
        ),
        const SizedBox(height: 16),
        ReverseButton(group: summary.group),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: SectionLabel(strings.groupCardsSection)),
            if (summary.cardCount > 0)
              TextButton.icon(
                icon: const Icon(Icons.play_arrow, size: 20),
                label: Text(strings.groupReviewAll),
                onPressed: () => _reviewAll(context, ref),
              ),
          ],
        ),
        _CardList(groupId: summary.groupId),
      ],
    );
  }

  /// "Review all": a session on every card of the group, where only the
  /// cards due today count; the others are bonus reviews.
  Future<void> _reviewAll(BuildContext context, WidgetRef ref) {
    final cards = ref.read(groupCardsProvider(summary.groupId)).value ?? [];
    final review = WholeGroupReview(ref.read(duePolicyProvider));
    return openSession(
      context,
      ref,
      review.cardIds(cards, ref.read(clockProvider)()),
    );
  }
}

/// The cards of the group, the acquired ones apart in a folded section.
class _CardList extends ConsumerWidget {
  const _CardList({required this.groupId});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(groupCardsProvider(groupId)).value ?? const [];
    final formatter = watchCardStatusFormatter(context, ref);
    if (cards.isEmpty || formatter == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          AppLocalizations.of(context).groupEmpty,
          style: TextStyle(color: AlambicColors.of(context).textSecondary),
        ),
      );
    } else {
      final ongoing = [
        for (final card in cards)
          if (card.state != CardState.acquired) card,
      ];
      final acquired = [
        for (final card in cards)
          if (card.state == CardState.acquired) card,
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          if (ongoing.isNotEmpty) _panel(context, ongoing, formatter),
          if (acquired.isNotEmpty)
            _AcquiredSection(
              count: acquired.length,
              panel: _panel(context, acquired, formatter),
            ),
        ],
      );
    }
  }

  Widget _panel(
    BuildContext context,
    List<Flashcard> cards,
    CardStatusFormatter formatter,
  ) => SurfacePanel(
    children: [
      for (final card in cards)
        CardListTile(
          card: card,
          formatter: formatter,
          onTap: () => openCard(context, card.id),
        ),
    ],
  );
}

/// "Acquired · 3", folded until its title is touched.
class _AcquiredSection extends StatefulWidget {
  const _AcquiredSection({required this.count, required this.panel});

  final int count;
  final Widget panel;

  @override
  State<_AcquiredSection> createState() => _AcquiredSectionState();
}

class _AcquiredSectionState extends State<_AcquiredSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          expanded: _expanded,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                children: [
                  Expanded(
                    child: SectionLabel(
                      AppLocalizations.of(context)
                          .groupAcquiredSection(widget.count),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 12, 8),
                    child: Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded) widget.panel,
      ],
    );
  }
}
