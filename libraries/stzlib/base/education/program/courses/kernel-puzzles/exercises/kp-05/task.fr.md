### Énigme 5 · Les fils qui n'ont pas d'élément

> Traduction provisoire, en attente de relecture par un locuteur natif.

Double encore un vecteur de 4 000 nombres -- mais cette fois c'est TOI qui écris la garde de bornes.

Les fils viennent par groupes de 256. Pour 4 000 éléments l'appareil lance 16 groupes : 4 096 fils,
et les 96 derniers n'ont pas d'élément. Un fil au-delà de la fin ne doit pas écrire. La garde est une
ligne à part, une condition sur `@i` (le numéro du fil) et `n` (le nombre d'éléments) :

    in a
    out c
    guard { @i < n }

Essaie l'énigme de trois façons. Avec la garde : *verified*. Avec `guard none` : les 96 fils en trop
écrivent au-delà de la région, dans la marge du vérificateur, et le verdict nomme le premier :
*write-outside at element 4001*. Avec `guard { @i < n - 1 }` : l'élément 4000 n'est jamais écrit, et
le verdict est *mismatch at element 4000*. Le vérificateur distingue les deux erreurs.

**Ce que le GPU a fait autrement qu'une boucle :** une boucle s'arrête quand elle atteint la fin. Le
GPU ne s'arrête jamais ; il lance un groupe entier à la fois, et les fils au-delà de la fin existent
que tu le veuilles ou non. La garde est la façon de leur dire de se taire.
