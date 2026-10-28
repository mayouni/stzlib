### Énigme 16 · Tourner les points

> Traduction provisoire, en attente de relecture par un locuteur natif.

L'entrée `p` porte 4 000 points, chacun un `vec2`, et le noyau doit faire tourner chacun d'eux
autour de l'origine de l'angle dont le cosinus est `c` (0,6) et le sinus `s` (0,8), environ 53
degrés. Un point `(x, y)` tourné de cet angle devient `(c x - s y, s x + c y)`. Mets chaque point
tourné dans `q`.

Cette fois l'entrée et la sortie portent des vecteurs, et les déclarations le disent :

    in p vec2
    scalar c
    scalar s
    out q vec2

Un tampon de `vec2` porte deux nombres par élément, côte à côte : l'élément 7 est les nombres 14 et
15. `@p` est le point de l'élément, `@p.x` et `@p.y` ses deux nombres, et la valeur du corps doit
être un `vec2`, comme `vec2(..., ...)`. Un nombre y est refusé, et un `vec3` aussi.

Il existe d'autres façons d'écrire la même rotation. Chaque nouvelle composante est un produit
scalaire avec une ligne de la rotation, et le point tourné est aussi `c` fois le point plus `s` fois
le point tourné d'un quart, `vec2(-@p.y, @p.x)`. Le vérificateur valide les trois.

**Ce que le GPU a fait autrement qu'une boucle :** une boucle parcourrait le tableau deux nombres à
la fois en gardant l'appariement en tête : l'indice 2i est x, 2i + 1 est y. Ici c'est la déclaration
qui le garde. Le noyau lit un point et écrit un point, et l'appariement est en un seul endroit, il
ne peut donc pas dériver.
