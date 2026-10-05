# La géométrie déclarée et résolue

*Mathématiques · Chapitre 6 · Compétence CR-02 : « Qu'est-ce qui casserait si j'avais tort ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Une figure de géométrie n'est pas dessinée : elle est déclarée et résolue. Vous dites ce qu'il y a, trois
points et un triangle, un cercle et ce qui s'y trouve, et un solveur trouve des coordonnées qui respectent
chaque règle. Un théorème est alors quelque chose que vous lisez sur les coordonnées résolues, jamais quelque
chose que vous avez dit à l'image de rendre vrai. Ce chapitre construit deux figures que la bibliothèque garde
comme histoires, la proposition I.47 d'Euclide aux couleurs de Byrne et le théorème de Thalès, déplace un
sommet dans chacune, et relit le théorème à chaque position.

## 1. Le triangle rectangle de Byrne

Trois points, un triangle, un angle droit en A : la substance dit cela, et le style dérive chaque carré des
trois points. Demandez à la figure résolue ce que vaut l'angle en A.

```ring
oP = StzPythagorasPictureQ( StzMathFigureFont() )
? oP.Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
#--> the angle at A.icon is 90.00 degrees
```

## 2. Un théorème lu sur les coordonnées

Rien dans la figure n'affirme que les deux petits carrés font le grand. L'expression ci-dessous est leur
différence, calculée à partir des points résolus, et elle est plus petite qu'un centième de pixel carré.

```ring
aGap = oP.Fact(:expr, [ StzPythagorasGapExpr(), "px^2" ])
? fabs( aGap[:value] ) < 0.01
#--> 1
```

## 3. Déplacer un sommet : le théorème tient

Un mouvement sur la figure déplace A. Les carrés sont dérivés des points, donc ils suivent ; l'angle droit est
une règle, donc le solveur le garde ; l'égalité n'a jamais été une règle, et elle tient quand même.

```ring
oM = StzMathMotionOverQ(oP)
oM.State("A moved: a^2 + b^2 - c^2 = {gap} px^2", [ [ :DragBy, "A.icon", 60, -30 ] ])
oM.StateFact("gap", :expr, [ StzPythagorasGapExpr(), "px^2" ])
oM.Apply(1)
? oM.Picture().Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
#--> the angle at A.icon is 90.00 degrees
? fabs( oM.Picture().Fact(:expr, [ StzPythagorasGapExpr(), "px^2" ])[:value] ) < 0.01
#--> 1
```

## 4. Thalès : trois points sur un cercle

La seconde histoire dit trois choses : B et C sont sur le cercle, BC passe par son centre, A est sur le
cercle. Elle ne dit jamais que l'angle en A est droit. Lisez-le.

```ring
oT = StzThalesPictureQ( StzMathFigureFont() )
? oT.Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
#--> the angle at A.icon is 90.00 degrees
? oT.Substance().Holds("Right", [ "BAC" ])
#--> 0
```

## 5. Déplacer A le long du cercle

Déplacez A n'importe où. Le solveur garde A sur le cercle et le diamètre par le centre, et l'angle en A lit
encore quatre-vingt-dix. C'est le théorème de Thalès : une conséquence de la construction, à chaque position.

```ring
oN = StzMathMotionOverQ(oT)
oN.State("A moved: the angle at A is {angle} degrees", [ [ :DragBy, "A.icon", 90, 40 ] ])
oN.StateFact("angle", :angle, [ "B.icon", "A.icon", "C.icon" ])
oN.Apply(1)
? oN.Picture().Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
#--> the angle at A.icon is 90.00 degrees
? fabs( oN.Picture().Fact(:expr, [ "dist(A.icon, K.icon) - K.icon.r", "px" ])[:value] ) < 0.01
#--> 1
```

## 6. Ce qu'un déplacement refuse

Seule une forme dont le solveur possède la position peut être déplacée. Un carré de la figure de Byrne est
dérivé des points, donc un état qui le déplace est refusé nommément.

```ring
try
	oM.State("x", [ [ :DragBy, "ABC.sqbc", 10, 10 ] ])
catch
	? "refused"
done
#--> refused
```

{{exercise:math-06-01}}

## Récapitulatif

- **Acquis :** vous avez construit la I.47 d'Euclide et la figure de Thalès à partir de leurs déclarations,
  lu l'angle droit et l'égalité sur les coordonnées résolues, déplacé un sommet dans chacune par un état
  déclaré, et relu le théorème là où le sommet est arrivé.
- **Pourquoi c'est important :** un théorème que l'image n'a jamais été priée de satisfaire, et qu'elle
  satisfait à chaque position, est une preuve d'une autre nature qu'un dessin fait pour avoir l'air juste. Ce
  qui casserait si le théorème était faux est exactement ce que ce chapitre lit.
- **La suite :** un nombre qui dit pourquoi il n'est pas exact. Le chapitre suivant rencontre les nombres
  exacts de la bibliothèque et l'instant où un calcul les quitte.
