# Le jeu du chaos

*Mathématiques · Chapitre 3 · Compétence PA-02 : « Quelle est la forme de cette liste ou de ces nombres ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Prenez les trois coins d'un triangle et un crayon n'importe où à l'intérieur. Lancez un dé : un ou deux
désigne le premier coin, trois ou quatre le deuxième, cinq ou six le troisième. Avancez à mi-chemin de là où
vous êtes vers ce coin, et posez un point. Relancez. Après deux mille lancers, les points ne sont pas une
tache : ils forment un triangle plein de trous, la même forme à toutes les tailles, que personne n'a dessinée.
Ce chapitre joue au jeu avec les nombres aléatoires de la bibliothèque, et compte ce qui apparaît au lieu de
l'admirer.

## 1. Trois coins

Les coins sont trois places sur la page. Ils ne bougent jamais ; seul le crayon bouge.

```ring
? @@( StzChaosGameCorners() )
#--> [ [ 320, 40 ], [ 40, 560 ], [ 600, 560 ] ]
```

## 2. Les six premiers lancers

Chaque point est une donnée : une place que la règle a produite. Une graine rend les lancers identiques à
chaque exécution de cette cellule, si bien qu'une promesse peut être faite sur le hasard.

```ring
oS = StzChaosGameSubstance(6, 7)
for i = 1 to 6
	? "" + oS.DataOf("d" + i, "x") + ", " + oS.DataOf("d" + i, "y")
next
#--> 320, 170
```

## 3. Deux mille lancers

L'image est un diagramme sans rien à résoudre : deux mille points, chacun dessiné là où sa donnée le dit.

```ring
oG = StzChaosGamePictureQ(StzMathFigureFont(), 2000, 7)
? oG.NumberOfShapes()
#--> 2000
? oG.NumberOfUnknowns()
#--> 0
```

## 4. Ce qui apparaît, compté

Le triangle de Sierpinski a deux signatures. Chaque point se trouve à l'intérieur du grand triangle, et pas
un seul à l'intérieur du trou central, le triangle dont les coins sont les milieux des côtés. La bibliothèque
compte les deux par un test indépendant sur la position de chaque point : la règle n'a jamais entendu parler
du trou.

```ring
aC = StzChaosGameCounts(oG, 2000)
? aC[1]
#--> 2000
? aC[2]
#--> 0
```

## 5. Le hasard, et pourtant la même forme

Une autre graine donne d'autres lancers et d'autres points, et les deux comptes sont les mêmes. La forme
appartient à la règle, non aux lancers.

```ring
oH = StzChaosGamePictureQ(StzMathFigureFont(), 500, 11)
? @@( StzChaosGameCounts(oH, 500) )
#--> [ 500, 0 ]
```

## 6. La place d'un point est sa donnée

L'image ne cache rien : un point est dessiné exactement là où sa donnée le met, et vous pouvez lire les deux.

```ring
? oG.ValueOf("d7.icon.cx") = oG.Substance().DataOf("d7", "x")
#--> 1
```

{{exercise:math-03-01}}

## Récapitulatif

- **Acquis :** vous avez joué au jeu du chaos avec des nombres aléatoires à graine, dessiné deux mille points
  sans rien à résoudre, et compté les deux signatures du triangle de Sierpinski par un test indépendant au lieu
  de vous fier à vos yeux.
- **Pourquoi c'est important :** un motif qui apparaît du hasard est une affirmation comme une autre. Compter
  ce que la règle a produit, c'est ainsi qu'une image devient une preuve.
- **La suite :** une fonction est une image, elle aussi. Le chapitre suivant en dessine une, marque où elle
  passe par zéro et où elle tourne, et vérifie chaque marque.
