import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/app/shell/main_shell.dart';

import '../support/golden_harness.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('main shell in ${brightness.name} theme', (tester) async {
      await pumpGolden(tester, const MainShell(), brightness: brightness);
      await tester.tap(find.text('Statistiques'));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MainShell),
        matchesGoldenFile('goldens/main_shell_${brightness.name}.png'),
      );
    });
  }
}
