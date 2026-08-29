load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 4 of the numeric foundation, fourth slice: THE FIRST DECOMPOSITION.
#
# LU with partial pivoting, in the engine (linalg.zig). It comes first of the six
# the plan calls for because it is the one that unlocks the others: a determinant,
# a linear solve, an inverse and eventually least squares are all the same
# factorisation read differently.
#
# WHY IT WAS URGENT. matrix.zig's determinant was naive COFACTOR EXPANSION --
# O(n!) time, and it allocated a fresh submatrix at every level of the recursion,
# so O(n!) allocations too. A 10x10 determinant was 3.6 million recursive calls; a
# 20x20 was not finishable. This was discovered by accident during phase 3, when a
# perfectly reasonable-looking 60x60 timing probe hung and had to be killed.
#
# The striking part is that `inverse`, a few lines below it in the same file, had
# ALWAYS done Gauss-Jordan with partial pivoting in O(n^3). The machinery the
# determinant needed was sitting next to it the whole time. A wrong asymptotic
# complexity does not announce itself: every test in the suite used a 2x2 or 3x3
# matrix, where cofactor expansion is not merely adequate but optimal.
#
# WHY BUILT RATHER THAN VENDORED (plan section 6): reference LAPACK is Fortran,
# which breaks this build model outright, and all eleven existing vendored
# dependencies are C. We need perhaps six decompositions, not 1700 routines.

Scenario("the determinant, at sizes that were previously impossible")
	# A triangular matrix's determinant is the product of its diagonal -- a fact
	# independent of the algorithm, so these are real checks rather than
	# self-checks.
	Then("2x2, where cofactor expansion was already fine",
	     Det([ [1,2], [3,4] ]), -2)
	Then("3x3, the largest size any existing test used",
	     Det([ [6,1,1], [4,-2,5], [2,8,7] ]), -306)

	Then("8x8 -- 40320 recursive allocations the old way", DetTri(8), pow(2, 8))
	Then("12x12 -- 479 million", DetTri(12), pow(2, 12))
	Then("20x20 -- not a finite computation", DetTri(20), pow(2, 20))
	Then("40x40 -- and this is 2^40, instantly", DetTri(40), pow(2, 40))
EndScenario()

Scenario("pivoting is a correctness requirement, not a refinement")
	# A zero in the leading position. Without partial pivoting this divides by
	# zero -- and the matrix is perfectly invertible.
	Then("a zero pivot is swapped away, not divided by",
	     Det([ [0,1], [1,0] ]), -1)
	Then("...and in 3x3", Det([ [0,2,1], [1,0,3], [4,1,8] ]), 9)
	# swapping two rows of the identity is one swap: the sign must flip
	Then("an odd number of swaps flips the sign",
	     Det([ [0,1,0], [1,0,0], [0,0,1] ]), -1)
	# A SMALL pivot is the subtler half of the argument: it does not fail, it
	# amplifies rounding error by however small it is. Choosing the largest
	# candidate in the column is what keeps that bounded.
EndScenario()

Scenario("a singular matrix answers zero rather than a small lie")
	Then("a duplicated row", Det([ [1,2,3], [1,2,3], [4,5,6] ]), 0)
	Then("a zero column", Det([ [1,0,3], [4,0,6], [7,0,9] ]), 0)
	Then("all zeros", Det([ [0,0], [0,0] ]), 0)
EndScenario()

Scenario("solving a system, which now goes through the engine")
	# SolveFor ALREADY EXISTED as a Ring-side Gauss-Jordan, and the first instinct
	# on adding an engine solve was to write a new one beside it. That is exactly
	# how LCM and GCD became second, divergent implementations -- one of which
	# answered 0 instead of 24. The engine path went INSIDE the existing method
	# instead, and the Ring loop stays as the fallback.
	oA = new stzMatrix([ [2,1,-1], [-3,-1,2], [-2,1,2] ])
	anX = oA.SolveFor([ 8, -11, -3 ])
	Then("2x+y-z=8, -3x-y+2z=-11, -2x+y+2z=-3 gives x=2", Rnd6(anX[1]), 2)
	Then("...y=3", Rnd6(anX[2]), 3)
	Then("...z=-1", Rnd6(anX[3]), -1)
	Then("and the matrix itself is untouched",
	     @@(oA.Content()), "[ [ 2, 1, -1 ], [ -3, -1, 2 ], [ -2, 1, 2 ] ]")

	Then("the Solve alias is the same method, not a twin",
	     @@(oA.Solve([ 8, -11, -3 ])), @@(anX))
