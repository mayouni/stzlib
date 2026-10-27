### Énigme 9 · La mémoire du groupe

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un vecteur `a` de 4 096 nombres (0, 1, 2 ...). Inverse-le **à l'intérieur de chaque groupe de 256** :
le premier groupe devient 255, 254 ... 0, le deuxième 511, 510 ... 256, et ainsi de suite.

Les 256 fils d'un groupe partagent une petite mémoire rapide que les fils des autres groupes ne voient
pas. `shared t 256` y déclare un tableau de 256 nombres. Une ligne **stage** est une écriture par fil ;
après elle le moteur pose une **barrière** : aucun fil ne continue avant que tous les fils du groupe
aient écrit. `@l` est la place d'un fil dans son groupe, de 0 à 255.

    stage { @t[@l] = @a }
    body { @c = @t[255 - @l] }

Après la barrière, chaque fil lit la case qu'un AUTRE fil a écrite. Sans la ligne stage le tableau
ne contient que des zéros : *mismatch at element 1*. Inverse tout le vecteur et l'élément 1 vaut
4 095 au lieu de 255 : encore *mismatch at element 1*.

La ligne stage écrit la barrière pour toi. Dans un noyau écrit à la main, la barrière oubliée est la
course qui passe presque tous les tests et en rate un.

**Ce que le GPU a fait autrement qu'une boucle :** une boucle qui inverse sur place échange les paires
l'une après l'autre. Ici 256 fils ont écrit ensemble, attendu une fois, et lu ensemble.
