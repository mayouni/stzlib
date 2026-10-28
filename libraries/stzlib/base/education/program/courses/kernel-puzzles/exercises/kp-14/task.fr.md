### Énigme 14 · Lancer le dé

> Traduction provisoire, en attente de relecture par un locuteur natif.

Chaque élément de `a` est une graine : 0, 7, 1, 8, 2, 9 ... (des nombres entiers jusqu'à 12). Un
générateur classique fait d'une graine le nombre suivant par `graine x 1664525 + 1013904223`, et un
dé à mille faces en garde les trois derniers chiffres. Écris le noyau qui met le lancer de chaque
graine dans `c` : la graine 7 donne 898.

Les nombres ici sont entiers, et le noyau le dit :

    in a int
    out c int

`int` fait de `@a` un nombre entier, et de chaque opération sur lui une opération entière : `/`
laisse tomber le reste et `%` le donne. Un nombre entier qui rencontre un int est un int ; un nombre
avec une virgule est un flottant.

Essaie d'abord en flottants, avec `in a` et `out c`, et le vérificateur nomme l'élément 1. Un
flottant garde 24 chiffres binaires, environ sept décimaux, et 1 013 904 223 en a dix : en flottant
il devient 1 013 904 192, donc la graine 0 donne 192, pas 223. Un int garde chaque chiffre.

Un int et un flottant ne se rencontrent jamais sans le dire : `@a * 0.5` est refusé. Écris
`float(@a) * 0.5`, ou `int(...)` dans l'autre sens.

**Ce que le GPU a fait autrement qu'une boucle :** rien, cette fois : une boucle en flottants sur un
CPU perd les mêmes chiffres. Ce qui vaut d'être su, c'est le comportement d'un int de GPU à ses
bords. Il revient au début après 2 147 483 647, comme sur tout CPU. Et sur la RTX 3050 où ce cours a
été construit, le compilateur du GPU prenait le `%` d'un int négatif comme si l'int n'avait pas de
signe (-7 % 4 donnait 1, là où WGSL dit -3) ; le transpileur écrit donc lui-même chaque reste
entier, et c'est en comparant que le vérificateur l'a trouvé.
