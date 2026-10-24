### Énigme 1 · Le double

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un vecteur `a` contient 4 000 nombres : 0, 1, 2, 3 et ainsi de suite. Écris le noyau qui met le
double de chaque nombre dans `c`, de sorte que `c[i] = a[i] * 2` pour chaque élément.

Sur un GPU, il n'y a pas de boucle. Un **fil** s'exécute pour chaque élément en même temps, et ta
description dit ce que chaque fil fait de *son* élément : `@a` est le `a` de ce fil, `@c` son `c`.
Pars de

    in a
    out c

et ajoute la ligne du corps. Tant que tu ne l'as pas fait, le vérificateur répond *waiting for your
implementation* : une énigme commence rouge.

Le vérificateur exécute ton noyau sur l'appareil pour les 4 000 nombres, puis une fois encore sur un
jeu caché d'une autre taille avec d'autres nombres, et compare chaque élément avec la description
qu'il détient. Un noyau qui répond juste seulement là où on lui a montré est attrapé là. Ton programme
affiche le mot du vérificateur.

Lance-le sur l'ordinateur (`rnxc ton-fichier.ring`) ou ouvre la page du cours dans un navigateur
avec WebGPU : la même description, le même verdict.

**Ce que le GPU a fait autrement qu'une boucle :** rien ne s'est passé l'un après l'autre. Quatre
mille fils ont chacun lu un nombre et écrit un nombre, au même instant.
