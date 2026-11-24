import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/layout/scroll_padding.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/cards/card_providers.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../application/groups/group_providers.dart';
import '../../application/groups/group_summary.dart';
import '../../application/groups/group_sections.dart';
import '../../application/clock.dart';
import '../../application/reviews/whole_group_review.dart';
import '../../application/scheduling/scheduling_providers.dart';
import '../../domain/cards/flashcard.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cards/add_cards_button.dart';
import '../cards/card_list_tile.dart';
import '../cards/card_navigation.dart';
import '../cards/card_status_formatter.dart';
import '../cards/card_status_formatter_provider.dart';
import '../distillation/group_distillation_section.dart';
import '../session/session_launcher.dart';
import 'back_visibility_button.dart';
import 'group_settings_screen.dart';
import 'queue_section.dart';
import 'section_title.dart';

/// A group page: "Distill" or the tracking of its distillation, the button
/// that hides the backs, then its cards in three sections: in progress,
/// waiting in queue order, which can be reordered, and learned, folded.
/// "Review all" sits beside the first title.
class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({required this.groupId, super.key});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final summary = ref.watch(groupSummaryProvider(groupId));
    return Scaffold(
      appBar: AppBar(
        title: Text(summary?.group.name ?? ''),
        actions: [
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
      floatingActionButton: AddCardsButton(groupId: groupId),
      body: summary == null
          ? const SizedBox.shrink()
          : _GroupBody(summary: summary),
    );
  }
}

class _GroupBody extends ConsumerWidget {
  const _GroupBody({required this.summary});

  final GroupSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards =
        ref.watch(groupCardsProvider(summary.groupId)).value ?? const [];
    final sections = GroupSections.of(cards);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: scrollPadding(
            context,
            const EdgeInsets.fromLTRB(20, 0, 20, 96),
          ),
          sliver: SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    GroupDistillationSection(groupId: summary.groupId),
                    const SizedBox(height: 16),
                    BackVisibilityButton(group: summary.group),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              _CardSections(
                sections: sections,
                showBack: !summary.group.backHidden,
                distilling:
                    ref.watch(groupDistillationProvider(summary.groupId)) !=
                    null,
                reviewAll:
                    sections.ongoing.isNotEmpty || sections.waiting.isNotEmpty
                    ? SectionButton(
                        icon: Icons.play_arrow,
                        label: AppLocalizations.of(context).groupReviewAll,
                        onPressed: () => _reviewAll(context, ref, cards),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// "Review all": a session on every card of the group, where only the
  /// cards due today count; the others are bonus reviews, and a pending card
  /// missed goes to the head of the queue.
  Future<void> _reviewAll(
    BuildContext context,
    WidgetRef ref,
    List<Flashcard> cards,
  ) {
    final review = WholeGroupReview(ref.read(duePolicyProvider));
    return openSession(
      context,
      ref,
      review.cardIds(cards, ref.read(clockProvider)()),
      raisesMissedPending: true,
    );
  }
}

/// The cards of the group in their sections, as slivers, each under a small
/// title with its count; an empty section is left out. [reviewAll] sits
/// beside the first title. The waiting cards do not say "waiting" (their
/// section does).
class _CardSections extends ConsumerWidget {
  const _CardSections({
    required this.sections,
    required this.showBack,
    required this.distilling,
    required this.reviewAll,
  });

  final GroupSections sections;
  final bool showBack;
  final bool distilling;
  final Widget? reviewAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final formatter = watchCardStatusFormatter(context, ref);
    if (sections.isEmpty || formatter == null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            strings.groupEmpty,
            style: TextStyle(color: AlambicColors.of(context).textSecondary),
          ),
        ),
      );
    } else {
      final present = [
        if (sections.ongoing case final ongoing when ongoing.isNotEmpty)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionTitle(
                  strings.groupOngoingSection(ongoing.length),
                  actions: [?reviewAll],
                ),
                _panel(context, ongoing, formatter),
              ],
            ),
          ),
        if (sections.waiting case final waiting when waiting.isNotEmpty)
          QueueSection(
            cards: waiting,
            formatter: formatter,
            showBack: showBack,
            distilling: distilling,
            reviewAll: sections.ongoing.isEmpty ? reviewAll : null,
          ),
        if (sections.acquired case final acquired when acquired.isNotEmpty)
          SliverToBoxAdapter(
            child: _AcquiredSection(
              count: acquired.length,
              panel: _panel(context, acquired, formatter),
            ),
          ),
      ];
      return SliverMainAxisGroup(
        slivers: [
          for (final (index, section) in present.indexed) ...[
            if (index > 0)
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
            section,
          ],
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
          showBack: showBack,
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
                    child: SectionTitle(
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
