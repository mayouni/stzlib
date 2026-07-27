load "../../stzBase.ring"
load "../_narrated.ring"

# REVERSE-MODE AUTOMATIC DIFFERENTIATION (numeric phase 6, slice 1).
#
# The plan calls this "the multiplier": with gradients of an arbitrary expression,
# L-BFGS is a few hundred lines and the library can be handed an objective it has
# never seen. This is that piece.
#
# HOW IT WORKS, because the code is short enough that the idea is the hard part. The
# expression compiles to a flat list of nodes in evaluation order, each naming its
# operands by index -- a tape. A forward pass fills every node's value. A backward
# pass then walks the SAME list in reverse carrying an adjoint (d result / d node),
# seeded at 1 for the result, and each node hands its adjoint to its operands by the
# chain rule.
#
# THE PAYOFF IS IN THAT ONE BACKWARD PASS: it produces the derivative with respect to
# EVERY variable at once. Finite differences need n+1 evaluations for n variables and
# are approximate no matter what -- too large a step and the truncation error shows,
# too small and rounding eats the difference of two nearly equal numbers. Reverse
# mode is exact to floating point and costs about the same as evaluating twice.
#
# WHY NOT W(), THE EXPRESSION LANGUAGE THIS LIBRARY ALREADY HAS. It was the first
# thing checked, because two definitions of one thing is the defect this project has
# paid for most often. It is the wrong tool rather than an awkward one: W() is a
# PREDICATE DSL for filtering lists. Its variable is "the current item", and its
# vocabulary is IsVowel, IsArabic, StartsWith, Replace. It has no exp, no log, no
# sin, no pow -- none of the functions an objective is written with -- and no named
# variables at all. The infix SYNTAX is deliberately identical (same operators, same
# precedence, same call form) so nobody learns a second language; what differs is the
# domain, and the domain is the whole point.
#
# THE VALIDATION THAT MATTERS is the last scenario. The library already contains a
# hand-derived backpropagation in stzTrainer, written independently and years apart
# from this. Two implementations of one derivative, agreeing to ten decimals, is a
# much stronger statement than either one agreeing with a step size.

Scenario("derivatives you can check by hand")
	oF = new stzMathFunction("x^2 + 3*x*y", [ "x", "y" ])
	# f(2,3) = 4 + 18 = 22 ; df/dx = 2x + 3y = 13 ; df/dy = 3x = 6
	Then("the value", oF.ValueAt([2,3]), 22)
	Then("d/dx", oF.DerivativeAt("x", [2,3]), 13)
	Then("d/dy", oF.DerivativeAt("y", [2,3]), 6)
	Then("...and the gradient is both at once", @@(oF.GradientAt([2,3])), "[ 13, 6 ]")

	oG = new stzMathFunction("exp(x)", [ "x" ])
	Then("d(exp)/dx at 0 is 1", oG.DerivativeAt("x", [0]), 1)
	oH = new stzMathFunction("log(x)", [ "x" ])
	Then("d(log)/dx at 4 is a quarter", oH.DerivativeAt("x", [4]), 0.25)
	oS = new stzMathFunction("sqrt(x)", [ "x" ])
	Then("d(sqrt)/dx at 9 is 1/6", Rnd8(oS.DerivativeAt("x", [9])), Rnd8(1.0/6))
	oC = new stzMathFunction("sin(x)", [ "x" ])
	Then("d(sin)/dx at 0 is 1", oC.DerivativeAt("x", [0]), 1)
	oTh = new stzMathFunction("tanh(x)", [ "x" ])
	Then("d(tanh)/dx at 0 is 1", oTh.DerivativeAt("x", [0]), 1)
EndScenario()

Scenario("a shared subexpression accumulates rather than overwrites")
	# x appears four times. If the backward pass ASSIGNED adjoints instead of adding
	# them, this would answer 2x instead of 4x -- the classic reverse-mode bug, and
	# invisible on any expression where each variable appears once.
	oF = new stzMathFunction("x*x + x*x", [ "x" ])
	Then("f(3) = 18", oF.ValueAt([3]), 18)
	Then("f'(3) = 12, not 6", oF.DerivativeAt("x", [3]), 12)

	oG = new stzMathFunction("(x+y)*(x+y)", [ "x", "y" ])
	# d/dx = 2(x+y) = 10 at (2,3)
	Then("both operands of a shared node get their share", oG.DerivativeAt("x", [2,3]), 10)
	Then("...and so does the other", oG.DerivativeAt("y", [2,3]), 10)
EndScenario()

