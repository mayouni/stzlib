load "../../stzBase.ring"
load "../_narrated.ring"

# Phase 4 of the numeric foundation, eighth slice: EIGENVALUES, and the two things
# only they can tell you -- a CONDITION NUMBER and a RANK.
#
# This is the decomposition that EXPLAINS the others. Slice 7's IsPositiveDefinite
# answers by whether a Cholesky factorisation exists; a symmetric matrix is positive
# definite exactly when all its eigenvalues are positive. Two algorithms sharing no
# code, no loop and no idea, answering one question -- so when they agree, that is
# evidence rather than a self-check. The last scenario below runs that comparison.
#
# CYCLIC JACOBI, NOT THE QR ITERATION LAPACK USES. Jacobi is slower on large
# matrices: O(n^3) per sweep, several sweeps. In exchange it is about eighty lines
# with no tridiagonal reduction, no shift strategy and no deflation logic, and it
# resolves the SMALL eigenvalues to high relative accuracy -- which is precisely what
# a condition number and a rank test depend on, since both are decided by the
# smallest one. Our matrices are table- and covariance-sized. If large dense
# symmetric problems ever become real the answer is tridiagonal QR, not a faster
# Jacobi.
#
# SYMMETRIC ONLY, AND THAT IS A REFUSAL RATHER THAN A LIMITATION. A general matrix
# has COMPLEX eigenvalues, needing a different algorithm and a complex type the
# library does not have. Handed a non-symmetric matrix, this raises -- rather than
# returning the eigenvalues of (A + A')/2 and letting the caller believe they belong
# to A.

Scenario("eigenvalues, checked against their own definition")
	oM = new stzMatrix([ [2,1], [1,2] ])
	anV = oM.EigenValues()
	Then("[[2,1],[1,2]] has eigenvalues 3 and 1", @@(anV), "[ 3, 1 ]")
	Then("...sorted descending, as PCA expects", anV[1] > anV[2], TRUE)

	# THE DEFINING PROPERTY: A times an eigenvector is the eigenvalue times that
	# eigenvector. No reference constants are involved, which is the point.
	aA = [ [4,1,2], [1,5,3], [2,3,6] ]
	oS = new stzMatrix(aA)
	anL = oS.EigenValues()
	aV = oS.EigenVectors()
	nWorst = 0
	for j = 1 to 3
		for i = 1 to 3
			nAv = 0
			for k = 1 to 3
				nAv += aA[i][k] * aV[k][j]
			next
			nDiff = fabs(nAv - anL[j] * aV[i][j])
			if nDiff > nWorst
				nWorst = nDiff
			ok
		next
	next
	Then("A*v = lambda*v holds for all nine components", nWorst < 0.000000001, TRUE)

	# the eigenvectors of a symmetric matrix are ORTHONORMAL
	nOff = 0
	for j1 = 1 to 3
		for j2 = 1 to 3
			nDot = 0
			for i = 1 to 3
				nDot += aV[i][j1] * aV[i][j2]
			next
			nWant = 0
			if j1 = j2
				nWant = 1
			ok
			if fabs(nDot - nWant) > nOff
				nOff = fabs(nDot - nWant)
			ok
		next
	next
	Then("...and the eigenvectors are orthonormal", nOff < 0.000000001, TRUE)
EndScenario()

Scenario("two invariants that tie eigenvalues to code that computed them differently")
	# The trace is the SUM of the eigenvalues and the determinant is their PRODUCT.
	# The determinant comes from the LU decomposition of slice 4 -- a completely
	# different algorithm -- so this connects two slices.
	aA = [ [6,-2,1,0], [-2,7,3,1], [1,3,9,-4], [0,1,-4,5] ]
	oM = new stzMatrix(aA)
	anL = oM.EigenValues()

	nTrace = 0
	for i = 1 to 4
		nTrace += aA[i][i]
	next
	nSum = 0
	for v in anL
		nSum += v
	next
	Then("the trace equals the sum of the eigenvalues", Rnd6(nTrace), Rnd6(nSum))

	nProd = 1
	for v in anL
		nProd *= v
	next
	Then("...and the LU determinant equals their product",
	     Rnd4(oM.Determinant()), Rnd4(nProd))
