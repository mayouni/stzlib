# L'identité n'est pas une auto-vérification

*Mathématiques · Chapitre 15 · Compétence CR-02 : « Qu'est-ce qui casserait si j'avais tort ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Une vérification vaut exactement ce que vaut sa chance d'échouer. Calculez un nombre à partir d'une formule,
puis vérifiez la formule contre le nombre que vous venez de calculer, et la vérification passe quoi que la
formule dise : c'est une identité, et une identité ne prouve rien. Une vraie vérification compare deux routes
indépendantes vers une même vérité, et elle doit pouvoir échouer. Ce chapitre construit une vérification qui
ne peut pas échouer, puis la même affirmation vérifiée par une image qui n'a jamais entendu parler de la
formule, par un second algorithme, et par la bande, et montre le négatif dont chaque positif a besoin.

## 1. Une vérification qui ne peut pas échouer

Calculez l'hypoténuse à partir des deux côtés par la formule, puis « vérifiez » la formule contre elle. Zéro,
toujours.

```ring
a = 3
b = 4
c = sqrt( a*a + b*b )
? a*a + b*b - c*c
#--> 0
```

## 2. Une formule fausse se vérifie tout aussi bien

Ajoutez un sous la racine, ce qu'aucun triangle rectangle ne permet, et vérifiez la formule fausse contre son
propre nombre. Zéro encore. La vérification n'a rien remarqué, parce qu'elle ne le pouvait pas.

```ring
c2 = sqrt( a*a + b*b + 1 )
? a*a + b*b + 1 - c2*c2
#--> 0.00
```

## 3. L'image qui n'a jamais entendu parler de la formule

La figure de Byrne du chapitre 6 a été résolue à partir de trois points et d'un angle droit ; l'égalité des
carrés n'a jamais été une règle. Mesurez ses trois côtés et vérifiez la formule contre des mesures qui ne
viennent pas d'elle. Maintenant la vérification aurait pu échouer, et elle n'a pas échoué.

```ring
oP = StzPythagorasPictureQ( StzMathFigureFont() )
nAB = oP.Fact(:distance, [ "A.icon", "B.icon" ])[:value]
nAC = oP.Fact(:distance, [ "A.icon", "C.icon" ])[:value]
nBC = oP.Fact(:distance, [ "B.icon", "C.icon" ])[:value]
? fabs( nBC*nBC - nAB*nAB - nAC*nAC ) < 0.01
#--> 1
```

## 4. Deux algorithmes pour un nombre

La figure de fonction trouve le zéro de x carré moins trois en encadrant un changement de signe. La racine
carrée de Ring trouve le même nombre par un autre algorithme. Deux routes, une vérité, au millionième.

```ring
oFig = StzMathFigureQ(:Function, [ :f = "x^2 - 3", :on = [ -3, 3 ], :mark = [ :zeros ] ])
aZ = oFig.Zeros()
z = aZ[1][1]
? z
#--> 1.73
? fabs( z - sqrt(3) ) < 0.000001
#--> 1
```

## 5. Le négatif dont chaque positif a besoin

Une vérification qui dit oui n'est une preuve que si elle aurait dit non à une mauvaise réponse. Donnez-lui-en
une : un et demi n'est pas la racine de trois, et la même vérification la refuse.

```ring
? fabs( 1.5 * 1.5 - 3 ) < 0.000001
#--> 0
```

## 6. La bande comme troisième route

Le chapitre 4 a trouvé l'extremum de x carré moins deux en regardant la courbe tourner ; le chapitre 14 a lu
la pente sur la bande. Un extremum est là où la pente est zéro, et la bande est d'accord sans avoir regardé
la courbe.

```ring
oQ = new stzMathFunction("x^2 - 2", [ "x" ])
? oQ.DerivativeAt("x", [ 0 ])
#--> 0
? oQ.DerivativeAt("x", [ 1 ])
#--> 2
```

## 7. Sur votre monde

Comptez les demandes de la semaine à votre école de deux façons : la longueur de la liste, et la somme des
comptes par sorte. Deux routes vers un nombre ; la page ne montre aucun résultat, parce qu'il dépend du
monde : exécutez-la.

```ring
aReq = EduWorldObjects("requested")
aKinds = StzListQ(aReq).DuplicatesRemoved()
nSum = 0
for i = 1 to len(aKinds)
	nSum += StzListQ(aReq).NumberOfOccurrence(aKinds[i])
next
? EduWorldName()
? len(aReq)
? nSum
```

{{exercise:math-15-01}}

## Récapitulatif

- **Acquis :** vous avez construit une vérification qui ne peut pas échouer et l'avez vue accepter une
  formule fausse, puis vérifié la même affirmation contre une image qui n'en avait jamais entendu parler,
  contre un second algorithme, et contre la bande, et donné à la vérification une mauvaise réponse à refuser.
- **Pourquoi c'est important :** chaque affirmation de ce cours portait sa vérification, et ce chapitre dit
  ce qui donnait de la valeur à ces vérifications : elles comparaient des routes indépendantes, et chacune
  aurait pu échouer.
- **La suite :** c'est le dernier chapitre écrit. Le premier regard de Tukey sur des données prendra le
  chapitre 13 quand le niveau Tukey sera construit, et le cours l'affiche comme prévu et non écrit jusque-là.
