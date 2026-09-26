# A family under a parameter

*Mathematics · Chapter 5 · Skill FO-04: "Can I say what I want and let the engine decide how?"*

Write a letter where a number was, and one function becomes a family: a times the sine of x is one curve for
each value of a. A parameter is that letter with a range and a value, and a motion is the family moved. This
chapter declares a motion, moves its parameter, and reads what moves with it at two speeds: the curve at
once, the marks when the parameter settles.

## 1. Declare the family

The declaration is a function figure's, with the parameter written in braces. The parameter is then given
its range and where it starts.

```ring
oM = StzMathMotionQ(:Function, [ :f = "{a} * sin(x)", :on = [ -6.3, 6.3 ], :mark = [ :extrema ], :maxmarks = 3 ])
oM.Param("a", 1, 3, 1)
? oM.Value("a")
#--> 1
```

## 2. Settle: the figure where the parameter stands

Settling builds and solves the figure for the parameter's current value. The declaration it uses is the
family with the letter replaced by the number.

```ring
oM.Settle()
? @@( oM.Resolved() )
#--> [ "f", "(1) * sin(x)" ]
? oM.Figure().Why()
#--> a function figure: 400 samples in 1 piece(s), 4 mark(s)
```

## 3. Move the parameter: the curve follows at once

Set a to two. The motion is now dirty, which means its marks still say one while its curve already says two.
The curve is sampled from the family compiled once with a as a variable: two hundred and forty places, each
checked here against Ring's own sine.

```ring
oM.Set("a", 2)
? oM.IsDirty()
#--> 1
? oM.LiveSampleCount()
#--> 240
aS = oM.LiveSamples()
? fabs( aS[100][2] - 2 * sin( aS[100][1] ) ) < 0.000001
#--> 1
```

## 4. Settle again: the marks catch up

The extrema of two times sine are at plus and minus two, where the extrema of sine were at plus and minus
one. They are found again, not scaled.

```ring
oM.Settle()
? @@( oM.Figure().Extrema() )
#--> [ [ -1.57, -2 ], [ 1.57, 2 ], [ -4.71, 2 ], [ 4.71, -2 ] ]
? oM.IsDirty()
#--> 0
```

## 5. Declared states

A motion can be told as states: each a caption and the act that reaches it. A fact bound to a state is
computed on the picture at that state and shown in the caption where you wrote its name in braces.

```ring
oM.State("With a at one, the mark nearest the origin sits at {top}.", [ [ :Set, "a", 1 ] ])
oM.StateFact("top", :datum, [ "m1", "y" ])
oM.State("With a at three it sits at {top}.", [ [ :Set, "a", 3 ] ])
oM.StateFact("top", :datum, [ "m1", "y" ])
? oM.NumberOfStates()
#--> 2
```

## 6. Apply a state, read the fact

Applying the second state sets a to three and settles. The mark nearest the origin is a minimum, and its
height is minus three: the parameter, read back off the solved picture.

```ring
oM.Apply(2)
? oM.Picture().Fact(:datum, [ "m1", "y" ])[:message]
#--> m1 carries y = -3
? oM.Applied()
#--> 2
```

## 7. What the motion refuses

A parameter the declaration never writes is refused by name, and so is a state whose act is not an act.

```ring
try
	oM.Param("b", 0, 1, 0.5)
catch
	? "refused"
done
#--> refused
```

{{exercise:math-05-01}}

## Recap

- **Achieved:** you declared a family of functions under a parameter, settled it, moved the parameter and
  saw the curve follow at once while the marks waited for the settle, checked a live sample against Ring's
  own sine, declared two states with a bound fact, and applied one.
- **Why it matters:** a picture that moves is not a film. The curve is recomputed and the marks are found
  again, so what you see at every value of the parameter is as checked as the still picture was.
- **Coming next:** a construction is declared too. The next chapter declares a right triangle and a triangle
  in a semicircle, drags a vertex, and reads a theorem off the coordinates.