EndScenario()

Scenario("a spectrum known by inspection, and a repeated eigenvalue")
	oD = new stzMatrix([ [3,0,0], [0,7,0], [0,0,1] ])
	Then("a diagonal matrix's eigenvalues ARE its diagonal, sorted",
	     @@(oD.EigenValues()), "[ 7, 3, 1 ]")

	# A REPEATED eigenvalue is where a naive rotation formula divides by zero: for
	# 2*I every off-diagonal is already zero and the two values coincide. The
	# eigenvectors must still come out orthonormal.
	oRep = new stzMatrix([ [2,0], [0,2] ])
	anR = oRep.EigenValues()
	Then("2*I has eigenvalue 2 twice", Rnd9(anR[1]) = 2 and Rnd9(anR[2]) = 2, TRUE)
	aVR = oRep.EigenVectors()
	nDot = aVR[1][1]*aVR[1][2] + aVR[2][1]*aVR[2][2]
	Then("...and its eigenvectors are still orthogonal", Rnd9(nDot), 0)
EndScenario()

Scenario("the condition number, which says how many digits a solve can lose")
	oId = new stzMatrix([ [1,0,0], [0,1,0], [0,0,1] ])
	Then("the identity is perfectly conditioned", Rnd9(oId.ConditionNumber()), 1)

	oD = new stzMatrix([ [1000,0,0], [0,10,0], [0,0,1] ])
	Then("a diagonal matrix's is largest over smallest",
	     Rnd6(oD.ConditionNumber()), 1000)
	# a condition number of 10^k costs about k of the sixteen digits a double has,
	# so 1000 here means three.

	Given("a singular matrix, where no solve is possible at all")
	oS = new stzMatrix([ [1,1], [1,1] ])
	Then("the condition number is INFINITE, not a large finite number",
	     oS.ConditionNumber() > 1000000000000, TRUE)
	Then("...its rank is 1, not 2", oS.Rank(), 1)
	Then("...and it reports itself singular", oS.IsSingular(), TRUE)
EndScenario()

Scenario("rank, counted RELATIVE to the largest eigenvalue")
	Then("the identity has full rank",
	     (new stzMatrix([ [1,0], [0,1] ])).Rank(), 2)
	Then("the zero matrix has rank 0",
	     (new stzMatrix([ [0,0], [0,0] ])).Rank(), 0)

	# THE REASON THE THRESHOLD IS RELATIVE. A matrix of uniformly tiny entries is
	# perfectly well conditioned and full rank; an absolute cutoff would call it rank
	# zero. Scaling a matrix cannot change its rank.
	oTiny = new stzMatrix([ [0.000000001, 0], [0, 0.000000001] ])
	Then("a matrix of tiny entries is still full rank", oTiny.Rank(), 2)
	Then("...and still perfectly conditioned", Rnd9(oTiny.ConditionNumber()), 1)
EndScenario()

