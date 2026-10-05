# La fraction

*Mathématiques · Chapitre 2 · Compétence PA-02 : « Quelle est la forme de cette liste ou de ces nombres ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Une fraction est une partie d'un tout : trois parts sur quatre parts égales, coloriées. Dit ainsi, c'est déjà
une image, et l'image répond plus vite que les nombres aux questions que l'on pose sur les fractions. Laquelle
des deux est la plus grande ? Ces deux-là sont-elles la même quantité ? Ce chapitre déclare des fractions comme
des figures, les colorie, les compare côte à côte, et lit chaque verdict deux fois : une fois sur l'image, une
fois par le calcul.

## 1. Trois sur quatre

Une figure de fraction se déclare par ce dont elle est la fraction. La figure construit un tout, le découpe en
parts égales et colorie ce que vaut le numérateur.

```ring
oF = StzMathFigureQ(:Fraction, [ :of = [ 3, 4 ], :label = "three of four" ])
? oF.Why()
#--> a fraction figure of 1 whole(s) as bars: 3 of 4 shaded
```

## 2. L'image se juge elle-même

Une figure de fraction porte trois règles : les parts coloriées sont le numérateur, les parts sont le
dénominateur, et les parts pavent le tout sans rien laisser. La figure les compte sur sa propre image.

```ring
? len( oF.Violations() )
#--> 0
```

## 3. Deux fractions côte à côte

Déclarées ensemble, deux fractions partagent une même largeur, si bien que l'œil les compare sans mesurer.
Entre chaque paire, la figure écrit son verdict.

```ring
oC = StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 4 ], [ 2, 3 ] ] ])
? oC.Why()
#--> a fraction figure of 2 whole(s) as bars: 3 of 4 shaded, 2 of 3 shaded
```

## 4. Le verdict, vérifié par le calcul

L'image dit que trois quarts est plus grand que deux tiers. Le calcul dit la même chose, par le produit en
croix : comparez trois fois trois avec deux fois quatre. Les deux côtés répondent un, qui est le mot de
Softanza pour vrai.

```ring
? 3 * 3 > 2 * 4
#--> 1
? 3/4 > 2/3
#--> 1
```

## 5. Deux noms pour une même quantité

Deux sur quatre et un sur deux colorient la même largeur. La figure écrit un signe égal entre elles, et les
produits en croix sont d'accord.

```ring
oE = StzMathFigureQ(:Fraction, [ :compare = [ [ 2, 4 ], [ 1, 2 ] ] ])
? oE.Why()
#--> a fraction figure of 2 whole(s) as bars: 2 of 4 shaded, 1 of 2 shaded
? 2 * 2 = 1 * 4
#--> 1
```

## 6. En disques

Les mêmes fractions peuvent être coloriées comme des secteurs d'un disque. Le verdict est la même image,
posée autrement.

```ring
oD = StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 8 ], [ 1, 4 ] ], :as = :disc ])
? oD.Why()
#--> a fraction figure of 2 whole(s) as discs: 3 of 8 shaded, 1 of 4 shaded
? 3 * 4 > 1 * 8
#--> 1
```

## 7. Ce que la figure refuse

Une figure de fraction montre une partie d'UN tout, aussi un numérateur plus grand que son dénominateur
est-il refusé nommément, et de même un dénominateur trop fin pour être dessiné.

```ring
try
	StzMathFigureQ(:Fraction, [ :of = [ 5, 4 ] ])
catch
	? "refused"
done
#--> refused
```

## 8. Sur votre monde

De toutes les demandes reçues par votre école cette semaine, quelle fraction demandait un relevé de notes ? Le
compte dépend du monde sur lequel ce cours s'exécute, aussi la page ne montre aucun résultat : exécutez-la.

```ring
aReq = EduWorldObjects("requested")
nT = StzListQ(aReq).NumberOfOccurrence("transcript")
oW = StzMathFigureQ(:Fraction, [ :of = [ nT, len(aReq) ], :label = "transcripts among the requests" ])
? EduWorldName()
? oW.Why()
```

{{exercise:math-02-01}}

## Récapitulatif

- **Acquis :** vous avez déclaré une fraction comme une figure coloriée, comparé deux fractions côte à côte, lu
  le verdict de la figure et l'avez vérifié par le produit en croix ; vous avez vu deux noms pour une même
  quantité, et ce que la figure refuse.
- **Pourquoi c'est important :** un verdict lu sur une image et un verdict calculé par l'arithmétique sont deux
  réponses indépendantes à une même question. Quand elles sont d'accord, vous pouvez faire confiance aux deux ;
  quand elles divergent, quelque chose est faux et vous le savez avant tout le monde.
- **La suite :** un jeu de hasard à trois coins et une seule règle dessine une forme que personne n'a dessinée.
  Le chapitre suivant y joue et compte ce qui apparaît.
