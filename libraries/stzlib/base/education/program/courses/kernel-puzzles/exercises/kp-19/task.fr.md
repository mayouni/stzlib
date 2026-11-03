### Énigme 19 · Ce qui a changé depuis la tranche précédente

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un volume est une pile de tranches, et chaque tranche est une grille. Le volume `a` compte ici 4 tranches
de 32 × 32 cellules (la forme cachée est une autre : 3 tranches de 16 × 32). Mets dans `c`, pour chaque
cellule, ce qui a changé depuis la tranche précédente : la cellule moins la même cellule une tranche plus
tôt. La première tranche n'a rien avant elle, elle garde donc sa propre valeur.

Un noyau voit un volume par deux lignes qu'une sortie ordinaire n'a pas :

    in a
    scalar w
    scalar d
    scalar p
    out c
    width w
    depth d
    body { @c = @a }

`width w` fait de la sortie une grille large de `w` cellules, travaillée par tuiles de 16 × 16 ; `depth d`
empile `d` de ces grilles. Une cellule trouve sa place par trois noms : `@slice`, la grille où elle est, et
`@row` et `@col`, sa ligne et sa colonne **dans cette tranche**. `@i` est sa place dans tout le volume, et
le scalaire `p` est le nombre de cellules d'une tranche : une tranche plus tôt, c'est `@i - p`. `@slice` sans
ligne `depth` est refusé, et une ligne `depth` demande une ligne `width`. Lire avant le premier élément
donne 0, comme partout.

Il existe une deuxième bonne réponse qui s'appuie sur ce zéro, et une troisième qui déplace la branche. Le
vérificateur accepte les trois, et il nomme l'élément où une réponse proche se trompe : celle qui compare
les lignes au lieu des tranches, celle qui écrit la taille d'une tranche comme un nombre (elle ne marche
que pour la forme montrée), et celle qui saute la deuxième tranche.

La taille d'une tranche arrive en `p` et n'est pas calculée en `n / d`, exprès : une division flottante
n'est pas exacte sur tous les périphériques (certains multiplient par un inverse, et fusionné avec la
soustraction l'indice tombe un cheveu sous son élément et lit le précédent), donc une taille qui sert
d'indice vaut mieux donnée exactement.

**Ce que le GPU a fait autrement qu'une triple boucle :** les trois boucles imbriquées, sur les tranches,
les lignes et les colonnes, ont disparu. Il y a un fil par cellule, qui apprend sa tranche, sa ligne et sa
colonne de sa place. Son groupe est une tuile 16 × 16 d'**une seule** tranche, jamais d'une tuile à cheval
sur deux, ce qui explique qu'une tranche doive être un nombre entier de tuiles. Le coût de cette énigme est
de deux lectures par cellule, chacune coalescée : les fils voisins d'un groupe lisent des adresses voisines,
dans la tranche et dans la précédente.
