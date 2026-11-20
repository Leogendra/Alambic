import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/groups/group_providers.dart';
import '../../domain/groups/card_group.dart';
import '../../l10n/generated/app_localizations.dart';

/// "Enable the back" on a group page: from then on each display of a card
/// asks its front or its back, at random. Pressed again, it disables it.
class ReverseButton extends ConsumerWidget {
  const ReverseButton({required this.group, super.key});

  final CardGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final enabled = group.reverseEnabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 6,
      children: [
        OutlinedButton.icon(
          icon: Icon(enabled ? Icons.flip_to_front : Icons.flip, size: 18),
          label: Text(
            enabled ? strings.groupReverseDisable : strings.groupReverseEnable,
          ),
          onPressed: () => ref
              .read(groupServiceProvider)
              .setReverseEnabled(group.id, enabled: !enabled),
        ),
        Text(
          enabled ? strings.groupReverseOnHint : strings.groupReverseOffHint,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AlambicColors.of(context).textSecondary,
          ),
        ),
      ],
    );
  }
}
