# Walk, ask, produce, act

*Elementary Introduction · Chapter 6 · Skill FO-02: "Which of the four moves is this step?"*

Every program is made of four moves. It **walks** through positions, it **asks** questions, it
**produces** new values, and it **acts** on the data. Softanza names each move, so a task decomposes into
them instead of into loops.

## 1. Walk: the positions, then what is there

The kitchen checks every third order. First the positions, then the orders at those positions.

```ring
aOrders = [ "tea", "rice", "tea", "fish", "rice", "tea", "soup", "tea", "rice" ]
? @@( StzListQ([ 1, 2, 3, 4, 5, 6, 7, 8, 9 ]).FindW("@item % 3 = 1") )
#--> [ 1, 4, 7 ]
? @@( StzListQ(aOrders).ItemsAtPositions([ 1, 4, 7 ]) )
#--> [ "tea", "fish", "soup" ]
```

## 2. Ask: a question answers TRUE or FALSE

```ring
? StzListQ(aOrders).Contains("soup")
#--> TRUE
? Q("cold").IsLowercase()
#--> TRUE
```

## 3. Produce: a yielder makes new values from old ones

The day's takings, with a refund written as a negative number. A yielder filters, maps and reduces without
one loop being written.

```ring
oY = new stzYielder([ 12, 0, 30, -5, 18 ])
? @@( oY.Filter(:IsPositive) )
#--> [ 12, 30, 18 ]
? @@( oY.Map(:Double) )
#--> [ 24, 0, 60, -10, 36 ]
? oY.Reduce(:Sum)
#--> 55
```

## 4. The moves chain

Filter, then reduce: the total of the real sales.

```ring
? oY.FilterQ(:IsPositive).Reduce(:Sum)
#--> 60
```

## 5. Act: a verb changes the data

```ring
oL = new stzList(aOrders)
oL.RemoveAll("tea")
? @@( oL.Content() )
#--> [ "rice", "fish", "rice", "soup", "rice" ]
```

## 6. A condition can be handed over as data

`ItemsW` takes the question itself as its argument. The next chapter is about this.

```ring
? @@( StzListQ([ 12, 0, 30, -5, 18 ]).ItemsW("@item > 0") )
#--> [ 12, 30, 18 ]
```

Softanza also has a dedicated walker object, `stzWalker`, with steps, directions and a history. It lives
in the library's `max` tier, which this course does not load, so it is not shown here.

{{exercise:ex-06-01}}

## Recap

- **Achieved:** you sorted a task into walking (positions), asking (questions), producing (a yielder) and
  acting (a verb), and chained them without a loop.
- **Why it matters:** a loop hides which move it is making. Naming the move makes a program readable to
  someone who did not write it.
- **Coming next:** declaring what you want and letting the engine decide how.
