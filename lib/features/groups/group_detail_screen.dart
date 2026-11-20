import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/layout/scroll_padding.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/cards/card_providers.dart';
import '../../application/groups/group_providers.dart';
import '../../application/groups/group_summary.dart';
import '../../application/groups/group_sections.dart';
import '../../application/clock.dart';
import '../../application/reviews/whole_group_review.dart';
import '../../application/scheduling/scheduling_providers.dart';
import '../../domain/cards/flashcard.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cards/bulk_add_screen.dart';
import '../cards/card_list_tile.dart';
import '../cards/card_navigation.dart';
import '../cards/card_status_formatter.dart';
import '../cards/card_status_formatter_provider.dart';
import '../distillation/group_distillation_section.dart';
import '../session/session_launcher.dart';
import 'group_settings_screen.dart';
import 'reverse_button.dart';

/// A group page: "Distill" or the tracking of its distillation, the back
/// option, then its cards, under a "Cards" title with "Review all" beside
/// it, in three sections: in progress, waiting in queue order, and learned,
/// folded.
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
    final cards =
        ref.watch(groupCardsProvider(summary.groupId)).value ?? const [];
    final sections = GroupSections.of(cards);
    return ListView(
      padding: scrollPadding(context, const EdgeInsets.fromLTRB(20, 0, 20, 96)),
      children: [
        const SizedBox(height: 8),
        GroupDistillationSection(
          groupId: summary.groupId,
          highlighted: highlightDistill,
        ),
        const SizedBox(height: 16),
        ReverseButton(group: summary.group),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: SectionLabel(strings.groupCardsSection)),
            if (sections.ongoing.isNotEmpty || sections.waiting.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 12, 0),
                    backgroundColor: colors.surface,
                    foregroundColor: colors.accentText,
                    side: BorderSide(color: colors.border),
                    shape: const StadiumBorder(),
                  ),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: Text(
                    strings.groupReviewAll,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _reviewAll(context, ref, cards),
                ),
              ),
          ],
        ),
        _CardSections(sections: sections),
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

/// The cards of the group in their sections, each under a small title with
/// its count; an empty section is left out.
class _CardSections extends ConsumerWidget {
  const _CardSections({required this.sections});

  final GroupSections sections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final formatter = watchCardStatusFormatter(context, ref);
    if (sections.isEmpty || formatter == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          strings.groupEmpty,
          style: TextStyle(color: AlambicColors.of(context).textSecondary),
        ),
      );
    } else {
      final nextId = sections.nextId;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          if (sections.ongoing case final ongoing when ongoing.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SubsectionLabel(strings.groupOngoingSection(ongoing.length)),
                _panel(context, ongoing, formatter),
              ],
            ),
          if (sections.waiting case final waiting when waiting.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SubsectionLabel(strings.groupWaitingSection(waiting.length)),
                _panel(
                  context,
                  waiting,
                  formatter,
                  nextId: nextId,
                  nextMark: strings.groupNextCard,
                ),
              ],
            ),
          if (sections.acquired case final acquired when acquired.isNotEmpty)
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
    CardStatusFormatter formatter, {
    int? nextId,
    String? nextMark,
  }) => SurfacePanel(
    children: [
      for (final card in cards)
        CardListTile(
          card: card,
          formatter: formatter,
          mark: card.id == nextId ? nextMark : null,
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
                    child: _SubsectionLabel(
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

/// Title of a section of cards, under "Cards": smaller, not in capitals.
class _SubsectionLabel extends StatelessWidget {
  const _SubsectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AlambicColors.of(context).textSecondary,
      ),
    ),
  );
}
