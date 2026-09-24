# One object, any structure

*Elementary Introduction · Chapter 5 · Skill FO-03: "Is this the same question I asked of a list, now asked of a string?"*

Chapter 1 asked three questions of a list: does it contain, how many, and where. This chapter asks the same
three questions of a string, with the same words. The structure changes; the thinking does not.

## 1. The three questions, asked of a string

```ring
oS = new stzString("tea rice tea fish")
? oS.Contains("tea")
#--> TRUE
? oS.NumberOfOccurrence("tea")
#--> 2
? @@( oS.FindAll("tea") )
#--> [ 1, 10 ]
```

## 2. The same three questions, asked of a list

```ring
oL = new stzList([ "tea", "rice", "tea", "fish" ])
? oL.Contains("tea")
#--> TRUE
? oL.NumberOfOccurrence("tea")
#--> 2
? @@( oL.FindAll("tea") )
#--> [ 1, 3 ]
```

## 3. Same words, different units

A position in a string counts characters; a position in a list counts items. The question is the same,
the ruler is not.

```ring
? StzLen("tea rice tea fish")
#--> 17
? oL.NumberOfItems()
#--> 4
```

## 4. One function for both

`StzFind` takes the thing you look for first, then wherever you look for it.

```ring
? @@( StzFind("tea", "tea rice tea fish") )
#--> [ 1, 10 ]
? @@( StzFind("tea", [ "tea", "rice", "tea", "fish" ]) )
#--> [ 1, 3 ]
```

## 5. Act the same way, and read the result carefully

Removing a word from a string leaves the spaces that surrounded it. Removing an item from a list leaves
nothing behind. The same verb, an honest difference.

```ring
? @@( oS.Removed("tea") )
#--> " rice  fish"
oL.RemoveAll("tea")
? @@( oL.Content() )
#--> [ "rice", "fish" ]
```

## 6. Your workplace, both ways

The most requested thing at your workplace, counted in the list of requests and in the same requests joined
into one sentence. Run it: the answer depends on the world.

```ring
aReq = EduWorldObjects("requested")
? StzListQ(aReq).NumberOfOccurrence(aReq[1])
? Q( Q(aReq).Joined(" ") ).NumberOfOccurrence(aReq[1])
```

{{exercise:ex-05-01}}

## Recap

- **Achieved:** you asked contains, count and find of a string and of a list with the same words, and saw
  where the answers differ in unit and in what removal leaves behind.
- **Why it matters:** one way of thinking covers every structure. When a table or a graph arrives, you
  already know the questions.
- **Coming next:** the four moves every program is made of: walk, ask, produce, act.
