# Une famille sous un paramètre

*Mathématiques · Chapitre 5 · Compétence FO-04 : « Puis-je dire ce que je veux et laisser le moteur décider comment ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Écrivez une lettre là où il y avait un nombre, et une fonction devient une famille : a fois le sinus de x
est une courbe pour chaque valeur de a. Un paramètre est cette lettre avec un intervalle et une valeur, et un
mouvement est la famille déplacée. Ce chapitre déclare un mouvement, déplace son paramètre, et lit ce qui
bouge avec lui à deux vitesses : la courbe aussitôt, les marques quand le paramètre se pose.

## 1. Déclarer la famille

La déclaration est celle d'une figure de fonction, avec le paramètre écrit entre accolades. Le paramètre
reçoit ensuite son intervalle et son point de départ.

```ring
oM = StzMathMotionQ(:Function, [ :f = "{a} * sin(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ], :maxmarks = 3 ])
oM.Param("a", 1, 3, 1)
? oM.Value("a")
#--> 1
```

## 2. Se poser : la figure là où se tient le paramètre

Se poser construit et résout la figure pour la valeur courante du paramètre. La déclaration qu'elle utilise
est la famille où la lettre est remplacée par le nombre.

```ring
oM.Settle()
? @@( oM.Resolved() )
#--> [ "f", "(1) * sin(x)" ]
? oM.Figure().Why()
#--> a function figure: 400 samples in 1 piece(s), 4 mark(s)
```

## 3. Déplacer le paramètre : la courbe suit aussitôt

Mettez a à deux. Le mouvement est maintenant en attente, ce qui veut dire que ses marques disent encore un
alors que sa courbe dit déjà deux. La courbe est échantillonnée à partir de la famille compilée une fois avec
a comme variable : deux cent quarante places, chacune vérifiée ici contre le sinus de Ring lui-même.

```ring
oM.Set("a", 2)
? oM.IsDirty()
#--> 1
? oM.LiveSampleCount()
#--> 240
aS = oM.LiveSamples()
? fabs( aS[100][2] - 2 * sin( aS[100][1] ) ) < 0.000001
#--> 1
```

## 4. Se poser à nouveau : les marques rattrapent

Les extremums de deux fois le sinus sont à plus et moins deux, là où ceux du sinus étaient à plus et moins
un. Ils sont retrouvés, non mis à l'échelle.

```ring
oM.Settle()
? @@( oM.Figure().Extrema() )
#--> [ [ -1.57, -2 ], [ 1.57, 2 ], [ -4.71, 2 ], [ 4.71, -2 ] ]
? oM.IsDirty()
#--> 0
```

## 5. Des états déclarés

Un mouvement peut se raconter en états : chacun une légende et l'acte qui y mène. Un fait lié à un état est
calculé sur l'image à cet état et montré dans la légende là où vous avez écrit son nom entre accolades.

```ring
oM.State("With a at one, the mark nearest the origin sits at {top}.", [ [ :Set, "a", 1 ] ])
oM.StateFact("top", :datum, [ "m1", "y" ])
oM.State("With a at three it sits at {top}.", [ [ :Set, "a", 3 ] ])
oM.StateFact("top", :datum, [ "m1", "y" ])
? oM.NumberOfStates()
#--> 2
```

## 6. Appliquer un état, lire le fait

Appliquer le second état met a à trois et se pose. La marque la plus proche de l'origine est un minimum, et
sa hauteur est moins trois : le paramètre, relu sur l'image résolue.

```ring
oM.Apply(2)
? oM.Picture().Fact(:datum, [ "m1", "y" ])[:message]
#--> m1 carries y = -3
? oM.Applied()
#--> 2
```

## 7. Ce que le mouvement refuse

Un paramètre que la déclaration n'écrit jamais est refusé nommément, et de même un état dont l'acte n'est
pas un acte.

```ring
try
	oM.Param("b", 0, 1, 0.5)
catch
	? "refused"
done
#--> refused
```

{{exercise:math-05-01}}

## Récapitulatif

- **Acquis :** vous avez déclaré une famille de fonctions sous un paramètre, l'avez posée, avez déplacé le
  paramètre et vu la courbe suivre aussitôt tandis que les marques attendaient la pose, vérifié un échantillon
  vivant contre le sinus de Ring, déclaré deux états avec un fait lié, et appliqué l'un d'eux.
- **Pourquoi c'est important :** une image qui bouge n'est pas un film. La courbe est recalculée et les
  marques sont retrouvées, donc ce que vous voyez à chaque valeur du paramètre est aussi vérifié que l'était
  l'image fixe.
- **La suite :** une construction se déclare aussi. Le chapitre suivant déclare un triangle rectangle et un
  triangle dans un demi-cercle, déplace un sommet, et lit un théorème sur les coordonnées.
