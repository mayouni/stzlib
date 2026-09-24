# Un objet, toute structure

*Introduction élémentaire · Chapitre 5 · Compétence FO-03 : « Est-ce la même question que j'ai posée à une liste, posée maintenant à une chaîne ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Le chapitre 1 posait trois questions à une liste : contient-elle, combien, et où. Ce chapitre pose les trois
mêmes questions à une chaîne, avec les mêmes mots. La structure change ; la pensée, non.

## 1. Les trois questions, posées à une chaîne

```ring
oS = new stzString("tea rice tea fish")
? oS.Contains("tea")
#--> TRUE
? oS.NumberOfOccurrence("tea")
#--> 2
? @@( oS.FindAll("tea") )
#--> [ 1, 10 ]
```

## 2. Les trois mêmes questions, posées à une liste

```ring
oL = new stzList([ "tea", "rice", "tea", "fish" ])
? oL.Contains("tea")
#--> TRUE
? oL.NumberOfOccurrence("tea")
#--> 2
? @@( oL.FindAll("tea") )
#--> [ 1, 3 ]
```

## 3. Mêmes mots, unités différentes

Une position dans une chaîne compte des caractères ; une position dans une liste compte des éléments. La
question est la même, la règle graduée ne l'est pas.

```ring
? StzLen("tea rice tea fish")
#--> 17
? oL.NumberOfItems()
#--> 4
```

## 4. Une seule fonction pour les deux

`StzFind` prend d'abord ce que vous cherchez, puis l'endroit où vous le cherchez.

```ring
? @@( StzFind("tea", "tea rice tea fish") )
#--> [ 1, 10 ]
? @@( StzFind("tea", [ "tea", "rice", "tea", "fish" ]) )
#--> [ 1, 3 ]
```

## 5. Agir de la même façon, et lire le résultat avec soin

Retirer un mot d'une chaîne laisse les espaces qui l'entouraient. Retirer un élément d'une liste ne laisse
rien. Le même verbe, une différence honnête.

```ring
? @@( oS.Removed("tea") )
#--> " rice  fish"
oL.RemoveAll("tea")
? @@( oL.Content() )
#--> [ "rice", "fish" ]
```

## 6. Votre lieu de travail, des deux façons

La chose la plus demandée sur votre lieu de travail, comptée dans la liste des demandes et dans ces mêmes
demandes réunies en une phrase. Exécutez la cellule : la réponse dépend du monde.

```ring
aReq = EduWorldObjects("requested")
? StzListQ(aReq).NumberOfOccurrence(aReq[1])
? Q( Q(aReq).Joined(" ") ).NumberOfOccurrence(aReq[1])
```

{{exercise:ex-05-01}}

## Récapitulatif

- **Acquis :** vous avez posé contient, combien et où à une chaîne et à une liste avec les mêmes mots, et
  vu où les réponses diffèrent, dans l'unité et dans ce que le retrait laisse derrière lui.
- **Pourquoi c'est important :** une seule façon de penser couvre toutes les structures. Quand une table ou
  un graphe arrivera, vous connaîtrez déjà les questions.
- **La suite :** les quatre gestes dont tout programme est fait : marcher, demander, produire, agir.
