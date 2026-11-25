import 'package:material_ui/material_ui.dart';

import '../../data/samples/sample_group.dart';
import '../../l10n/generated/app_localizations.dart';

/// Names of the sample groups.
extension SampleGroupLabels on AppLocalizations {
  String sampleGroupName(SampleGroup sample) => switch (sample) {
    SampleGroup.capitals => sampleGroupCapitals,
  };
}

/// The texts of the language [edition] is written in, whatever the language
/// of the app: its group is named in that language.
AppLocalizations editionStrings(SampleEdition edition) =>
    lookupAppLocalizations(Locale(edition.languageCode));

/// The name of the group of [edition], in its own language: "Capitales" for
/// the French capitals.
String editionGroupName(SampleEdition edition) =>
    editionStrings(edition).sampleGroupName(edition.sample);
