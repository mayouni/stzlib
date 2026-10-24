### Énigme 8 · Beaucoup de mains, le repli

> Traduction provisoire, en attente de relecture par un locuteur natif.

Les 1 024 sommes partielles de l'énigme 7 forment maintenant un vecteur `c`, et `m` (un scalaire,
1 024) dit combien il y en a. Écris le noyau qui les replie en UN SEUL nombre :
`d[0] = c[0] + c[1] + ... + c[m-1]`. La sortie a un seul élément.

    in c
    scalar m
    out d

Replie `m - 1` d'entre elles et le total manque la dernière partielle ; copie `@c` et tu as la première
partielle, pas la somme. Les deux donnent *mismatch at element 1* -- il n'y en a qu'un.

Ensemble, les énigmes 7 et 8 forment une réduction en deux passes : mille fils somment chacun seize,
puis un fil somme les mille. C'est ainsi qu'un GPU additionne un million de nombres : jamais l'un après
l'autre jusqu'au bout, jamais un seul fil qui fait tout.

**Ce que le GPU a fait autrement qu'une boucle :** l'unique total courant de la boucle a été éclaté en
mille petits totaux qu'aucun fil n'a eu à attendre, puis rassemblés une fois.
