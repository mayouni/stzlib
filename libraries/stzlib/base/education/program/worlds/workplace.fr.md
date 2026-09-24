# Le restaurant

Bella Cucina, un petit restaurant, et le monde sur lequel ce cours s'exécute sauf si vous en choisissez un autre. La
cuisine reçoit des commandes ; chaque commande demande un plat, et les plats contiennent des ingrédients. Cette page
est le monde lui-même, interrogé : chaque cellule s'exécute sur `worlds/workplace.zknw`, le simple fichier sur lequel
les chapitres raisonnent, et la page ne stocke rien.

## 1. Son nom

La première chose qu'un monde dit, c'est ce qu'il est.

```ring
? EduWorldName()
#--> bella-cucina (restaurant)
```

## 2. Ce qui a été demandé

Six commandes sont arrivées aujourd'hui. Certaines demandent le même plat : c'est pourquoi le chapitre 1 retire les
doublons et le chapitre 5 compte la demande la plus fréquente.

```ring
aReq = EduWorldObjects("requested")
? len(aReq)
#--> 6
? @@( aReq )
#--> [ "margherita", "tiramisu", "margherita", "lasagna", "tiramisu", "margherita" ]
o1 = new stzList(aReq)
? @@( o1.DuplicatesRemoved() )
#--> [ "margherita", "tiramisu", "lasagna" ]
? StzListQ(aReq).NumberOfOccurrence("margherita")
#--> 3
```

## 3. Ce qu'un plat contient

Le monde sait plus que les commandes : ce que contient chaque plat, et quel plat contient un ingrédient donné.

```ring
? @@( EduWorld().Query([ "margherita", "contains", "?what" ]) )
#--> [ "tomato", "mozzarella" ]
? @@( EduWorld().Query([ "?dish", "contains", "beef" ]) )
#--> [ "lasagna" ]
? @@( EduWorld().Query([ "tiramisu", "contains", "?what" ]) )
#--> [ "mascarpone" ]
```

## 4. Une question à laquelle il ne peut pas encore répondre

Qui a commandé les lasagnes ? Le monde dit ce que chaque commande demande, mais pas qui l'a passée : la réponse est
donc vide, pas devinée. Le chapitre 12 montre comment ajouter le fait manquant ; le chapitre 13 montre comment
Softanza vous interroge sur un manque comme celui-ci.

```ring
? @@( EduWorld().Query([ "?who", "placed", "order-4" ]) )
#--> [ ]
```
