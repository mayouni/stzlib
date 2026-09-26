# The chaos game

*Mathematics · Chapter 3 · Skill PA-02: "What is the shape of this list or these numbers?"*

Take three corners of a triangle and a pencil anywhere inside. Roll a die: one or two means the first
corner, three or four the second, five or six the third. Move halfway from where you are towards that corner,
and put a dot. Roll again. After two thousand rolls the dots are not a smudge: they are a triangle full of
holes, the same shape at every size, that nobody drew. This chapter plays the game with the library's random
numbers, and counts what appears instead of admiring it.

## 1. Three corners

The corners are three places on the page. They never move; only the pencil does.

```ring
? @@( StzChaosGameCorners() )
#--> [ [ 320, 40 ], [ 40, 560 ], [ 600, 560 ] ]
```

## 2. The first six rolls

Every dot is data: a place the rule produced. A seed makes the rolls the same every time this cell runs, so a
promise can be made about chance.

```ring
oS = StzChaosGameSubstance(6, 7)
for i = 1 to 6
	? "" + oS.DataOf("d" + i, "x") + ", " + oS.DataOf("d" + i, "y")
next
#--> 320, 170
```

## 3. Two thousand rolls

The picture is a diagram with nothing to solve: two thousand dots, each drawn where its data says.

```ring
oG = StzChaosGamePictureQ(StzMathFigureFont(), 2000, 7)
? oG.NumberOfShapes()
#--> 2000
? oG.NumberOfUnknowns()
#--> 0
```

## 4. What appears, counted

Sierpinski's triangle has two signatures. Every dot lies inside the outer triangle, and not one lies inside
the central hole, the triangle whose corners are the midpoints of the sides. The library counts both by an
independent test on each dot's position: the rule was never told about the hole.

```ring
aC = StzChaosGameCounts(oG, 2000)
? aC[1]
#--> 2000
? aC[2]
#--> 0
```

## 5. Chance, and yet the same shape

Another seed gives other rolls and other dots, and the two counts come out the same. The shape belongs to the
rule, not to the rolls.

```ring
oH = StzChaosGamePictureQ(StzMathFigureFont(), 500, 11)
? @@( StzChaosGameCounts(oH, 500) )
#--> [ 500, 0 ]
```

## 6. A dot's place is its datum

The picture holds no secret: a dot is drawn exactly where its data puts it, and you can read both.

```ring
? oG.ValueOf("d7.icon.cx") = oG.Substance().DataOf("d7", "x")
#--> 1
```

{{exercise:math-03-01}}

## Recap

- **Achieved:** you played the chaos game with seeded random numbers, drew two thousand dots with nothing to
  solve, and counted the two signatures of Sierpinski's triangle by an independent test instead of trusting
  your eyes.
- **Why it matters:** a pattern that appears from chance is a claim like any other. Counting what the rule
  produced is how a picture becomes evidence.
- **Coming next:** a function is a picture too. The next chapter draws one, marks where it crosses zero and
  where it turns, and checks every mark.
