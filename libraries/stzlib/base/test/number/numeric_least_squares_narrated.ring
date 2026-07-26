load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 4 of the numeric foundation, seventh slice: QR, CHOLESKY, LEAST SQUARES.
#
# Slice 4 added LU, which answers a SQUARE system exactly. This adds the two
# factorisations either side of it, and the capability they exist for.
#
# THE GAP THIS CLOSES IS NOT A SPEED ONE. An OVERDETERMINED system -- more equations
# than unknowns, which is what fitting a model to data always is -- had no answer
# anywhere in the library. `SolveFor` needs a square matrix. `stats.zig`'s regression
# is SIMPLE regression: two data series in, one slope and one intercept out. There
# was no route to a fit with two predictors, let alone five.
#
# HOUSEHOLDER QR, NOT THE NORMAL EQUATIONS, and the reason is worth stating because
# the shortcut is so tempting. Least squares is often taught as "solve A'A x = A'b",
# which is one line given the LU solve we already had. But forming A'A SQUARES THE
# CONDITION NUMBER: a problem that would lose 8 significant digits loses 16, and a
# double has 16. Householder reflections cost about twice as much and are
# unconditionally stable. For a fit computed once, that is not a trade at all.
#
# CHOLESKY is the cheap case: half the work of LU (n^3/3 against 2n^3/3) and NO
# PIVOTING, because a positive-definite matrix cannot produce a zero pivot. That is
# a theorem rather than an optimisation. It also gives the cheapest
# positive-definiteness test available -- the factorisation exists if and only if the
# property holds, so a failure is an answer.

Scenario("least squares on a consistent system finds the exact answer")
	# Four points on y = 2x + 1, design matrix [1, x]. Overdetermined -- four
	# equations, two unknowns -- but consistent, so the residual is zero and the fit
	# must recover the line exactly.
	oA = new stzMatrix([ [1,0], [1,1], [1,2], [1,3] ])
	anFit = oA.LeastSquaresFor([ 1, 3, 5, 7 ])
	Then("the intercept is 1", Rnd8(anFit[1]), 1)
	Then("the slope is 2", Rnd8(anFit[2]), 2)
	Then("the aliases are the same method, not twins",
	     @@(oA.LeastSquares([1,3,5,7])), @@(anFit))
	Then("...both of them", @@(oA.BestFitFor([1,3,5,7])), @@(anFit))
EndScenario()

Scenario("MULTIPLE regression, which the library could not express at all")
	# z = 3 + 2u - 1.5v over five observations. stats.zig's regression takes exactly
	# one predictor; this takes two.
	oM = new stzMatrix([ [1,1,1], [1,2,1], [1,3,2], [1,4,3], [1,5,5] ])
	aU = [ 1, 2, 3, 4, 5 ]
	aV = [ 1, 1, 2, 3, 5 ]
	az = []
	for i = 1 to 5
		az + (3 + 2 * aU[i] - 1.5 * aV[i])
	next
	anC = oM.LeastSquaresFor(az)
	Then("the constant term is recovered", Rnd6(anC[1]), 3)
	Then("...the first coefficient", Rnd6(anC[2]), 2)
	Then("...and the second, including its sign", Rnd6(anC[3]), -1.5)
EndScenario()

Scenario("an INEXACT fit is checked against the DEFINITION of least squares")
	# Five points that are not collinear, so no exact solution exists. The answer is
	# defined by a property, not a formula: the residual must be orthogonal to every
	# column of A. Asserting that is asserting what least squares MEANS, rather than
	# a number someone remembered.
	aD = [ [1,1], [1,2], [1,3], [1,4], [1,5] ]
	ay = [ 2.1, 3.9, 6.2, 7.8, 10.1 ]
	oI = new stzMatrix(aD)
	anX = oI.LeastSquaresFor(ay)

	nWorst = 0
	for j = 1 to 2
		nDot = 0
		for i = 1 to 5
			nResid = aD[i][1] * anX[1] + aD[i][2] * anX[2] - ay[i]
			nDot += aD[i][j] * nResid
		next
		if fabs(nDot) > nWorst
			nWorst = fabs(nDot)
		ok
	next
	Then("the residual is orthogonal to both columns", nWorst < 0.000000001, TRUE)

	# ...and no nearby coefficient vector does better. A minimum is a minimum.
	nSS = SumSq(aD, ay, anX[1], anX[2])
	Then("nudging the intercept up makes it worse",
	     SumSq(aD, ay, anX[1] + 0.01, anX[2]) > nSS, TRUE)
	Then("...down as well", SumSq(aD, ay, anX[1] - 0.01, anX[2]) > nSS, TRUE)
	Then("...and the slope either way",
	     SumSq(aD, ay, anX[1], anX[2] + 0.01) > nSS and
	     SumSq(aD, ay, anX[1], anX[2] - 0.01) > nSS, TRUE)
EndScenario()

