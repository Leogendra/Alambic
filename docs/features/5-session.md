# Feature 5 — Session de révision dans l'app

Statut : en cours (2026-11-11)

## Goal

Réviser dans l'app les cartes [à réviser](../lexicon.md#à-réviser), une à une, avec les deux mêmes réponses que dans les notifications, puis revoir aussitôt les cartes ratées sans fausser la planification.

## Implementation overview

### Déroulé

Une session part d'une liste de sens à réviser, triée par [échéance](../lexicon.md#échéance) (la plus ancienne d'abord). La page d'un groupe la lance sur les cartes dues de ce groupe (« Réviser les N dues ») ; l'accueil la lancera sur toutes les cartes dues.

Pour chaque carte, l'écran montre la face posée, avec le groupe et le preset en tête, et la mention « verso → recto » quand c'est le sens inverse. Toucher la carte ou « Afficher la réponse » révèle l'autre face, puis les boutons « À revoir » et « Correct ». Sous chaque bouton figure l'effet de la réponse : « demain », « dans 6 j », « à 15:17 », « acquise », ou « sans effet » pour une révision bonus. Une barre de progression et un compteur « 3 / 12 » suivent l'avancée ; la croix quitte la session, les réponses déjà données restant enregistrées.

### Réponse

Toute réponse passe par `ReviewService`, le même service que les notifications. Il relit le sens en base au moment de la réponse et décide :

- si le sens est à réviser, il calcule la nouvelle échéance ([Feature 1](1-planification.md)), l'enregistre avec l'instant de la réponse, inscrit la réponse dans l'historique et prévient la planification des notifications ;
- sinon, ou si la session est une session bonus, il n'inscrit qu'une [révision bonus](../lexicon.md#révision-bonus) dans l'historique, sans toucher au cran ni à l'échéance.

Relire le sens à chaque réponse garde la session juste si la même carte a été révisée entre-temps depuis une notification : la réponse en session devient alors un bonus.

L'aperçu affiché sous les boutons est calculé par le même service, avec les mêmes règles, sans rien écrire.

### Fin de session

L'écran de fin donne le nombre de cartes, la durée, le nombre de réponses correctes et à revoir. S'il y a des cartes ratées, « Revoir les N ratées maintenant » ouvre une session bonus sur elles : leurs réponses sont inscrites dans l'historique mais leurs échéances ne bougent pas. « Retour à l'accueil » ferme la session.

## Acceptance criteria

- [x] La réponse n'apparaît qu'après un tap sur la carte ou sur « Afficher la réponse ».
- [x] Chaque bouton annonce quand la carte reviendra si on le choisit.
- [x] Répondre à une carte à réviser la replanifie et inscrit la réponse dans l'historique.
- [x] Répondre à une carte qui n'est pas à réviser est une révision bonus : historique seulement.
- [x] L'écran de fin compte les réponses et propose de revoir les ratées en révision bonus.
- [x] La page d'un groupe lance une session sur ses cartes dues.

## Test strategy

- Le service de réponse est testé sur une base en mémoire avec une horloge fixée : réponse sur une carte due, sur une carte due plus tard dans la journée, sur une carte déjà révisée (bonus), bonus forcé, et accord entre l'aperçu et la réponse enregistrée.
- Le suivi de session (ordre, comptes, ratées) est testé en logique pure.
- Le parcours complet est testé à l'écran : révéler, répondre, écran de fin, session bonus des ratées, puis lecture de l'historique en base. Le recto, le verso et l'écran de fin sont aussi des golden tests.

## File mapping

- `lib/application/reviews/` — service de réponse, aperçu, file des cartes dues et suivi de session.
- `lib/data/repositories/review_repository.dart` — historique des réponses.
- `lib/features/session/` — écran de session, carte, boutons de réponse, écran de fin et lancement.

## Technical details

La file des cartes dues (`dueItemsProvider`) est calculée à partir de toutes les cartes et de l'instant courant republié chaque minute. La session en reçoit une copie à son ouverture et la garde : une carte qui devient due pendant la session n'y entre pas.

Une révision bonus ne met pas à jour la date de dernière révision du sens. Cette date sert à la règle « à réviser » ; la changer ferait disparaître une carte due du jour après une simple révision bonus.
