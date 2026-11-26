import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../l10n/generated/app_localizations.dart';

/// A system permission under "Permissions": once [allowed], the row only
/// says so with a check mark, there is nothing to turn off; refused, it
/// offers to allow it with a button calling [onAllow].
class PermissionRow extends StatelessWidget {
  const PermissionRow({
    required this.title,
    required this.allowed,
    required this.allowedHint,
    required this.refusedHint,
    required this.onAllow,
    super.key,
  });

  final String title;
  final bool allowed;
  final String allowedHint;
  final String refusedHint;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    if (allowed) {
      return PanelRow(
        title: title,
        subtitle: allowedHint,
        trailing: Icon(
          Icons.check_circle,
          color: AlambicColors.of(context).accent,
        ),
      );
    }
    return PanelRow(
      title: title,
      subtitle: refusedHint,
      trailing: FilledButton.tonal(
        style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
        onPressed: onAllow,
        child: Text(AppLocalizations.of(context).settingsPermissionAllow),
      ),
    );
  }
}
