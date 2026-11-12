import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/surface_panel.dart';
import '../../app/widgets/text_input_dialog.dart';
import '../../application/cards/card_providers.dart';
import '../../application/groups/group_providers.dart';
import '../../application/groups/group_summary.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cards/card_list_tile.dart';
import '../cards/card_navigation.dart';
import '../cards/card_status_formatter_provider.dart';
import 'group_detail_screen.dart';
import 'group_summary_tile.dart';

/// Groups tab: card search on top, "No group", then the groups.
class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      children: [
        _header(strings),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: strings.groupsSearchHint,
            prefixIcon: const Icon(Icons.search),
          ),
          onChanged: (text) => setState(() => _query = text.trim()),
        ),
        const SizedBox(height: 16),
        if (_query.isEmpty) _groupList() else _searchResults(strings),
      ],
    );
  }

  Widget _header(AppLocalizations strings) => Row(
    children: [
      Expanded(
        child: Text(
          strings.groupsTitle,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        ),
      ),
      TextButton.icon(
        onPressed: _createGroup,
        icon: const Icon(Icons.add),
        label: Text(strings.commonNew),
      ),
    ],
  );

  Widget _groupList() {
    final summaries = ref.watch(groupSummariesProvider);
    return Column(
      spacing: 10,
      children: [
        for (final summary in summaries)
          GroupSummaryTile(summary: summary, onTap: () => _openGroup(summary)),
      ],
    );
  }

  Widget _searchResults(AppLocalizations strings) {
    final results = ref.watch(cardSearchProvider(_query)).value ?? const [];
    final formatter = watchCardStatusFormatter(context, ref);
    if (results.isEmpty || formatter == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          strings.groupsNoResult,
          textAlign: TextAlign.center,
          style: TextStyle(color: AlambicColors.of(context).textSecondary),
        ),
      );
    } else {
      return SurfacePanel(
        children: [
          for (final card in results)
            CardListTile(
              card: card,
              formatter: formatter,
              onTap: () => openCard(context, card.card.id),
            ),
        ],
      );
    }
  }

  void _openGroup(GroupSummary summary) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => GroupDetailScreen(groupId: summary.groupId),
    ),
  );

  Future<void> _createGroup() async {
    final strings = AppLocalizations.of(context);
    final name = await showTextInputDialog(
      context,
      title: strings.newGroupTitle,
      label: strings.groupNameLabel,
    );
    if (name != null) {
      await ref.read(groupServiceProvider).create(name);
    }
  }
}
