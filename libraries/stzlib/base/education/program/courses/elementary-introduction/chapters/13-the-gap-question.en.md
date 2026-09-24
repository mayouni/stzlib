# The gap question

*Elementary Introduction · Chapter 13 · Skills KN-03 "What has Softanza asked me, and why?" and KN-04 "What does the library call the thing I mean?"*

A vague request gets a guess from most systems. Softanza asks instead. You declare what a complete world
must contain, and the gap between that goal and the world becomes the next question, with its reason. This
chapter also turns the same idea on the library itself: you ask it what it calls the thing you mean.

## 1. Declare a goal

Every dish must say what it contains. Two dishes, nothing recorded: two gaps.

```ring
oRest = new stzKnowledgeGraph("restaurant")
oRest.Know("margherita", "dish").Know("tiramisu", "dish")
oRest.AddConversationQ("setup").SetGoal(StzGoalQ().RequireEach("dish", "contains"))
? len( oRest.GapsIn("setup") )
#--> 2
```

## 2. Softanza asks, and says why

```ring
aQ = oRest.AskInXT("setup")
? aQ[:question]
#--> What does 'margherita' have for 'contains'?  (why: every dish needs 'contains')
```

## 3. You answer in words, and the world grows

```ring
aV = oRest.ReplyIn("setup", "tomato and mozzarella")
? @@( aV[:admitted] )
#--> [ "tomato", "mozzarella" ]
? @@( oRest.Query([ "margherita", "contains", "?o" ]) )
#--> [ "tomato", "mozzarella" ]
? len( oRest.GapsIn("setup") )
#--> 1
```

## 4. The next question offers what it already knows

```ring
aQ2 = oRest.AskInXT("setup")
? aQ2[:question]
#--> Which 'contains' does 'tiramisu' have? (1) tomato  (2) mozzarella -- or answer freely.  (why: every dish needs 'contains')
```

## 5. Ask the library what it calls the thing you mean

The library describes itself. `HowTo` turns an intent into a call, and says how it got there.

```ring
oDoc = StzSelfDocQ("stzList")
? oDoc.HowTo("remove duplicates")
#--> Q([...]).RemoveDuplicates()   -- composed by grammar (remove duplicates)
? oDoc.HasMethod("DuplicatesRemoved")
#--> TRUE
```

## 6. Explain a method, and refuse an unknown one

```ring
? StzLeft( oDoc.ExplainMethod("DuplicatesRemoved"), 20 )
#--> DuplicatesRemoved --
? oDoc.ExplainMethod("NoSuchThing")
#--> No method 'NoSuchThing' in stzList.
```

{{exercise:ex-13-01}}

{{exercise:ex-13-02}}

## Recap

- **Achieved:** you declared a goal, received the gap question with its reason, answered it in words, saw
  the next question offer what was known, and asked the library to name a method from your intent.
- **Why it matters:** a system that asks teaches you what a complete model needs. A system that guesses
  hides it.
- **Coming next:** an agent that proposes and cannot act.
