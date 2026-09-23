# Trouver, puis agir

*Introduction élémentaire · Chapitre 1 · Compétence EX-03 : « Où est-ce, et qu'est-ce que j'en fais ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Tout lieu de travail reçoit des demandes : un restaurant reçoit des commandes, une banque reçoit des tickets, et la
même demande arrive souvent plusieurs fois. Ce chapitre traite les demandes répétées à la manière de Softanza.
D'abord on choisit l'objet. Ensuite on demande s'il contient ce que l'on cherche, on le compte, on le trouve. Et
seulement alors on agit.

## 1. Choisir l'objet

Une liste de demandes est une `stzList`.

```ring
o1 = new stzList([ "tea", "rice", "tea", "fish", "rice", "tea" ])
? o1.NumberOfItems()
#--> 6
```

## 2. Poser la question de la présence

Avant d'agir, demandez s'il y a quelque chose sur quoi agir.

```ring
? o1.ContainsDuplicates()
#--> TRUE
```

## 3. Poser la question du nombre

```ring
? o1.NumberOfDuplicates()
#--> 3
```

## 4. Demander les positions

```ring
? @@( o1.FindDuplicates() )
#--> [ 3, 5, 6 ]
```

## 5. Agir sur les positions

Vous savez où se trouvent les demandes répétées : vous pouvez les retirer.

```ring
o1.RemoveItemsAtPositions( o1.FindDuplicates() )
? @@( o1.Content() )
#--> [ "tea", "rice", "fish" ]
```

Softanza a aussi un seul mot pour tout le geste. Lisez-le comme une phrase : *la liste, doublons retirés*.

```ring
? @@( StzListQ([ "tea", "rice", "tea" ]).DuplicatesRemoved() )
#--> [ "tea", "rice" ]
```

## 6. Les mêmes questions, sur votre lieu de travail

Cette cellule lit les demandes que votre lieu de travail a reçues aujourd'hui. Ce qu'elle affiche dépend du monde
sur lequel ce cours s'exécute : la page n'affiche donc jamais de résultat. Exécutez-la.

```ring
o2 = new stzList( EduWorldObjects("requested") )
? EduWorldName()
? o2.ContainsDuplicates()
? o2.NumberOfDuplicates()
? @@( o2.DuplicatesRemoved() )
```

## 7. Le dire avec vos propres mots

Softanza comprend aussi la même demande écrite en français.

```ring
? @@( NaturallyIn("fr", "Crée une liste avec [ 5, 3, 5, 1 ] et enlève les doublons").Result() )
#--> [ 5, 3, 1 ]
```

{{exercise:ex-01-01}}

## Récapitulatif

- **Acquis :** vous avez fait passer une liste par le modèle mental. Vous l'avez choisie, vous avez demandé si elle
  contenait des doublons, vous les avez comptés et trouvés, puis vous les avez retirés.
- **Pourquoi c'est important :** l'action vient en dernier. Chaque question posée d'abord rend l'action exacte, et
  chaque réponse peut être vérifiée.
- **La suite :** les mêmes cinq questions valent pour les chaînes, les tables et les graphes. Le chapitre suivant
  les pose à une chaîne.
