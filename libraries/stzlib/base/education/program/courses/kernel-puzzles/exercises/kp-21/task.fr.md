### Énigme 21 · Tasser les grands

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un vecteur `a` de 4 000 nombres, chacun de 0 à 12. Dans chaque groupe de 256, garde les nombres **au-dessus de 5**
et tasse-les, dans leur ordre, au début des places du groupe ; les autres places du groupe valent 0. Un groupe
qui contenait 1, 9, 2, 7, 11, 3 ... répond 9, 7, 11 ... puis des zéros. C'est la **compaction de flux**.

Une boucle ajouterait chaque nombre gardé à la fin d'une liste de sortie. Aucun fil ne sait quelle est la longueur
de la sortie jusque-là ; la réponse vient donc d'un nombre que chaque fil peut calculer seul : le **rang** d'un
élément gardé, c'est-à-dire combien d'éléments gardés se trouvent avant lui. C'est un total courant de 1 et de 0,
le scan de l'énigme précédente. Ici il est lent et simple, et rangé dans un second tableau par son propre stage :

    in a
    out c
    shared t 256
    shared r 256
    stage { @t[@l] = @a }
    stage { @r[@l] = sum(j, 0, 256, when(j <= @l, when(@t[j] > 5, 1, 0), 0)) }

`@r[j]` dit maintenant combien d'éléments gardés il y a jusqu'à la place `j` comprise. La place `@l` de la sortie
contient l'élément gardé dont le rang est `@l + 1` : écris le corps qui le trouve. Un noyau n'écrit que la place qui
lui appartient ; le tassement se fait donc par la place qui cherche son élément, à l'inverse d'une boucle qui pousse.
Il existe une deuxième bonne réponse avec le rang compté dans l'autre sens (seulement les éléments gardés avant
chaque place) ; trouve-la aussi. Le vérificateur accepte les deux et nomme l'élément où une réponse proche se
trompe : celle qui met les petits à zéro sans rien tasser, celle qui lit le rang trop haut d'un, et celle qui garde
les 5.

**Ce que le GPU a fait autrement qu'une boucle :** la sortie d'une boucle grandit au fil de l'eau, donc chaque
ajout dépend du précédent. Ici chaque fil a appris sa place d'un décompte fait en une fois, et personne n'a attendu
personne. La `Compact` de la bibliothèque le fait comme un GPU le préfère quand c'est tout le vecteur qui compte :
chaque élément gardé se dépose à son propre rang, trouvé par un scan sur tout le vecteur, et le nombre d'éléments
gardés revient comme un seul nombre.
