# Declare what, not how

*Elementary Introduction · Chapter 7 · Skills FO-04 "Can I say what I want and let the engine decide how?" and PA-03 "Can I hand the condition over instead of writing the branch?"*

Until now you named a fixed thing: "tea", the duplicates, position 4. This chapter names a **condition**, and
hands it over as data. You say *what* qualifies; the engine decides *how* to walk the list, test each item
and collect the answer. The `W` at the end of a name means *where*.

## 1. Find where a condition holds

`@item` stands for each item in turn. The condition is a piece of text between braces.

```ring
o = new stzList([ 4, 7, 10, 3, 8 ])
? @@( o.FindW("{ @item > 5 }") )
#--> [ 2, 3, 5 ]
? @@( o.ItemsW("{ @item > 5 }") )
#--> [ 7, 10, 8 ]
? o.CountW("{ @item > 5 }")
#--> 3
```

## 2. Any question can be the condition

```ring
? @@( o.FindW("{ IsEven(@item) }") )
#--> [ 1, 3, 5 ]
? o.CheckW("{ isNumber(@item) }")
#--> TRUE
```

## 3. A rule is data: keep it, and apply it anywhere

The rule lives in a variable. Two lists, one rule, and the rule never knew which list it would meet.

```ring
cRule = "{ @item > 20 }"
oA = new stzList([ 12, 0, 30, -5, 18, 25 ])
oB = new stzList([ 3, 40, 9 ])
? oA.CountW(cRule)
#--> 2
? oB.CountW(cRule)
#--> 1
```

## 4. Act where the rule holds

```ring
? @@( oA.ItemsW(cRule) )
#--> [ 30, 25 ]
oA.RemoveW(cRule)
? @@( oA.Content() )
#--> [ 12, 0, -5, 18 ]
```

## 5. The same word on words

```ring
oS = new stzList([ "ring", "PHP", "C#", "ruby", "GO" ])
? @@( oS.FindW("{ IsUppercase(@item) }") )
#--> [ 2, 3, 5 ]
? @@( oS.ItemsW("{ Q(@item).IsLowercase() }") )
#--> [ "ring", "ruby" ]
```

{{exercise:ex-07-01}}

{{exercise:ex-07-02}}

## Recap

- **Achieved:** you found, counted, kept and removed items by a condition you wrote once as text, and
  applied one rule to two lists without changing it.
- **Why it matters:** a condition that is data can be stored in a file, sent to a colleague, and applied to
  data that did not exist when it was written. A branch inside a loop can do none of that.
- **Coming next:** conditions on text have their own language, and it is called a pattern.
