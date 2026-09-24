# L'école

Un lycée de Niamey. Les familles et les élèves viennent au bureau pour des relevés de notes, des manuels, une place
dans une classe et des certificats. Cette page est le monde lui-même, interrogé : chaque cellule s'exécute sur
`worlds/school.zknw`, le simple fichier sur lequel les chapitres raisonnent quand vous choisissez ce monde, et la page
ne stocke rien.

## 1. Son nom

La première chose qu'un monde dit, c'est ce qu'il est.

```ring
? EduWorldName()
#--> lycee-de-niamey (school)
```

## 2. Ce qui a été demandé

Sept demandes sont arrivées au bureau cette semaine. Certaines demandent la même chose : c'est pourquoi le
chapitre 1 retire les doublons et le chapitre 5 compte la demande la plus fréquente.

```ring
aReq = EduWorldObjects("requested")
? len(aReq)
#--> 7
? @@( aReq )
#--> [ "transcript", "textbook", "transcript", "enrolment", "certificate", "textbook", "transcript" ]
o1 = new stzList(aReq)
? @@( o1.DuplicatesRemoved() )
#--> [ "transcript", "textbook", "enrolment", "certificate" ]
? StzListQ(aReq).NumberOfOccurrence("transcript")
#--> 3
```

## 3. Quelle matière, quelle classe

Le monde sait plus que les demandes : quelle matière est enseignée dans quelle classe, et qui dirige chaque classe.

```ring
? @@( EduWorld().Query([ "?subject", "taught-in", "class-3a" ]) )
#--> [ "mathematics", "physics" ]
? @@( EduWorld().Query([ "history", "taught-in", "?class" ]) )
#--> [ "class-3b" ]
? @@( EduWorld().Query([ "class-3b", "led-by", "?who" ]) )
#--> [ "m-issoufou" ]
```

## 4. Une question à laquelle il ne peut pas encore répondre

Qui enseigne l'histoire ? Le monde dit dans quelle classe l'histoire est enseignée et qui dirige cette classe, mais
pas qui enseigne la matière : la réponse est donc vide, pas devinée. Le chapitre 12 montre comment ajouter le fait
manquant ; le chapitre 13 montre comment Softanza vous interroge sur un manque comme celui-ci.

```ring
? @@( EduWorld().Query([ "history", "taught-by", "?who" ]) )
#--> [ ]
```
