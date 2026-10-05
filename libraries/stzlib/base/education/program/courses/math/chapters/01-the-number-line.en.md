# The number line

*Mathematics · Chapter 1 · Skill SE-01: "Would a picture answer this faster than a number?"*

A number is a place. Three, minus two and seven and a half are three places on one line, and that line is the
first picture of mathematics: everything on it has a position, an order and a distance. This chapter declares
a number line the Softanza way. You say what is on it; the figure computes where each thing goes, draws it,
and judges its own picture before you trust it.

## 1. Declare the line

A number line is declared as keys: the range it covers, and the points on it. The figure answers with one
sentence about what it computed.

```ring
oL = StzMathFigureQ(:NumberLine, [ :on = [ -5, 10 ], :points = [ 3, -2, 7.5 ] ])
? oL.Why()
#--> a number line from -5 to 10: 16 ticks, 3 point(s), 0 jump(s)
```

## 2. The picture judges itself

Every figure carries rules. A number line must keep its points in the order of their numbers, must land a
jump where the jump says, and must keep every name readable next to its point. Ask the figure whether its
own picture broke any rule. Zero is the answer you want, and it is computed, not promised.

```ring
? len( oL.Violations() )
#--> 0
```

## 3. Order is a question you can ask

Which is further left, minus two or three? On the line, left means smaller. Softanza answers with a number:
one for true, zero for false.

```ring
? -2 < 3
#--> 1
? 7.5 < 3
#--> 0
```

## 4. A jump is a difference

A jump from one place to another is drawn as an arc, and the figure checks that the arc lands where it says.
A jump has two ends, and the figure counts them as points. From nine to four is a jump of minus five: it goes
to the left.

```ring
oJ = StzMathFigureQ(:NumberLine, [ :on = [ 0, 12 ], :jumps = [ [ 9, 4 ] ], :step = 1 ])
? oJ.Why()
#--> a number line from 0 to 12: 13 ticks, 2 point(s), 1 jump(s)
? 4 - 9
#--> -5
```

## 5. The distance between two places

A distance is a difference with its sign removed. Between minus two and seven and a half there are nine and a
half units, whichever end you start from.

```ring
? fabs( 7.5 - (-2) )
#--> 9.50
? fabs( -2 - 7.5 )
#--> 9.50
```

## 6. Name a place

A point may carry a name, and the figure places the name where it can be read without touching the line, the
ticks or another name. A half sits halfway between zero and one.

```ring
oN = StzMathFigureQ(:NumberLine, [ :on = [ 0, 2 ], :step = 0.5,
                                   :points = [ [ 0.5, "half" ], [ 1.5, "one and a half" ] ] ])
? oN.Why()
#--> a number line from 0 to 2: 5 ticks, 2 point(s), 0 jump(s)
? len( oN.Violations() )
#--> 0
```

## 7. On your world

This cell counts the requests your school received this week and places the count on a line. What it prints
depends on the world this course runs over, so the page never shows a result: run it.

```ring
aReq = EduWorldObjects("requested")
oW = StzMathFigureQ(:NumberLine, [ :on = [ 0, 10 ], :points = [ [ len(aReq), "requests" ] ] ])
? EduWorldName()
? oW.Why()
```

{{exercise:math-01-01}}

## Recap

- **Achieved:** you declared a number line with its range and its points, read the figure's own sentence
  about what it computed, asked it to judge its picture, compared two places, jumped between two and measured
  their distance.
- **Why it matters:** a picture is declared, computed and then checked. Nothing on it was drawn by hand, so
  nothing on it can be wrong quietly: every claim in this chapter is a line the figure printed.
- **Coming next:** a fraction is a part of a whole, and the next chapter shades it, compares two of them and
  reads the verdict off the picture.
