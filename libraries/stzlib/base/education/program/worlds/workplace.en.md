# The restaurant

Bella Cucina, a small restaurant, and the world this course runs over unless you choose another. The
kitchen receives orders; each order asks for a dish, and dishes contain ingredients. This page is the
world itself, questioned: every cell runs over `worlds/workplace.zknw`, the plain file the chapters
reason over, and the page stores nothing.

## 1. Its name

The first thing a world says is what it is.

```ring
? EduWorldName()
#--> bella-cucina (restaurant)
```

## 2. What was requested

Six orders came in today. Some ask for the same dish, which is why chapter 1 removes the duplicates and
chapter 5 counts the most requested.

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

## 3. What a dish contains

The world knows more than orders: what each dish contains, and which dish contains a given ingredient.

```ring
? @@( EduWorld().Query([ "margherita", "contains", "?what" ]) )
#--> [ "tomato", "mozzarella" ]
? @@( EduWorld().Query([ "?dish", "contains", "beef" ]) )
#--> [ "lasagna" ]
? @@( EduWorld().Query([ "tiramisu", "contains", "?what" ]) )
#--> [ "mascarpone" ]
```

## 4. A question it cannot answer yet

Who ordered the lasagna? The world says what each order requested, but not who placed it, so the
answer is empty, not a guess. Chapter 12 shows how you add the missing fact; chapter 13 shows how
Softanza asks you about a gap like this one.

```ring
? @@( EduWorld().Query([ "?who", "placed", "order-4" ]) )
#--> [ ]
```
