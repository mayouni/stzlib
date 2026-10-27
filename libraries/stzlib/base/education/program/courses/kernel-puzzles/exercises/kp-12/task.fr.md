### Énigme 12 · Jusqu'où peut-il aller vite ?

> Traduction provisoire, en attente de relecture par un locuteur natif.

Écris `c = alpha * a + b` sur deux vecteurs (`alpha` vaut 2,5). C'est l'énigme 2 avec un scalaire, et
tu l'auras juste du premier coup. L'énigme, c'est ce qui vient après le verdict.

Une fois ton noyau vérifié, la page le relance sur 4 194 304 éléments et le place sous les deux
**plafonds** de cette machine, mesurés sur place avec les noyaux du moteur :

- le **plafond de bande passante** : combien d'octets par seconde une simple copie déplace ici ;
- le **plafond de calcul** : combien d'opérations par seconde fait un noyau qui ne fait que des multiplications-additions.

Ton noyau lit deux nombres, en écrit un et fait deux opérations : 12 octets pour 2 opérations. C'est
bien moins de travail par octet que l'appareil n'en peut faire, donc il attend la mémoire, et le
nombre qui compte est sa part du plafond de bande passante. La page dit quel plafond est le plus bas pour lui.

Essaie ensuite celui-ci, juste lui aussi :

    body { @c = alpha * @a + @b + 0 * sum(k, 0, 64, @a[k]) }

Il donne les mêmes nombres, et chaque fil en lit 64 de plus. Compare les deux parts. *verified* dit
que la réponse est juste ; il ne dit pas que le noyau est bon.

**Ce que le GPU a fait autrement qu'une boucle :** le temps d'une boucle, ce sont ses pas. Le temps
d'un noyau est le plus lent de deux choses, les octets qu'il déplace et le calcul qu'il fait, et ici
ce sont presque toujours les octets.
