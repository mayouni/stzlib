### Énigme 7 · Beaucoup de mains, première passe

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un vecteur `a` de 16 384 nombres (0, 0,1, 0,2 ... 0,9, 0, 0,1 ...). Tu veux leur total. Un fil ne
peut pas additionner 16 384 nombres vite, mais 1 024 fils peuvent chacun en additionner 16 : écris
le noyau dont le fil `i` somme sa propre fenêtre, `c[i] = a[16i] + a[16i+1] + ... + a[16i+15]`, dans
un vecteur de 1 024 sommes partielles.

Une somme bornée s'écrit `sum(k, from, to, expression)` : `k` va de `from` jusqu'à `to` exclu, et
l'expression peut utiliser `k`. L'entrée est plus longue que la sortie ici ; déclare-les comme toujours :

    in a
    out c

Somme 15 au lieu de 16 et chaque partielle est fausse dès la première ; fais glisser la fenêtre de 1
au lieu de 16 et seule la première partielle est juste -- le vérificateur nomme l'élément dans les deux cas.

**Ce que le GPU a fait autrement qu'une boucle :** une boucle additionne 16 384 nombres l'un après
l'autre, seize mille pas. Ici 1 024 fils ont chacun fait seize pas, côte à côte : le travail était le
même, l'attente un millième.
