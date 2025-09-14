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
#--> [ -5, 1, 3 ]
```

**Game Example**: Loot drop system

```ring
treasureChest = [ "gold", "sword", "potion", "gem", "scroll" ]
rareItems = Few(treasureChest)      # 10% chance items
commonItems = Most(treasureChest)   # 70% chance items
```

Custom probabilities:

```ring
? SomeXT(NumbersIn(-5:5), 20/100)
#--> [ -5, 0, 4 ]

? MostXT(PositiveNumbersIn(-5:5), 90/100)
#--> [ 3, 4, 5, 1 ]
```

## Configuration Functions

Control randomness behavior globally:

```ring
? DefaultSome()
#--> 0.3

SetSome(0.5)        # Change default probability
SetRandomRound(5)   # Set decimal precision
```

**Application Example**: Financial trading simulator

```ring
SetRandomRound(4)   # 4 decimal places for currency
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

**Testing Example**: Generate reproducible test data

```ring
testSeed = 12345
userIds = []
for i = 1 to 1000
    add(userIds, ARandomNumberXT(testSeed + i))
next
```

## Random Number Functions

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
? random01()
#--> 0.61

? ARandomNumberBetween(-3.5, 2.8)
#--> -2.45

SetRandomRound(3)
? ARandomNumberLessThan01(0.7)
#--> 0.557
```

**Weather Simulation**: Temperature generation

```ring
temperatures = []
for day = 1 to 30
    temp = ARandomNumberBetween(15.0, 35.0)
    add(temperatures, temp)
next
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
    #--> T
    
    ? ARandomCharAfterPosition(4)
    #--> A
    
    ? ARandomCharExcept("A")
    #--> S
}
```

**Password Generator**: Random character selection

```ring
charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
password = ""
for i = 1 to 8
    password += Q(charset).ARandomChar()
next
```

List randomization for shuffling and sampling:

```ring
deck = [ 1, 2, 3, 4, "A", "B", "C", "D" ]
o1 = new stzList(deck)

o1.Randomize()                    # Full shuffle
#--> [ 1, "A", 4, 3, "D", "C", "B", 2 ]

o1.RandomizeNumbers()             # Numbers only
#--> [ "A", "B", 30, 50, 40, 60, "A", "B", "C" ]

o1.RandomizeSection(1, 4)         # Partial shuffle
#--> [ 2, 1, 3, 4, "A", "B", "C", "D" ]
```

**Card Game**: Deck shuffling

```ring
cards = 1:52
gameDeck = new stzList(cards)
gameDeck.Randomize()
playerHand = gameDeck.FirstN(5)
```

Item selection:

```ring
? ARandomItemIn("A":"E")
#--> B

? NRandomItemsInU(3, "A":"E")     # Unique samples
#--> [ "B", "E", "A" ]

playerChoices = [ "rock", "paper", "scissors" ]
? ARandomItemIn(playerChoices)
#--> "paper"
```

## Percent Functions

Calculate percentages for business logic:

```ring
nAnnualGain = 20500
? NPercentOf(10, nAnnualGain)
#--> 2050
```

**E-commerce**: Discount calculations

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
