# Feature 0 — Socle technique

Statut : en cours (2026-11-11)

## Goal

Infrastructure sans exigence fonctionnelle propre : projet Flutter `fr.gatienh.remanence`, thème « hybride » clair et sombre, navigation principale et textes traduisibles. Toutes les autres features s'appuient dessus.

## Implementation overview

L'app démarre sur `RemanenceApp`, qui applique le thème clair ou sombre selon le réglage du système et charge les textes français. L'écran racine est une coquille à quatre onglets (Accueil, Groupes, Statistiques, Réglages) avec un bouton flottant « + » pour créer une carte.

Le thème part d'un `ColorScheme` Material 3 construit sur l'accent `#1447FF`, puis le surcharge avec les couleurs de la maquette. Les couleurs qui n'ont pas d'équivalent Material (fond des segments, couleurs du bouton « À revoir », texte secondaire et tertiaire) sont portées par l'extension de thème `RemanenceColors`, lue par les écrans avec `RemanenceColors.of(context)`. Chaque jeton a une valeur claire et une valeur sombre, reprises de la maquette.

La police DM Sans est embarquée en graisses statiques (400, 500, 600, 700) et non en police variable. Flutter n'applique pas de lui-même l'axe de graisse d'une police variable, alors qu'il choisit le bon fichier statique d'après `fontWeight`.

## Acceptance criteria

- [x] L'identifiant Android est `fr.gatienh.remanence` et le nom affiché est « Remanence ».
- [x] Les versions des dépendances sont fixées à l'identique dans `pubspec.yaml` et `pubspec.lock`.
- [x] L'app suit le thème clair ou sombre du système, en DM Sans avec l'accent `#1447FF`.
- [x] La navigation principale montre quatre onglets et un bouton « + ».

## Test strategy

- La coquille est couverte par des golden tests, en thème clair et en thème sombre, à la taille des écrans de la maquette (390 × 844).
- Les golden tests chargent les vraies polices (DM Sans et les icônes Material), sans quoi le texte serait rendu en blocs et les images ne montreraient pas la typographie.

## File mapping

- `lib/app/` — coquille de l'app et thème.
- `lib/l10n/app_fr.arb` — textes de l'interface, source des traductions générées.
- `assets/fonts/` — DM Sans et sa licence OFL.
- `android/app/build.gradle.kts` — `compileSdk` 37 et désucrage, exigés par les notifications (voir `stack.md`).
- `test/support/` — harnais commun des golden tests.
- `test/flutter_test_config.dart` — chargement des polices avant tous les tests.
