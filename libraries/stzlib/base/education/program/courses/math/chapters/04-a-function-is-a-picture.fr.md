# Une fonction est une image

*Mathématiques · Chapitre 4 · Compétence SE-02 : « Où, et combien ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Une fonction est une règle qui transforme un nombre en un autre, et son image est l'ensemble des places que
la règle atteint. L'image répond à ce que la formule cache : où la règle donne zéro, où elle cesse de monter
pour descendre, où elle se brise. Ce chapitre déclare une fonction comme une figure. La courbe est calculée
par le moteur ; les marques qu'elle porte sont trouvées, placées, puis vérifiées une à une par le calcul.

## 1. Déclarer la fonction

Une figure de fonction se déclare par sa formule, l'intervalle sur lequel la dessiner, et les marques que
vous voulez voir trouvées.

```ring
oF = StzMathFigureQ(:Function, [ :f = "x^2 - 2", :on = [ -3, 3 ], :mark = [ :zeros, :extrema ] ])
? oF.Why()
#--> a function figure: 400 samples in 1 piece(s), 3 mark(s)
```

## 2. Où elle s'annule, et où elle tourne

La figure a trouvé deux zéros et un extremum. Chaque marque est une place : un x et un y.

```ring
? @@( oF.Zeros() )
#--> [ [ 1.41, -0.00 ], [ -1.41, -0.00 ] ]
? @@( oF.Extrema() )
#--> [ [ 0, -2 ] ]
```

## 3. Une marque est une affirmation, et l'affirmation est vérifiée

La figure dit que la courbe s'annule en 1,41. Le calcul le vérifie : élevez ce nombre au carré et retirez
deux, et ce qui reste est plus petit qu'un millionième. La figure a trouvé la racine carrée de deux sans
qu'on la lui dise.

```ring
aZ = oF.Zeros()
z = aZ[1][1]
? z
#--> 1.41
? fabs( z * z - 2 ) < 0.000001
#--> 1
```

## 4. L'image se juge elle-même

Une figure de fonction porte des règles : une marque de zéro encadre un changement de signe, une marque
d'extremum encadre un retournement, et chaque note se lit près de sa marque. Zéro infraction est calculé, non
promis.

```ring
? len( oF.Violations() )
#--> 0
```

## 5. La fenêtre est choisie d'après la courbe

La figure regarde les valeurs qu'elle a calculées et laisse de l'air au-dessus et au-dessous, de sorte que les
marques ne touchent jamais le cadre. La fenêtre est quatre nombres : de et à sur x, puis sur y.

```ring
? @@( oF.Window() )
#--> [ -3, 3, -3.33, 8.33 ]
```

## 6. D'autres façons de dire une courbe

Une courbe n'est pas forcément y de x. Un cercle est x et y d'un troisième nombre t, et une rosace est une
distance r d'un angle t. Rien n'est marqué sur ces courbes, donc rien à résoudre : la figure le dit.

```ring
oCircle = StzMathFigureQ(:Function, [ :x = "cos(t)", :y = "sin(t)", :t = [ 0, 6.2832 ], :label = "a circle" ])
? oCircle.Why()
#--> a function figure: 400 samples in 1 piece(s), 0 mark(s); nothing to lay out
oRose = StzMathFigureQ(:Function, [ :r = "cos(3*t)", :t = [ 0, 3.1416 ], :label = "a rose" ])
? oRose.Why()
#--> a function figure: 400 samples in 1 piece(s), 0 mark(s); nothing to lay out
```

## 7. Une tangente à une place que vous nommez

Demandez la tangente en x égal à un et la figure y ajoute une marque donnée, avec la hauteur de la courbe à
cette place : le sinus de un vaut 0,84.

```ring
oT = StzMathFigureQ(:Function, [ :f = "sin(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ], :tangent = 1, :maxmarks = 4 ])
? @@( oT.Marks() )
#--> [ "given", 1, 0.84 ]
```

## 8. Où la règle se brise

Un sur x moins un n'a pas de valeur en x égal à un. La figure ne dessine pas à travers la brisure : elle
dessine deux morceaux et dit où elle n'a pas pu aller.

```ring
oP = StzMathFigureQ(:Function, [ :f = "1 / (x - 1)", :on = [ -3, 4 ] ])
? oP.Why()
#--> a function figure: 400 samples in 2 piece(s), 0 mark(s), 1 place(s) not finite
? oP.PieceCount()
#--> 2
```

## 9. Sur votre monde

Une droite par l'origine dont la pente est le nombre de demandes reçues par votre école cette semaine. Ce
qu'elle affiche dépend du monde sur lequel ce cours s'exécute, aussi la page ne montre aucun résultat :
exécutez-la.

```ring
aReq = EduWorldObjects("requested")
oW = StzMathFigureQ(:Function, [ :f = "" + len(aReq) + " * x", :on = [ -2, 2 ], :mark = [ :zeros ] ])
? EduWorldName()
? oW.Why()
```

{{exercise:math-04-01}}

## Récapitulatif

- **Acquis :** vous avez déclaré une fonction comme une figure, lu où elle s'annule et où elle tourne, vérifié
  un zéro par le calcul, lu la fenêtre que la figure a choisie, dessiné un cercle et une rosace, demandé une
  tangente, et vu la figure s'arrêter à une brisure au lieu de dessiner à travers.
- **Pourquoi c'est important :** la courbe est calculée et les marques sont trouvées, donc chaque place que
  l'image nomme est une affirmation que vous pouvez vérifier par une ligne de calcul, et ce chapitre l'a fait.
- **La suite :** mettez une lettre dans la formule et l'image devient une famille. Le chapitre suivant déplace
  la lettre et regarde ce qui bouge avec elle.
