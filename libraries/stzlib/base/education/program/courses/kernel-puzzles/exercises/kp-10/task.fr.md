### Énigme 10 · Un produit de matrices par tuiles

> Traduction provisoire, en attente de relecture par un locuteur natif.

`a` est une matrice 32 x 64 et `b` une 64 x 48, ligne après ligne. Écris `c = a x b`, 32 x 48 :
`c[ligne][col]` est la somme sur j de `a[ligne][j] * b[j][col]`. Les scalaires disent la forme :
`k` = 64 la longueur intérieure, `w` = 48 la largeur de `b` et de `c`.

`width w` fait de la sortie une matrice traitée par **tuiles de 16 x 16** : chaque groupe de 256
fils calcule une tuile de `c`, et un fil nomme sa case par `@row` et `@col`, sa place dans la tuile
par `@lx` (colonne, 0-15) et `@ly` (ligne, 0-15).

La façon simple est juste et lente : chaque fil lit 64 nombres de `a` et 64 de `b` en mémoire. La
façon par tuiles tourne `tiles t { k / 16 }` fois ; à chaque tour le groupe dépose une tuile 16 x 16
de `a` et une de `b` dans sa mémoire, et chaque fil y ajoute seize produits. Chaque nombre est lu
une fois par groupe au lieu d'une fois par fil. Le point de départ dépose la tuile de `a` :

    stage { @ta[@ly * 16 + @lx] = @a[@row * k + t * 16 + @lx] }

Écris la tuile de `b` (ligne `t * 16 + @ly`, colonne `@col`), puis

    accumulate { @acc = @acc + sum(j, 0, 16, @ta[@ly * 16 + j] * @tb[j * 16 + @lx]) }
    body { @c = @acc }

`@acc` est le total courant du fil, gardé d'un tour à l'autre. Un seul tour et chaque case n'a que
ses seize premiers produits : *mismatch at element 1*. La forme cachée est une autre matrice,
16 x 80 fois 80 x 32 : un noyau qui connaît 64 et 48 par coeur y échoue.

**Ce que le GPU a fait autrement qu'une boucle :** une boucle calcule une case après l'autre. Ici
256 cases ont été calculées ensemble, et les nombres dont elles ont besoin ont été lus une fois, ensemble.
