# Teach a world

*Elementary Introduction · Chapter 12 · Skills KN-01 "What does my workplace know, and how do I write it down?" and KN-02 "What follows from what I wrote down?"*

Softanza knows nothing about your restaurant, your bank or your school until you tell it. A **world** is what
you tell it: facts, written as three words each, and a few laws about the relations between them. Once a
world exists, Softanza can answer questions over it, and prove the answers.

## 1. State facts

A fact is *subject, relation, object*. `Know` states what a thing is; `KnowRelation` states any other relation.

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

## 2. A query answers from what was recorded

Nobody recorded that a margherita is a kind of food. A query says only what was written.

```ring
? @@( oKB.Query([ "margherita", "kind-of", "?o" ]) )
#--> [ "pizza" ]
```

## 3. A law makes reasoning possible

`kind-of` chains: a margherita is a kind of pizza, a pizza is a kind of food. Declare the relation
transitive, and `Prove` follows the chain and shows every step.

```ring
oKB.ConstrainRelation("kind-of", :Transitive)
aProof = oKB.Prove([ "margherita", "kind-of", "food" ])
? aProof[:verdict]
#--> TRUE
? aProof[:narration]
#--> proved: margherita kind-of pizza kind-of food
```

## 4. A world is a file you can read

```ring
? oKB.ExportToKnow()
#--> knowledge "menu"
#--> margherita | is-a | dish
#--> margherita | contains | tomato
#--> kind-of | transitive
```

## 5. The world this course runs over

The chapters of this course reason over a world file. Here it is, questioned. What it prints depends on
the world, so run it.

```ring
? EduWorldName()
? @@( EduWorld().Query([ "?o", "requested", "?d" ]) )
```

{{exercise:ex-12-01}}

{{exercise:ex-12-02}}

## Recap

- **Achieved:** you stated facts as three words each, queried them, declared one relation transitive, and
  had Softanza prove a chain and narrate each step; then you saw the world as the plain file it is.
- **Why it matters:** Softanza does not know the world's facts. It knows *your* world, and only what you
  taught it, which is why its answers can be traced to a line you wrote.
- **Coming next:** when the world has a gap, Softanza asks you about it.
