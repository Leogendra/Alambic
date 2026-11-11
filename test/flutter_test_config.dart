import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real fonts so golden images show readable text instead of the
/// default test font made of boxes.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadFont('DM Sans', const [
    'assets/fonts/DMSans-Regular.ttf',
    'assets/fonts/DMSans-Medium.ttf',
    'assets/fonts/DMSans-SemiBold.ttf',
    'assets/fonts/DMSans-Bold.ttf',
  ]);
  await _loadFont('MaterialIcons', const ['fonts/MaterialIcons-Regular.otf']);
  await testMain();
}

Future<void> _loadFont(String family, List<String> assetPaths) async {
  final loader = FontLoader(family);
  for (final path in assetPaths) {
    loader.addFont(rootBundle.load(path));
  }
  await loader.load();
}
