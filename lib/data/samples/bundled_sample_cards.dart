import 'package:flutter/services.dart';

/// The cards of the sample group, shipped with the app in the format of the
/// bulk add: one file per language of the app.
abstract final class BundledSampleCards {
  static String assetFor(String languageCode) =>
      'assets/samples/capitals_$languageCode.txt';

  /// Read only during the onboarding: not worth keeping in the cache of the
  /// bundle.
  static Future<String> load(String languageCode) =>
      rootBundle.loadString(assetFor(languageCode), cache: false);
}
