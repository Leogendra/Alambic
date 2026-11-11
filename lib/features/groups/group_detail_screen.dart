import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/preset_labels.dart';
import '../../app/theme/remanence_colors.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/cards/card_providers.dart';
import '../../application/groups/group_providers.dart';
import '../../application/groups/group_summary.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cards/card_list_tile.dart';
import '../cards/card_navigation.dart';
import '../cards/card_status_formatter_provider.dart';
import 'group_settings_screen.dart';
import 'group_stat_tile.dart';

/// A group page, or "Sans groupe" when [groupId] is `null`.
class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({required this.groupId, super.key});

  final int? groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final summary = ref.watch(groupSummaryProvider(groupId));
    return Scaffold(
      appBar: AppBar(
        title: Text(summary?.group?.name ?? strings.noGroup),
        actions: [
          if (groupId != null)
            IconButton(
              tooltip: strings.groupSettingsTooltip,
              icon: const Icon(Icons.tune),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => GroupSettingsScreen(groupId: groupId!),
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
          : _GroupBody(summary: summary),
    );
  }
}

class _GroupBody extends ConsumerWidget {
  const _GroupBody({required this.summary});

  final GroupSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = RemanenceColors.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
      children: [
        Text(
          '${strings.cardCount(summary.cardCount)} · ${summary.preset.name} · '
          '${strings.presetModeLabel(summary.preset)} · '
          '${strings.presetScheduleLabel(summary.preset)}',
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          spacing: 10,
          children: [
            GroupStatTile(value: summary.dueCount, label: strings.groupStatDue),
            GroupStatTile(
              value: summary.activeCount,
              label: strings.groupStatActive,
            ),
            GroupStatTile(
              value: summary.pendingCount,
              label: strings.groupStatPending,
            ),
          ],
        ),
        const SizedBox(height: 24),
        SectionLabel(strings.groupCardsSection),
        _CardList(groupId: summary.groupId),
      ],
    );
  }
}

class _CardList extends ConsumerWidget {
  const _CardList({required this.groupId});

  final int? groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(groupCardsProvider(groupId)).value ?? const [];
    final formatter = watchCardStatusFormatter(context, ref);
    if (cards.isEmpty || formatter == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          AppLocalizations.of(context).groupEmpty,
          style: TextStyle(color: RemanenceColors.of(context).textSecondary),
        ),
      );
    } else {
      return SurfacePanel(
        children: [
          for (final card in cards)
            CardListTile(
              card: card,
              formatter: formatter,
              onTap: () => openCard(context, card.card.id),
            ),
        ],
      );
    }
  }
}
