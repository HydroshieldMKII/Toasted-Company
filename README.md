# Toasted Company

_**Créé par Vincent Bureau**_

---

## Description

**Toasted Company** reprend des concepts clés de jeux populaires comme _Lethal Company_, mais introduit sa propre approche avec des ennemis uniques et des défis qui augmentent avec le temps. Ce jeu met à l’épreuve les réflexes et la stratégie des joueurs.

---

## Concepts utilisés

- [Génération procédurale](#1-génération-procédurale)
- [Pièges](#2-pièges)
- [State Machine](#3-state-machine)
- [Inventaire](#4-inventaire)

---

### 1. Génération procédurale

La génération procédurale des niveaux dans Toasted Company repose sur un algorithme basé sur des salles (room-based generation). Ce processus est divisé en plusieurs étapes dynamiques pour créer des niveaux uniques:

#### Création des salles :

Des salles de tailles aléatoires sont générées dans une zone prédéfinie.
Les dimensions des salles varient entre une taille minimale et maximale configurée, en respectant les contraintes de placement pour éviter les chevauchements.

#### Placement des corridors :

Les salles adjacentes sont connectées par des corridors.
L’algorithme choisit des trajectoires soit horizontales-verticales, soit verticales-horizontales pour créer des chemins naturels et diversifiés.

#### Remplissage des données de niveau :

Une fois les salles et corridors définis, le terrain est rempli avec des tuiles spécifiques :
Les salles utilisent des tuiles de sol standard avec des variations esthétiques.
Les corridors sont dessinés avec des tuiles plus étroites pour simuler des passages.

#### Ajout des murs :

Un algorithme secondaire vérifie chaque case pour ajouter des murs aux bordures des salles et des corridors.
Ces murs servent également à générer des occluders de lumière et des collisions physiques pour limiter le champ de vision et les mouvements.

#### Gestion de la diversité :

Chaque niveau est agrandi progressivement en fonction du niveau actuel du joueur.
Les salles, corridors, et pièges augmentent en quantité pour correspondre à la difficulté croissante.

Source: [Vidéo YouTube](https://www.youtube.com/watch?v=_BABPmlkqh8)

<div align="center">
    <img src="images/dongeon.png" alt="Exemple de génération de niveau" style="max-width: 500px;">
    <br>
    <em>Exemple de génération de niveau</em>
</div>

---

### 2. Pièges

Pour rendre le jeu plus difficile, j'ai ajouté des pièges. Les pièges sont des **pointes cachées** dans le sol qui se déclenchent lorsque le joueur marche dessus. Ils restent activés pendant un certain temps et infligent des dégâts. Pour les éviter, le joueur doit être attentif, car ils sont peu visibles et peuvent bloquer un passage étroit temporairement.

#### Exemple de piège :

<div align="center" style="margin-top: 20px;">
    <img src="images/spikes0.png" alt="Piège inactif" style="max-width: 400px;">
    <br>
    <em>Piège inactif</em>
</div>

<div align="center" style="margin-top: 20px;">
    <img src="images/spikes1.png" alt="Piège actif" style="max-width: 400px;">
    <br>
    <em>Piège actif</em>
</div>

---

### 3. State Machine

Il existe deux types d'ennemis dans le jeu : **minotaures** et **mages noirs**. Pour gérer leur comportement, j'ai utilisé une machine à états (_State Machine_). Chaque monstre possède des états qui dictent son comportement :

- **Minotaure** :

  - `Idle` : Attente passive.
  - `Taunt` : Provoque le joueur s'il est à portée.
  - `Attack` : Attaque lorsque le joueur est suffisamment proche.

- **Mage noir** :
  - `Idle` : Attente passive. Se téléporte de temps en temps.
  - `Attack` : Se téléporte et lance un projectile sur le joueur.

#### Illustrations des comportements :

<div align="center" style="margin-top: 20px;">
    <img src="images/mino0.png" alt="Minotaure en mode Taunt" style="max-width: 400px;">
    <br>
    <em>Minotaure en mode Taunt</em>
</div>

<div align="center" style="margin-top: 20px;">
    <img src="images/mino1.png" alt="Minotaure en mode Attack" style="max-width: 400px;">
        <img src="images/mino2.png" alt="Minotaure en mode Attack" style="max-width: 400px;">
    <br>
    <em>Minotaure en mode Attack</em>
</div>

<div align="center" style="margin-top: 20px;">
    <img src="images/mages0.png" alt="Mage noir en mode Idle" style="max-width: 400px;">
    <br>
    <em>Mage noir en mode Idle</em>
</div>

<div align="center" style="margin-top: 20px;">
    <img src="images/mages1.png" alt="Mage noir en mode Attack" style="max-width: 400px;">
    <br>
    <em>Mage noir en mode Attack</em>
</div>

---

### 4. Inventaire

Le joueur peut ramasser des objets et les stocker dans un inventaire. Cependant, cet inventaire est limité à **2 objets**. Lorsque le joueur porte des objets, sa vitesse diminue, et son champ de vision se réduit. Pour déposer les objets, il doit se rendre à la sortie du niveau. Chaque objet a une valeur générée aléatoirement, et cette valeur moyenne augmente avec les niveaux.

#### Illustrations de l'inventaire :

<div align="center" style="margin-top: 20px;">
    <img src="images/inventory.png" alt="Inventaire du joueur" style="max-width: 400px;">
    <br>
    <em>Inventaire du joueur</em>
</div>

<div align="center" style="margin-top: 20px;">
    <img src="images/item.png" alt="Objet à ramasser" style="max-width: 400px;">
    <br>
    <em>Objet à ramasser</em>
</div>

---

## Conclusion

Toasted Company est un jeu qui mêle aventure, réflexion, et défis croissants grâce à des concepts comme la génération procédurale, des pièges rusés, des ennemis dynamiques et une gestion d'inventaire stratégique. À vous de jouer !
