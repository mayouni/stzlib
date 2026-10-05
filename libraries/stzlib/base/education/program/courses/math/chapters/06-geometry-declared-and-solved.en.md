# Geometry declared and solved

*Mathematics · Chapter 6 · Skill CR-02: "What would break if I were wrong?"*

A geometry picture is not drawn: it is declared and solved. You say what there is, three points and a
triangle, a circle and what lies on it, and a solver finds coordinates that keep every rule. A theorem is
then something you read off the solved coordinates, never something you told the picture to make true. This
chapter builds two pictures the library keeps as stories, Euclid's I.47 in Byrne's colours and Thales'
theorem, drags a vertex in each, and reads the theorem back at every position.

## 1. Byrne's right triangle

Three points, a triangle, a right angle at A: the substance says that much, and the style derives every
square from the three points. Ask the solved picture what the angle at A is.

```ring
oP = StzPythagorasPictureQ( StzMathFigureFont() )
? oP.Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
#--> the angle at A.icon is 90.00 degrees
```

## 2. A theorem read off the coordinates

Nothing in the picture asserts that the two smaller squares make the larger one. The expression below is the
difference between them, computed from the solved points, and it is smaller than a hundredth of a square
pixel.

```ring
aGap = oP.Fact(:expr, [ StzPythagorasGapExpr(), "px^2" ])
? fabs( aGap[:value] ) < 0.01
#--> 1
```

## 3. Drag a vertex: the theorem holds

A motion over the picture drags A. The squares are derived from the points, so they follow; the right angle
is a rule, so the solver keeps it; the equality was never a rule, and it holds anyway.

```ring
oM = StzMathMotionOverQ(oP)
oM.State("A moved: a^2 + b^2 - c^2 = {gap} px^2", [ [ :DragBy, "A.icon", 60, -30 ] ])
oM.StateFact("gap", :expr, [ StzPythagorasGapExpr(), "px^2" ])
oM.Apply(1)
? oM.Picture().Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
#--> the angle at A.icon is 90.00 degrees
? fabs( oM.Picture().Fact(:expr, [ StzPythagorasGapExpr(), "px^2" ])[:value] ) < 0.01
#--> 1
```

## 4. Thales: three points on a circle

The second story says three things: B and C are on the circle, BC runs through its centre, A is on the
circle. It never says the angle at A is right. Read it.

```ring
oT = StzThalesPictureQ( StzMathFigureFont() )
? oT.Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
#--> the angle at A.icon is 90.00 degrees
? oT.Substance().Holds("Right", [ "BAC" ])
#--> 0
```

## 5. Move A along the circle

Drag A anywhere. The solver keeps A on the circle and the diameter through the centre, and the angle at A
reads ninety again. That is Thales' theorem: a consequence of the construction, at every position.

```ring
oN = StzMathMotionOverQ(oT)
oN.State("A moved: the angle at A is {angle} degrees", [ [ :DragBy, "A.icon", 90, 40 ] ])
oN.StateFact("angle", :angle, [ "B.icon", "A.icon", "C.icon" ])
oN.Apply(1)
? oN.Picture().Fact(:angle, [ "B.icon", "A.icon", "C.icon" ])[:message]
#--> the angle at A.icon is 90.00 degrees
? fabs( oN.Picture().Fact(:expr, [ "dist(A.icon, K.icon) - K.icon.r", "px" ])[:value] ) < 0.01
#--> 1
```

## 6. What a drag refuses

Only a shape whose position the solver owns can be dragged. A square of Byrne's figure is derived from the
points, so a state that drags it is refused by name.

```ring
try
	oM.State("x", [ [ :DragBy, "ABC.sqbc", 10, 10 ] ])
catch
	? "refused"
done
#--> refused
```

{{exercise:math-06-01}}

## Recap

- **Achieved:** you built Euclid's I.47 and Thales' picture from their declarations, read the right angle and
  the equality off the solved coordinates, dragged a vertex in each through a declared state, and read the
  theorem again where the vertex landed.
- **Why it matters:** a theorem the picture was never asked to satisfy, and satisfies at every position, is
  evidence of a different kind from a drawing that was made to look right. What would break if the theorem
  were wrong is exactly what this chapter reads.
- **Coming next:** a number that says why it is not exact. The next chapter meets the library's exact numbers
  and the moment a computation leaves them.
