# La question du manque

*Introduction élémentaire · Chapitre 13 · Compétences KN-03 « Que m'a demandé Softanza, et pourquoi ? » et KN-04 « Comment la bibliothèque appelle-t-elle ce que je veux dire ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Une demande vague reçoit une supposition de la plupart des systèmes. Softanza, elle, demande. Vous déclarez
ce qu'un monde complet doit contenir, et l'écart entre cet objectif et le monde devient la question suivante,
avec sa raison. Ce chapitre retourne aussi la même idée vers la bibliothèque elle-même : vous lui demandez
comment elle appelle ce que vous voulez dire.

## 1. Déclarer un objectif

Chaque plat doit dire ce qu'il contient. Deux plats, rien d'enregistré : deux manques.

```ring
oRest = new stzKnowledgeGraph("restaurant")
oRest.Know("margherita", "dish").Know("tiramisu", "dish")
oRest.AddConversationQ("setup").SetGoal(StzGoalQ().RequireEach("dish", "contains"))
? len( oRest.GapsIn("setup") )
#--> 2
```

## 2. Softanza demande, et dit pourquoi

```ring
aQ = oRest.AskInXT("setup")
? aQ[:question]
#--> What does 'margherita' have for 'contains'?  (why: every dish needs 'contains')
```

## 3. Vous répondez avec des mots, et le monde grandit

```ring
aV = oRest.ReplyIn("setup", "tomato and mozzarella")
? @@( aV[:admitted] )
#--> [ "tomato", "mozzarella" ]
? @@( oRest.Query([ "margherita", "contains", "?o" ]) )
#--> [ "tomato", "mozzarella" ]
? len( oRest.GapsIn("setup") )
#--> 1
```

## 4. La question suivante propose ce qu'elle sait déjà

```ring
aQ2 = oRest.AskInXT("setup")
? aQ2[:question]
#--> Which 'contains' does 'tiramisu' have? (1) tomato  (2) mozzarella -- or answer freely.  (why: every dish needs 'contains')
```

## 5. Demander à la bibliothèque comment elle appelle ce que vous voulez dire

La bibliothèque se décrit elle-même. `HowTo` transforme une intention en appel, et dit comment elle y est
arrivée.

```ring
oDoc = StzSelfDocQ("stzList")
? oDoc.HowTo("remove duplicates")
#--> Q([...]).RemoveDuplicates()   -- composed by grammar (remove duplicates)
? oDoc.HasMethod("DuplicatesRemoved")
#--> TRUE
```

## 6. Expliquer une méthode, et refuser une méthode inconnue

```ring
? StzLeft( oDoc.ExplainMethod("DuplicatesRemoved"), 20 )
#--> DuplicatesRemoved --
? oDoc.ExplainMethod("NoSuchThing")
#--> No method 'NoSuchThing' in stzList.
```

{{exercise:ex-13-01}}

{{exercise:ex-13-02}}

## Récapitulatif

- **Acquis :** vous avez déclaré un objectif, reçu la question du manque avec sa raison, répondu avec des
  mots, vu la question suivante proposer ce qui était connu, et demandé à la bibliothèque de nommer une
  méthode d'après votre intention.
- **Pourquoi c'est important :** un système qui demande vous apprend ce dont un modèle complet a besoin. Un
  système qui devine vous le cache.
- **La suite :** un agent qui propose et ne peut pas agir.
