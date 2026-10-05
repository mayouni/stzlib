# La statistique comme langage de pensée

*Mathématiques · Chapitre 9 · Compétence FO-01 : « Qu'est-ce que je demande vraiment, en le moins de mots possible ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Huit nombres sont huit faits. La statistique est le langage qui dit ce qu'ils ont en commun en quelques mots,
et une boîte à moustaches est ce langage dessiné : où est le milieu, quelle est la largeur de la moitié
centrale, et quelle valeur se tient à l'écart. Ce chapitre fait passer huit valeurs par les mots, puis par
l'image, et vérifie que les deux disent la même chose.

## 1. Huit valeurs, deux milieux

La moyenne additionne tout et divise. La médiane est la valeur du milieu une fois les valeurs triées. Une
grande valeur tire la moyenne vers le haut et laisse la médiane où elle était.

```ring
aV = [ 2, 4, 4, 5, 7, 9, 12, 25 ]
oD = new stzDataSet(aV)
? oD.Mean()
#--> 8.50
? oD.Median()
#--> 6
```

## 2. Les quartiles et celle qui se tient à l'écart

Les quartiles coupent les valeurs triées en quatre parts. Une valeur loin au-delà de la moitié centrale est
une valeur aberrante, et le jeu de données la nomme.

```ring
? @@( oD.Quartiles() )
#--> [ 4, 6, 9.75 ]
? @@( oD.Outliers() )
#--> [ 25 ]
```

## 3. Les mêmes mots, dessinés

Une figure de boîte à moustaches se déclare par ses valeurs. Sa phrase dit les mêmes nombres que le jeu de
données : la boîte du premier quartile au troisième, la médiane à l'intérieur, et la valeur aberrante
comptée.

```ring
oB = StzMathFigureQ(:BoxPlot, [ :of = aV, :label = "eight values" ])
? oB.Why()
#--> a box plot of 1 group(s): n = 8, box 4 | 6 | 9.75, 1 outlier(s)
? len( oB.Violations() )
#--> 0
```

## 4. L'image en texte

La figure peut se dire en texte, pour un terminal, un message ou une page sans image : les nombres, puis la
boîte, les moustaches et la valeur seule.

```ring
? oB.Text()
#--> group 1  n=8  min 2  Q1 4  med 6  Q3 9.75  max 25  outliers 1
```

## 5. Aberrante par règle, non par opinion

La règle est une clôture : une fois et demie la largeur de la boîte, au-delà du troisième quartile.
Vingt-cinq est au-delà, donc la moustache s'arrête à douze, la dernière valeur en deçà.

```ring
aS = oD.BoxPlotStats()
? aS[:iqr]
#--> 5.75
? 9.75 + 1.5 * 5.75
#--> 18.38
? 25 > 18.375
#--> 1
? aS[:whisker_high]
#--> 12
```

## 6. Deux groupes côte à côte

Deux groupes partagent un même axe, si bien que l'œil compare leurs milieux sans nombre. Le matin a une
valeur aberrante ; le soir n'en a pas.

```ring
oG = StzMathFigureQ(:BoxPlot, [ :groups = [ [ "morning", [ 12, 15, 14, 18, 16, 15, 13, 40 ] ],
                                            [ "evening", [ 20, 22, 19, 25, 24, 21, 23, 22 ] ] ] ])
? oG.Why()
#--> a box plot of 2 group(s): morning n = 8, box 13.75 | 15 | 16.5, 1 outlier(s); evening n = 8, box 20.75 | 22 | 23.25, 0 outlier(s)
```

## 7. La dispersion en un nombre

L'écart type dit à quelle distance de la moyenne les valeurs se tiennent, en moyenne. C'est un seul nombre
pour toute la dispersion, et lui aussi est tiré par la valeur seule.

```ring
? oD.StandardDeviation()
#--> 7.39
```

## 8. Sur votre monde

Combien de demandes de chaque sorte votre école a reçues, comme jeu de données : le compte moyen par sorte et
la médiane. Ce qu'elle affiche dépend du monde sur lequel ce cours s'exécute, aussi la page ne montre aucun
résultat : exécutez-la.

```ring
aReq = EduWorldObjects("requested")
aKinds = StzListQ(aReq).DuplicatesRemoved()
aCounts = []
for i = 1 to len(aKinds)
	aCounts + StzListQ(aReq).NumberOfOccurrence(aKinds[i])
next
oK = new stzDataSet(aCounts)
? EduWorldName()
? oK.Mean()
? oK.Median()
```

{{exercise:math-09-01}}

## Récapitulatif

- **Acquis :** vous avez résumé huit valeurs en mots, moyenne et médiane et quartiles et valeur aberrante,
  puis les avez dessinées comme une boîte à moustaches dont la phrase et le texte disent les mêmes nombres,
  appliqué la règle de la clôture à la main, comparé deux groupes, et lu la dispersion en un nombre.
- **Pourquoi c'est important :** un résumé est une affirmation sur beaucoup de nombres. Quand les mots,
  l'image et la règle s'accordent, l'affirmation est vérifiée de trois façons ; quand l'un diverge, vous savez
  lequel.
- **La suite :** le hasard. Le chapitre suivant lance une pièce mille fois et lit la proportion sur le
  continuum de quelques-uns à la plupart.
