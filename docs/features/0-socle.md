# Feature 0 — Socle technique

Statut : en cours (2026-11-11)

## Goal

Infrastructure sans exigence fonctionnelle propre : projet Flutter `fr.gatienh.remanence`, thème « hybride » clair et sombre, navigation principale, textes traduisibles et base de données locale. Toutes les autres features s'appuient dessus.

## Implementation overview

L'app démarre sur `RemanenceApp`, qui applique le thème clair ou sombre selon le réglage du système et charge les textes français. L'écran racine est une coquille à quatre onglets (Accueil, Groupes, Statistiques, Réglages) avec un bouton flottant « + » pour créer une carte.

Le thème part d'un `ColorScheme` Material 3 construit sur l'accent `#1447FF`, puis le surcharge avec les couleurs de la maquette. Les couleurs qui n'ont pas d'équivalent Material (fond des segments, couleurs du bouton « À revoir », texte secondaire et tertiaire) sont portées par l'extension de thème `RemanenceColors`, lue par les écrans avec `RemanenceColors.of(context)`. Chaque jeton a une valeur claire et une valeur sombre, reprises de la maquette.

La police DM Sans est embarquée en graisses statiques (400, 500, 600, 700) et non en police variable. Flutter n'applique pas de lui-même l'axe de graisse d'une police variable, alors qu'il choisit le bon fichier statique d'après `fontWeight`.

### Base de données

Toutes les données vivent dans une base SQLite locale gérée par drift, `RemanenceDatabase`. Les tables utilisent directement les classes du domaine comme lignes (`@UseRowClass`) : un `Preset` ou une `CardDirection` lu en base est l'objet que manipulent les règles métier, sans couche de conversion. Les énumérations sont stockées par leur nom, la séquence d'un preset en JSON et les heures en minutes depuis minuit.

Les tables suivent le modèle du [lexique](../lexicon.md) : `presets`, `app_settings` (une seule ligne, qui porte le preset global), `card_groups`, `flashcards`, `card_directions` (un sens par carte et par orientation), `review_records` (l'historique) et `extra_reminders` (les rappels de « Réviser bientôt »). Les clés étrangères sont activées à chaque ouverture, ce qui donne deux règles de suppression :

- supprimer une carte supprime ses sens, leur historique et leurs rappels ;
- supprimer un groupe range ses cartes dans « Sans groupe » au lieu de les supprimer.

Le preset global est dans la base et non dans les préférences, parce qu'il fait partie des données de révision : il doit être lisible depuis les tâches de fond et voyager avec l'export.

À la création de la base, les presets Standard et Intensif sont insérés et Standard devient le preset global. La connexion est partagée entre isolates (`shareAcrossIsolates`) : une réponse donnée depuis une notification, traitée dans un isolate de fond, rafraîchit les écrans de l'app ouverte.

## Acceptance criteria

- [x] L'identifiant Android est `fr.gatienh.remanence` et le nom affiché est « Remanence ».
- [x] Les versions des dépendances sont fixées à l'identique dans `pubspec.yaml` et `pubspec.lock`.
- [x] L'app suit le thème clair ou sombre du système, en DM Sans avec l'accent `#1447FF`.
- [x] La navigation principale montre quatre onglets et un bouton « + ».
- [x] Une base neuve contient les presets Standard et Intensif, Standard étant le preset global.
- [x] Supprimer un groupe range ses cartes dans « Sans groupe » ; supprimer une carte supprime ses sens et leur historique.

## Test strategy

- La coquille est couverte par des golden tests, en thème clair et en thème sombre, à la taille des écrans de la maquette (390 × 844).
- Le schéma est testé sur une base SQLite en mémoire, réelle et non simulée : contenu initial et règles de suppression en cascade.
- Les golden tests chargent les vraies polices (DM Sans et les icônes Material), sans quoi le texte serait rendu en blocs et les images ne montreraient pas la typographie.

## File mapping

- `lib/app/` — coquille de l'app et thème.
- `lib/data/database/` — base drift : tables, convertisseurs et contenu initial. Le fichier `remanence_database.g.dart` est généré par `build_runner`.
- `lib/l10n/app_fr.arb` — textes de l'interface, source des traductions générées.
- `assets/fonts/` — DM Sans et sa licence OFL.
- `android/app/build.gradle.kts` — `compileSdk` 37 et désucrage, exigés par les notifications (voir `stack.md`).
- `test/support/` — harnais commun des golden tests.
- `test/flutter_test_config.dart` — chargement des polices avant tous les tests.
