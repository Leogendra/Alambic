# Feature 1 — Planification des révisions

Statut : implémenté (2026-11-11)

## Goal

Décider, après chaque réponse, quand un [sens](../lexicon.md#sens) doit revenir. C'est le cœur de la répétition espacée : une carte réussie revient de plus en plus tard, une carte ratée revient plus tôt. Cette feature couvre le moteur séquence ; le moteur adaptatif (FSRS) viendra s'ajouter à côté.

## Implementation overview

La planification est entièrement dans le domaine et se fait en trois temps.

1. Le moteur séquence (`SequenceEngine`) calcule le nouveau [cran](../lexicon.md#cran) à partir du cran actuel, de la réponse et du [preset](../lexicon.md#preset). Il renvoie l'intervalle à attendre, ou indique que le sens est acquis.
2. Le planificateur (`ReviewScheduler`) transforme cet intervalle en [échéance](../lexicon.md#échéance), selon que l'intervalle se compte en jours ou en minutes.
3. Il applique enfin la règle des deux sens : si l'autre sens de la carte est dû le même jour, celui qu'on planifie passe au lendemain.

La [journée](../lexicon.md#journée) commence à 4h, via `SchedulingCalendar`. Une réponse donnée à 1h du matin compte pour la veille, et toutes les comparaisons « même jour » passent par ce calendrier. Les jours sont ajoutés en jours calendaires et non en tranches de 24 heures, pour qu'un passage à l'heure d'été ne décale pas l'horaire d'une heure.

Le moteur ne lit jamais l'heure : l'instant de la réponse lui est fourni. Il ne lit pas non plus la base ; c'est l'appelant qui lui donne le cran actuel, le preset résolu et l'échéance de l'autre sens.

### Le cran

Le cran est l'indice, dans la séquence du preset, de l'intervalle actuellement attendu. Un sens jamais révisé n'a pas de cran : sa première réponse correcte attend le premier intervalle. Dans la séquence Standard (1 j, 2 j, 1 sem, 1 mois, 3 mois, 6 mois), une carte réussie trois fois de suite attend donc 1 semaine, au cran 3 sur 6.

Si la séquence a été raccourcie, ou si la carte est passée sur un preset plus court, le moteur ramène le cran au dernier cran existant avant de calculer. Le cran stocké n'est corrigé qu'à la réponse suivante.

### Échéance d'un nouveau sens

Un sens qui entre en révision (création d'une carte, activation du sens inverse) est dû au prochain horaire du preset : aujourd'hui si l'horaire n'est pas encore passé, demain sinon. La règle des deux sens s'applique aussi : une carte créée avec ses deux sens a son sens verso → recto planifié le lendemain du sens recto → verso.

### À réviser

Un sens compte comme [à réviser](../lexicon.md#à-réviser) quand il est actif, que sa carte n'est pas suspendue, et :

- que son échéance est passée ;
- ou que son échéance tombe aujourd'hui (ou avant) et qu'il n'a pas déjà été révisé aujourd'hui.

La seconde condition permet de réviser dans l'app dès le matin une carte prévue à 12h, sans attendre la notification. Elle ne s'applique pas à une carte qu'on vient de réussir avec un intervalle de 10 minutes : révisée aujourd'hui, elle attend son échéance exacte.

## Examples

Preset Standard, horaire 12h :

| Situation | Réponse | Résultat |
|---|---|---|
| Jamais révisée, mardi 21h30 | Correct | cran 1 (1 j), mercredi 12h |
| Cran 1, mardi 21h30 | Correct | cran 2 (2 j), jeudi 12h |
| Cran 4 (1 mois), mardi 12h05 | À revoir | cran 3 (1 sem), mardi suivant 12h |
| Jamais révisée, mercredi 1h du matin | Correct | mercredi 12h (la réponse compte pour mardi) |
| Jamais révisée, l'autre sens dû mercredi | Correct mardi | jeudi 12h au lieu de mercredi |

Preset Intensif (10 min, 1 h, …) : une première réponse correcte à 15h07 donne une échéance à 15h17, quel que soit l'horaire du preset.

## Acceptance criteria

- [x] Correct avance d'un cran ; la première réponse correcte attend le premier intervalle.
- [x] À revoir applique le comportement du preset : recule d'un cran sans descendre sous le premier, retour au début, ou même cran. Un sens jamais révisé et raté attend le premier intervalle.
- [x] Après le dernier cran, Correct applique la fin de séquence du preset : répète le dernier intervalle, marque acquis (plus d'échéance), ou boucle au début.
- [x] Un intervalle d'un jour ou plus se compte depuis le jour de la réponse et tombe à l'horaire du preset.
- [x] Un intervalle de moins d'un jour se compte depuis l'instant de la réponse.
- [x] Après un échec, l'échéance est l'intervalle du cran obtenu : jamais le jour même pour une séquence en jours.
- [x] La journée bascule à 4h du matin.
- [x] Les deux sens d'une carte ne sont jamais dus le même jour : le sens planifié passe au lendemain.
- [x] Un cran au-delà d'une séquence raccourcie est ramené au dernier cran.

## Test strategy

- Chaque règle du moteur est prouvée par un test unitaire du domaine, sans base de données : avancée, chaque comportement d'échec, chaque fin de séquence, cran ramené.
- Les dates sont fixées dans les tests (novembre 2026) : aucun test ne lit l'horloge ni n'attend.
- Les bords de la journée (3h59 et 4h, fin de mois, horaire avant 4h) sont testés explicitement sur le calendrier.
- Le décalage du sens inverse est testé à la création et après une réponse.

## File mapping

- `lib/domain/scheduling/` — calendrier à 4h, moteur séquence, planificateur et règle « à réviser ».
- `lib/domain/presets/preset_interval.dart` — un intervalle et son unité ; une unité d'un jour ou plus est comptée en jours.

## Technical details

Les mois comptent 30 jours (`IntervalUnit.month`). Un « 1 mois » a ainsi toujours la même durée, et l'aperçu « dans 30 j » affiché sur les boutons reste vrai quel que soit le mois en cours.

Un horaire de preset antérieur à 4h (par exemple 2h) appartient à la fin de la journée de planification : `momentAt` le place sur la date calendaire suivante. Sans cela, une échéance « le jour J à 2h » tomberait la veille au soir dans le calendrier de l'utilisateur.

La règle des deux sens ne regarde que l'échéance courante de l'autre sens. Elle ne s'applique qu'aux intervalles en jours : un intervalle de 10 minutes n'est jamais repoussé au lendemain.

## Constraints

- Le domaine de planification reste du Dart pur : pas d'import de Flutter, de drift ni de plugin.
