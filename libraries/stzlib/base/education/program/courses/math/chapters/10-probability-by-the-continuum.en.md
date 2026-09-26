# Probability by the quantifier continuum

*Mathematics · Chapter 10 · Skill KN-02: "What follows from what I wrote down?"*

Before probability had numbers it had words: none, few, some, half, many, most, all. Softanza keeps those
words as quantifiers over a list, and they form a continuum whose order the library holds. A probability is
then a proportion you can read on that continuum, and a thousand seeded throws of a coin are a proportion
you can count. This chapter walks the continuum, throws the coin, rolls the die, and places what it saw on a
number line.

## 1. The continuum, in order

Each quantifier takes a share of a list: few is a small share, some a larger one, most nearly all. Whatever
the share, the order holds, and the library checks it on ten numbers.

```ring
aTen = 1:10
? len( Few(aTen) ) < len( Some(aTen) )
#--> 1
? len( Some(aTen) ) < len( Most(aTen) )
#--> 1
? len( All(aTen) )
#--> 10
? len( No(aTen) )
#--> 0
```

## 2. Half, exactly

Half of ten is five. The quantifier's count is a number the library computes, never a guess.

```ring
? len( Half(aTen) )
#--> 5
```

## 3. A thousand throws of a fair coin

A seed makes the throws the same every time, so a promise can be made about chance. A fair coin's
probability of heads is one half; a thousand throws with seed three give five hundred and four heads, within
five hundredths of a half.

```ring
SeedRandom(3)
nHeads = 0
for i = 1 to 1000
	if StzRandom01() < 0.5  nHeads++  ok
next
? nHeads
#--> 504
? fabs( nHeads / 1000 - 0.5 ) < 0.05
#--> 1
```

## 4. Sixty rolls of a die

Each face has probability one sixth, and sixty rolls should show each face about ten times. The frequency
table counts what the seeded rolls actually gave: every face appeared, and none appeared as often as chance
would allow it to.

```ring
SeedRandom(3)
aRolls = []
for i = 1 to 60
	aRolls + ( floor( StzRandom01() * 6 ) + 1 )
next
oD = new stzDataSet(aRolls)
? len( oD.FrequencyTable() )
#--> 6
? @@( oD.FrequencyTable() )
#--> [ "1", 16 ]
```

## 5. What was seen, on a line

The proportion of heads is a place between zero and one. Draw it on a number line next to the fair coin's
half, and the two are close but not the same place: chance is what lies between them.

```ring
oL = StzMathFigureQ(:NumberLine, [ :on = [ 0, 1 ], :step = 0.1,
                                   :points = [ [ 0.5, "fair" ], [ nHeads / 1000, "seen" ] ] ])
? oL.Why()
#--> a number line from 0 to 1: 11 ticks, 2 point(s), 0 jump(s)
```

## 6. Ten rolls, as a fraction

Of ten seeded rolls, how many are sixes? The count is a fraction of ten, shaded.

```ring
SeedRandom(5)
nSixes = 0
for i = 1 to 10
	if floor( StzRandom01() * 6 ) + 1 = 6  nSixes++  ok
next
? nSixes
#--> 1
oF = StzMathFigureQ(:Fraction, [ :of = [ nSixes, 10 ], :label = "sixes in ten rolls" ])
? oF.Why()
#--> a fraction figure of 1 whole(s) as bars: 1 of 10 shaded
```

## 7. On your world

Of the requests your school received this week, what share asked for a transcript, and is it few, some or
most? What it prints depends on the world this course runs over, so the page shows no result: run it.

```ring
aReq = EduWorldObjects("requested")
nT = StzListQ(aReq).NumberOfOccurrence("transcript")
? EduWorldName()
? nT / len(aReq)
```

{{exercise:math-10-01}}

## Recap

- **Achieved:** you walked the quantifier continuum from none to all and saw its order held, threw a seeded
  coin a thousand times and read the proportion against a half, rolled a die sixty times and counted every
  face, placed the proportion on a number line and shaded ten rolls as a fraction.
- **Why it matters:** chance is not the absence of a claim. With a seed, a throw is a fact you can promise;
  with a count, a probability is a proportion you can check.
- **Coming next:** money must not lose a centime. The next chapter adds and divides amounts with the exact
  numbers that say why they are not exact when they are not.
