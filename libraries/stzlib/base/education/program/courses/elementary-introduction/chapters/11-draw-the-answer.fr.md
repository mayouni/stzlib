# Dessiner la réponse

*Introduction élémentaire · Chapitre 11 · Compétences SE-01 « Une image répondrait-elle plus vite qu'un nombre ? » et SE-02 « Où, et combien ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

`[ 3, 9, 15 ]` est une réponse correcte à « où est ring ? ». Ce n'est pas une réponse rapide. Une image met
la réponse là où l'œil est déjà. Softanza dessine ses réponses en texte : un dessin est donc quelque chose
qu'un programme peut afficher, qu'une page peut porter et qu'une garde peut vérifier, ligne par ligne.

## 1. Montrer où, pas seulement quelle position

```ring
o1 = new stzString("fjringljringdjringg")
? @@( o1.FindAll("ring") )
#--> [ 3, 9, 15 ]
? o1.vizFind("ring")
#--> fjringljringdjringg
#--> --^-----^-----^----
```

## 2. Avec les nombres sous les marques

```ring
? o1.vizFindXT("ring", [ :Numbered = TRUE ])
#--> fjringljringdjringg
#--> --^-----^-----^----
#--> 3     9     15
```

## 3. Un graphe est une image de relations

Une commande atteint la cuisine, et la cuisine atteint la table. Le graphe répond aux questions, puis se
dessine lui-même.

```ring
oG = new stzGraph("kitchen")
oG {
	AddNodeXT("order", "Order")
	AddNodeXT("kitchen", "Kitchen")
	AddNodeXT("table", "Table")
	Connect("order", "kitchen")
	Connect("kitchen", "table")
}
? oG.PathExists("order", "table")
#--> TRUE
? @@( oG.Neighbors("kitchen") )
#--> [ "table" ]
oG.Show()
#--> │ Order │
#--> │ Table │
```

## 4. Combien : une barre par plat

```ring
oP = new stzHBarPlot([ :tea = 6, :rice = 3, :fish = 2 ])
oP.Show()
#--> Tea │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇
#--> Fish │ ▇▇▇▇▇▇
```

## 5. Les mêmes barres, debout

```ring
oP2 = new stzVBarPlot([ :tea = 6, :rice = 3, :fish = 2 ])
oP2.SetHeight(4)
oP2.Show()
#--> Tea Rice Fish
```

Les cartes ont leur place ici aussi : Softanza dessine des données sur la carte d'un lieu réel, et choisit
la projection qui ne ment pas sur elles. C'est le niveau praticien de cette compétence, et un cours ultérieur.

{{exercise:ex-11-01}}

{{exercise:ex-11-02}}

## Récapitulatif

- **Acquis :** vous avez dessiné où se trouve un mot, dessiné un graphe de trois relations et lui avez posé
  une question, et dessiné les commandes de trois plats en barres, couchées puis debout.
- **Pourquoi c'est important :** le rendu est l'instrument. Un nombre peut être juste et rester illisible ;
  une image se lit d'un coup, et une image faite de texte peut encore être vérifiée par une garde.
- **La suite :** enseigner à Softanza ce que sait votre lieu de travail, pour qu'il puisse raisonner dessus.
