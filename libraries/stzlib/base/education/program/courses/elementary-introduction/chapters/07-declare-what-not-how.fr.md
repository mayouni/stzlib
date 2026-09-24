# Déclarer le quoi, pas le comment

*Introduction élémentaire · Chapitre 7 · Compétences FO-04 « Puis-je dire ce que je veux et laisser le moteur décider comment ? » et PA-03 « Puis-je transmettre la condition au lieu d'écrire le branchement ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Jusqu'ici vous nommiez une chose fixe : « tea », les doublons, la position 4. Ce chapitre nomme une
**condition**, et la transmet comme une donnée. Vous dites *ce qui* compte ; le moteur décide *comment*
parcourir la liste, tester chaque élément et rassembler la réponse. Le `W` à la fin d'un nom signifie
*where*, « où ».

## 1. Trouver où une condition est vraie

`@item` désigne chaque élément à son tour. La condition est un morceau de texte entre accolades.

```ring
o = new stzList([ 4, 7, 10, 3, 8 ])
? @@( o.FindW("{ @item > 5 }") )
#--> [ 2, 3, 5 ]
? @@( o.ItemsW("{ @item > 5 }") )
#--> [ 7, 10, 8 ]
? o.CountW("{ @item > 5 }")
#--> 3
```

## 2. N'importe quelle question peut être la condition

```ring
? @@( o.FindW("{ IsEven(@item) }") )
#--> [ 1, 3, 5 ]
? o.CheckW("{ isNumber(@item) }")
#--> TRUE
```

## 3. Une règle est une donnée : gardez-la, appliquez-la partout

La règle vit dans une variable. Deux listes, une règle, et la règle n'a jamais su quelle liste elle
rencontrerait.

```ring
cRule = "{ @item > 20 }"
oA = new stzList([ 12, 0, 30, -5, 18, 25 ])
oB = new stzList([ 3, 40, 9 ])
? oA.CountW(cRule)
#--> 2
? oB.CountW(cRule)
#--> 1
```

## 4. Agir là où la règle est vraie

```ring
? @@( oA.ItemsW(cRule) )
#--> [ 30, 25 ]
oA.RemoveW(cRule)
? @@( oA.Content() )
#--> [ 12, 0, -5, 18 ]
```

## 5. Le même mot sur des mots

```ring
oS = new stzList([ "ring", "PHP", "C#", "ruby", "GO" ])
? @@( oS.FindW("{ IsUppercase(@item) }") )
#--> [ 2, 3, 5 ]
? @@( oS.ItemsW("{ Q(@item).IsLowercase() }") )
#--> [ "ring", "ruby" ]
```

{{exercise:ex-07-01}}

{{exercise:ex-07-02}}

## Récapitulatif

- **Acquis :** vous avez trouvé, compté, gardé et retiré des éléments d'après une condition écrite une fois
  comme du texte, et appliqué une même règle à deux listes sans la changer.
- **Pourquoi c'est important :** une condition qui est une donnée peut être rangée dans un fichier, envoyée à
  un collègue, et appliquée à des données qui n'existaient pas quand elle a été écrite. Un branchement dans
  une boucle ne peut rien de tout cela.
- **La suite :** les conditions sur le texte ont leur propre langue, et elle s'appelle un motif.
