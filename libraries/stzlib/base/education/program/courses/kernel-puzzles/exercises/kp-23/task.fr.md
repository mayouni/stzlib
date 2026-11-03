### Énigme 23 · Un total courant qui repart de zéro

> Traduction provisoire, en attente de relecture par un locuteur natif.

Deux vecteurs de 4 096 nombres : des valeurs `a` (0 à 12) et des marques `b`. Une marque **inférieure à 2** commence un
**segment** à cet élément. Mets dans `c`, pour chaque élément, le total des valeurs de son segment jusqu'à lui, à
l'intérieur de chaque groupe de 256 (un groupe repart de zéro à son propre bord).

Le total de la dernière énigme traversait tout un groupe. Celui-ci doit repartir à chaque début, et aucun fil ne voit où
commencent les segments des autres ; chaque élément calcule donc un **numéro de segment** : le nombre de débuts jusqu'à lui
compris. C'est un total courant de 1 et de 0, le scan des dernières énigmes. Ensuite un élément totalise les éléments qui
le précèdent ou le sont lui-même et partagent son numéro de segment :

    in a
    in b
    out c
    shared t 256
    shared s 256
    shared r 256
    stage { @t[@l] = @a }
    stage { @s[@l] = when(@b < 2, 1, 0) }
    stage { @r[@l] = sum(j, 0, 256, when(j <= @l, @s[j], 0)) }

Écris le corps. Il existe une deuxième bonne réponse qui compte les débuts strictement avant un élément et rajoute son
propre début quand elle compare les numéros ; trouve-la. Le vérificateur accepte les deux et nomme l'élément où une réponse
proche se trompe : celle qui oublie les remises à zéro (le total courant simple), celle qui compare les marques elles-mêmes
et non les numéros de segment, et celle qui ne compte que les débuts avant un élément, si bien qu'un début rejoint le
segment précédent.

**Ce que le GPU a fait autrement qu'une boucle :** une boucle garde un seul total courant et le remet à zéro quand elle
rencontre un début ; elle doit donc lire les éléments dans l'ordre. Ici chaque élément a appris son segment d'un décompte
et a totalisé les éléments antérieurs de son segment sans attendre aucun autre fil. Le `SegmentedScan` de la bibliothèque
range la remise à zéro dans le scan lui-même : des paires (début, total) sont combinées de sorte qu'un début jette ce qui
le précède, et le même scan en trois phases fonctionne alors sur tout un vecteur. `SegmentedReduce` garde le dernier total
de chaque segment : un nombre par segment.
