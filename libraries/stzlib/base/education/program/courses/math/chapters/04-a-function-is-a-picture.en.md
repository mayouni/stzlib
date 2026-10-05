# A function is a picture

*Mathematics · Chapter 4 · Skill SE-02: "Where, and how much?"*

A function is a rule that turns one number into another, and its picture is the set of all the places the rule
reaches. The picture answers what the formula hides: where the rule gives zero, where it stops rising and
starts falling, where it breaks. This chapter declares a function as a figure. The curve is computed by the
engine; the marks on it are found, placed and then checked, one by one, by arithmetic.

## 1. Declare the function

A function figure is declared by its formula, the range to draw it on, and the marks you want found.

```ring
oF = StzMathFigureQ(:Function, [ :f = "x^2 - 2", :on = [ -3, 3 ], :mark = [ :zeros, :extrema ] ])
? oF.Why()
#--> a function figure: 400 samples in 1 piece(s), 3 mark(s)
```

## 2. Where it is zero, and where it turns

The figure found two zeros and one extremum. Each mark is a place: an x and a y.

```ring
? @@( oF.Zeros() )
#--> [ [ 1.41, -0.00 ], [ -1.41, -0.00 ] ]
? @@( oF.Extrema() )
#--> [ [ 0, -2 ] ]
```

## 3. A mark is a claim, and the claim is checked

The figure says the curve is zero at 1.41. Arithmetic checks it: square that number and take two away, and
what remains is smaller than a millionth. The figure found the square root of two without being told it.

```ring
aZ = oF.Zeros()
z = aZ[1][1]
? z
#--> 1.41
? fabs( z * z - 2 ) < 0.000001
#--> 1
```

## 4. The picture judges itself

A function figure carries rules: a zero mark brackets a sign change, an extremum mark brackets a turn, and
every note reads near its mark. Zero violations is computed, not promised.

```ring
? len( oF.Violations() )
#--> 0
```

## 5. The window is chosen from the curve

The figure looks at the values it computed and leaves air above and below them, so the marks never touch the
frame. The window is four numbers: from and to on x, then on y.

```ring
? @@( oF.Window() )
#--> [ -3, 3, -3.33, 8.33 ]
```

## 6. Other ways to say a curve

A curve need not be y of x. A circle is x and y of a third number t, and a rose is a distance r of an angle
t. Nothing on these curves is marked, so there is nothing to solve: the figure says so.

```ring
oCircle = StzMathFigureQ(:Function, [ :x = "cos(t)", :y = "sin(t)", :t = [ 0, 6.2832 ], :label = "a circle" ])
? oCircle.Why()
#--> a function figure: 400 samples in 1 piece(s), 0 mark(s); nothing to lay out
oRose = StzMathFigureQ(:Function, [ :r = "cos(3*t)", :t = [ 0, 3.1416 ], :label = "a rose" ])
? oRose.Why()
#--> a function figure: 400 samples in 1 piece(s), 0 mark(s); nothing to lay out
```

## 7. A tangent at a place you name

Ask for the tangent at x equal to one and the figure adds a given mark there, with the curve's height at that
place: sine of one is 0.84.

```ring
oT = StzMathFigureQ(:Function, [ :f = "sin(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ], :tangent = 1, :maxmarks = 4 ])
? @@( oT.Marks() )
#--> [ "given", 1, 0.84 ]
```

## 8. Where the rule breaks

One over x minus one has no value at x equal to one. The figure does not draw through the break: it draws
two pieces and says where it could not go.

```ring
oP = StzMathFigureQ(:Function, [ :f = "1 / (x - 1)", :on = [ -3, 4 ] ])
? oP.Why()
#--> a function figure: 400 samples in 2 piece(s), 0 mark(s), 1 place(s) not finite
? oP.PieceCount()
#--> 2
```

## 9. On your world

A line through the origin whose slope is the number of requests your school received this week. What it
prints depends on the world this course runs over, so the page shows no result: run it.

```ring
aReq = EduWorldObjects("requested")
oW = StzMathFigureQ(:Function, [ :f = "" + len(aReq) + " * x", :on = [ -2, 2 ], :mark = [ :zeros ] ])
? EduWorldName()
? oW.Why()
```

{{exercise:math-04-01}}

## Recap

- **Achieved:** you declared a function as a figure, read where it is zero and where it turns, checked a zero
  by arithmetic, read the window the figure chose, drew a circle and a rose, asked for a tangent, and saw the
  figure stop at a break instead of drawing through it.
- **Why it matters:** the curve is computed and the marks are found, so every place the picture names is a
  claim you can check with one line of arithmetic, and this chapter did.
- **Coming next:** put a letter in the formula and the picture becomes a family. The next chapter moves the
  letter and watches what moves with it.
