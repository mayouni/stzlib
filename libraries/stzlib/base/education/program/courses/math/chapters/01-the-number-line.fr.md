# La droite numérique

*Mathématiques · Chapitre 1 · Compétence SE-01 : « Une image répondrait-elle plus vite qu'un nombre ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un nombre est une place. Trois, moins deux et sept et demi sont trois places sur une même droite, et cette
droite est la première image des mathématiques : tout ce qui s'y trouve a une position, un ordre et une
distance. Ce chapitre déclare une droite numérique à la manière de Softanza. Vous dites ce qu'elle porte ; la
figure calcule où va chaque chose, la dessine, et juge sa propre image avant que vous ne lui fassiez confiance.

## 1. Déclarer la droite

Une droite numérique se déclare par des clés : l'intervalle qu'elle couvre, et les points qu'elle porte. La
figure répond par une phrase sur ce qu'elle a calculé.

```ring
oL = StzMathFigureQ(:NumberLine, [ :on = [ -5, 10 ], :points = [ 3, -2, 7.5 ] ])
? oL.Why()
#--> a number line from -5 to 10: 16 ticks, 3 point(s), 0 jump(s)
```

## 2. L'image se juge elle-même

Chaque figure porte des règles. Une droite numérique doit garder ses points dans l'ordre de leurs nombres,
faire atterrir un saut là où le saut le dit, et garder chaque nom lisible à côté de son point. Demandez à la
figure si sa propre image a enfreint une règle. Zéro est la réponse que vous voulez, et elle est calculée, non
promise.

```ring
? len( oL.Violations() )
#--> 0
```

## 3. L'ordre est une question que l'on peut poser

Lequel est le plus à gauche, moins deux ou trois ? Sur la droite, à gauche veut dire plus petit. Softanza
répond par un nombre : un pour vrai, zéro pour faux.

```ring
? -2 < 3
#--> 1
? 7.5 < 3
#--> 0
```

## 4. Un saut est une différence

Un saut d'une place à une autre est dessiné comme un arc, et la figure vérifie que l'arc atterrit là où il le
dit. Un saut a deux extrémités, et la figure les compte comme des points. De neuf à quatre, c'est un saut de
moins cinq : il va vers la gauche.

```ring
oJ = StzMathFigureQ(:NumberLine, [ :on = [ 0, 12 ], :jumps = [ [ 9, 4 ] ], :step = 1 ])
? oJ.Why()
#--> a number line from 0 to 12: 13 ticks, 2 point(s), 1 jump(s)
? 4 - 9
#--> -5
```

## 5. La distance entre deux places

Une distance est une différence dont on a retiré le signe. Entre moins deux et sept et demi il y a neuf unités
et demie, quelle que soit l'extrémité par laquelle on commence.

```ring
? fabs( 7.5 - (-2) )
#--> 9.50
? fabs( -2 - 7.5 )
#--> 9.50
```

## 6. Nommer une place

Un point peut porter un nom, et la figure place le nom là où il se lit sans toucher la droite, les graduations
ni un autre nom. Un demi se trouve à mi-chemin entre zéro et un.

```ring
oN = StzMathFigureQ(:NumberLine, [ :on = [ 0, 2 ], :step = 0.5,
                                   :points = [ [ 0.5, "half" ], [ 1.5, "one and a half" ] ] ])
? oN.Why()
#--> a number line from 0 to 2: 5 ticks, 2 point(s), 0 jump(s)
? len( oN.Violations() )
#--> 0
```

## 7. Sur votre monde

Cette cellule compte les demandes reçues par votre école cette semaine et place ce compte sur une droite. Ce
qu'elle affiche dépend du monde sur lequel ce cours s'exécute, aussi la page ne montre jamais de résultat :
exécutez-la.

```ring
aReq = EduWorldObjects("requested")
oW = StzMathFigureQ(:NumberLine, [ :on = [ 0, 10 ], :points = [ [ len(aReq), "requests" ] ] ])
? EduWorldName()
? oW.Why()
```

{{exercise:math-01-01}}

## Récapitulatif

- **Acquis :** vous avez déclaré une droite numérique avec son intervalle et ses points, lu la phrase que la
  figure donne d'elle-même sur ce qu'elle a calculé, lui avez demandé de juger son image, comparé deux places,
  sauté de l'une à l'autre et mesuré leur distance.
- **Pourquoi c'est important :** une image est déclarée, calculée puis vérifiée. Rien n'y a été dessiné à la
  main, donc rien n'y peut être faux en silence : chaque affirmation de ce chapitre est une ligne que la figure
  a affichée.
- **La suite :** une fraction est une partie d'un tout, et le chapitre suivant la colorie, en compare deux et
  lit le verdict sur l'image.
