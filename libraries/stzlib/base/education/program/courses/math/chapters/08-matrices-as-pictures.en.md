# Matrices as pictures

*Mathematics · Chapter 8 · Skill PA-04: "Which cells answer my question?"*

A matrix is a grid of numbers, and a product of two matrices is a grid whose every cell is a row of the first
met with a column of the second. Said as a picture, a product is three grids side by side, with the row, the
column and the cell they make lit together. This chapter declares matrices as figures, reads a cell off the
figure, checks a product cell by hand, and asks the figure to refuse what cannot multiply.

## 1. One grid

A matrix figure is declared by its rows. The figure counts its cells and names them by grid letter, row and
column: the first grid is a, its second row and first column is a2_1.

```ring
oA = StzMathFigureQ(:Matrix, [ :of = [ [ 1, 2 ], [ 3, 4 ] ], :label = "A" ])
? oA.Why()
#--> a matrix figure: A (2 x 2), 4 cells
? oA.Fact(:datum, [ "a2_1", "v" ])[:message]
#--> a2_1 carries v = 3
```

## 2. A product, as three grids

Declare a product and the figure draws A, B and A times B, computes every cell of the result, and lights the
row and column that make the cell you ask to see.

```ring
oP = StzMathFigureQ(:Matrix, [ :product = [ [ [ 2, 7, 1, 8 ], [ 2, 8, 1, 8 ], [ 2, 8, 4, 5 ] ],
                                            [ [ 1, 0 ], [ 0, 1 ], [ 2, 3 ], [ 1, 1 ] ] ], :show = [ 2, 1 ] ])
? oP.Why()
#--> a matrix figure: A (3 x 4) . B (4 x 2) = A . B (3 x 2), 26 cells
```

## 3. The picture judges itself

A matrix figure carries three rules: a product cell is the dot product of its row and its column, the
dimensions agree, and every grid holds its cells. The figure checks them on its own picture.

```ring
? len( oP.Violations() )
#--> 0
```

## 4. A product cell, checked by hand

The lit cell is row 2 of A met with column 1 of B. Read it off the figure, then compute it yourself: two
times one, plus eight times zero, plus one times two, plus eight times one.

```ring
? oP.Fact(:datum, [ "c2_1", "v" ])[:message]
#--> c2_1 carries v = 12
? 2 * 1 + 8 * 0 + 1 * 2 + 8 * 1
#--> 12
```

## 5. What cannot multiply

A row of A must be as long as a column of B is tall. A product that breaks this is refused by name, with the
two numbers that disagree.

```ring
try
	StzMathFigureQ(:Matrix, [ :product = [ [ [ 1, 2 ] ], [ [ 1, 2 ] ] ] ])
catch
	? "refused"
done
#--> refused
```

## 6. Numbers as colour

Asked to show a matrix as heat, the figure colours every cell on one ramp from its smallest value to its
largest. The ramp position is a number the figure carries: the largest value sits at one.

```ring
oH = StzMathFigureQ(:Matrix, [ :of = [ [ 4, 1, 0 ], [ 1, 4, 1 ], [ 0, 1, 4 ] ], :as = :heat, :label = "A" ])
? oH.Why()
#--> a matrix figure: A (3 x 3), 9 cells on one ramp
? oH.Fact(:datum, [ "a2_2", "t" ])[:message]
#--> a2_2 carries t = 1
```

## 7. On your world

One row: how many requests of each kind your school received this week, drawn as a matrix. What it prints
depends on the world this course runs over, so the page shows no result: run it.

```ring
aReq = EduWorldObjects("requested")
aKinds = StzListQ(aReq).DuplicatesRemoved()
aRow = []
for i = 1 to len(aKinds)
	aRow + StzListQ(aReq).NumberOfOccurrence(aKinds[i])
next
oW = StzMathFigureQ(:Matrix, [ :of = [ aRow ], :label = "requests by kind" ])
? EduWorldName()
? oW.Why()
```

{{exercise:math-08-01}}

## Recap

- **Achieved:** you declared a matrix as a figure, read a cell by its name, declared a product and saw its
  three grids, checked a product cell by hand against the figure's own value, saw a product refused for its
  dimensions, and coloured a matrix on one ramp.
- **Why it matters:** a product is twenty-six cells and one rule. The figure computes every cell and carries
  the rule, so the one cell you check by hand stands for all of them.
- **Coming next:** a handful of numbers, and the words that summarise them. The next chapter draws a box plot
  and reads the median, the quartiles and the outliers off the picture.
