### Énigme 2 · Deux vecteurs, une somme

> Traduction provisoire, en attente de relecture par un locuteur natif.

Deux vecteurs de 4 000 nombres : `a` contient 0, 1, 2, 3 ... et `b` contient 0, 0,5, 1, 1,5 ...
Écris le noyau qui met leur somme dans `c` : `c[i] = a[i] + b[i]`.

Chaque fil possède un élément de CHAQUE vecteur qu'il déclare : `@a` et `@b` sont ses deux nombres,
`@c` l'endroit de sa réponse. Pars de

    in a
    in b
    out c

Un noyau qui lit `a` deux fois et jamais `b` est juste au premier élément (les deux valent 0) et faux
à partir du second ; le vérificateur nomme l'élément.

**Ce que le GPU a fait autrement qu'une boucle :** une boucle parcourrait deux tableaux côte à côte,
indice par indice. Ici chaque fil se tient déjà à son propre indice dans les deux ; rien n'a été parcouru.
