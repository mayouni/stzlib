# La dérivée qui vérifie une formule

*Mathématiques · Chapitre 14 · Compétence CR-02 : « Qu'est-ce qui casserait si j'avais tort ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Une dérivée est la pente d'une courbe en une place : à quelle vitesse la valeur change quand l'entrée bouge
un peu. L'école l'enseigne comme une formule à dériver à la main, et une dérivée écrite à la main peut être
fausse. Le moteur calcule la dérivée de toute expression qu'il a compilée, exactement, en parcourant la bande
de l'expression elle-même, si bien qu'une formule écrite à la main devient une affirmation que la bande peut
vérifier. Ce chapitre compile une fonction, lit sa dérivée sur la bande, vérifie une formule juste et attrape
une formule fausse, et confirme les marques du chapitre 4 par des pentes.

## 1. Compiler une fonction

Une fonction est une expression sur des variables nommées, compilée une fois sur la bande du moteur. Demandez
sa valeur en une place.

```ring
oF = new stzMathFunction("x^3 - 2*x", [ "x" ])
? oF.ValueAt([ 2 ])
#--> 4
```

## 2. La dérivée, sur la bande

La dérivée en deux est dix. Rien n'a été dérivé à la main : la bande porte comment chaque nœud change avec
x, et le moteur relit la pente.

```ring
? oF.DerivativeAt("x", [ 2 ])
#--> 10
```

## 3. Une formule à la main, vérifiée

La dérivée du manuel pour x cube moins deux x est trois x carré moins deux. En deux elle donne dix, et la
bande est d'accord. La formule était une affirmation ; elle est maintenant vérifiée.

```ring
? 3 * 2 * 2 - 2
#--> 10
? fabs( (3 * 2 * 2 - 2) - oF.DerivativeAt("x", [ 2 ]) ) < 0.000001
#--> 1
```

## 4. Une formule fausse, attrapée

Écrivez la dérivée comme trois x carré moins un, la faute d'une main fatiguée. En deux elle donne onze, et
la bande dit non.

```ring
? 3 * 2 * 2 - 1
#--> 11
? fabs( (3 * 2 * 2 - 1) - oF.DerivativeAt("x", [ 2 ]) ) < 0.000001
#--> 0
```

## 5. Un troisième témoin : la différence finie

Bougez un peu de chaque côté de deux et divisez la variation de la valeur par la variation de l'entrée.
C'est une pente mesurée, non dérivée, et elle s'accorde avec la bande à un millionième près.

```ring
h = 0.0001
nSlope = ( oF.ValueAt([ 2 + h ]) - oF.ValueAt([ 2 - h ]) ) / ( 2 * h )
? nSlope
#--> 10.00
? fabs( nSlope - 10 ) < 0.000001
#--> 1
```

## 6. Deux variables, un gradient

Avec deux variables la dérivée est une paire, une pente par variable. Pour x y plus y carré en deux et trois,
la pente selon x est trois et selon y est huit.

```ring
oG = new stzMathFunction("x*y + y^2", [ "x", "y" ])
? oG.ValueAt([ 2, 3 ])
#--> 15
? @@( oG.GradientAt([ 2, 3 ]) )
#--> [ 3, 8 ]
```

## 7. La pente du sinus en zéro

La dérivée du sinus est le cosinus. En zéro la bande dit un, et le cosinus de zéro de Ring dit un.

```ring
oS = new stzMathFunction("sin(x)", [ "x" ])
? oS.DerivativeAt("x", [ 0 ])
#--> 1
? fabs( oS.DerivativeAt("x", [ 0 ]) - cos(0) ) < 0.000000001
#--> 1
```

## 8. Les marques du chapitre 4, confirmées par des pentes

Le chapitre 4 a trouvé l'extremum de x carré moins deux en zéro en regardant la courbe tourner. La pente y
est zéro, ce qu'un extremum veut dire, et au zéro la pente est deux fois la racine carrée de deux.

```ring
oQ = new stzMathFunction("x^2 - 2", [ "x" ])
? oQ.DerivativeAt("x", [ 0 ])
#--> 0
? oQ.DerivativeAt("x", [ 1.41421356 ])
#--> 2.83
```

{{exercise:math-14-01}}

## Récapitulatif

- **Acquis :** vous avez compilé une fonction sur la bande, lu sa dérivée en une place, vérifié une formule
  écrite à la main contre elle et attrapé une formule fausse, mesuré la pente par une différence finie comme
  troisième témoin, lu un gradient à deux variables, et confirmé les marques du chapitre 4 par des pentes.
- **Pourquoi c'est important :** une formule dérivée à la main est une affirmation. La bande calcule la même
  pente par une autre route, donc l'affirmation est vérifiée par quelque chose qui ne connaissait pas la
  formule.
- **La suite :** une vérification qui ne peut pas échouer n'est pas une vérification. Le dernier chapitre
  distingue une auto-vérification d'une vérification indépendante, et montre pourquoi chaque positif a besoin
  d'un négatif à côté de lui.
