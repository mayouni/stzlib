# Read the name as a sentence

*Elementary Introduction · Chapter 3 · Skill EX-04: "Does this name change the object, give me a copy, or continue the sentence?"*

A Softanza method name is a sentence spoken to an object. Its grammar tells you what will happen before you
run it. This chapter teaches the three forms you will meet on every page: the active, the passive and the
fluent.

## 1. The active form changes the object

`RemoveAll` is an order. The object obeys and is changed.

```ring
o1 = new stzString("RIxxNxG")
o1.RemoveAll("x")
? o1.Content()
#--> RING
```

## 2. The passive form gives you a copy

`Removed` is a past participle: *the string, with x removed*. It answers with a new value and leaves the
object as it was.

```ring
o1 = new stzString("RIxxNxG")
? o1.Removed("x")
#--> RING
? o1.Content()
#--> RIxxNxG
```

## 3. The fluent form continues the sentence

A `Q` at the end of a name means *and then*. The sentence goes on until a passive closes it.

```ring
? Q("rixxnxg").RemoveQ("x").UppercaseQ().Spacified()
#--> R I N G
```

## 4. A fluent sentence on an object changes it

```ring
o1 = new stzString("rixxnxg")
? o1.RemoveQ("x").Uppercased()
#--> RING
? o1.Content()
#--> ring
```

## 5. Say "on a copy" with QC

`QC` means *and then, on a copy*. The original is untouched.

```ring
o1 = new stzString("rixxnxg")
? o1.RemoveQC("x").Uppercased()
#--> RING
? o1.Content()
#--> rixxnxg
```

## 6. A named parameter reads as prose

```ring
? Q("tea, rice, tea").Replaced("tea", :With = "coffee")
#--> coffee, rice, coffee
```

## 7. A question is a name that starts with Is

```ring
? Q("bread").IsLowercase()
#--> TRUE
```

{{exercise:ex-03-01}}

## Recap

- **Achieved:** you can tell, from a name alone, whether it changes the object (`RemoveAll`), answers with
  a copy (`Removed`), or continues the sentence (`RemoveQ`, and `RemoveQC` on a copy).
- **Why it matters:** you never need to run a method to know whether your data will survive it. The name
  says so.
- **Coming next:** the same sentence, spoken in French, Arabic or Hausa.