Scenario("one backward pass, every variable")
	# ten variables, one call. This is the property that makes the tape worth having:
	# finite differences would need eleven evaluations for the same answer.
	acV = [ "a", "b", "c", "d", "e1", "f", "g1", "h", "i", "j" ]
	oF = new stzMathFunction("a+2*b+3*c+4*d+5*e1+6*f+7*g1+8*h+9*i+10*j", acV)
	aP = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
	Then("the value", oF.ValueAt(aP), 385)
	aG = oF.GradientAt(aP)
	Then("ten gradients came back", len(aG), 10)
	Then("the first is 1", aG[1], 1)
	Then("the fifth is 5", aG[5], 5)
	Then("the tenth is 10", aG[10], 10)
EndScenario()

Scenario("against finite differences, where they can still be trusted")
	# A step size of 1e-6 on a well-scaled function is about as good as finite
	# differences get. Agreement to 1e-6 is therefore the RIGHT tolerance here --
	# tightening it further would be testing the step size, not the gradient.
	oF = new stzMathFunction("exp(-(x*x + y*y)) * sin(3*x) / (1 + abs(y))", [ "x", "y" ])
	aP = [ 0.37, -0.62 ]
	aG = oF.GradientAt(aP)

	nH = 0.000001
	nNumX = (oF.ValueAt([aP[1]+nH, aP[2]]) - oF.ValueAt([aP[1]-nH, aP[2]])) / (2*nH)
	nNumY = (oF.ValueAt([aP[1], aP[2]+nH]) - oF.ValueAt([aP[1], aP[2]-nH])) / (2*nH)

	Then("d/dx agrees with a central difference", fabs(aG[1] - nNumX) < 0.000001, TRUE)
	Then("d/dy too", fabs(aG[2] - nNumY) < 0.000001, TRUE)
	Then("...and they are not trivially zero", fabs(aG[1]) > 0.01, TRUE)
EndScenario()

Scenario("the syntax reads the way it is written")
	oA = new stzMathFunction("2 + 3 * x", [ "x" ])
	Then("multiplication binds tighter than addition", oA.ValueAt([4]), 14)
	oB = new stzMathFunction("2 ^ 3 ^ 2", [ "x" ])
	Then("^ is right-associative: 2^(3^2), not (2^3)^2", oB.ValueAt([0]), 512)
	oC = new stzMathFunction("-x ^ 2", [ "x" ])
	Then("unary minus applies to the power", oC.ValueAt([3]), -9)
	oD = new stzMathFunction("x ^ -2", [ "x" ])
	Then("a negative exponent parses", oD.ValueAt([2]), 0.25)
	oE = new stzMathFunction("sin(pi/2) + 0*x", [ "x" ])
	Then("pi is a constant, not a variable", Rnd8(oE.ValueAt([5])), 1)
	oF = new stzMathFunction("log(e) + 0*x", [ "x" ])
	Then("...and so is e", Rnd8(oF.ValueAt([5])), 1)
	oG = new stzMathFunction("X + Y", [ "x", "y" ])
	Then("names match case-insensitively, as Ring does", oG.ValueAt([1,2]), 3)
EndScenario()

Scenario("what it refuses, and whether it says why")
	# A null handle says only 'no'. This library has been bitten before by an error
	# that named the wrong cause, so the reason is carried back in words.
	Then("an unknown name is refused", RaisesF("x + zz", ["x"]), TRUE)
	Then("...naming the problem", StzFindFirst("not one of the variables",
	     WhyF("x + zz", ["x"])) > 0, TRUE)
	Then("an unknown function is refused", RaisesF("wobble(x)", ["x"]), TRUE)
	Then("...and says so", StzFindFirst("function", WhyF("wobble(x)", ["x"])) > 0, TRUE)
	Then("an unclosed parenthesis is refused", RaisesF("(x + 1", ["x"]), TRUE)
	Then("...and says so", StzFindFirst("parenthesis", WhyF("(x + 1", ["x"])) > 0, TRUE)
	Then("a dangling operator is refused", RaisesF("x +", ["x"]), TRUE)
	Then("a stray character is refused", RaisesF("x $ 2", ["x"]), TRUE)
	Then("an empty expression is refused", RaisesF("", ["x"]), TRUE)
	Then("no variables at all is refused", RaisesF("1+1", []), TRUE)

	oF = new stzMathFunction("x+y", ["x","y"])
	Then("a point of the wrong size is refused", RaisesAt(oF, [1]), TRUE)
	Then("...saying how many were wanted",
	     StzFindFirst("2 variable(s)", WhyAt(oF, [1])) > 0, TRUE)
	Then("asking for a variable it does not have is refused",
	     RaisesDeriv(oF, "z", [1,2]), TRUE)
EndScenario()

