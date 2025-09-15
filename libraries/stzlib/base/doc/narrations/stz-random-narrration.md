# Practical Randomness in Softanza

Softanza builds on Ring’s C-based random engine by offering **semantic APIs** that cover the most common randomness needs in programming. Instead of low-level calls, you get expressive functions for probabilities, list shuffling, string randomization, and reproducible test data.

## Probabilistic Functions

Softanza makes it simple to apply probabilities—ideal for AI simulations, statistical modeling, and game mechanics.

```ring
aNumbers = [ 12, 9, 10, 7, 25, 12, 9, 8 ]
? Some(aNumbers)
#--> [ 12, 10, 7 ]

? Few(NumbersIn(-5:5))
#--> [ 0, -4 ]

? Most(PositiveNumbersIn(-5:5))
#--> [ 1, 2, 4, 5 ]

? Half(OddNumbersIn(-5:5))
#--> [ 1, 5 ]
```

### Example: Loot Drop System

```ring
acTreasureChest = [ "gold", "sword", "potion", "gem", "scroll" ]

acRareItems = Few(acTreasureChest)      # 10% chance items
? @@(acRareItems)
#--> [ "gold" ]

acCommonItems = Most(acTreasureChest)   # 70% chance items
? @@(acCommonItems)
#--> [ "sword", "gem", "gold", "scroll" ]
```

For finer control, you can specify exact probabilities using the extended forms:

```ring
? SomeXT(NumbersIn(-5:5), 20/100)
#--> [ -5, 0, 4 ]

? MostXT(PositiveNumbersIn(-5:5), 90/100)
#--> [ 3, 4, 5, 1 ]
```

## Configuration Functions

You can configure randomness globally: set the probability ratio for `Some()` and control the decimal precision (`round` in Ring/Softanza).

```ring
# Default configuration
? DefaultSome()
#--> 0.3

# Change decimal precision (e.g., for currency)
SetRandomRound(4)

# Set volatility probability (25%)
SetSome(0.25)
```

This is especially useful in domains like financial simulations, where precision and consistency matter.


## Core Random Functions

For low-level randomness, Softanza provides number generators with **seed control**—perfect for reproducible results.

```ring
? ARandomNumber()
#--> 133_322_384

? ARandomNumberXT(77)
#--> 32_438_4546
```

Generate test data that can be replayed identically:

```ring
nTestSeed = 12345
anUserIds = []

for i = 1 to 1000
    anUserIds + ARandomNumberXT(nTestSeed + i)
next

? ShowShort(anUserIds)
#--> [ 7587, 7590, 7593, "...", 10843, 10846, 10849 ]
```

***

## Generating Random Numbers

Produce numbers within constraints:

```ring
? ARandomNumberLessThan(10)
#--> 2

? RandomNumberBetween(100, 150)
#--> 149

? NRandomNumbersBetweenU(3, 100, 110)
#--> [ 102, 109, 105 ]
```

Softanza also supports negative numbers:

```ring
? random01()
#--> 0.61

? ARandomNumberBetween(-3.5, 2.8)
#--> -2.45

SetRandomRound(3)
? ARandomNumberLessThan01(0.7)
#--> 0.557

? StzRandom(-10)
#--> -5

? SomeRandomNumbersBetween(-10, -1)
#--> [ -10, -10, -4 ]
```

## Random Strings and Lists

Randomness isn’t only about numbers—you can generate strings and shuffle lists too.

```ring
Q("123456789") {
    ? ARandomSection()
    #--> "234"
    
    ? SomeRandomSections()
    #--> [ "345678", "4567" ]
}

Q("SOFTANZA") {
    ? ARandomChar()
    #--> "T"
    
    ? ARandomCharAfterPosition(4)
    #--> "A"
    
    ? ARandomCharExcept("A")
    #--> "S"
}
```

### Example: Password Generator

```ring
cCharSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
	   "0123456789" + "#!@~_" +
	   "abcdefghijklmnopqurstuvwxyz"
	  
cPassword = ""

for i = 1 to 8
    cPassword += Q(cCharSet).ARandomChar()
next

? cPassword
#--> @3Ond72H
#--> 2z47AD@Z
#--> LrmaUo7Z
```

### Shuffling and Sampling

```ring
# Full shuffle
aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.Randomize()
? @@(o1.Content())
#--> [ "D", 4, "A", 3, "C", 2, 1, "B" ]

# Shuffle only numbers
aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.RandomizeNumbers()
? @@(o1.Content())
#--> [ 4, 1, 2, 3, "A", "B", "C", "D" ]

# Shuffle only a section
aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.RandomizeSection(5, 8)
? @@(o1.Content())
#--> [ 1, 2, 3, 4, "D", "A", "C", "B" ]
```

### Card Game Example

```ring
nCards = 1:52
oGameDeck = new stzList(nCards)

oGameDeck.Randomize()
anPlayerHand = oGameDeck.FirstN(5)

? @@(anPlayerHand)
#--> [ 48, 20, 6, 51, 35 ]
```

And for simple item selection:

```ring
? ARandomItemIn("A":"E")
#--> B

? NRandomItemsInU(3, "A":"E")
#--> [ "B", "E", "A" ]

acPlayerChoices = [ "rock", "paper", "scissors" ]
? ARandomItemIn(acPlayerChoices)
#--> "paper"
```

***

✨ With these APIs, randomness in Softanza becomes **predictable when needed, configurable when required, and expressive by design**.