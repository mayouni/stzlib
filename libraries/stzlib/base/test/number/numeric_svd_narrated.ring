load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 4 of the numeric foundation, ninth slice: SVD, the RECTANGULAR rank and
# conditioning it gives -- and a defect in slice 8 that building it exposed.
#
# Slice 8's eigen answers rank and conditioning for a SQUARE SYMMETRIC matrix. A
# DESIGN MATRIX is neither. Fitting 200 observations to 4 predictors and asking "are
# my predictors collinear?" needs the singular values of a 200x4, and no route in the
# library reached them -- Rank() and ConditionNumber() raised on anything but a square
# symmetric matrix.
#
# ONE-SIDED JACOBI rather than Golub-Kahan bidiagonalisation. Golub-Kahan is what
# LAPACK uses and is faster on large matrices, but it is two algorithms (bidiagonal
# reduction, then an implicit-shift QR sweep) and several hundred lines. One-sided
# Jacobi is the SAME ROTATION IDEA as slice 8's symmetric eigen: orthogonalise pairs
# of COLUMNS until every pair is orthogonal, at which point the column norms ARE the
# singular values. It reuses a rotation the file already had to get right, and it is
# the variant known for high relative accuracy on the SMALL singular values -- which,
# exactly as with the eigenvalues, is what a rank test and a condition number are
# decided by.
#
# THE DEFECT IT EXPOSED, and this is why building the general case was worth it. A
# rank test and a condition number are the SAME QUESTION asked twice: "is the smallest
# value negligible?" They were using separate rules. One-sided Jacobi leaves a
# rank-deficient column at rounding level rather than exactly zero, so for a 5x3
# matrix of rank 2:
#
#     singular values    5.418285    2.577243    6.04e-17
#     Rank()                 -> 2                     correct
#     ConditionNumber()      -> 8.97e16               WRONG -- a finite number
#
# AND SLICE 8 HAD IT TOO: a singular symmetric matrix reported rank 2 with a condition
# number of 1.22e16. Its test passed only because the matrix I happened to choose,
# [[1,1],[1,1]], produces an EXACT zero eigenvalue. The general case does not.
# `negligibleThreshold` is now the single definition of "counts as zero", asked by all
# four functions, so the two answers cannot drift apart again.

Scenario("the rectangular rank nothing else could answer")
	# Column 3 IS column 1 + column 2. That is collinearity, and it is precisely what
	# makes a least-squares fit non-unique -- so this is the diagnosis a caller wants
	# BEFORE asking for the fit.
	oDep = new stzMatrix([ [1,0,1], [0,1,1], [1,1,2], [2,0,2], [0,3,3] ])
	Then("the rank is 2, not 3", oDep.Rank(), 2)
	Then("...so it is rank deficient", oDep.IsRankDeficient(), TRUE)
	Then("...and not full rank", oDep.IsFullRank(), FALSE)
	Then("LeastSquaresFor refuses the same matrix",
	     @@(oDep.LeastSquaresFor([1,2,3,4,5])), "[ ]")
	# the two agree BY CONSTRUCTION: QR's isFullRank and the SVD rank both ask
	# whether the columns are independent.

	oOk = new stzMatrix([ [1,0,0], [0,1,0], [0,0,1], [1,1,0], [0,1,1] ])
	Then("an independent 5x3 has full rank", oOk.Rank(), 3)
	Then("...and IS full rank", oOk.IsFullRank(), TRUE)
	Then("...so the fit succeeds", len(oOk.LeastSquaresFor([1,2,3,4,5])), 3)
EndScenario()

Scenario("RANK AND THE CONDITION NUMBER CANNOT DISAGREE -- the defect this slice fixed")
	# Rank deficient must mean an INFINITE condition number. Before this slice the
	# two used separate rules and contradicted each other whenever the smallest value
	# came out at rounding level instead of exactly zero.
	oDep = new stzMatrix([ [1,0,1], [0,1,1], [1,1,2], [2,0,2], [0,3,3] ])
	Then("rank deficient means an infinite condition number",
	     oDep.ConditionNumber() > 1000000000000000000, TRUE)
	Then("...where it used to answer a finite 8.97e16", oDep.Rank() < 3, TRUE)

	# THE SLICE-8 CASE. Its zero eigenvalue comes out at 1.15e-15, so the old rule
	# reported rank 2 alongside a condition number of 1.22e16.
	oSing = new stzMatrix([ [2,1,3], [1,5,6], [3,6,9] ])   # row 3 = row 1 + row 2
	Then("a singular SYMMETRIC matrix has rank 2", oSing.Rank(), 2)
	Then("...and now an infinite condition number too",
	     oSing.ConditionNumber() > 1000000000000000000, TRUE)

	# ...while a full-rank matrix keeps a finite one, so the fix is not "return
	# infinity more often"
	oFull = new stzMatrix([ [4,1,0], [1,5,2], [0,2,6] ])
	Then("a full-rank matrix has a finite condition number",
	     oFull.ConditionNumber() < 1000, TRUE)
	Then("...and full rank", oFull.Rank(), 3)
EndScenario()

