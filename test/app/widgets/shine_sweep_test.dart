import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:alambic/app/widgets/shine_sweep.dart';

void main() {
  Widget host({bool disableAnimations = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: const Scaffold(
        body: ShineSweep(child: SizedBox(width: 200, height: 52)),
      ),
    ),
  );

  testWidgets('glides once after a short pause, then rests', (tester) async {
    await tester.pumpWidget(host());
    expect(tester.binding.transientCallbackCount, greaterThan(0));
    await tester.pumpAndSettle();
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('plays nothing when animations are disabled', (tester) async {
    await tester.pumpWidget(host(disableAnimations: true));
    expect(tester.binding.transientCallbackCount, 0);
  });
}
