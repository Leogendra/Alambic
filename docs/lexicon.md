# Lexique — Remanence

Seul endroit où les termes sont définis. Les specs y renvoient au lieu de les redéfinir. Le nom utilisé dans le code est indiqué entre parenthèses.

## Termes

### Carte

Une flashcard recto / verso (`Flashcard`). Chaque face porte du texte brut et/ou une image. Une carte appartient à un [groupe](#groupe) ou à aucun.

### Sens

Une des deux façons de réviser une carte (`CardDirection`) : recto → verso (`frontToBack`) ou verso → recto (`backToFront`). Chaque sens a son propre état, son [cran](#cran), son [échéance](#échéance) et son historique. Ses états sont inactif, en attente (file d'une distillation), actif et acquis.

### Groupe

Liste plate de cartes partageant un [preset](#preset) (`CardGroup`). Les cartes sans groupe forment la liste virtuelle « Sans groupe ».

### Preset

Ensemble complet de règles de répétition (`Preset`) : moteur, séquence d'intervalles, comportement en cas d'échec et en fin de séquence, horaire, mode de notification. Un niveau (carte, groupe, global) choisit un preset entier ou hérite du niveau suivant.

### Cran

Position d'un sens dans la séquence de son preset (`step`) : l'indice de l'intervalle actuellement attendu, affiché à partir de 1 (« cran 2 sur 6 »). Un sens jamais révisé n'a pas de cran.

### Échéance

Moment où un sens redevient à réviser (`dueAt`). Pour un intervalle d'un jour ou plus, c'est l'horaire du preset le jour voulu ; pour un intervalle plus court, l'instant de la réponse plus l'intervalle.

### Journée

Journée de planification, qui commence à 4h du matin et non à minuit (`SchedulingCalendar`). Toutes les règles « même jour » et « aujourd'hui » l'utilisent.

### À réviser

Un sens est à réviser aujourd'hui quand son échéance est passée, ou quand elle tombe aujourd'hui et qu'il n'a pas déjà été révisé aujourd'hui (`DuePolicy`).

### Révision bonus

Réponse à une carte qui n'est pas à réviser. Elle est inscrite dans l'historique mais ne change ni le cran ni l'échéance.
