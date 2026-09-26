# The derivative that checks a formula

*Mathematics · Chapter 14 · Skill CR-02: "What would break if I were wrong?"*

A derivative is the slope of a curve at one place: how fast the value changes when the input moves a little.
Schools teach it as a formula to derive by hand, and a hand-written derivative can be wrong. The engine
computes the derivative of any expression it compiled, exactly, by walking the expression's own tape, so a
hand-written formula becomes a claim the tape can check. This chapter compiles a function, reads its
derivative off the tape, checks a right formula and catches a wrong one, and confirms the marks of chapter
4 with slopes.

## 1. Compile a function

A function is an expression over named variables, compiled once on the engine's tape. Ask its value at a
place.

```ring
oF = new stzMathFunction("x^3 - 2*x", [ "x" ])
? oF.ValueAt([ 2 ])
#--> 4
```

## 2. The derivative, off the tape

The derivative at two is ten. Nothing was derived by hand: the tape carries how each node changes with x,
and the engine reads the slope back.

```ring
? oF.DerivativeAt("x", [ 2 ])
#--> 10
```

## 3. A hand formula, checked

The textbook derivative of x cubed minus two x is three x squared minus two. At two it gives ten, and the
tape agrees. The formula was a claim; now it is a checked one.

```ring
? 3 * 2 * 2 - 2
#--> 10
? fabs( (3 * 2 * 2 - 2) - oF.DerivativeAt("x", [ 2 ]) ) < 0.000001
#--> 1
```

## 4. A wrong formula, caught

Write the derivative as three x squared minus one, a slip a tired hand makes. At two it gives eleven, and
the tape says no.

```ring
? 3 * 2 * 2 - 1
#--> 11
? fabs( (3 * 2 * 2 - 1) - oF.DerivativeAt("x", [ 2 ]) ) < 0.000001
#--> 0
```

## 5. A third witness: the finite difference

Move a little to each side of two and divide the change in value by the change in input. That is a slope
measured, not derived, and it agrees with the tape to a millionth.

```ring
h = 0.0001
nSlope = ( oF.ValueAt([ 2 + h ]) - oF.ValueAt([ 2 - h ]) ) / ( 2 * h )
? nSlope
#--> 10.00
? fabs( nSlope - 10 ) < 0.000001
#--> 1
```

## 6. Two variables, one gradient

With two variables the derivative is a pair, one slope per variable. For x y plus y squared at two and
three, the slope along x is three and along y is eight.

```ring
oG = new stzMathFunction("x*y + y^2", [ "x", "y" ])
? oG.ValueAt([ 2, 3 ])
#--> 15
? @@( oG.GradientAt([ 2, 3 ]) )
#--> [ 3, 8 ]
```

## 7. The slope of sine at zero

The derivative of sine is cosine. At zero the tape says one, and Ring's own cosine of zero says one.

```ring
oS = new stzMathFunction("sin(x)", [ "x" ])
? oS.DerivativeAt("x", [ 0 ])
#--> 1
? fabs( oS.DerivativeAt("x", [ 0 ]) - cos(0) ) < 0.000000001
#--> 1
```

## 8. The marks of chapter 4, confirmed by slopes

Chapter 4 found the extremum of x squared minus two at zero by watching the curve turn. The slope there is
zero, which is what an extremum means, and at the zero the slope is two times the square root of two.

```ring
oQ = new stzMathFunction("x^2 - 2", [ "x" ])
? oQ.DerivativeAt("x", [ 0 ])
#--> 0
? oQ.DerivativeAt("x", [ 1.41421356 ])
#--> 2.83
```

{{exercise:math-14-01}}

## Recap

- **Achieved:** you compiled a function on the tape, read its derivative at a place, checked a hand-written
  formula against it and caught a wrong one, measured the slope by a finite difference as a third witness,
  read a gradient of two variables, and confirmed the marks of chapter 4 with slopes.
- **Why it matters:** a formula derived by hand is a claim. The tape computes the same slope by another
  route, so the claim is checked by something that did not know the formula.
- **Coming next:** a check that cannot fail is not a check. The last chapter tells a self-check from an
  independent one, and shows why every positive needs a negative beside it.
