import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

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

/// Groups tab: card search on top, then the groups.
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
        if (_query.isEmpty) _groupList(strings) else _searchResults(strings),
      ],
    );
  }

  Widget _header(AppLocalizations strings) => Text(
    strings.groupsTitle,
    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
  );

  /// One row per group, in a single panel, then "New" under the last one.
  Widget _groupList(AppLocalizations strings) {
    final summaries = ref.watch(groupSummariesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summaries.isNotEmpty)
          SurfacePanel(
            children: [
              for (final summary in summaries)
                GroupSummaryTile(
                  summary: summary,
                  onTap: () => _openGroup(summary),
                ),
            ],
          ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _createGroup,
          icon: const Icon(Icons.add),
          label: Text(strings.commonNew),
        ),
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
              onTap: () => openCard(context, card.id),
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
