# An identity is not a self-check

*Mathematics · Chapter 15 · Skill CR-02: "What would break if I were wrong?"*

A check is worth exactly as much as its chance of failing. Compute a number from a formula, then check the
formula against the number you just computed, and the check passes whatever the formula says: it is an
identity, and an identity proves nothing. A real check compares two independent routes to one truth, and it
must be able to fail. This chapter builds a check that cannot fail, then the same claim checked by a picture
that never heard of the formula, by a second algorithm, and by the tape, and shows the negative every
positive needs.

## 1. A check that cannot fail

Compute the hypotenuse from the two sides by the formula, then "check" the formula against it. Zero, always.

```ring
a = 3
b = 4
c = sqrt( a*a + b*b )
? a*a + b*b - c*c
#--> 0
```

## 2. A wrong formula checks itself just as well

Add one inside the root, which no right triangle allows, and check the wrong formula against its own
number. Zero again. The check did not notice, because it could not.

```ring
c2 = sqrt( a*a + b*b + 1 )
? a*a + b*b + 1 - c2*c2
#--> 0.00
```

## 3. The picture that never heard of the formula

Byrne's picture from chapter 6 was solved from three points and a right angle; the equality of the squares
was never a rule. Measure its three sides and check the formula against measurements that did not come from
it. Now the check could have failed, and it did not.

```ring
oP = StzPythagorasPictureQ( StzMathFigureFont() )
nAB = oP.Fact(:distance, [ "A.icon", "B.icon" ])[:value]
nAC = oP.Fact(:distance, [ "A.icon", "C.icon" ])[:value]
nBC = oP.Fact(:distance, [ "B.icon", "C.icon" ])[:value]
? fabs( nBC*nBC - nAB*nAB - nAC*nAC ) < 0.01
#--> 1
```

## 4. Two algorithms for one number

The function figure finds the zero of x squared minus three by bracketing a sign change. Ring's square root
finds the same number by another algorithm. Two routes, one truth, to a millionth.

```ring
oFig = StzMathFigureQ(:Function, [ :f = "x^2 - 3", :on = [ -3, 3 ], :mark = [ :zeros ] ])
aZ = oFig.Zeros()
z = aZ[1][1]
? z
#--> 1.73
? fabs( z - sqrt(3) ) < 0.000001
#--> 1
```

## 5. The negative every positive needs

A check that says yes is only evidence if it would have said no to a wrong answer. Hand it one: one and a
half is not the root of three, and the same check refuses it.

```ring
? fabs( 1.5 * 1.5 - 3 ) < 0.000001
#--> 0
```

## 6. The tape as a third route

Chapter 4 found the extremum of x squared minus two by watching the curve turn; chapter 14 read the slope
off the tape. An extremum is where the slope is zero, and the tape agrees without having watched the curve.

```ring
oQ = new stzMathFunction("x^2 - 2", [ "x" ])
? oQ.DerivativeAt("x", [ 0 ])
#--> 0
? oQ.DerivativeAt("x", [ 1 ])
#--> 2
```

## 7. On your world

Count this week's requests at your school two ways: the length of the list, and the sum of the counts by
kind. Two routes to one number; the page shows no result, because it depends on the world: run it.

```ring
aReq = EduWorldObjects("requested")
aKinds = StzListQ(aReq).DuplicatesRemoved()
nSum = 0
for i = 1 to len(aKinds)
	nSum += StzListQ(aReq).NumberOfOccurrence(aKinds[i])
next
? EduWorldName()
? len(aReq)
? nSum
```

{{exercise:math-15-01}}

## Recap

- **Achieved:** you built a check that cannot fail and watched it pass a wrong formula, then checked the
  same claim against a picture that never heard of it, against a second algorithm, and against the tape,
  and gave the check a wrong answer to refuse.
- **Why it matters:** every claim in this course carried its check, and this chapter says what made those
  checks worth anything: they compared independent routes, and each could have failed.
- **Coming next:** this is the last chapter written. Tukey's first look at data takes chapter 13 when the
  Tukey tier is built, and the course prints it as planned and unwritten until then.
