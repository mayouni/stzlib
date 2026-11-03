### Énigme 20 · Le total courant d'un groupe

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un vecteur `a` de 4 000 nombres. Mets dans `c` le **total courant à l'intérieur de chaque groupe de 256** :
l'élément `i` d'un groupe contient la somme des éléments 0 à `i` du groupe. Chaque groupe recommence : l'élément
256 vaut `a[256]` seul, pas tout ce qui le précède. Le dernier groupe contient 160 nombres ; les 96 fils
au-delà de la fin n'ajoutent rien.

Les 256 fils d'un groupe voient les nombres des autres par la mémoire du groupe (énigme 9). La réponse lente
fait additionner à chaque fil son propre préfixe :

    in a
    out c
    shared t 256
    stage { @t[@l] = @a }
    body { @c = sum(j, 0, 256, when(j <= @l, @t[j], 0)) }

Cela fait jusqu'à 256 additions dans un fil, et les fils attendent le plus long. Il existe une réponse plus
rapide en huit étapes qui doublent chacune la portée : à l'étape `s`, chaque fil ajoute le nombre situé `2^s`
places à sa gauche. Elle demande un second tableau (un stage ne peut pas lire le tableau qu'il écrit), une
boucle `tiles` de huit tours avec deux stages dans chacun, et `pow(2, s)` pour la distance. Lire avant le
début d'un tableau donne 0, donc les fils du bord n'ont pas besoin de branche. Trouve-la. Le vérificateur
accepte les deux et nomme l'élément où une réponse proche se trompe : celle qui oublie le nombre du fil lui-même,
celle qui ne recommence pas à chaque groupe, et celle à sept étapes, qui ne remonte que de 128 places.

**Ce que le GPU a fait autrement qu'une boucle :** une boucle porte un total d'un élément au suivant, donc
le troisième attend le deuxième. Ici aucun fil n'attend le total d'un autre. En huit étapes, les 256 totaux
sont faits, là où la boucle prenait 256 tours à la file, au prix d'environ huit fois plus d'additions. C'est
l'étape de bloc du `Scan` de la bibliothèque : il fait le total courant de chaque bloc de 256 ainsi, fait de
même pour les totaux des blocs, et rajoute le décalage de chaque bloc.
