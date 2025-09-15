# Softanza Random Features: Practical Randomness for Ring

Softanza extends Ring's C-based random engine with semantic APIs for common randomness needs in programming.

## Probabilistic Functions

Control probability distributions for AI simulations and game mechanics:

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

**Game Example**: Loot drop system

```ring
acTreasureChest = [ "gold", "sword", "potion", "gem", "scroll" ]

acRareItems = Few(acTreasureChest)      # 10% chance items
? @@(acRareItems)
#--> [ "gold" ]

acCommonItems = Most(acTreasureChest)   # 70% chance items
? @@(acCommonItems)
#--> [ "sword", "gem", "gold", "scroll" ]
```

Custom probabilities (using the eXTended form of `Some()`, `SomeXT()`):

```ring
? SomeXT(NumbersIn(-5:5), 20/100)
#--> [ -5, 0, 4 ]

? MostXT(PositiveNumbersIn(-5:5), 90/100)
#--> [ 3, 4, 5, 1 ]
```

## Configuration Functions

Control randomness behavior globally by setting the probability ratio used by `Some()` function (a value between 0 and 1), along with the decimal precision applied (called `round` in Ring and Softanza semantics):

```ring
# Configuring randomness for a financial trading simulator

? DefaultSome()
#--> 0.3

# Change default probability
SetRandomRound(4)   # 4 decimal places for currency

# Set decimal precision
SetSome(0.25)      # 25% market volatility events
```

## Core Random Functions

Essential randomness with seed control:

```ring
? ARandomNumber()
#--> 133_322_384

? ARandomNumberXT(77)    # With seed for reproducible results
#--> 32_438_4546
```

In practice, you can use this to generate reproducible test data

```ring
nTestSeed = 12345
anUserIds = []

for i = 1 to 1000
    anUserIds + ARandomNumberXT(nTestSeed + i)
next

? ShowShort( anUserIds )
#--> [ 7587, 7590, 7593, "...", 10843, 10846, 10849 ]
```

## Generating Random Numbers

Generate constrained numbers for data simulation:

```ring
? ARandomNumberLessThan(10)
#--> 2

? RandomNumberBetween(100, 150)
#--> 149

? NRandomNumbersBetweenU(3, 100, 110)    # Unique values
#--> [ 102, 109, 105 ]
```

Real numbers for scientific calculations:

```ring
? random01() # Or ARandomNumberBetween(0, 1)
#--> 0.61

? ARandomNumberBetween(-3.5, 2.8)
#--> -2.45

SetRandomRound(3)
? ARandomNumberLessThan01(0.7) # A random number between 0 and 1 that's less then 0.7
#--> 0.557
```

Negative range support:

```ring
? StzRandom(-10)
#--> -5

? SomeRandomNumbersBetween(-10, -1)
#--> [ -10, -10, -4 ]
```

## Random String and List Functions

String operations for content generation:

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

**Password Generator**: Random character selection

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

List randomization for shuffling and sampling:

```ring
# Full ranomisation of the positions of all the items

aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.Randomize() # Full shuffle
? @@( o1.Content() )
#--> [ "D", 4, "A", 3, "C", 2, 1, "B" ]

# Randomising the positions of only numbers

aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.RandomizeNumbers()
? @@( o1.Content() )
#--> [ 4, 1, 2, 3, "A", "B", "C", "D" ]

# Randomising the positions of only items in a section

aDeck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(aDeck)
o1.RandomizeSection(5, 8) # Partial shuffle
? @@( o1.Content() )
#--> [ 1, 2, 3, 4, "D", "A", "C", "B" ]
```

**Card Game**: Deck shuffling, again, but now with getting a random player hand

```ring
nCards = 1:52
oGameDeck = new stzList(nCards)

oGameDeck.Randomize()
anPlayerHand = oGameDeck.FirstN(5)

? @@(anPlayerHand)
#--> [ 48, 20, 6, 51, 35 ]
```

Item selection in a list:

```ring
? ARandomItemIn("A":"E")
#--> B

? NRandomItemsInU(3, "A":"E")     # U ~> Unique samples
#--> [ "B", "E", "A" ]

acPlayerChoices = [ "rock", "paper", "scissors" ]
? ARandomItemIn(acPlayerChoices)
#--> "paper"
```

## Percent Functions

Calculate percentages for business logic:

```ring
nAnnualGain = 20500

? NPercentOf(10, nAnnualGain)
#--> 2050

# Or Better
? 10PercentOf(nAnnualGain)

# Or even more generally
? Q(10).PercentOf(nAnnualGain)
```

Discount calculations

```ring
originalPrice = 150.00
discountRate = 15
discountAmount = NPercentOf(discountRate, originalPrice)
finalPrice = originalPrice - discountAmount
```

## Real-World Applications

**Game Development**:

```ring
# Enemy spawn rates
enemies = [ "goblin", "orc", "dragon" ]
commonEnemies = Most(enemies)     # 70% spawn rate
rareEnemies = Few(enemies)        # 10% spawn rate

# Random quest rewards
goldAmount = RandomNumberBetween(50, 200)
experiencePoints = NPercentOf(25, goldAmount)
```

**Data Testing**:

```ring
# Generate test user ages
userAges = NRandomNumbersBetweenU(100, 18, 65)

# Random email domains for testing
domains = [ "gmail.com", "yahoo.com", "hotmail.com" ]
testEmails = []
for i = 1 to 50
    domain = ARandomItemIn(domains)
    add(testEmails, "user" + i + "@" + domain)
next
```

**Scientific Simulation**:

```ring
# Population sampling
populationData = 1:10000
sampleSize = NPercentOf(5, len(populationData))  # 5% sample
randomSample = NRandomItemsInU(sampleSize, populationData)

# Measurement noise
SetRandomRound(6)
measurements = []
for reading = 1 to 100
    noise = ARandomNumberBetween(-0.001, 0.001)
    cleanValue = 23.456789
    add(measurements, cleanValue + noise)
next
```
