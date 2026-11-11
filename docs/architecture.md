# Architecture — Remanence

## Rôle

Remanence est une app Android de répétition espacée où la notification est l'interface principale. Chaque carte a deux [sens](lexicon.md#sens) suivis séparément ; un [preset](lexicon.md#preset) décide quand chaque sens revient. Les règles produit de référence sont dans `SPECS.md` (non versionné) ; `docs/features/` décrit ce qui est implémenté.

## Pièces principales

Le code est découpé en couches, de la plus stable à la plus dépendante de la plateforme. Une couche n'importe que les couches situées au-dessus d'elle dans cette liste.

- `lib/domain/` : les règles métier en Dart pur. Calendrier à 4h, moteur séquence, calcul des échéances, résolution des presets, lecture de l'ajout en masse. Aucun import de Flutter, de drift ou d'un plugin : ces règles se testent sans base ni émulateur. Voir [Feature 1](features/1-planification.md) et [Feature 2](features/2-presets.md).
- `lib/data/` : la persistance. La base drift (`lib/data/database/`) stocke les objets du domaine tels quels. Voir [Feature 0](features/0-socle.md#base-de-données).
- `lib/app/` : la coquille de l'app (`RemanenceApp`, onglets, bouton « + ») et le thème. Voir [Feature 0](features/0-socle.md).
- `lib/l10n/` : les textes de l'interface, en fichiers ARB.

## Décisions de conception

### Le domaine ne connaît pas l'heure

Les fonctions du domaine reçoivent l'instant courant en paramètre au lieu de lire l'horloge. C'est ce qui permet de tester la bascule de 4h, les intervalles de moins d'un jour ou la règle des deux sens sans attendre ni simuler le temps.

### Le pas d'une séquence est ramené à la séquence courante

Un sens garde son [cran](lexicon.md#cran) quand son preset change ou quand la séquence est raccourcie. Plutôt que de réécrire les cartes concernées au moment du changement, le moteur ramène le cran au dernier cran existant à chaque calcul. Le changement de preset à moteur égal n'a donc aucune migration de données à faire.
