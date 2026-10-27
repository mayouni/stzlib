### Énigme 11 · Softmax, une ligne par groupe

> Traduction provisoire, en attente de relecture par un locuteur natif.

`a` contient 16 lignes de 256 nombres. Transforme chaque ligne en parts dont la somme vaut 1 :
`c[i] = exp(a[i] - max) / somme`, où `max` est la plus grande valeur de la ligne et `somme` la somme
de `exp(a - max)` sur la ligne. Un groupe de 256 fils est une ligne.

Une ligne **reduce** replie un tableau partagé dans sa case 0, en le coupant en deux avec une
barrière à chaque étape : 256 valeurs, puis 128, 64 ... 1. `reduce m max` laisse la plus grande
valeur dans `@m[0]` ; `reduce s sum` laisse le total dans `@s[0]`.

    stage { @m[@l] = @a }
    reduce m max
    stage { @s[@l] = exp(@a - @m[0]) }
    reduce s sum
    body { @c = exp(@a - @m[0]) / @s[0] }

Après un reduce, seule la case 0 tient la réponse ; les autres tiennent ce que les moitiés y ont
laissé. Divise par `@s[@l]` et l'élément 1 est juste (il lit la case 0) mais pas l'élément 2 :
*mismatch at element 2*. Oublie de diviser : *mismatch at element 1*.

Soustraire le max ne change pas la réponse : la version sans lui est vérifiée ici, sur des nombres
entre 0 et 0,9. Il sert le jour où la ligne contient 1 000, dont l'exponentielle ne tient pas dans un float.

**Ce que le GPU a fait autrement qu'une boucle :** une boucle trouve le maximum en parcourant la ligne
une fois et additionne en la parcourant encore. Ici chaque parcours a été huit moitiés, larges de 256 fils.
