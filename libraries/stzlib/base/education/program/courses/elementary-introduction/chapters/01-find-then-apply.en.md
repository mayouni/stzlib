# Find, then apply

*Elementary Introduction · Chapter 1 · Skill EX-03: "Where is it, and what do I do there?"*

Every workplace receives requests. A restaurant receives orders and a bank receives tickets, and the same request
often arrives more than once. This chapter deals with repeated requests the Softanza way. First you select the
object. Then you ask whether it contains what you are looking for, count it, and find it. Only then do you act.

## 1. Select the object

A list of requests is a `stzList`.

```ring
o1 = new stzList([ "tea", "rice", "tea", "fish", "rice", "tea" ])
? o1.NumberOfItems()
#--> 6
```

## 2. Ask the containment question

Before acting, ask whether there is anything to act on.

```ring
? o1.ContainsDuplicates()
#--> TRUE
```

## 3. Ask the count question

```ring
? o1.NumberOfDuplicates()
#--> 3
```

## 4. Ask for the positions

```ring
? @@( o1.FindDuplicates() )
#--> [ 3, 5, 6 ]
```

## 5. Act on the positions

You know where the repeated requests are, so you can remove them.

```ring
o1.RemoveItemsAtPositions( o1.FindDuplicates() )
? @@( o1.Content() )
#--> [ "tea", "rice", "fish" ]
```

Softanza also has one word for the whole move. Read it as a sentence: *the list, with its duplicates removed*.

```ring
? @@( StzListQ([ "tea", "rice", "tea" ]).DuplicatesRemoved() )
#--> [ "tea", "rice" ]
```

## 6. The same questions, on your workplace

This cell reads the requests that your workplace received today. What it prints depends on the world this course
runs over, so the page never shows an output: run it.

```ring
o2 = new stzList( EduWorldObjects("requested") )
? EduWorldName()
? o2.ContainsDuplicates()
? o2.NumberOfDuplicates()
? @@( o2.DuplicatesRemoved() )
```

## 7. Say it in your own words

Softanza also understands the same request written as a sentence.

```ring
? @@( Naturally("Create a list with [ 5, 3, 5, 1 ] and remove its duplicates").Result() )
#--> [ 5, 3, 1 ]
```

{{exercise:ex-01-01}}

## Recap

- **Achieved:** you took a list through the mental model. You selected it, asked whether it contained duplicates,
  counted them and found them, and then removed them.
- **Why it matters:** acting comes last. Each question you ask first makes the action exact, and each answer is
  one you can check.
- **Coming next:** the same five questions work on strings, tables and graphs. The next chapter asks them of a
  string.
