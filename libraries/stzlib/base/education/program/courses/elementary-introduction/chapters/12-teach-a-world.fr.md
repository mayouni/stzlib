# Enseigner un monde

*Introduction élémentaire · Chapitre 12 · Compétences KN-01 « Que sait mon lieu de travail, et comment l'écrire ? » et KN-02 « Que découle de ce que j'ai écrit ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Softanza ne sait rien de votre restaurant, de votre banque ou de votre école tant que vous ne le lui dites
pas. Un **monde**, c'est ce que vous lui dites : des faits, écrits en trois mots chacun, et quelques lois sur
les relations entre eux. Une fois qu'un monde existe, Softanza peut répondre à des questions dessus, et
prouver ses réponses.

## 1. Énoncer des faits

Un fait, c'est *sujet, relation, objet*. `Know` dit ce qu'une chose est ; `KnowRelation` dit toute autre
relation.

```ring
oKB = new stzKnowledgeGraph("menu")
oKB.Know("margherita", "dish").Know("tiramisu", "dish").Know("pizza", "dish")
oKB.KnowRelation("margherita", "kind-of", "pizza")
oKB.KnowRelation("pizza", "kind-of", "food")
oKB.KnowRelation("margherita", "contains", "tomato")
? @@( oKB.Query([ "?x", "is-a", "dish" ]) )
#--> [ "margherita", "tiramisu", "pizza" ]
? @@( oKB.Query([ "margherita", "contains", "?o" ]) )
#--> [ "tomato" ]
```

## 2. Une requête répond d'après ce qui a été enregistré

Personne n'a enregistré qu'une margherita est une sorte d'aliment. Une requête ne dit que ce qui a été écrit.

```ring
? @@( oKB.Query([ "margherita", "kind-of", "?o" ]) )
#--> [ "pizza" ]
```

## 3. Une loi rend le raisonnement possible

`kind-of` s'enchaîne : une margherita est une sorte de pizza, une pizza est une sorte d'aliment. Déclarez
la relation transitive, et `Prove` suit la chaîne et montre chaque étape.

```ring
oKB.ConstrainRelation("kind-of", :Transitive)
aProof = oKB.Prove([ "margherita", "kind-of", "food" ])
? aProof[:verdict]
#--> TRUE
? aProof[:narration]
#--> proved: margherita kind-of pizza kind-of food
```

## 4. Un monde est un fichier que vous pouvez lire

```ring
? oKB.ExportToKnow()
#--> knowledge "menu"
#--> margherita | is-a | dish
#--> margherita | contains | tomato
#--> kind-of | transitive
```

## 5. Le monde sur lequel ce cours s'exécute

Les chapitres de ce cours raisonnent sur un fichier de monde. Le voici, interrogé. Ce qui s'affiche dépend
du monde : exécutez la cellule.

```ring
? EduWorldName()
? @@( EduWorld().Query([ "?o", "requested", "?d" ]) )
```

{{exercise:ex-12-01}}

{{exercise:ex-12-02}}

## Récapitulatif

- **Acquis :** vous avez énoncé des faits en trois mots chacun, les avez interrogés, déclaré une relation
  transitive, et fait prouver une chaîne à Softanza en narrant chaque étape ; puis vous avez vu le monde
  comme le simple fichier qu'il est.
- **Pourquoi c'est important :** Softanza ne connaît pas les faits du monde. Il connaît *votre* monde, et
  seulement ce que vous lui avez enseigné : c'est pourquoi ses réponses remontent à une ligne que vous avez
  écrite.
- **La suite :** quand le monde a un manque, Softanza vous pose la question.
