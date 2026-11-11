# Feature 4 — Groupes

Statut : en cours (2026-11-11)

## Goal

Ranger les cartes en [groupes](../lexicon.md#groupe) plats, retrouver une carte par recherche, voir d'un coup d'œil ce qui est dû dans chaque groupe, et régler le nom et le preset d'un groupe.

## Implementation overview

### Onglet Groupes

L'onglet affiche un champ de recherche, puis « Sans groupe » en tête, puis les groupes par ordre alphabétique. Chaque ligne donne le nombre de cartes et le preset suivi (« preset global » pour « Sans groupe »), et un badge avec le nombre de cartes [à réviser](../lexicon.md#à-réviser) quand il y en a. « Nouveau » crée un groupe après avoir demandé son nom.

Dès qu'un texte est saisi, la liste des groupes laisse place aux cartes dont le recto ou le verso contient ce texte, sans tenir compte de la casse, tous groupes confondus (100 résultats au plus).

### Page d'un groupe

La page d'un groupe (ou de « Sans groupe ») rappelle le nombre de cartes, le preset, son mode de notification et son horaire. Trois compteurs suivent : cartes dues, cartes actives (au moins un sens actif ou acquis), cartes en attente de distillation. La liste des cartes est dans l'ordre de création, qui est l'ordre du groupe. Chaque carte montre son recto, son verso, l'état du sens recto → verso (« nouvelle », « cran 2 sur 6 », « suspendue », « en attente de distillation », « acquise ») et sa prochaine échéance (« Due », « à 15:17 », « demain », « dans 3 j »). Le bouton « + » crée une carte directement dans le groupe.

### Réglages d'un groupe

Les réglages d'un groupe sont son nom, son preset et sa suppression. Le preset se choisit dans la liste des presets, ou hérite du preset global. Le groupe suit toujours un preset entier : l'écran rappelle qu'il faut dupliquer un preset pour l'ajuster.

Supprimer un groupe demande confirmation et range ses cartes dans « Sans groupe » ; aucune carte n'est supprimée.

### Comptages

Les compteurs sont calculés par `GroupOverview` à partir de toutes les cartes, du catalogue des presets et de l'instant courant. Une carte compte comme due dès qu'un de ses sens l'est. L'instant courant est republié chaque minute (`currentMomentProvider`), si bien qu'une carte prévue à 12h rejoint les compteurs à l'heure dite sans qu'aucune donnée ne change.

## Acceptance criteria

- [x] L'onglet liste « Sans groupe » en premier, puis les groupes, avec nombre de cartes, preset et nombre de cartes dues.
- [x] La recherche trouve les cartes par leur recto ou leur verso, sans tenir compte de la casse.
- [x] La page d'un groupe montre les compteurs dues / actives / en attente et la liste des cartes avec leur état et leur échéance.
- [x] Un groupe se crée, se renomme, change de preset ou hérite du preset global.
- [x] Supprimer un groupe garde ses cartes, rangées dans « Sans groupe ».
- [x] Une carte suspendue ne compte pas comme due.

## Test strategy

- Les comptages sont testés sur une base en mémoire remplie par les services, à des instants choisis : avant et après l'horaire du preset, avec une carte suspendue.
- Le service des groupes est testé pour la création, le renommage, le refus d'un nom vide et la suppression sans perte de cartes.
- L'onglet (liste et recherche), la page d'un groupe et ses réglages sont couverts par des golden tests sur un jeu de données d'exemple, avec une horloge fixée.

## File mapping

- `lib/application/groups/` — service des groupes, comptages (`GroupOverview`) et fournisseurs.
- `lib/application/time/minute_ticker.dart` — instant courant republié chaque minute.
- `lib/data/repositories/group_repository.dart` — stockage des groupes.
- `lib/features/groups/` — onglet, page et réglages d'un groupe.
- `lib/features/cards/card_list_tile.dart` — ligne de carte partagée par la page d'un groupe et la recherche ; ses textes viennent de `card_status_formatter.dart`.

## Technical details

« Sans groupe » n'est pas une ligne de la table des groupes : c'est la valeur `null` du groupe d'une carte. Les écrans et les comptages le traitent comme un groupe dont l'identifiant est `null`, sans réglages ni distillation.

La recherche s'appuie sur `LIKE` de SQLite, insensible à la casse pour les lettres ASCII seulement : « é » ne trouve pas « É ».
