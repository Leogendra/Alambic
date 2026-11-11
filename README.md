# Remanence

Application Android de répétition espacée pensée « notification d'abord » : la plupart des révisions se font depuis la notification, sans ouvrir l'app. Les cartes recto / verso sont révisées selon des presets (séquences d'intervalles), et la distillation introduit les nouvelles cartes au compte-gouttes.

## Installation

Prérequis : Flutter 3.47 (stable), un SDK Android avec la plateforme 37, et un téléphone Android en mode développeur.

```sh
flutter pub get
flutter build apk --debug
flutter install
```

## Utilisation

Au premier lancement, l'app crée les presets Standard et Intensif. Le bouton « + » crée une carte ; l'onglet Groupes range les cartes et permet l'ajout en masse. Les cartes dues arrivent en notification à l'heure du preset, avec les boutons « Correct » et « À revoir ».

### Exemple : apprendre des capitales

1. Onglet Groupes, « Nouveau », nommer le groupe « Capitales ».
2. Dans le groupe, « Ajout en masse », coller une carte par ligne, recto et verso séparés par `;` :

   ```text
   Capitale du Chili ; Santiago
   Capitale du Kenya ; Nairobi
   ```

3. Les cartes arrivent à 12h le lendemain (preset Standard), puis à 2 jours, 1 semaine, 1 mois, 3 mois et 6 mois si elles sont correctes.

### Exemple : réviser un examen dans la journée

1. Réglages, Presets : choisir « Intensif » (10 min, 1 h, 1 j, 3 j, 1 sem).
2. Dans les réglages du groupe, choisir ce preset. Une carte réussie revient 10 minutes plus tard, puis une heure après.

## Développement

Commandes, conventions et pièges connus : [docs/stack.md](docs/stack.md). Architecture : [docs/architecture.md](docs/architecture.md).
