import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/app/shell/main_shell.dart';
import 'package:alambic/features/cards/bulk_add_screen.dart';
import 'package:alambic/features/cards/card_editor_screen.dart';

import '../support/screen_harness.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('main shell in ${brightness.name} theme', (tester) async {
      await pumpScreen(tester, const MainShell(), brightness: brightness);
      for (final tab in [l10n.tabHome, l10n.tabGroups, l10n.tabSettings]) {
        expect(find.text(tab), findsOneWidget);
      }
      await captureShot(
        tester,
        find.byType(MainShell),
        'main_shell_${brightness.name}',
      );
      await expectNoOverflow(tester);
    });
  }

  for (final tab in [l10n.tabHome, l10n.tabGroups, l10n.tabSettings]) {
    testWidgets('the "+" of the $tab tab offers one card or several, in no '
        'group', (tester) async {
      await pumpScreen(tester, const MainShell());
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(l10n.addCardsTooltip));
      await tester.pumpAndSettle();
      expect(find.text(l10n.addCardsOne), findsOneWidget);
      await tester.tap(find.text(l10n.addCardsBulk));
      await tester.pumpAndSettle();
      expect(
        tester.widget<BulkAddScreen>(find.byType(BulkAddScreen)).initialGroupId,
        isNull,
      );
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(l10n.addCardsTooltip));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.addCardsOne));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CardEditorScreen>(find.byType(CardEditorScreen))
            .initialGroupId,
        isNull,
      );
    });
  }
}
