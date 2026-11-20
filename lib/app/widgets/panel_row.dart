import 'package:material_ui/material_ui.dart';

import '../theme/alambic_colors.dart';

/// One line of a [SurfacePanel]: a title, an optional subtitle, the current
/// [value] of the setting and an optional [trailing] control.
///
/// A row that opens something (a screen, a picker, a dialog) ends with a
/// chevron, so that no tappable row reads as plain text. By default the
/// chevron is shown when the row has an [onTap] and no [trailing] control:
/// a switch, a stepper or an action icon already says what a tap does.
class PanelRow extends StatelessWidget {
  const PanelRow({
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.titleColor,
    this.showsChevron,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// Current value of the setting, shown before [trailing].
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  /// Overrides the default rule of the chevron when not `null`.
  final bool? showsChevron;

  bool get _hasChevron => showsChevron ?? (onTap != null && trailing == null);

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(child: _texts(colors)),
              if (value != null) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    value!,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
              if (_hasChevron) ...[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right, color: colors.textSecondary),
              ],
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
        ),
      ),
    );
  }

  Widget _texts(AlambicColors colors) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: titleColor ?? colors.textPrimary,
        ),
      ),
      if (subtitle != null)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            subtitle!,
            style: TextStyle(
              fontSize: 13,
              height: 1.35,
              color: colors.textSecondary,
            ),
          ),
        ),
    ],
  );
}
