# La coopérative

Une coopérative agricole de la plaine de Tillabéri. Ses membres apportent ce qu'ils cultivent et demandent à la
coopérative des semences, de l'engrais, du crédit et une place pour stocker la récolte. Cette page est le monde
lui-même, interrogé : chaque cellule s'exécute sur `worlds/cooperative.zknw`, le simple fichier sur lequel les
chapitres raisonnent quand vous choisissez ce monde, et la page ne stocke rien.

## 1. Son nom

La première chose qu'un monde dit, c'est ce qu'il est.

```ring
? EduWorldName()
#--> tillaberi-cooperative (cooperative)
```

## 2. Ce qui a été demandé

Sept demandes sont arrivées cette saison. Certaines demandent la même chose : c'est pourquoi le chapitre 1 retire
les doublons et le chapitre 5 compte la demande la plus fréquente.

```ring
aReq = EduWorldObjects("requested")
? len(aReq)
#--> 7
? @@( aReq )
#--> [ "seed", "fertiliser", "seed", "credit", "storage", "seed", "credit" ]
o1 = new stzList(aReq)
? @@( o1.DuplicatesRemoved() )
#--> [ "seed", "fertiliser", "credit", "storage" ]
? StzListQ(aReq).NumberOfOccurrence("seed")
#--> 3
```

## 3. Qui cultive quoi

Le monde sait plus que les demandes : quel membre cultive quelle culture, et où chaque culture est stockée.

```ring
? @@( EduWorld().Query([ "?who", "grows", "millet" ]) )
#--> [ "amadou", "issa" ]
? @@( EduWorld().Query([ "hadiza", "grows", "?what" ]) )
#--> [ "cowpea" ]
? @@( EduWorld().Query([ "cowpea", "stored-in", "?where" ]) )
#--> [ "granary-2" ]
```

## 4. Une question à laquelle il ne peut pas encore répondre

Qui a demandé le crédit ? Le monde ne dit pas qui a fait chaque demande, donc la réponse est vide, pas devinée.
Le chapitre 12 montre comment ajouter le fait manquant ; le chapitre 13 montre comment Softanza vous interroge sur un
manque comme celui-ci.

```ring
? @@( EduWorld().Query([ "hadiza", "requested", "?what" ]) )
#--> [ ]
```
