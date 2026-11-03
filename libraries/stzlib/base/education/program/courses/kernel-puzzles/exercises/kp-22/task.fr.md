### Énigme 22 · Trier un groupe

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un vecteur `a` de 4 096 nombres, chacun de 0 à 12. Trie **chaque groupe de 256** par ordre croissant : le plus petit nombre
du groupe en premier. (Un dernier groupe plus court verrait ses nombres manquants comme 0.)

Une boucle échangerait des voisins jusqu'à ce que plus rien ne bouge. Aucun fil ne voit l'ordre entier ; la réponse vient
donc de ce que chaque fil peut calculer seul : son **rang**, combien de nombres du groupe passent avant le sien. Les nombres
égaux demandent un départage, sinon deux d'entre eux réclament le même rang et une place reste vide : ici, celui qui est
placé en premier dans le groupe passe en premier.

    in a
    out c
    shared t 256
    shared r 256
    stage { @t[@l] = @a }
    stage { @r[@l] = sum(j, 0, 256, when(@t[j] < @t[@l] or (@t[j] == @t[@l] and j < @l), 1, 0)) }

`@r[l]` est maintenant la place où va le nombre qui est en `l`. Comme dans l'énigme précédente, un noyau n'écrit que la
place qui lui appartient : la place `@l` cherche donc le nombre dont le rang est `@l` ; écris ce corps. Il existe une
deuxième bonne réponse qui départage dans l'autre sens (l'égal placé plus tard passe en premier) ; trouve-la. Le
vérificateur accepte les deux et nomme l'élément où une réponse proche se trompe : les égaux au même rang, qui laissent des
trous et des doublons ; un compte qui inclut le nombre lui-même, ce qui monte chaque rang d'un ; et un rang par les plus
grands, qui trie vers le bas.

**Ce que le GPU a fait autrement qu'une boucle :** une boucle de tri fait passer les nombres les uns devant les autres,
une comparaison après l'autre. Ici les 256 nombres ont été comparés aux 256 d'un coup, et chacun a appris sa place du
décompte : 65 536 comparaisons en une étape, sans qu'aucun fil n'en attende un autre. C'est un gaspillage pour un grand
vecteur, ce qui explique que le `Sort` de la bibliothèque ne le fasse pas : il fait huit passes de quatre bits, chacune
plaçant chaque clé en comptant les clés dont le chiffre vient avant le sien, si bien que le travail croît avec la taille du
vecteur et non avec son carré.