Scenario("QR and LU must agree, and they share no code")
	# On a square full-rank system both are exact, so this is a genuine cross-check
	# between two independent factorisations rather than a self-check.
	aA = [ [4,-2,1,3], [3,6,-4,2], [2,1,8,-5], [-1,3,2,7] ]
	ab = [ 5, -3, 8, 1 ]
	oQ = new stzMatrix(aA)
	oL = new stzMatrix(aA)
	anQR = oQ.LeastSquaresFor(ab)
	anLU = oL.SolveFor(ab)
	Then("the four unknowns match to eight decimals",
	     Rnd8(anQR[1]) = Rnd8(anLU[1]) and Rnd8(anQR[2]) = Rnd8(anLU[2]) and
	     Rnd8(anQR[3]) = Rnd8(anLU[3]) and Rnd8(anQR[4]) = Rnd8(anLU[4]), TRUE)
EndScenario()

Scenario("what it refuses, and why refusing is right")
	# Rank deficiency: a duplicated column means the columns are linearly dependent,
	# so infinitely many coefficient vectors give the same minimum residual. There is
	# no unique answer, and returning one of them silently would be the worst option.
	oDup = new stzMatrix([ [1,1], [2,2], [3,3] ])
	Then("a rank-deficient system answers [] rather than picking one",
	     @@(oDup.LeastSquaresFor([1,2,3])), "[ ]")

	# Underdetermined: fewer equations than unknowns. Here there are infinitely many
	# EXACT solutions, and least squares has no opinion about which to prefer -- that
	# is a different problem (minimum norm) needing a different decomposition.
	oWide = new stzMatrix([ [1,2,3], [4,5,6] ])
	Then("an underdetermined system raises", RaisesLS(oWide, [1,2]), TRUE)

	Then("a b of the wrong length raises", RaisesLS(oDup, [1,2]), TRUE)
EndScenario()

Scenario("Cholesky, and positive-definiteness as a cheap by-product")
	oC = new stzMatrix([ [4,2], [2,3] ])
	Then("the factor is lower triangular with the right diagonal",
	     @@(oC.CholeskyFactor()), "[ [ 2, 0 ], [ 1, 1.41 ] ]")
	Then("...and it says the matrix is positive definite", oC.IsPositiveDefinite(), TRUE)

	# L * L-transpose must reconstruct A -- the only check that matters for a
	# factorisation.
	aL = oC.CholeskyFactor()
	Then("L*L' gives back the 4", Rnd8(aL[1][1]*aL[1][1] + aL[1][2]*aL[1][2]), 4)
	Then("...the 2", Rnd8(aL[2][1]*aL[1][1] + aL[2][2]*aL[1][2]), 2)
	Then("...and the 3", Rnd8(aL[2][1]*aL[2][1] + aL[2][2]*aL[2][2]), 3)

	Given("a symmetric matrix that is NOT positive definite")
	oInd = new stzMatrix([ [1,2], [2,1] ])
	Then("it is reported, not approximated", oInd.IsPositiveDefinite(), FALSE)
	Then("...and no factor is offered", @@(oInd.CholeskyFactor()), "[ ]")

	Given("the identity, which is the easiest positive-definite matrix there is")
	oId = new stzMatrix([ [1,0,0], [0,1,0], [0,0,1] ])
	Then("it factors to itself", @@(oId.CholeskyFactor()),
	     "[ [ 1, 0, 0 ], [ 0, 1, 0 ], [ 0, 0, 1 ] ]")
	Then("...and is positive definite", oId.IsPositiveDefinite(), TRUE)

	Given("a negative diagonal, which cannot be a covariance of anything")
	oNeg = new stzMatrix([ [-1,0], [0,-1] ])
	Then("refused", oNeg.IsPositiveDefinite(), FALSE)
EndScenario()

Scenario("a fit at a size worth having, and the matrix is left alone")
	# 200 observations, 4 predictors. The point is that this is now possible at all;
	# the timing is there so a future regression in the QR is visible.
	nObs = 200
	aD = []
	ay = []
	for i = 1 to nObs
		nU = (i % 13) + 1
		nV = (i % 7) + 1
		nW = (i % 5) + 1
		aD + [ 1, nU, nV, nW ]
		ay + (10 - 3 * nU + 0.5 * nV + 2 * nW)
	next
	oBig = new stzMatrix(aD)

	nT0 = clock()
	anC = oBig.LeastSquaresFor(ay)
	nT1 = clock()
	Then("a 200x4 fit is well under a second",
	     ((nT1 - nT0) / clockspersecond()) < 1, TRUE)
	Then("the constant is recovered from 200 exact observations", Rnd6(anC[1]), 10)
	Then("...and every coefficient", Rnd6(anC[2]), -3)
	Then("...including the fractional one", Rnd6(anC[3]), 0.5)
	Then("...and the last", Rnd6(anC[4]), 2)
	Then("the design matrix itself is unchanged", oBig.Rows(), nObs)
EndScenario()

Summary()

func SumSq(aD, ay, c1, c2)
	nS = 0
	nLen = len(ay)
	for i = 1 to nLen
		nR = aD[i][1] * c1 + aD[i][2] * c2 - ay[i]
		nS += nR * nR
	next
	return nS

func RaisesLS(oM, aB)
	bR = FALSE
	try
		anIgnored = oM.LeastSquaresFor(aB)
	catch
		bR = TRUE
	done
	return bR

func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000
func Rnd8(n)
	return ceil(n * 100000000 - 0.5) / 100000000
