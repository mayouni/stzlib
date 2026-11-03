### Énigme 18 · Arrondir à une puissance de deux

> Traduction provisoire, en attente de relecture par un locuteur natif.

Chaque élément de `a` est une taille, de 0 à 3 999. Mets dans `c` la plus petite puissance de deux qui
la contient, et au moins 1 : 1 pour 0 et 1, 2 pour 2, 4 pour 3 et 4, 8 de 5 à 8, et ainsi de suite
jusqu'à 4 096.

Le nombre de doublements dépend de la taille : le noyau a besoin d'une boucle dont la longueur change
d'un élément à l'autre. C'est `iterate` :

    in a
    out c
    body { @c = iterate(k, 0, 40, s, 0.5, s * 2, s >= @a) }

`iterate(k, from, to, s, init, step, stop)` fait vivre un **état** `s`, qui part de `init` ; à chaque
passe `k` compte à partir de `from` et l'état devient `step`. Quand la condition facultative `stop`
est vraie après une passe, la boucle s'arrête avec l'état de cette passe, et sa valeur est l'état. Ici :
partir d'un demi, doubler, et s'arrêter dès que l'état contient la taille. La boucle fait au plus
4 096 passes quoi que tu écrives : un noyau finit toujours, et une étendue littérale plus grande est
refusée. `sum(k, a, b, e)` est le cas particulier qui ajoute `e` à chaque passe.

L'état peut être un flottant, un entier (écris `int(1)` pour en commencer un) ou un vecteur. Il existe
une deuxième bonne réponse sans `stop`, et une troisième avec un état entier : trouve-les. Le
vérificateur valide les trois, et il nomme l'élément où une quasi-réponse se trompe : un arrêt en `>`
au lieu de `>=`, un départ à 1, trop peu de passes.

**Ce que le GPU a fait autrement qu'une boucle :** rien, dans la réponse. Dans le coût, beaucoup.
Chaque fil fait SA propre copie de cette boucle, treize passes pour une taille de 3 000 et une seule
pour une taille de 1. Les fils d'un groupe avancent ensemble : un groupe qui contient un fil à treize
passes attend treize passes, et les fils déjà finis l'attendent. Un arrêt précoce économise le travail
d'un fil, pas le temps de son groupe, sauf si les tailles voisines se ressemblent.
