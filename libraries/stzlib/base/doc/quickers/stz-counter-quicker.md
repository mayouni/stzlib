# Mastering Complex Loop Patterns with stzCounter

Ever struggled with complex loop index calculations? Let's explore how `stzCounter` eliminates the mental gymnastics of modular arithmetic and cycle management.

## The Problem: Manual Index Management

Picture this scenario: you're building a carousel that cycles through 5 slides, but when it reaches the end, it should restart from slide 2 (skipping the intro slide).

**Traditional approach** - mental math nightmare:

```ring
anSlides = []

for i = 1 to 20
    if i <= 5
        anSlides + i
    else
        # Complex calculation: ((i-6) % 4) + 2
        nRemainder = (i - 6) % 4
        if nRemainder = 0 nRemainder = 4 ok
        	anSlides + (nRemainder + 1)
    	ok
next

? anSlides  # Messy, error-prone
```

**With stzCounter** - declarative clarity:

```ring
load "stzlib.ring"

oCarouselCounter = new stzCounter([
    :StartAt = 1,
    :WhenYouReach = 5,
    :RestartAt = 2
])

anSlides = oCarouselCounter.CountTo(20)
? @@(anSlides)
#--> [ 1, 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 3, 4, 2, 3, 4, 2 ]
```

Notice how the counter naturally handles the cycle: 1→2→3→4→2→3→4→... No modular arithmetic headaches.

## Exploring Basic Cycling

Let's start simple. You need to distribute tasks among 3 workers cyclically:

```ring
oWorkerCounter = new stzCounter([
    :StartAt = 1,
    :WhenYouReach = 3,
    :RestartAt = 1
])

anAssignments = oWorkerCounter.CountTo(10)
? @@(anAssignments)
#--> [ 1, 2, 3, 1, 2, 3, 1, 2, 3, 1 ]

# Need just the 7th assignment?
? oWorkerCounter.CountToXT(10, :ReturnNth = 7)
#--> 1
```

**Traditional equivalent** would require tracking state and manual modulo operations:

```ring
anAssignments = []
for i = 1 to 10
    nWorkerId = ((i-1) % 3) + 1  # Off-by-one trap!
    anAssignments + nWorkerId
next
```

## Advanced Pattern: Skip and Restart

Real-world complexity: A security system cycles through 10 sensors, but after checking sensor 9, it skips sensor 10 and restarts from sensor 0 (master reset).

```ring
oSecurityCounter = new stzCounter([
    :StartAt = 1,
    :AfterYouSkip = 9,    # Stop after 9
    :RestartAt = 0,       # Begin next cycle at 0
    :Step = 1
])

oPatrolSequence = oSecurityCounter.Counting(:To = 15)
? @@(oPatrolSequence)
#--> [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5 ]
```

**Manual implementation** becomes a state management nightmare:

```ring
anSequence = []
nCurrent = 1
for i = 1 to 15
    anSequence + nCurrent
    if nCurrent = 9
        nCurrent = 0
    else
        nCurrent++
    ok
next
```

The counter abstracts away the conditional logic entirely.

## Practical Application: Pagination with Gaps

Consider a report system where pages 1-4 show data, page 5 is ads, then restart at page 1:

```ring
oPageCounter = new stzCounter([
    :StartAt = 1,
    :WhenYouReach = 5,
    :RestartAt = 1
])

oPageCounter {
    # Generate 12 page views
    ? oPageCounter.CountTo(12)
    #--> [ 1, 2, 3, 4, 1, 2, 3, 4, 1, 2, 3, 4 ]
    
    # What page appears 8th in the sequence?
    ? CountToXT(12, :ReturnNth = 8)
    #--> 4
}
```

## Flexible Method Names: Code That Reads Like Your Thoughts

Softanza embraces semantic flexibility. All these method variations produce identical results:

```ring
# All equivalent - choose what fits your narrative:
CountTo(15)           # Action-oriented  
Counting(:To = 15)    # Process-focused
```

This flexibility lets your code match how you think about the problem. Need a quick result? Use `CountTo()`. Describing a sequence? Use `Counting()`. The method name becomes part of your code's story.

## Advanced Query: Getting Specific Elements

Sometimes you need just the final state or specific positions:

```ring
oCounter = new stzCounter([
    :StartAt = 1,
    :WhenYouReach = 5,
    :RestartAt = 2
])

oCounter {
    # What's the last number in a 15-count sequence?
    ? CountingXT(:To = 15, :AndReturning = :Last)
    #--> 3
    
    # What's at position 12?
    ? CountXT(:To = 15, :AndReturnNth = 12)
    #--> 4
}
```

**Traditional approach** requires generating the full sequence or complex state tracking:

```ring
# Inefficient: generate everything just to get one value
anTemp = []
nCurrent = 1
for i = 1 to 15
    anTemp + nCurrent
    if nCurrent = 4 
        nCurrent = 2 
    else 
        nCurrent++ 
    ok
next
nResult = anTemp[12]  # Memory waste for single value
```

## The Power of Abstraction

`stzCounter` transforms complex loop patterns into readable configuration. Instead of debugging off-by-one errors and modular arithmetic, you declare your intent:

* **StartAt**: Where to begin
* **WhenYouReach/AfterYouSkip**: When to cycle
* **RestartAt**: Where to resume
* **Step**: How to increment

The result: code that matches your mental model, not the computer's arithmetic.