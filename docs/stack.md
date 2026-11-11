# Stack — Remanence

## Langages et environnements

- Dart 3.13 et Flutter 3.47 (canal stable). La cible de la V1 est Android uniquement : le projet ne contient que le dossier `android/`.
- Android : AGP 9.1, Kotlin 2.4, `compileSdk` 37, Java 17 avec désucrage de la bibliothèque standard (`coreLibraryDesugaring`).

## Bibliothèques clés

Les versions sont fixées à l'identique dans `pubspec.yaml` (pas de `^`) et dans `pubspec.lock`, pour qu'un build sur une autre machine produise la même app. Une montée de version est un changement explicite des deux fichiers.

- `flutter_riverpod` : état et injection de dépendances.
- `drift` et `drift_flutter` : base SQLite locale (cartes, sens, révisions, presets). `drift_dev` et `build_runner` génèrent le code en développement.
- `shared_preferences` : préférences d'interface.
- `flutter_local_notifications` : notifications avec boutons d'action traités en tâche de fond.
- `android_alarm_manager_plus` : réveil de l'app à l'heure d'une échéance, y compris après un redémarrage du téléphone.
- `intl` et `flutter_localizations` : traductions générées depuis les fichiers ARB de `lib/l10n/`.
- Police DM Sans (OFL), embarquée en quatre graisses statiques dans `assets/fonts/`.

## Commandes

- Dépendances : `flutter pub get`. Les traductions sont régénérées à cette occasion dans `lib/l10n/generated/`, qui n'est pas versionné.
- Code généré par drift : `dart run build_runner build`. Les fichiers `*.g.dart` sont versionnés pour qu'un clone compile sans cette étape.
- Analyse : `flutter analyze`. Formatage : `dart format lib test`.
- Tests : `flutter test`. Régénérer les golden tests après un changement visuel voulu : `flutter test --update-goldens`.
- APK de debug : `flutter build apk --debug`. Installation sur un téléphone branché : `flutter install` ou `flutter run`.

## Conventions

- Code et commentaires en anglais ; documentation et textes de l'interface en français, l'anglais arrivant par les fichiers ARB.
- Style officiel Dart (`dart format`, indentation de deux espaces) et lints `flutter_lints` complétés dans `analysis_options.yaml`. L'`.editorconfig` reprend ces règles pour les autres éditeurs.
- Une classe, une énumération ou un type par fichier, nommé d'après lui.
- Le domaine (`lib/domain/`) est du Dart pur : il n'importe ni Flutter, ni drift, ni plugin. Le temps courant lui est toujours passé en paramètre.

## Pièges

- `flutter_local_notifications` 23 exige `compileSdk` 37. Avec AGP 9, le SDK 37 s'installe sous le nom `android-37.0` : `compileSdk = 37` échoue avec « Failed to find target with hash string 'android-37' ». Il faut la syntaxe `compileSdk { version = release(37) { minorApiLevel = 0 } }` de `android/app/build.gradle.kts`.
- Dans les golden tests, Flutter remplace les ombres par un contour noir : le bouton flottant apparaît cerclé de noir sur les images de référence. Ce n'est pas un défaut de l'app.
- Les golden tests dépendent du rendu de la plateforme qui les a générés (Windows ici). Les régénérer sur une autre plateforme produit des écarts de quelques pixels.
