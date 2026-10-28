### Énigme 17 · Compter les votes

> Traduction provisoire, en attente de relecture par un locuteur natif.

4 000 personnes ont voté, chacune pour un des 13 candidats numérotés de 0 à 12 : le vote de la
personne `i` est `a[i]`. Compte les votes de chaque candidat dans `h`, pour que `h[k]` soit le nombre
de personnes qui ont voté pour `k`.

Jusqu'ici chaque fil écrivait son propre élément. Ici 4 000 fils écrivent dans 13 compteurs, et
beaucoup d'entre eux dans le même au même instant. Une écriture simple perdrait des votes : deux fils
lisent 307, tous deux écrivent 308, et un vote a disparu. La sortie est déclarée comme des compteurs
qui ne font qu'ajouter :

    in a
    out h atomic 13
    body { @h[@a] += 1 }

`@h[index] += valeur` ajoute `valeur` au compteur `index`, sans risque, quels que soient ceux qui y
ajoutent au même moment ; `max=` et `min=` gardent le plus grand ou le plus petit. Les compteurs
portent des nombres entiers et partent de 0. Un indice hors de 0 à 12 est abandonné, pas écrit.
L'ordre d'arrivée des votes ne peut pas changer une somme, donc le décompte du vérificateur, sur le
CPU, est la réponse que l'appareil doit donner.

**Ce que le GPU a fait autrement qu'une boucle :** une boucle compte un vote à la fois et n'a jamais
deux mains sur un compteur. Ici chaque vote est compté en même temps, et l'appareil fait passer à
tour de rôle les fils qui partagent un compteur. Plus un candidat reçoit de votes, plus sa file est
longue : c'est pourquoi un histogramme rapide sur GPU donne d'abord à chaque groupe ses propres
compteurs, en mémoire partagée, et les additionne à la fin.
