import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/groups/group_providers.dart';
import '../../domain/groups/card_group.dart';
import '../../l10n/generated/app_localizations.dart';

/// "Hide the back" on a group page: the card lists of the group then show
/// the fronts alone. Pressed again, it shows the backs.
class BackVisibilityButton extends ConsumerWidget {
  const BackVisibilityButton({required this.group, super.key});

  final CardGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final hidden = group.backHidden;
    return OutlinedButton.icon(
      icon: Icon(
        hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 18,
      ),
      label: Text(hidden ? strings.groupBackShow : strings.groupBackHide),
      onPressed: () => ref
          .read(groupServiceProvider)
          .setBackHidden(group.id, hidden: !hidden),
    );
  }
}
