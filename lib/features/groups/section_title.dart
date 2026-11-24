import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';

/// Title of a section of cards: small, not in capitals, with optional
/// buttons at its right; the title sits at the bottom of those buttons.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {this.actions = const [], super.key});

  final String text;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final label = Padding(
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
    return actions.isEmpty
        ? label
        : Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: label),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: actions,
                ),
              ),
            ],
          );
  }
}

/// A small rounded button of a [SectionTitle], with an icon and a label.
class SectionButton extends StatelessWidget {
  const SectionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 12, 0),
        backgroundColor: colors.surface,
        foregroundColor: colors.accentText,
        side: BorderSide(color: colors.border),
        shape: const StadiumBorder(),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      onPressed: onPressed,
    );
  }
}

/// A small round button of a [SectionTitle], with an icon only, which
/// [tooltip] names.
class SectionIconButton extends StatelessWidget {
  const SectionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return IconButton(
      tooltip: tooltip,
      style: IconButton.styleFrom(
        minimumSize: const Size(36, 36),
        fixedSize: const Size(36, 36),
        padding: EdgeInsets.zero,
        backgroundColor: colors.surface,
        foregroundColor: colors.accentText,
        side: BorderSide(color: colors.border),
      ),
      icon: Icon(icon, size: 18),
      onPressed: onPressed,
    );
  }
}
