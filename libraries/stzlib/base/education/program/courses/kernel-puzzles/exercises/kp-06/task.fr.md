### Énigme 6 · Regarde tes voisins

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un vecteur `a` de 4 000 nombres qui vont 0, 7, 1, 8, 2, 9 ... (chacun vaut `(i * 7) % 13`). Écris le
noyau qui le lisse : chaque élément devient la moyenne de son voisin de gauche, de lui-même et de son
voisin de droite, `c[i] = (a[i-1] + a[i] + a[i+1]) / 3` -- et les deux bords, qui n'ont qu'un voisin,
sont laissés non écrits.

Un fil peut lire un AUTRE élément d'une entrée : `@a[@i - 1]` est celui d'avant, `@a[@i + 1]` celui
d'après. Hors du vecteur une lecture répond 0, donc les bords sont à toi de garder :

    in a
    out c
    guard { @i > 0 and @i < n - 1 }

Sans la garde des bords, les bords sont écrits et le verdict est *mismatch at element 1* : le premier
bord, que la tâche dit de laisser.

**Ce que le GPU a fait autrement qu'une boucle :** chaque fil a lu trois nombres d'un coup, et ses
voisins lisaient les mêmes nombres au même instant ; personne n'a attendu le fil d'avant.
