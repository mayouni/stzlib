# Les matrices comme images

*Mathématiques · Chapitre 8 · Compétence PA-04 : « Quelles cellules répondent à ma question ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Une matrice est une grille de nombres, et un produit de deux matrices est une grille dont chaque cellule est
une ligne de la première rencontrant une colonne de la seconde. Dit comme une image, un produit est trois
grilles côte à côte, avec la ligne, la colonne et la cellule qu'elles forment éclairées ensemble. Ce chapitre
déclare des matrices comme des figures, lit une cellule sur la figure, vérifie une cellule du produit à la
main, et demande à la figure de refuser ce qui ne peut pas se multiplier.

## 1. Une grille

Une figure de matrice se déclare par ses lignes. La figure compte ses cellules et les nomme par lettre de
grille, ligne et colonne : la première grille est a, sa deuxième ligne et première colonne est a2_1.

```ring
oA = StzMathFigureQ(:Matrix, [ :of = [ [ 1, 2 ], [ 3, 4 ] ], :label = "A" ])
? oA.Why()
#--> a matrix figure: A (2 x 2), 4 cells
? oA.Fact(:datum, [ "a2_1", "v" ])[:message]
#--> a2_1 carries v = 3
```

## 2. Un produit, en trois grilles

Déclarez un produit et la figure dessine A, B et A fois B, calcule chaque cellule du résultat, et éclaire la
ligne et la colonne qui forment la cellule que vous demandez à voir.

```ring
oP = StzMathFigureQ(:Matrix, [ :product = [ [ [ 2, 7, 1, 8 ], [ 2, 8, 1, 8 ], [ 2, 8, 4, 5 ] ],
                                            [ [ 1, 0 ], [ 0, 1 ], [ 2, 3 ], [ 1, 1 ] ] ], :show = [ 2, 1 ] ])
? oP.Why()
#--> a matrix figure: A (3 x 4) . B (4 x 2) = A . B (3 x 2), 26 cells
```

## 3. L'image se juge elle-même

Une figure de matrice porte trois règles : une cellule du produit est le produit scalaire de sa ligne et de
sa colonne, les dimensions s'accordent, et chaque grille contient ses cellules. La figure les vérifie sur sa
propre image.

```ring
? len( oP.Violations() )
#--> 0
```

## 4. Une cellule du produit, vérifiée à la main

La cellule éclairée est la ligne 2 de A rencontrant la colonne 1 de B. Lisez-la sur la figure, puis
calculez-la vous-même : deux fois un, plus huit fois zéro, plus un fois deux, plus huit fois un.

```ring
? oP.Fact(:datum, [ "c2_1", "v" ])[:message]
#--> c2_1 carries v = 12
? 2 * 1 + 8 * 0 + 1 * 2 + 8 * 1
#--> 12
```

## 5. Ce qui ne peut pas se multiplier

Une ligne de A doit être aussi longue qu'une colonne de B est haute. Un produit qui enfreint cela est refusé
nommément, avec les deux nombres qui ne s'accordent pas.

```ring
try
	StzMathFigureQ(:Matrix, [ :product = [ [ [ 1, 2 ] ], [ [ 1, 2 ] ] ] ])
catch
	? "refused"
done
#--> refused
```

## 6. Les nombres comme couleur

Demandée en chaleur, la figure colore chaque cellule sur une seule rampe, de sa plus petite valeur à sa plus
grande. La position sur la rampe est un nombre que la figure porte : la plus grande valeur est à un.

```ring
oH = StzMathFigureQ(:Matrix, [ :of = [ [ 4, 1, 0 ], [ 1, 4, 1 ], [ 0, 1, 4 ] ], :as = :heat, :label = "A" ])
? oH.Why()
#--> a matrix figure: A (3 x 3), 9 cells on one ramp
? oH.Fact(:datum, [ "a2_2", "t" ])[:message]
#--> a2_2 carries t = 1
```

## 7. Sur votre monde

Une ligne : combien de demandes de chaque sorte votre école a reçues cette semaine, dessinée comme une
matrice. Ce qu'elle affiche dépend du monde sur lequel ce cours s'exécute, aussi la page ne montre aucun
résultat : exécutez-la.

```ring
aReq = EduWorldObjects("requested")
aKinds = StzListQ(aReq).DuplicatesRemoved()
aRow = []
for i = 1 to len(aKinds)
	aRow + StzListQ(aReq).NumberOfOccurrence(aKinds[i])
next
oW = StzMathFigureQ(:Matrix, [ :of = [ aRow ], :label = "requests by kind" ])
? EduWorldName()
? oW.Why()
```

{{exercise:math-08-01}}

## Récapitulatif

- **Acquis :** vous avez déclaré une matrice comme une figure, lu une cellule par son nom, déclaré un produit
  et vu ses trois grilles, vérifié une cellule du produit à la main contre la valeur de la figure, vu un
  produit refusé pour ses dimensions, et coloré une matrice sur une rampe.
- **Pourquoi c'est important :** un produit, c'est vingt-six cellules et une règle. La figure calcule chaque
  cellule et porte la règle, donc la cellule que vous vérifiez à la main répond pour toutes.
- **La suite :** une poignée de nombres, et les mots qui les résument. Le chapitre suivant dessine une boîte à
  moustaches et lit la médiane, les quartiles et les valeurs aberrantes sur l'image.
