# Feature 3 — Cartes

Statut : en cours (2026-11-11)

## Goal

Créer et modifier les [cartes](../lexicon.md#carte) recto / verso, choisir de les réviser dans un seul sens ou dans les deux, les ranger dans un groupe et leur donner un preset. Pour l'instant une face ne porte que du texte ; les images viendront plus tard.

## Implementation overview

Le bouton « + » de la navigation ouvre l'éditeur de carte vide. Le même écran sert à modifier une carte existante. Il montre le recto, le verso, l'option « Aussi dans l'autre sens », le groupe (« Sans groupe » par défaut, ou le groupe d'où l'on vient) et le preset, hérité tant qu'on n'en choisit pas un. La ligne du preset dit d'où il vient : « Hérité du groupe : Standard » ou « Preset global : Standard ».

Le recto et le verso sont obligatoires. Le texte est enregistré sans les espaces de début et de fin.

### Sens créés

Toute carte a deux [sens](../lexicon.md#sens) en base dès sa création, quel que soit le choix fait :

- recto → verso est actif et dû au prochain horaire de son preset ([Feature 1](1-planification.md#échéance-dun-nouveau-sens)) ;
- verso → recto est actif seulement si « Aussi dans l'autre sens » est coché, et dû alors le lendemain du recto ; sinon il est inactif.

Créer le sens inverse d'office, même inactif, évite de devoir le fabriquer plus tard : cocher l'option en modification, ou une distillation côté verso, n'a qu'à changer son état.

En modification, cocher l'option planifie le sens inverse comme un sens neuf ; la décocher le rend inactif, sans effacer son historique.

### Ajout en masse

La page d'un groupe (et celle de « Sans groupe ») ouvre l'ajout en masse : on colle une carte par ligne, recto et verso séparés par un séparateur. Le séparateur est un champ libre prérempli avec `;`, et peut faire plusieurs caractères.

La lecture des lignes est une règle du domaine (`BulkCardParser`), refaite à chaque frappe :

- une ligne vide est sautée sans erreur ;
- le recto s'arrête au premier séparateur, si bien que le verso peut lui-même contenir le séparateur ;
- une ligne sans séparateur, ou dont le recto ou le verso est vide, est signalée par son numéro et ignorée.

L'écran annonce le nombre de cartes prêtes et liste les lignes ignorées avant l'ajout. Les cartes sont créées dans une seule transaction, dans l'ordre des lignes, avec l'option « Aussi dans l'autre sens » choisie une fois pour toutes ; elles suivent le preset de leur groupe.

### Gestion de la carte

Le service des cartes porte aussi la suspension (une carte suspendue n'est jamais due, dans aucun sens), la remise à zéro de la progression (chaque sens actif ou acquis repart comme un sens neuf, historique conservé) et la suppression. Chaque opération qui touche aux échéances prévient la planification des notifications.

## Acceptance criteria

- [x] Une carte se crée avec un recto et un verso texte ; une face vide est refusée.
- [x] Sans l'option, seul le sens recto → verso est actif, dû au prochain horaire du preset.
- [x] Avec l'option, le sens verso → recto est actif aussi, dû le lendemain.
- [x] Modifier une carte change son texte, son groupe, son preset, et active ou arrête le sens inverse.
- [x] L'ajout en masse crée une carte par ligne valide, dans l'ordre, et signale les lignes ignorées par leur numéro.
- [x] Le séparateur de l'ajout en masse est modifiable ; changer de séparateur relit toutes les lignes.
- [x] Réinitialiser replanifie les sens actifs comme des sens neufs, en gardant l'historique.

## Test strategy

- Le service est testé sur une base en mémoire avec une horloge fixée : état et échéance de chaque sens après création, modification et remise à zéro, lus depuis la base.
- Chaque test vérifie aussi que la planification des notifications a été prévenue, par un écouteur qui compte les appels.
- La lecture des lignes collées est testée en logique pure : espaces, lignes vides, séparateur absent, face vide, séparateur de plusieurs caractères.
- L'écran d'ajout en masse est testé de bout en bout sur une base en mémoire : rapport avant ajout, changement de séparateur, cartes créées dans le groupe avec leurs deux sens.
- L'éditeur et l'ajout en masse sont couverts par des golden tests.

## File mapping

- `lib/application/cards/` — service des cartes, brouillon de l'éditeur, fournisseurs.
- `lib/data/repositories/card_repository.dart` — stockage des cartes et de leurs sens, flux des cartes avec leurs sens.
- `lib/domain/cards/bulk/` — lecture des lignes de l'ajout en masse.
- `lib/features/cards/` — éditeur de carte, ajout en masse, sélecteur de groupe, ligne de carte des listes.

## Technical details

Les flux de cartes (`watchCard`, `watchCardsOfGroup`, `watchSearch`) observent à la fois la table des cartes et celle des sens, et relisent les deux à chaque changement. Une réponse modifie un sens sans toucher à sa carte : un flux qui n'observerait que les cartes afficherait des crans et des échéances périmés.
