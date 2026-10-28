### Énigme 15 · La lumière sur une surface

> Traduction provisoire, en attente de relecture par un locuteur natif.

Chaque élément est un point d'une surface, et trois entrées portent la direction vers laquelle la
surface regarde à cet endroit, sa normale : `nx`, `ny` et `nz`. Le soleil éclaire selon
`(sx, sy, sz)`, qui vaut `(2, -1, -2)`. Une surface est aussi claire que le cosinus de l'angle entre
les deux directions, et une surface tournée à l'opposé de la lumière n'en reçoit pas. Écris le noyau
qui met la clarté de chaque point, de 0 à 1, dans `c`.

Trois nombres qui vont ensemble forment une seule valeur, un vecteur :

    vec3(@nx, @ny, @nz)

`dot(a, b)` multiplie deux vecteurs composante par composante et additionne ; pour deux directions
de longueur un, c'est le cosinus. `normalize(v)` ramène un vecteur à la longueur un, `length(v)` dit
sa longueur, et `.x`, `.y`, `.z` lisent une composante (`.zyx` en lit trois, à l'envers). Le calcul
se fait composante par composante, et un nombre qui rencontre un vecteur est réparti sur lui :
`vec3(sx, sy, sz) / 3`.

Une sortie porte toujours un nombre par élément : il faut réduire un vecteur avant la fin, et
`@c = normalize(...)` est refusé. Un vecteur ne se compare pas en entier non plus : compare une
composante, ou un produit scalaire.

**Ce que le GPU a fait autrement qu'une boucle :** le même calcul, écrit autrement. Un GPU a
toujours travaillé en vecteurs, positions et couleurs, et son langage a `vec3` et `dot` en propre ;
le noyau le dit en quatre mots là où une boucle écrirait neuf multiplications. Là où la réponse
demande une racine carrée, l'appareil arrondit son dernier chiffre à sa façon, donc cette énigme
admet un écart de 0,00001.
