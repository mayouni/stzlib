### Énigme 13 · Deux tarifs

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un vecteur de 4 000 quantités, `a`, contient 0, 7, 1, 8, 2, 9 ... (jamais plus de 12), et un scalaire
`t` vaut 6. Les `t` premières unités d'une quantité coûtent 1 chacune, et chaque unité au-delà de `t`
coûte 2. Écris le noyau qui met le prix de chaque quantité dans `c` : 5 coûte 5, et 9 coûte
6 + 2 x 3 = 12.

Le prix a deux formules, et celle qui s'applique dépend de la quantité.
`when(condition, valeur si vrai, valeur si faux)` est ce choix :

    in a
    scalar t
    out c
    body { @c = when(@a <= t, ..., ...) }

La condition compare des valeurs, comme une garde : `@a <= t`. Ce n'est pas un nombre : `(@a > t) * 2`
est refusé, tout comme un nombre à la place de la condition, `when(@a - t, ...)`. Mets les deux prix
l'un à la place de l'autre et le vérificateur nomme le premier élément où ils diffèrent.

Il existe une deuxième réponse sans aucun `when` : le prix est la quantité, plus ce qui dépasse `t`
une fois de plus. Trouve-la ; le vérificateur la valide aussi.

**Ce que le GPU a fait autrement qu'une boucle :** dans une boucle, un `if` exécute un côté et saute
l'autre. Les fils d'un groupe avancent ensemble, donc ce noyau calcule LES DEUX prix et en garde un :
son WGSL est `select(valeur si faux, valeur si vrai, condition)`, la valeur fausse d'abord. Un choix
sur un GPU coûte ses deux côtés. Ici chaque côté est une ligne d'arithmétique, le coût est donc
faible ; quand un côté est long, tous les fils du groupe l'attendent.
