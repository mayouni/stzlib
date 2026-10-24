### Énigme 3 · Un nombre pour tous

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un vecteur `a` de 4 000 nombres et un paramètre `alpha`. Écris le noyau qui met chaque élément à
l'échelle : `c[i] = alpha * a[i]`.

Un **scalaire** est une valeur que chaque fil lit ; il ne vient pas d'un vecteur. Déclare-le avec une
ligne `scalar` et utilise son nom nu dans le corps :

    in a
    scalar alpha
    out c

N'écris pas le nombre lui-même : le vérificateur lie `alpha` pour toi, et un noyau qui a écrit `2` est
faux pour chaque élément où alpha ne vaut pas 2 (il vaut 2,5 ici).

**Ce que le GPU a fait autrement qu'une boucle :** le paramètre n'a pas été passé quatre mille fois.
Il était posé une fois dans un petit tampon uniforme, et chaque fil a regardé au même endroit.
