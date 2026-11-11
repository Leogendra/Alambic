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

### Gestion des presets

La liste des presets s'ouvre depuis Réglages, qui permet aussi de choisir le preset global. Chaque preset y montre sa séquence, son horaire et son mode de notification ; le preset global porte un badge.

L'éditeur travaille sur un brouillon et n'écrit rien avant « Enregistrer ». Il règle la séquence (ajout d'un cran en durée et unité, retrait d'un cran tant qu'il en reste un autre), le comportement en cas d'échec, la fin de séquence, la réponse tapée, l'horaire (heure fixe ou plage) et le mode de notification (une par carte, ou rappel groupé qui ouvre l'app ou enchaîne les cartes). Ces trois derniers réglages sont enregistrés dès maintenant ; les notifications qui les exploitent sont décrites dans leur propre feature.

« Nouveau » ouvre un brouillon aux valeurs de Standard. « Dupliquer » enregistre aussitôt une copie nommée « <nom> (copie) » et ouvre son éditeur. Une copie n'est jamais un preset livré, même quand elle copie Standard. Les presets livrés restent modifiables.

Le moteur adaptatif n'est pas encore proposé dans l'éditeur : tout preset créé est une séquence.

### Changement de preset

Changer le preset d'une carte, d'un groupe ou le preset global ne réécrit aucune carte : le cran et l'échéance de chaque sens restent tels quels. Si la nouvelle séquence est plus courte, le moteur ramène le cran au dernier cran au moment de la réponse suivante ([Feature 1](1-planification.md#le-cran)).

## Acceptance criteria

- [x] Une base neuve contient Standard et Intensif, avec les intervalles ci-dessus et l'heure fixe 12h.
- [x] Une carte sans choix suit le preset de son groupe, un groupe sans choix suit le preset global.
- [x] Le choix fait sur une carte l'emporte sur celui de son groupe.
- [x] Changer de preset (même moteur) conserve le cran et l'échéance ; un cran trop grand est ramené au dernier cran.
- [x] On crée un preset depuis les valeurs de Standard, on modifie n'importe quel preset, on duplique un preset sous un nouveau nom.
- [x] Un preset sans nom ou sans cran ne peut pas être enregistré.
- [x] Le preset global se choisit dans Réglages.

## Test strategy

- La cascade est prouvée deux fois : en logique pure sur `PresetCatalog`, puis de bout en bout sur une base en mémoire, en changeant les choix par les dépôts comme le font les écrans.
- Le maintien du cran et de l'échéance est vérifié sur les données stockées après le changement, et non sur un objet en mémoire.
- Création, modification, duplication et refus d'un preset invalide sont testés par le service, sur une base en mémoire.
- La liste et l'éditeur sont couverts par des golden tests sur les presets livrés.

## File mapping

- `lib/domain/presets/` — modèle de preset, presets livrés, règle de résolution et `PresetCatalog`.
- `lib/data/repositories/preset_repository.dart` — lecture et écriture des presets et du preset global, flux du catalogue.
- `lib/data/database/preset_companions.dart` — écriture d'un `Preset` du domaine dans sa table.
- `lib/application/presets/` — service de création, modification et duplication ; fournisseurs Riverpod des presets et du catalogue.
- `lib/features/presets/` — liste, éditeur, dialogue d'ajout de cran et sélecteur de preset réutilisé par les groupes et les cartes.
- `lib/features/settings/settings_screen.dart` — accès aux presets et choix du preset global.

## Technical details

Le flux du catalogue observe trois tables (presets, réglages, groupes) par une requête témoin `SELECT 1` déclarée sur ces tables, puis relit le tout dans une transaction. Drift ne sait pas combiner nativement plusieurs requêtes en un flux ; ce procédé garde une photographie cohérente à chaque émission.

Le choix d'un moteur différent (séquence vers adaptatif) remet la progression à zéro. Il n'existe pas encore, faute de moteur adaptatif.
