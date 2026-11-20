import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the real fonts so golden images show readable text instead of the
/// default test font made of boxes, and fails a widget test stuck for 30 s
/// instead of the 10 min of flutter_test: the longest takes about 3 s.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  if (binding is AutomatedTestWidgetsFlutterBinding) {
    binding.defaultTestTimeout = const Timeout(Duration(seconds: 30));
  }
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
