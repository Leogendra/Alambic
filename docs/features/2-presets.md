# Feature 2 — Presets

Statut : en cours (2026-11-11)

## Goal

Un [preset](../lexicon.md#preset) regroupe toutes les règles de répétition d'une carte : séquence d'intervalles, comportement en cas d'échec, fin de séquence, horaire, mode de notification. L'utilisateur n'a rien à régler pour commencer (Standard s'applique partout), puis peut choisir un autre preset pour un groupe ou une carte, ou créer le sien.

## Implementation overview

### Presets livrés

La base est créée avec deux presets, tous deux à heure fixe 12h, en une notification par carte, qui reculent d'un cran en cas d'échec et répètent le dernier intervalle en fin de séquence :

- **Standard** : 1 j, 2 j, 1 sem, 1 mois, 3 mois, 6 mois. C'est le preset global de départ.
- **Intensif** : 10 min, 1 h, 1 j, 3 j, 1 sem.

Chaque preset livré porte une clé (`builtInKey`) qui le reconnaît même renommé, pour pouvoir traduire son nom.

### Résolution en cascade

Le preset d'une carte se lit en trois niveaux : le choix fait sur la carte, sinon celui de son groupe, sinon le preset global. Un niveau sans choix hérite du suivant ; il n'y a pas de surcharge champ par champ. Les cartes sans groupe passent directement de leur propre choix au preset global.

Cette règle a une seule implémentation, `PresetResolver`. Les écrans et les services passent par `PresetCatalog`, une photographie de tous les presets et des choix de chaque groupe, qui résout le preset de nombreuses cartes sans interroger la base pour chacune. Le dépôt des presets la publie en flux et la republie dès qu'un preset, le preset global ou le choix d'un groupe change.

### Changement de preset

Changer le preset d'une carte, d'un groupe ou le preset global ne réécrit aucune carte : le cran et l'échéance de chaque sens restent tels quels. Si la nouvelle séquence est plus courte, le moteur ramène le cran au dernier cran au moment de la réponse suivante ([Feature 1](1-planification.md#le-cran)).

## Acceptance criteria

- [x] Une base neuve contient Standard et Intensif, avec les intervalles ci-dessus et l'heure fixe 12h.
- [x] Une carte sans choix suit le preset de son groupe, un groupe sans choix suit le preset global.
- [x] Le choix fait sur une carte l'emporte sur celui de son groupe.
- [x] Changer de preset (même moteur) conserve le cran et l'échéance ; un cran trop grand est ramené au dernier cran.

## Test strategy

- La cascade est prouvée deux fois : en logique pure sur `PresetCatalog`, puis de bout en bout sur une base en mémoire, en changeant les choix par les dépôts comme le font les écrans.
- Le maintien du cran et de l'échéance est vérifié sur les données stockées après le changement, et non sur un objet en mémoire.

## File mapping

- `lib/domain/presets/` — modèle de preset, presets livrés, règle de résolution et `PresetCatalog`.
- `lib/data/repositories/preset_repository.dart` — lecture et écriture des presets et du preset global, flux du catalogue.
- `lib/data/database/preset_companions.dart` — écriture d'un `Preset` du domaine dans sa table.

## Technical details

Le flux du catalogue observe trois tables (presets, réglages, groupes) par une requête témoin `SELECT 1` déclarée sur ces tables, puis relit le tout dans une transaction. Drift ne sait pas combiner nativement plusieurs requêtes en un flux ; ce procédé garde une photographie cohérente à chaque émission.

Le choix d'un moteur différent (séquence vers adaptatif) remet la progression à zéro. Il n'existe pas encore, faute de moteur adaptatif.
