# Softanza Documentation Notes: A Central Repository of Sweetness
![Softanza Sweetness, by Microsoft Image AI](../images/stznotes.jpg)

I compiled all the **notes** I wrote inside the documentation files into one place, so you can get a taste of the power of some of the tiny yet powerful Softanza **small** functions, function **prefixes** and **suffixes**, expressive function **named params**, and other rather sweet features and utilities.

## Getting Started: Load the Sweetness
Of course, you need to load the library first:
```ring
load "stzlib.ring"
```
---

## Q() small function: Elevating Values to Softanza Objects

The `Q(val)` small function elevates the value `val`, whatever type it has, to the corresponding Softanza object.

**Example**: the first Q() elevates "you" to a stzString object, while the second alevates [ "you", "and", "me" ] to a stzList object:

```ring
? Q("you").Uppercased() #--> YOU
? Q([ "you", "and", "me" ]).Uppercased() #--> [ "YOU", "AND" , "ME" ]
```

>Note how `Uppercase()` function works also for lists.

---

## StzStringQ(): One-Liners, Fluent Chains, and Declarative Crafting of Code

The `Q` in `StzStringQ(str)` returns a `stzString` object containing the string `str`. It's more practical (and elegant) than instantiating it using `o1 = new stzString(str)`.

This feature is designed to enable smart **one-liners**, **fluent code chains**, and a **declarative coding style** directly within the object itself (thank you Ring!):

```ring
# A one-liner expressing a chain of transformations

? StzStringQ("h e l l o").RemoveSpacesQ().UppercaseQ().Content()
#--> "HELLO"

# A declarative crafting block of code

StzStringQ("h e l l o") {
    RemoveSpaces()
    Uppercase()
    ? Content()
    #--> "HELLO"
}
```

---

## @@() small function: Clarity with a Readable Representation
>`@@(val)` is a Softanza small function, akin to a **pair of glasses** that enhance vision, designed to produce a readable string representation of any value `val`.

---

## Across Strings and Lists: A Unified Syntax

In Softanza, as a general principle, anything that works for strings will work the same way for lists, following the same syntax and semantics.

**Example**:

```ring
? @@( StzStringQ("ABRACADABRA").**FindDuplicates()** )
#--> [ 4, 6, 8, 9, 10, 11 ]

? @@( StzListQ(@Chars("ABRACADABRA")).**FindDuplicates()** )
#--> [ 4, 6, 8, 9, 10, 11 ]
```

---

## XT() Function Suffix: Extending Basic Features

The `XT()` suffix, when appended to a Softanza function, signifies an e**XT**ended outcome of the basic feature in question.

**Example**:
```ring
o1 = new stzString("text with something at the right")
? o1.NRightChars(5)     #--> the **list of chars** [ "r", "i", "g", "h", "t" ]
? o1.NRightChars**XT**(5)   #--> the **string** "right"
```

As you can see, the **XT** suffix forces the output to be a **string** rather than a **list** of characters, which is the basic output.

>This is just one example of dozens of others you will discover along your journey in exploring Softanza documentation and samples.

---

## Z() and ZZ() Function Suffixes: Positions or Sections, Your Choice

If you try `o1.FindZ()` instead of `o1.FindZZ()` on any Softanza `o1` object, beeing a `stzString` or `stzList`, you'll see that both `Z()` and `ZZ()` return positions, but the first **as numbers** and the second **as sections** (pairs of numbers). Whatever your need, such smart yet powerful Softanza tiny **suffixes**, applied to almost any function, will have you covered!

**Example**:
```ring
? Q("Programming in Softanza is prog**ramm**ing by heart!").FindZ("ramm") # Or simply Find() without Z
#--> [ 5, 32 ]

? Q("Programming in Softanza is programming by heart!").FindZZ("ramm") # Or FindAsSections()
#--> [ [ 5, 8 ], [ 32, 35 ] ]
```

---

## Method Chaining: A Tool for Fluid Design Thinking

**Method chaining** in Softanza enables the fluent design of transformation pipelines by simply appending the method you want to chain with a small `...Q()`.

**Example**:
```ring
? Q("h e l l o").RemoveSpacesQ().UppercaseQ().Content()
#--> "HELLO"
```

**Fluent chains** of `Q()`**ed** methods calls generally end with a **passive function form** that returns the **final value**, rather than an intermediate Softanza object.

To create the passive version of a function, convert its active form, which is essentially a **verb**, into its **past participle**, e.g., `Uppercase → Uppercased`. Thus, the chain from the earlier example becomes:

```ring
? Q("h e l l o").RemoveSpacesQ().Uppercased()
```