Scenario("a non-symmetric matrix is never silently symmetrised")
	# UPDATED IN PHASE 7. This scenario used to assert that EigenValues() RAISED for
	# every non-symmetric matrix, which is what it did when only the symmetric Jacobi
	# routine existed. Phase 7 added a complex type and a Francis double-shift QR, so
	# the refusal narrowed to the case that actually needs it.
	#
	# WHAT HAS NOT CHANGED, and was the point of this scenario all along: a
	# non-symmetric matrix is never handed the eigenvalues of (A + A')/2. [[1,2],[3,4]]
	# is answered from ITS OWN spectrum -- 5.372 and -0.372 -- and the symmetrised
	# matrix [[1,2.5],[2.5,4]] would give 5.850 and -0.850, which are different
	# numbers belonging to a different matrix.
	oN = new stzMatrix([ [1,2], [3,4] ])
	Then("it is detected as non-symmetric", oN.IsSymmetric(), FALSE)

	aN = oN.EigenValues()
	Then("its real spectrum is answered now", len(aN), 2)
	Then("...summing to ITS trace, 5", Rnd6(aN[1] + aN[2]), 5)
	Then("...and multiplying to ITS determinant, -2", Rnd6(aN[1] * aN[2]), -2)
	# the symmetrised matrix has trace 5 too, so the trace alone would not catch a
	# substitution -- the determinant is what separates them (-2 against -2.25)
	Then("NOT the symmetrised matrix's eigenvalues",
	     Rnd4(aN[1]) != Rnd4(5.8508), TRUE)

	# and a matrix whose eigenvalues are genuinely complex is still refused by the
	# method that returns plain numbers
	Then("a rotation is still refused", RaisesEigen(new stzMatrix([ [0,-1], [1,0] ])), TRUE)
	# returning the spectrum of (A + A')/2 while calling it the spectrum of A would
	# be a wrong answer wearing a right answer's face -- the failure mode this whole
	# phase keeps finding.

	# But symmetry is judged with a RELATIVE tolerance: data out of a real
	# computation is rarely symmetric to the last bit, and an exact test would reject
	# matrices symmetric in every sense that matters.
	oAlmost = new stzMatrix([ [1,2], [2.0000000000000004,4] ])
	Then("symmetric to rounding still counts as symmetric", oAlmost.IsSymmetric(), TRUE)
	oNot = new stzMatrix([ [1,2], [2.001,4] ])
	Then("...but a real asymmetry does not", oNot.IsSymmetric(), FALSE)

	Then("a non-square matrix is not symmetric either",
	     (new stzMatrix([ [1,2,3], [4,5,6] ])).IsSymmetric(), FALSE)
EndScenario()

Scenario("POSITIVE DEFINITENESS, answered twice by unrelated algorithms")
	# The scenario this slice exists for. Cholesky says positive definite when its
	# factorisation exists; eigen says so when every eigenvalue is positive. The two
	# share no code, so agreement across a range of cases is independent evidence --
	# and it checks slice 7's work from outside.
	aCases = [
		[ [4,2], [2,3] ],        # positive definite
		[ [1,2], [2,1] ],        # indefinite
		[ [-1,0], [0,-1] ],      # negative definite
		[ [0,0], [0,1] ],        # semi-definite -- the boundary case
		[ [1,0], [0,1] ],        # the identity
		[ [2,-1], [-1,2] ]       # positive definite
	]
	nAgree = 0
	nLen = len(aCases)
	for i = 1 to nLen
		oM = new stzMatrix(aCases[i])
		bAllPositive = TRUE
		for v in oM.EigenValues()
			if v <= 0.000000000001
				bAllPositive = FALSE
			ok
		next
		if bAllPositive = oM.IsPositiveDefinite()
			nAgree++
		ok
	next
	Then("all six cases agree, including the semi-definite boundary", nAgree, nLen)

	# and the direction of the claim, so the test cannot pass by both being wrong
	Then("a known positive-definite matrix IS positive definite",
	     (new stzMatrix([ [4,2], [2,3] ])).IsPositiveDefinite(), TRUE)
	Then("...and a known indefinite one is NOT",
	     (new stzMatrix([ [1,2], [2,1] ])).IsPositiveDefinite(), FALSE)
EndScenario()

Summary()

func RaisesEigen(oM)
	bR = FALSE
	try
		anIgnored = oM.EigenValues()
	catch
		bR = TRUE
	done
	return bR

func Rnd4(n)
	return ceil(n * 10000 - 0.5) / 10000
func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000
func Rnd9(n)
	return ceil(n * 1000000000 - 0.5) / 1000000000
