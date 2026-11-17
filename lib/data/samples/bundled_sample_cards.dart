import 'package:flutter/services.dart';

/// The cards of the sample group, shipped with the app in the format of the
/// bulk add.
abstract final class BundledSampleCards {
  static const String asset = 'assets/samples/nato_alphabet.txt';

  /// Read only during the onboarding: not worth keeping in the cache of the
  /// bundle.
  static Future<String> load() => rootBundle.loadString(asset, cache: false);
}
