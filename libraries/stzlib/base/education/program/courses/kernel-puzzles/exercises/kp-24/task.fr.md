### Énigme 24 · Une matrice creuse fois un vecteur

> Traduction provisoire, en attente de relecture par un locuteur natif.

Une matrice qui a très peu de nombres non nuls ne se range pas en entier. Ici elle est rangée **huit entrées par ligne** : le
vecteur `a` contient les valeurs des entrées, le vecteur `b` contient la **colonne** où chacune se trouve, et la ligne `i` possède
les entrées 8*i à 8*i + 7 (une ligne de moins de huit est complétée ; c'est la forme à largeur fixe). `x` est un vecteur dense
à un nombre par colonne. Mets dans `y`, pour chaque ligne, son produit avec `x` : la somme, sur les entrées de la ligne, de la
valeur fois le `x` de sa colonne.

    in a
    in b
    in x
    out y

La nouveauté est le **gather** (la collecte) : `@x[@b[k]]` lit `x` non pas à la place du fil mais à la place qu'un autre
vecteur nomme. Sur un GPU, la collecte est le coût du travail creux : les lectures de `x` tombent où les colonnes le disent, si
bien que des fils voisins lisent des endroits éloignés, et la bande passante des énigmes denses est en grande partie perdue. Il
existe une deuxième bonne réponse qui boucle sur les numéros d'entrée eux-mêmes ; trouve-la. Le vérificateur accepte les deux et
nomme l'élément où une réponse proche se trompe : celle qui échange les valeurs et les colonnes, celle dont le pas de ligne est 7,
celle qui lit neuf entrées et emprunte donc la première de la ligne suivante, et celle qui oublie de collecter et multiplie par la
place dans la ligne.

**Ce que le GPU a fait autrement qu'une boucle :** une boucle sur les lignes est une boucle sur les entrées dans une boucle sur
les lignes. Ici chaque ligne est son propre fil et ne parcourt que ses huit entrées. C'est la forme du produit creux `Spmv` de la
bibliothèque, à une différence près : il prend des lignes de n'importe quelle longueur (la forme CSR, où une ligne commence où les
décalages le disent) et choisit entre un fil par ligne, pour les lignes courtes, et un groupe par ligne, pour les longues.
