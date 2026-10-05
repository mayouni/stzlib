# La probabilité par le continuum des quantificateurs

*Mathématiques · Chapitre 10 · Compétence KN-02 : « Qu'est-ce qui découle de ce que j'ai écrit ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Avant d'avoir des nombres, la probabilité avait des mots : aucun, quelques-uns, certains, la moitié,
beaucoup, la plupart, tous. Softanza garde ces mots comme des quantificateurs sur une liste, et ils forment
un continuum dont la bibliothèque tient l'ordre. Une probabilité est alors une proportion que vous pouvez
lire sur ce continuum, et mille lancers amorcés d'une pièce sont une proportion que vous pouvez compter. Ce
chapitre parcourt le continuum, lance la pièce, jette le dé, et place ce qu'il a vu sur une droite numérique.

## 1. Le continuum, dans l'ordre

Chaque quantificateur prend une part d'une liste : quelques-uns une petite part, certains une plus grande, la
plupart presque tout. Quelle que soit la part, l'ordre tient, et la bibliothèque le vérifie sur dix nombres.

```ring
aTen = 1:10
? len( Few(aTen) ) < len( Some(aTen) )
#--> 1
? len( Some(aTen) ) < len( Most(aTen) )
#--> 1
? len( All(aTen) )
#--> 10
? len( No(aTen) )
#--> 0
```

## 2. La moitié, exactement

La moitié de dix est cinq. Le compte du quantificateur est un nombre que la bibliothèque calcule, jamais une
estimation.

```ring
? len( Half(aTen) )
#--> 5
```

## 3. Mille lancers d'une pièce équilibrée

Une graine rend les lancers identiques à chaque fois, si bien qu'une promesse peut être faite sur le hasard.
La probabilité de pile d'une pièce équilibrée est un demi ; mille lancers avec la graine trois donnent cinq
cent quatre piles, à moins de cinq centièmes d'un demi.

```ring
SeedRandom(3)
nHeads = 0
for i = 1 to 1000
	if StzRandom01() < 0.5  nHeads++  ok
next
? nHeads
#--> 504
? fabs( nHeads / 1000 - 0.5 ) < 0.05
#--> 1
```

## 4. Soixante jets d'un dé

Chaque face a la probabilité un sixième, et soixante jets devraient montrer chaque face environ dix fois. La
table des fréquences compte ce que les jets amorcés ont réellement donné : chaque face est apparue, et aucune
aussi souvent que le hasard le lui permettrait.

```ring
SeedRandom(3)
aRolls = []
for i = 1 to 60
	aRolls + ( floor( StzRandom01() * 6 ) + 1 )
next
oD = new stzDataSet(aRolls)
? len( oD.FrequencyTable() )
#--> 6
? @@( oD.FrequencyTable() )
#--> [ "1", 16 ]
```

## 5. Ce qui a été vu, sur une droite

La proportion de piles est une place entre zéro et un. Dessinez-la sur une droite numérique à côté du demi de
la pièce équilibrée, et les deux sont proches sans être la même place : le hasard est ce qui les sépare.

```ring
oL = StzMathFigureQ(:NumberLine, [ :on = [ 0, 1 ], :step = 0.1,
                                   :points = [ [ 0.5, "fair" ], [ nHeads / 1000, "seen" ] ] ])
? oL.Why()
#--> a number line from 0 to 1: 11 ticks, 2 point(s), 0 jump(s)
```

## 6. Dix jets, comme une fraction

Sur dix jets amorcés, combien de six ? Le compte est une fraction de dix, coloriée.

```ring
SeedRandom(5)
nSixes = 0
for i = 1 to 10
	if floor( StzRandom01() * 6 ) + 1 = 6  nSixes++  ok
next
? nSixes
#--> 1
oF = StzMathFigureQ(:Fraction, [ :of = [ nSixes, 10 ], :label = "sixes in ten rolls" ])
? oF.Why()
#--> a fraction figure of 1 whole(s) as bars: 1 of 10 shaded
```

## 7. Sur votre monde

Parmi les demandes reçues par votre école cette semaine, quelle part demandait un relevé de notes, et est-ce
quelques-unes, certaines ou la plupart ? Ce qu'elle affiche dépend du monde sur lequel ce cours s'exécute,
aussi la page ne montre aucun résultat : exécutez-la.

```ring
aReq = EduWorldObjects("requested")
nT = StzListQ(aReq).NumberOfOccurrence("transcript")
? EduWorldName()
? nT / len(aReq)
```

{{exercise:math-10-01}}

## Récapitulatif

- **Acquis :** vous avez parcouru le continuum des quantificateurs d'aucun à tous et vu son ordre tenir,
  lancé une pièce amorcée mille fois et lu la proportion contre un demi, jeté un dé soixante fois et compté
  chaque face, placé la proportion sur une droite numérique et colorié dix jets comme une fraction.
- **Pourquoi c'est important :** le hasard n'est pas l'absence d'affirmation. Avec une graine, un lancer est
  un fait que vous pouvez promettre ; avec un compte, une probabilité est une proportion que vous pouvez
  vérifier.
- **La suite :** l'argent ne doit pas perdre un centime. Le chapitre suivant additionne et divise des montants
  avec les nombres exacts qui disent pourquoi ils ne sont pas exacts quand ils ne le sont pas.
