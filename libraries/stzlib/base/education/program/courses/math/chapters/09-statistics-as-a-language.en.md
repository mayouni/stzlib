# Statistics as a language of thought

*Mathematics · Chapter 9 · Skill FO-01: "What am I really asking, in the fewest words?"*

Eight numbers are eight facts. Statistics is the language that says what they have in common in a few
words, and a box plot is that language drawn: where the middle is, how wide the middle half is, and which
value stands alone. This chapter takes eight values through the words, then through the picture, and checks
that the two say the same thing.

## 1. Eight values, two middles

The mean adds everything and divides. The median is the value in the middle once the values are sorted. One
large value pulls the mean up and leaves the median where it was.

```ring
aV = [ 2, 4, 4, 5, 7, 9, 12, 25 ]
oD = new stzDataSet(aV)
? oD.Mean()
#--> 8.50
? oD.Median()
#--> 6
```

## 2. The quartiles and the one that stands alone

The quartiles cut the sorted values into four parts. A value far beyond the middle half is an outlier, and
the data set names it.

```ring
? @@( oD.Quartiles() )
#--> [ 4, 6, 9.75 ]
? @@( oD.Outliers() )
#--> [ 25 ]
```

## 3. The same words, drawn

A box plot figure is declared by its values. Its sentence says the same numbers the data set said: the box
from the first quartile to the third, the median inside it, and the outlier counted.

```ring
oB = StzMathFigureQ(:BoxPlot, [ :of = aV, :label = "eight values" ])
? oB.Why()
#--> a box plot of 1 group(s): n = 8, box 4 | 6 | 9.75, 1 outlier(s)
? len( oB.Violations() )
#--> 0
```

## 4. The picture in text

The figure can say itself in text, for a terminal, a message or a page with no picture: the numbers, then the
box, the whiskers and the lone value.

```ring
? oB.Text()
#--> group 1  n=8  min 2  Q1 4  med 6  Q3 9.75  max 25  outliers 1
```

## 5. An outlier by rule, not by opinion

The rule is a fence: one and a half times the width of the box, beyond the third quartile. Twenty-five lies
beyond it, so the whisker stops at twelve, the last value inside.

```ring
aS = oD.BoxPlotStats()
? aS[:iqr]
#--> 5.75
? 9.75 + 1.5 * 5.75
#--> 18.38
? 25 > 18.375
#--> 1
? aS[:whisker_high]
#--> 12
```

## 6. Two groups side by side

Two groups share one axis, so the eye compares their middles without a number. The morning has an outlier;
the evening has none.

```ring
oG = StzMathFigureQ(:BoxPlot, [ :groups = [ [ "morning", [ 12, 15, 14, 18, 16, 15, 13, 40 ] ],
                                            [ "evening", [ 20, 22, 19, 25, 24, 21, 23, 22 ] ] ] ])
? oG.Why()
#--> a box plot of 2 group(s): morning n = 8, box 13.75 | 15 | 16.5, 1 outlier(s); evening n = 8, box 20.75 | 22 | 23.25, 0 outlier(s)
```

## 7. Spread as one number

The standard deviation says how far the values sit from the mean, on average. It is one number for the whole
spread, and it too is pulled by the lone value.

```ring
? oD.StandardDeviation()
#--> 7.39
```

## 8. On your world

How many requests of each kind your school received, as a data set: the mean count per kind and the largest.
What it prints depends on the world this course runs over, so the page shows no result: run it.

```ring
aReq = EduWorldObjects("requested")
aKinds = StzListQ(aReq).DuplicatesRemoved()
aCounts = []
for i = 1 to len(aKinds)
	aCounts + StzListQ(aReq).NumberOfOccurrence(aKinds[i])
next
oK = new stzDataSet(aCounts)
? EduWorldName()
? oK.Mean()
? oK.Median()
```

{{exercise:math-09-01}}

## Recap

- **Achieved:** you summarised eight values in words, mean and median and quartiles and outlier, then drew
  them as a box plot whose sentence and text say the same numbers, applied the fence rule by hand, compared
  two groups, and read the spread as one number.
- **Why it matters:** a summary is a claim about many numbers. When the words, the picture and the rule agree,
  the claim is checked three ways; when one disagrees, you know which.
- **Coming next:** chance. The next chapter throws a coin a thousand times and reads the proportion off the
  continuum from few to most.
