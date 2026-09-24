# Quand le code rencontre les cellules

*Introduction élémentaire · Chapitre 10 · Compétence PA-04 : « Quelles cellules répondent à ma question ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Le menu d'un restaurant est une table : une ligne par plat, une colonne par information sur lui. `stzTable`
la porte, la dessine, et répond aux questions par colonne, par ligne et par cellule. Et une colonne est une
liste : tout ce que vous avez demandé à une liste dans les premiers chapitres peut être demandé à une colonne.

## 1. Construire la table, et la regarder

La première ligne nomme les colonnes. Exécutez la cellule pour voir la table dessinée.

```ring
oT = new stzTable([
	[ :DISH, :PRICE, :ORDERS ],
	[ "tea",  200, 6 ],
	[ "rice", 500, 3 ],
	[ "fish", 900, 2 ]
])
oT.Show()
```

## 2. Sa forme

```ring
? oT.NumberOfRows()
#--> 3
? oT.NumberOfCols()
#--> 3
? @@( oT.ColNames() )
#--> [ "dish", "price", "orders" ]
```

## 3. Une colonne, une ligne

```ring
? @@( oT.Col(:PRICE) )
#--> [ 200, 500, 900 ]
? @@( oT.Row(2) )
#--> [ "rice", 500, 3 ]
```

## 4. Une cellule, et où se trouve une valeur

```ring
? oT.Cell(:PRICE, 3)
#--> 900
? @@( oT.FindInCol(:DISH, "fish") )
#--> [ 3 ]
```

## 5. Une colonne est une liste : posez-lui les questions des listes

```ring
? StzListQ(oT.Col(:ORDERS)).Sum()
#--> 11
? @@( StzListQ(oT.Col(:PRICE)).FindW("{ @item > 400 }") )
#--> [ 2, 3 ]
```

{{exercise:ex-10-01}}

## Récapitulatif

- **Acquis :** vous avez construit une table à partir de lignes, lu sa forme, pris une colonne, une ligne et
  une cellule, trouvé une valeur dans une colonne, et posé à une colonne les questions du chapitre 7.
- **Pourquoi c'est important :** la plupart des données du monde arrivent en tables. Savoir qu'une colonne
  est une liste, c'est déjà savoir l'interroger.
- **La suite :** certaines réponses sont mieux dessinées qu'affichées.
