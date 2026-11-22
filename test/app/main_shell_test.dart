import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/app/shell/main_shell.dart';

import '../support/screen_harness.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('main shell in ${brightness.name} theme', (tester) async {
      await pumpScreen(tester, const MainShell(), brightness: brightness);
      await captureShot(
        tester,
        find.byType(MainShell),
        'main_shell_${brightness.name}',
      );
    });
  }
}
