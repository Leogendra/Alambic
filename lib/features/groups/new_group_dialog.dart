import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/sample_group_labels.dart';
import '../../app/widgets/choice_tile.dart';
import '../../app/widgets/section_label.dart';
import '../../application/groups/sample_group_providers.dart';
import '../../data/samples/sample_group.dart';
import '../../l10n/generated/app_localizations.dart';

/// What "New" creates: an empty group, named afterwards, or a sample group.
sealed class NewGroupChoice {
  const NewGroupChoice();
}

final class EmptyGroupChoice extends NewGroupChoice {
  const EmptyGroupChoice();
}

final class SampleGroupChoice extends NewGroupChoice {
  const SampleGroupChoice(this.edition);

  final SampleEdition edition;
}

/// Asks what "New" creates: an empty group, or one of the sample groups in
/// any of its languages, whatever the language of the app. Returns `null`
/// when the dialog is dismissed.
Future<NewGroupChoice?> showNewGroupDialog(BuildContext context) =>
    showDialog<NewGroupChoice>(
      context: context,
      builder: (context) => const _NewGroupDialog(),
    );

class _NewGroupDialog extends StatelessWidget {
  const _NewGroupDialog();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SimpleDialog(
      title: Text(strings.newGroupTitle),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        ChoiceTile(
          label: strings.newGroupEmpty,
          detail: strings.newGroupEmptyHint,
          isSelected: false,
          onTap: () => Navigator.of(context).pop(const EmptyGroupChoice()),
        ),
        const SizedBox(height: 20),
        SectionLabel(strings.newGroupFromExample),
        for (final edition in SampleGroup.editions)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _SampleTile(edition),
          ),
      ],
    );
  }
}

/// A sample group in one language: its name in that language, then the
/// language and its number of cards once they are read ("Français · 197
/// cards").
class _SampleTile extends ConsumerWidget {
  const _SampleTile(this.edition);

  final SampleEdition edition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final cards = ref.watch(sampleCardsProvider(edition)).value;
    final language = editionStrings(edition).languageName;
    return ChoiceTile(
      label: editionGroupName(edition),
      detail: cards == null
          ? language
          : '$language · ${strings.cardCount(cards.length)}',
      isSelected: false,
      onTap: () => Navigator.of(context).pop(SampleGroupChoice(edition)),
    );
  }
}