Scenario("THE CROSS-CHECK: the tape against the library's hand-derived backprop")
	# stzTrainer contains a backpropagation written by hand, independently of this,
	# and its comment records a deliberate subtlety: for a sigmoid output it uses
	# delta = (a - y), which is the gradient of BINARY CROSS-ENTROPY, while the loss
	# it REPORTS is squared error. Checking it against the squared-error derivative
	# shows a factor of about two and looks like a bug. Checking it against the loss
	# it actually differentiates shows agreement to ten decimals.
	#
	# So this is two independent implementations of one derivative -- a hand-derived
	# chain rule written for a fixed network, and a general reverse-mode tape -- and
	# they must agree. That is a far stronger statement than either one agreeing with
	# a finite-difference step.
	#
	# The network: 1 input -> 1 tanh unit -> 1 sigmoid unit, so the whole loss fits
	# in one expression and every weight is a named variable.
	nX = 0.4
	nY = 1
	nW1 = 0.3   nB1 = -0.2   nW2 = 0.7   nB2 = 0.1

	cA1 = "tanh(w1*" + nX + " + b1)"
	cZ2 = "(w2*" + cA1 + " + b2)"
	cA2 = "1/(1+exp(-" + cZ2 + "))"
	cLoss = "-( " + nY + "*log(" + cA2 + ") + (1-" + nY + ")*log(1-" + cA2 + ") )"

	oL = new stzMathFunction(cLoss, [ "w1", "b1", "w2", "b2" ])
	aG = oL.GradientAt([ nW1, nB1, nW2, nB2 ])

	# the same network in the library, one SGD step, gradient read back from the move
	oN = new stzNeuralNetwork([ :Inputs = 1 ])
	oN.AddDenseLayer(1, :Tanh)
	oN.AddDenseLayer(1, :Sigmoid)
	oN.AdoptLayers([ [ 1, "tanh", [[nW1]], [nB1] ], [ 1, "sigmoid", [[nW2]], [nB2] ] ])
	oT = new stzTrainer()
	oT.SetLearningRate(0.01)
	oT.Train(oN, [ [nX] ], [ [nY] ], 1)
	aAfter = oN.Layers()

	nBpW1 = (nW1 - aAfter[1][3][1][1]) / 0.01
	nBpB1 = (nB1 - aAfter[1][4][1]) / 0.01
	nBpW2 = (nW2 - aAfter[2][3][1][1]) / 0.01
	nBpB2 = (nB2 - aAfter[2][4][1]) / 0.01

	Then("d/dw1 agrees with backprop", Rnd8(aG[1]), Rnd8(nBpW1))
	Then("d/db1 agrees", Rnd8(aG[2]), Rnd8(nBpB1))
	Then("d/dw2 agrees", Rnd8(aG[3]), Rnd8(nBpW2))
	Then("d/db2 agrees", Rnd8(aG[4]), Rnd8(nBpB2))
	Then("...and the gradients are not all zero", fabs(aG[1]) > 0.0001, TRUE)

	# AND THE MISMATCH THE COMMENT WARNS ABOUT, pinned so it stays visible: the
	# trainer minimises cross-entropy but REPORTS squared error, so a user watching
	# FinalLoss() is watching a different quantity from the one being minimised.
	cSq = "(" + cA2 + " - " + nY + ")^2"
	oSq = new stzMathFunction(cSq, [ "w1", "b1", "w2", "b2" ])
	aSq = oSq.GradientAt([ nW1, nB1, nW2, nB2 ])
	Then("the squared-error gradient is a DIFFERENT number",
	     Rnd8(aSq[1]) != Rnd8(nBpW1), TRUE)
	Then("...which is why checking against it looked like a bug",
	     fabs(aSq[1]) > 0, TRUE)
EndScenario()

Summary()

func Rnd8(n)
	return ceil(n * 100000000 - 0.5) / 100000000

func RaisesF(c, ac)
	b = FALSE
	try
		o = new stzMathFunction(c, ac)
	catch
		b = TRUE
	done
	return b

func WhyF(c, ac)
	s = ""
	try
		o = new stzMathFunction(c, ac)
	catch
		s = cCatchError
	done
	return s

func RaisesAt(o, aP)
	b = FALSE
	try
		v = o.ValueAt(aP)
	catch
		b = TRUE
	done
	return b

func WhyAt(o, aP)
	s = ""
	try
		v = o.ValueAt(aP)
	catch
		s = cCatchError
	done
	return s

func RaisesDeriv(o, c, aP)
	b = FALSE
	try
		v = o.DerivativeAt(c, aP)
	catch
		b = TRUE
	done
	return b
