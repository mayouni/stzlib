# Marcher, demander, produire, agir

*Introduction élémentaire · Chapitre 6 · Compétence FO-02 : « Laquelle des quatre actions est cette étape ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Tout programme est fait de quatre gestes. Il **marche** à travers des positions, il **demande** en posant des
questions, il **produit** de nouvelles valeurs, et il **agit** sur les données. Softanza nomme chaque geste,
si bien qu'une tâche se décompose en gestes et non en boucles.

## 1. Marcher : les positions, puis ce qui s'y trouve

La cuisine vérifie une commande sur trois. D'abord les positions, puis les commandes à ces positions.

```ring
aOrders = [ "tea", "rice", "tea", "fish", "rice", "tea", "soup", "tea", "rice" ]
? @@( StzListQ([ 1, 2, 3, 4, 5, 6, 7, 8, 9 ]).FindW("@item % 3 = 1") )
#--> [ 1, 4, 7 ]
? @@( StzListQ(aOrders).ItemsAtPositions([ 1, 4, 7 ]) )
#--> [ "tea", "fish", "soup" ]
```

## 2. Demander : une question répond TRUE ou FALSE

```ring
? StzListQ(aOrders).Contains("soup")
#--> TRUE
? Q("cold").IsLowercase()
#--> TRUE
```

## 3. Produire : un producteur fabrique de nouvelles valeurs à partir des anciennes

La recette du jour, un remboursement écrit en nombre négatif. Un producteur filtre, transforme et réduit sans
qu'une seule boucle soit écrite.

```ring
oY = new stzYielder([ 12, 0, 30, -5, 18 ])
? @@( oY.Filter(:IsPositive) )
#--> [ 12, 30, 18 ]
? @@( oY.Map(:Double) )
#--> [ 24, 0, 60, -10, 36 ]
? oY.Reduce(:Sum)
#--> 55
```

## 4. Les gestes s'enchaînent

Filtrer, puis réduire : le total des vraies ventes.

```ring
? oY.FilterQ(:IsPositive).Reduce(:Sum)
#--> 60
```

## 5. Agir : un verbe change les données

```ring
oL = new stzList(aOrders)
oL.RemoveAll("tea")
? @@( oL.Content() )
#--> [ "rice", "fish", "rice", "soup", "rice" ]
```

## 6. Une condition peut être transmise comme une donnée

`ItemsW` prend la question elle-même comme argument. Le chapitre suivant porte là-dessus.

```ring
? @@( StzListQ([ 12, 0, 30, -5, 18 ]).ItemsW("@item > 0") )
#--> [ 12, 30, 18 ]
```

Softanza possède aussi un objet marcheur dédié, `stzWalker`, avec des pas, des directions et un historique.
Il vit dans le niveau `max` de la bibliothèque, que ce cours ne charge pas ; il n'est donc pas montré ici.

{{exercise:ex-06-01}}

## Récapitulatif

- **Acquis :** vous avez trié une tâche en marcher (des positions), demander (des questions), produire (un
  producteur) et agir (un verbe), et vous les avez enchaînés sans boucle.
- **Pourquoi c'est important :** une boucle cache quel geste elle fait. Nommer le geste rend un programme
  lisible par quelqu'un qui ne l'a pas écrit.
- **La suite :** déclarer ce que vous voulez et laisser le moteur décider comment.