EndScenario()

Scenario("the contract the Ring version had is the contract the engine keeps")
	# Singular systems REFUSE rather than guessing -- the method's documented LAW
	# 3. The engine returns NULL for a singular factorisation, and that is turned
	# back into the same refusal rather than being allowed to fall through to the
	# Ring path, which would solve it twice before declining.
	oS = new stzMatrix([ [1,2], [2,4] ])
	Then("a singular system raises", Raises(oS, [1,2]), TRUE)

	oN = new stzMatrix([ [1,2,3], [4,5,6] ])
	Then("a non-square system raises", Raises(oN, [1,2]), TRUE)
	Then("a b of the wrong length raises", Raises(oS, [1,2,3]), TRUE)
EndScenario()

Scenario("the answers are checked by residual, not by eye")
	# For each system, compute A*x and compare it with b. This tests the solve
	# against the definition of a solution rather than against a remembered number.
	nWorst = 0
	_aND142_ = [ 3, 5, 9, 15 ]
	_nND142_ = len(_aND142_)
	for _iND142_ = 1 to _nND142_
		nD = _aND142_[_iND142_]
		aM = TestSystem(nD)
		ab = []
		for i = 1 to nD
			ab + (i * 2 + 1)
		next
		oM = new stzMatrix(aM)
		anX = oM.SolveFor(ab)
		for i = 1 to nD
			nS = 0
			for j = 1 to nD
				nS += aM[i][j] * anX[j]
			next
			nR = fabs(nS - ab[i])
			if nR > nWorst
				nWorst = nR
			ok
		next
	next
	Then("across 3x3, 5x5, 9x9 and 15x15, max |A*x - b| is negligible",
	     nWorst < 0.000000001, TRUE)
EndScenario()

Scenario("what the engine bought, measured")
	# A 60x60 system, ten solves: 0.21s through the Ring triple loop, 0.01s
	# through one LU factorisation in the engine. The gate sits between them.
	nD = 60
	aM = []
	for i = 1 to nD
		r = []
		for j = 1 to nD
			if i = j
				r + (nD + 1)
			else
				r + 1
			ok
		next
		aM + r
	next
	ab = []
	for i = 1 to nD
		ab + (nD + nD)
	next
	oL = new stzMatrix(aM)

	nT0 = clock()
	for k = 1 to 10
		anX = oL.SolveFor(ab)
	next
	nT1 = clock()
	Then("ten 60x60 solves come in well under the Ring loop's 0.21s",
	     ((nT1 - nT0) / clockspersecond()) < 0.10, TRUE)
	# this system is built so every x is exactly 1
	Then("...and every unknown is 1, as constructed", Rnd6(anX[1]), 1)
	Then("...including the last", Rnd6(anX[nD]), 1)
EndScenario()

Summary()

func Det(aM)
	oD = new stzMatrix(aM)
	return oD.Determinant()

# n x n with 2 on the diagonal, 1 above it, 0 below: determinant = 2^n
func DetTri(n)
	aM = []
	for i = 1 to n
		r = []
		for j = 1 to n
			if j < i
				r + 0
			but j = i
				r + 2
			else
				r + 1
			ok
		next
		aM + r
	next
	oT = new stzMatrix(aM)
	return oT.Determinant()

func TestSystem(n)
	aM = []
	for i = 1 to n
		r = []
		for j = 1 to n
			if i = j
				r + (n * 2)
			else
				r + (((i * 3 + j * 7) % 5) + 1)
			ok
		next
		aM + r
	next
	return aM

func Raises(oM, aB)
	bRaised = FALSE
	try
		anIgnored = oM.SolveFor(aB)
	catch
		bRaised = TRUE
	done
	return bRaised

func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000