Scenario("singular values, and what they are")
	# A diagonal matrix's singular values are the ABSOLUTE values of its diagonal --
	# note the sign disappears, because a singular value never has one.
	oD = new stzMatrix([ [3,0,0], [0,-7,0], [0,0,1] ])
	Then("the -7 becomes 7, sorted first", @@(oD.SingularValues()), "[ 7, 3, 1 ]")
	Then("...and the condition number is 7 over 1", Rnd6(oD.ConditionNumber()), 7)

	oId = new stzMatrix([ [1,0], [0,1] ])
	Then("the identity's singular values are all 1", @@(oId.SingularValues()), "[ 1, 1 ]")
	Then("...and it is perfectly conditioned", Rnd9(oId.ConditionNumber()), 1)

	# SCALE INVARIANCE. Multiplying a matrix by 1e-9 divides every singular value by
	# 1e-9, so neither the rank nor the condition number may move. This is why the
	# threshold is RELATIVE: an absolute one would call this singular.
	oTiny = new stzMatrix([ [0.000000003,0,0], [0,-0.000000007,0], [0,0,0.000000001] ])
	Then("a tiny-scaled matrix keeps its rank", oTiny.Rank(), 3)
	Then("...and its condition number", Rnd6(oTiny.ConditionNumber()), 7)
EndScenario()

Scenario("the square symmetric case still goes through the eigenvalues")
	# Two routes, and the more accurate one is chosen when it applies -- eigen resolves
	# the small values slightly better than one-sided Jacobi on the same matrix.
	oS = new stzMatrix([ [2,1], [1,2] ])
	Then("rank via eigen", oS.Rank(), 2)
	Then("condition via eigen", Rnd9(oS.ConditionNumber()), 3)

	# and the two routes must agree where both apply: a symmetric matrix's singular
	# values are the absolute values of its eigenvalues
	oM = new stzMatrix([ [4,1,0], [1,5,2], [0,2,6] ])
	anEig = oM.EigenValues()
	anSv = oM.SingularValues()
	nWorst = 0
	for i = 1 to 3
		if fabs(fabs(anEig[i]) - anSv[i]) > nWorst
			nWorst = fabs(fabs(anEig[i]) - anSv[i])
		ok
	next
	Then("for a symmetric matrix, singular values are |eigenvalues|",
	     nWorst < 0.000001, TRUE)
	# two entirely different algorithms -- one-sided Jacobi on the columns, two-sided
	# Jacobi on the matrix -- producing the same numbers.
EndScenario()

Scenario("a wide matrix is refused, with the fix in the message")
	# m < n has infinitely many exact solutions and needs a different treatment. The
	# singular values of A and A-transpose are identical, so the advice is actionable
	# rather than a dead end.
	oWide = new stzMatrix([ [1,2,3], [4,5,6] ])
	Then("Rank raises", RaisesRank(oWide), TRUE)
	Then("...and says to transpose", RaisesRankSaying(oWide, "transpose"), TRUE)
	Then("SingularValues raises too", RaisesSV(oWide), TRUE)

	# ...and transposing genuinely works, which is what makes the advice honest
	oTall = new stzMatrix([ [1,4], [2,5], [3,6] ])
	Then("the transpose is answerable", oTall.Rank(), 2)
EndScenario()

Scenario("a real design matrix: 200 observations, 4 predictors")
	# The case the slice exists for. Diagnose the design BEFORE fitting.
	aD = []
	ay = []
	for i = 1 to 200
		nU = (i % 13) + 1
		nV = (i % 7) + 1
		nW = (i % 5) + 1
		aD + [ 1, nU, nV, nW ]
		ay + (10 - 3 * nU + 0.5 * nV + 2 * nW)
	next
	oA = new stzMatrix(aD)
	Then("the design is full rank", oA.Rank(), 4)
	Then("...so the fit is unique", len(oA.LeastSquaresFor(ay)), 4)
	Then("...and the condition number says how trustworthy it is",
	     oA.ConditionNumber() < 1000, TRUE)

	Given("the same design with a redundant predictor bolted on")
	aBad = []
	for i = 1 to 200
		aBad + [ aD[i][1], aD[i][2], aD[i][3], aD[i][2] + aD[i][3] ]
	next
	oBad = new stzMatrix(aBad)
	Then("the rank drops below the column count", oBad.Rank(), 3)
	Then("...the condition number goes infinite",
	     oBad.ConditionNumber() > 1000000000000000000, TRUE)
	Then("...and the fit is refused rather than arbitrary",
	     @@(oBad.LeastSquaresFor(ay)), "[ ]")
	# WHICH IS THE POINT: the caller can now find out WHY, instead of only that the
	# fit failed.
EndScenario()

Summary()

func RaisesRank(oM)
	bR = FALSE
	try
		nIgnored = oM.Rank()
	catch
		bR = TRUE
	done
	return bR

func RaisesRankSaying(oM, cWord)
	bFound = FALSE
	try
		nIgnored = oM.Rank()
	catch
		bFound = StzFindFirst(cWord, cCatchError) > 0
	done
	return bFound

func RaisesSV(oM)
	bR = FALSE
	try
		anIgnored = oM.SingularValues()
	catch
		bR = TRUE
	done
	return bR

func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000
func Rnd9(n)
	return ceil(n * 1000000000 - 0.5) / 1000000000
