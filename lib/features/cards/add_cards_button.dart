import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'bulk_add_screen.dart';
import 'card_navigation.dart';

/// The "+" button of the app. It opens two separate floating buttons above
/// itself, "Add a card" and "Add several cards", over a barrier that closes
/// them; the "+" turns into a close button meanwhile. When [groupId] is given,
/// both start in that group.
class AddCardsButton extends StatelessWidget {
  const AddCardsButton({this.groupId, super.key});

  final int? groupId;

  static const _gap = 12.0;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return FloatingActionButton(
      tooltip: strings.addCardsTooltip,
      onPressed: () => _open(context),
      child: const Icon(Icons.add),
    );
  }

  /// Opens the buttons where the "+" sits, then runs the chosen action.
  Future<void> _open(BuildContext context) async {
    final navigator = Navigator.of(context);
    final overlay = navigator.overlay!.context.findRenderObject()! as RenderBox;
    final button = context.findRenderObject()! as RenderBox;
    final bounds =
        button.localToGlobal(Offset.zero, ancestor: overlay) & button.size;
    final choice = await showGeneralDialog<_AddChoice>(
      context: context,
      barrierDismissible: true,
      barrierLabel: AppLocalizations.of(context).commonClose,
      barrierColor: Colors.black38,
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (context, _, _) => _Choices(bounds: bounds),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case _AddChoice.card:
        await openNewCard(context, groupId: groupId);
      case _AddChoice.bulk:
        await navigator.push(
          MaterialPageRoute<void>(
            builder: (context) => BulkAddScreen(initialGroupId: groupId),
          ),
        );
      case null:
        break;
    }
  }
}

enum _AddChoice { card, bulk }

/// The floating buttons, right-aligned on the "+" ([bounds]) and stacked above
/// it, with a close button in its place.
class _Choices extends StatelessWidget {
  const _Choices({required this.bounds});

  final Rect bounds;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        PositionedDirectional(
          end: size.width - bounds.right,
          bottom: size.height - bounds.top + AddCardsButton._gap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: AddCardsButton._gap,
            children: [
              _ChoiceButton(
                icon: Icons.playlist_add,
                label: strings.addCardsBulk,
                choice: _AddChoice.bulk,
              ),
              _ChoiceButton(
                icon: Icons.edit_outlined,
                label: strings.addCardsOne,
                choice: _AddChoice.card,
              ),
            ],
          ),
        ),
        Positioned.fromRect(
          rect: bounds,
          child: FloatingActionButton(
            heroTag: null,
            tooltip: strings.commonClose,
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(Icons.close),
          ),
        ),
      ],
    );
  }
}

/// One floating button: on the surface with an outline, so it stands apart
/// from the accent of the "+".
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.icon,
    required this.label,
    required this.choice,
  });

  final IconData icon;
  final String label;
  final _AddChoice choice;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return FloatingActionButton.extended(
      heroTag: null,
      backgroundColor: colors.surface,
      foregroundColor: colors.accentText,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.border),
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: () => Navigator.of(context).pop(choice),
    );
  }
}
