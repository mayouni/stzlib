# The cooperative

A farmers' cooperative on the Tillaberi plain. Its members bring what they grow, and they ask the
cooperative for seed, fertiliser, credit and a place to store the harvest. This page is the world itself,
questioned: every cell runs over `worlds/cooperative.zknw`, the plain file the chapters reason over when
you choose this world, and the page stores nothing.

## 1. Its name

The first thing a world says is what it is.

```ring
? EduWorldName()
#--> tillaberi-cooperative (cooperative)
```

## 2. What was requested

Seven requests came in this season. Some ask for the same thing, which is why chapter 1 removes the
duplicates and chapter 5 counts the most requested.

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

## 3. Who grows what

The world knows more than requests: which member grows which crop, and where each crop is stored.

```ring
? @@( EduWorld().Query([ "?who", "grows", "millet" ]) )
#--> [ "amadou", "issa" ]
? @@( EduWorld().Query([ "hadiza", "grows", "?what" ]) )
#--> [ "cowpea" ]
? @@( EduWorld().Query([ "cowpea", "stored-in", "?where" ]) )
#--> [ "granary-2" ]
```

## 4. A question it cannot answer yet

Who requested the credit? The world does not say who made each request, so the answer is empty, not a
guess. Chapter 12 shows how you add the missing fact; chapter 13 shows how Softanza asks you about a gap
like this one.

```ring
? @@( EduWorld().Query([ "hadiza", "requested", "?what" ]) )
#--> [ ]
```
