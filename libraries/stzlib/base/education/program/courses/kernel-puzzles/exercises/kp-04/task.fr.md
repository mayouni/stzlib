### Énigme 4 · Où suis-je ?

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un vecteur `a` de 4 000 nombres : 0, 0,5, 1, 1,5 ... Écris le noyau qui ajoute à chaque élément sa
propre position : `c[i] = a[i] + i`, les positions comptées à partir de 0.

Chaque fil sait OÙ il se tient : `@i` est son numéro d'élément, à partir de 0. Ce n'est pas un
vecteur que tu déclares ; c'est la place du fil, et elle est là dans tout noyau.

    in a
    out c

Décalé d'un -- compter à partir de 1 -- est faux dès le tout premier élément, et le vérificateur le dit.

**Ce que le GPU a fait autrement qu'une boucle :** il n'y avait pas de compteur à incrémenter. Chaque
fil est né en connaissant son numéro ; quatre mille numéros ont existé d'un coup.
