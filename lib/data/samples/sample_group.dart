import 'package:flutter/services.dart';

/// A group of example cards shipped with the app, in the format of the bulk
/// add: one text file per language it is written in.
enum SampleGroup {
  capitals(languageCodes: ['en', 'fr']);

  const SampleGroup({required this.languageCodes});

  final List<String> languageCodes;

  /// Every language of every sample group, in the order of the catalog.
  static List<SampleEdition> get editions => [
    for (final sample in values)
      for (final languageCode in sample.languageCodes)
        (sample: sample, languageCode: languageCode),
  ];

  String assetFor(String languageCode) =>
      'assets/samples/${name}_$languageCode.txt';

  /// Read only to create the group or to show it before: not worth keeping
  /// in the cache of the bundle.
  Future<String> load(String languageCode) =>
      rootBundle.loadString(assetFor(languageCode), cache: false);
}

/// A sample group in one of its languages.
typedef SampleEdition = ({SampleGroup sample, String languageCode});
