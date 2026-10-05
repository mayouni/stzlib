# Un nombre qui dit pourquoi il n'est pas exact

*Mathématiques · Chapitre 7 · Compétence CR-03 : « Pourquoi a-t-il dit non ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Le nombre d'une machine est une boîte de taille fixe, et une valeur qui n'y tient pas est arrondie pour y
tenir, en silence. Un dixième n'y tient pas. Le nombre de Softanza est différent d'une façon qui change tout :
il sait s'il est exact, et quand il ne l'est pas, il peut dire ce qui a été perdu et où. Ce chapitre rencontre
d'abord le nombre de la machine, puis le nombre exact, et laisse celui-ci s'expliquer.

## 1. Le nombre de la machine, pris sur le fait

Additionnez un dixième et deux dixièmes sur la machine et demandez si le résultat est trois dixièmes. La
machine dit non, et affiche une valeur qui ressemble à oui. Les deux réponses viennent du même arrondi.

```ring
? 0.1 + 0.2 = 0.3
#--> 0
? 0.1 + 0.2
#--> 0.30
```

## 2. Le nombre exact

Donnez les nombres comme du texte et la bibliothèque les garde comme des décimaux. La somme est trois
dixièmes, exacte, et le nombre dit quelle représentation il porte.

```ring
oS = StzNumberQ("0.1")
oS.Add("0.2")
? oS.Content()
#--> 0.3
? oS.IsExact()
#--> 1
? oS.Representation()
#--> decimal
```

## 3. Égaux comme nombres, non comme texte

Trois dixièmes et trente centièmes sont le même nombre et un texte différent. Le nombre exact compare comme
un nombre ; le signe égal de Ring compare le texte.

```ring
? oS.Same("0.30")
#--> 1
? "0.3" = "0.30"
#--> 0
```

## 4. Une division qui ne peut pas finir

Un divisé par trois ne finit jamais. Le nombre s'arrête à six décimales, dit qu'il n'est pas exact, et dit
pourquoi.

```ring
oT = StzNumberQ("1")
oT.Divide("3")
? oT.Content()
#--> 0.333333
? oT.IsExact()
#--> 0
? oT.WhyNotExact()
#--> the division does not terminate in 6 decimal place(s)
```

## 5. Gardez-le comme fraction, et rien n'est perdu

Écrit un sur trois, le nombre est rationnel et exact. Ajoutez deux tiers et le résultat est un, et le nombre
dit qu'il est le même que un.

```ring
oQ = StzNumberQ("1/3")
? oQ.Representation()
#--> rational
? oQ.IsExact()
#--> 1
oQ.Add("2/3")
? oQ.Content()
#--> 1
? oQ.Same(1)
#--> 1
```

## 6. Au-delà du plus grand nombre impair de la machine

Le nombre de la machine ne peut pas tenir tous les entiers au-delà de neuf millions de milliards : ajoutez un
à un nombre impair là-haut et il retombe sur un pair. Le grand entier de la bibliothèque le tient.

```ring
oB = StzNumberQ("9007199254740993")
? oB.Representation()
#--> biginteger
oB.Add(1)
? oB.Content()
#--> 9007199254740994
? 9007199254740993 + 1
#--> 9007199254740992.00
```

## 7. Trois dixièmes, trois façons

Un dixième fois trois fait trois dixièmes pour le nombre exact, et pas pour la machine.

```ring
oM = StzNumberQ("0.1")
oM.MultiplyBy("3")
? oM.Content()
#--> 0.3
? oM.IsExact()
#--> 1
? 0.1 * 3 = 0.3
#--> 0
```

## 8. Sur votre monde

La part des relevés de notes parmi les demandes de votre école, comme division exacte : le nombre dit si la
part se termine, et pourquoi pas quand elle ne se termine pas. Ce qu'elle affiche dépend du monde sur lequel
ce cours s'exécute, aussi la page ne montre aucun résultat : exécutez-la.

```ring
aReq = EduWorldObjects("requested")
nT = StzListQ(aReq).NumberOfOccurrence("transcript")
oW = StzNumberQ("" + nT)
oW.Divide("" + len(aReq))
? EduWorldName()
? oW.Content()
? oW.IsExact()
? oW.WhyNotExact()
```

{{exercise:math-07-01}}

## Récapitulatif

- **Acquis :** vous avez pris le nombre de la machine à arrondir un dixième, additionné les mêmes dixièmes
  exactement, comparé des nombres comme des nombres, divisé un par trois et lu pourquoi le résultat n'est pas
  exact, gardé un tiers comme fraction sans rien perdre, et dépassé le plus grand nombre impair de la machine.
- **Pourquoi c'est important :** un nombre qui dit pourquoi il n'est pas exact transforme un arrondi
  silencieux en une phrase que vous pouvez lire. L'argent, dans un chapitre à venir, est là où cette phrase
  coûte un centime quand elle manque.
- **La suite :** les matrices comme images. Le chapitre suivant dessine un produit en trois grilles et en
  vérifie une cellule à la main.
