# The fraction

*Mathematics · Chapter 2 · Skill PA-02: "What is the shape of this list or these numbers?"*

A fraction is a part of a whole: three of four equal parts, shaded. Said that way it is already a picture,
and the picture answers the questions people ask of fractions faster than the numbers do. Which of two is
larger? Are these two the same amount? This chapter declares fractions as figures, shades them, compares them
side by side, and reads every verdict twice: once off the picture, once by arithmetic.

## 1. Three of four

A fraction figure is declared by what it is of. The figure builds a whole, cuts it into equal parts and
shades the numerator's worth.

```ring
oF = StzMathFigureQ(:Fraction, [ :of = [ 3, 4 ], :label = "three of four" ])
? oF.Why()
#--> a fraction figure of 1 whole(s) as bars: 3 of 4 shaded
```

## 2. The picture judges itself

A fraction figure carries three rules: the shaded parts are the numerator, the parts are the denominator, and
the parts tile the whole with nothing left over. The figure counts them on its own picture.

```ring
? len( oF.Violations() )
#--> 0
```

## 3. Two fractions side by side

Declared together, two fractions share one width, so the eye compares them without measuring. Between each
pair the figure writes its verdict.

```ring
oC = StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 4 ], [ 2, 3 ] ] ])
? oC.Why()
#--> a fraction figure of 2 whole(s) as bars: 3 of 4 shaded, 2 of 3 shaded
```

## 4. The verdict, checked by arithmetic

The picture says three quarters is larger than two thirds. Arithmetic says the same, by cross multiplication:
compare three times three with two times four. Both sides answer one, which is Softanza's word for true.

```ring
? 3 * 3 > 2 * 4
#--> 1
? 3/4 > 2/3
#--> 1
```

## 5. Two names for one amount

Two of four and one of two shade the same width. The figure writes an equals sign between them, and the cross
products agree.

```ring
oE = StzMathFigureQ(:Fraction, [ :compare = [ [ 2, 4 ], [ 1, 2 ] ] ])
? oE.Why()
#--> a fraction figure of 2 whole(s) as bars: 2 of 4 shaded, 1 of 2 shaded
? 2 * 2 = 1 * 4
#--> 1
```

## 6. As discs

The same fractions can be shaded as wedges of a disc. The verdict is the same picture asked another way.

```ring
oD = StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 8 ], [ 1, 4 ] ], :as = :disc ])
? oD.Why()
#--> a fraction figure of 2 whole(s) as discs: 3 of 8 shaded, 1 of 4 shaded
? 3 * 4 > 1 * 8
#--> 1
```

## 7. What the figure refuses

A fraction figure shows a part of ONE whole, so a numerator larger than its denominator is refused by name,
and so is a denominator too fine to draw.

```ring
try
	StzMathFigureQ(:Fraction, [ :of = [ 5, 4 ] ])
catch
	? "refused"
done
#--> refused
```

## 8. On your world

Of all the requests your school received this week, what fraction asked for a transcript? The count depends
on the world this course runs over, so the page shows no result: run it.

```ring
aReq = EduWorldObjects("requested")
nT = StzListQ(aReq).NumberOfOccurrence("transcript")
oW = StzMathFigureQ(:Fraction, [ :of = [ nT, len(aReq) ], :label = "transcripts among the requests" ])
? EduWorldName()
? oW.Why()
```

{{exercise:math-02-01}}

## Recap

- **Achieved:** you declared a fraction as a shaded figure, compared two fractions side by side, read the
  figure's verdict, and checked it by cross multiplication; you saw two names for one amount, and what the
  figure refuses.
- **Why it matters:** a verdict read off a picture and a verdict computed by arithmetic are two independent
  answers to one question. When they agree you can trust both; when they disagree, something is wrong and you
  know it before anyone else does.
- **Coming next:** a game of chance with three corners and one rule draws a shape nobody drew. The next
  chapter plays it and counts what appears.
