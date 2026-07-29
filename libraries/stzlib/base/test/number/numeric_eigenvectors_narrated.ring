load "../../stzBase.ring"
load "../_narrated.ring"

# EIGENVECTORS OF A GENERAL MATRIX (numeric phase 7, second pass).
#
# The first pass lifted phase 4's refusal of non-symmetric EIGENVALUES and deferred
# the vectors by name, saying they "need either inverse iteration or a
# back-substitution on the full Schur form, they are far more delicate near a
# repeated eigenvalue, and nothing has asked for them". This is that deferred half.
#
# WHY THE VECTORS ARE THE HARDER PROBLEM, and it is not a matter of degree:
#
#     EIGENVALUES CAN BE READ OFF A MATRIX YOU HAVE DESTROYED.
#     EIGENVECTORS CANNOT.
#
# The eigenvalue routine balances the matrix, reduces it to Hessenberg form and runs
# QR to convergence, throwing every transformation away as it goes. That is sound,
# because each step is a SIMILARITY and a similarity does not move the spectrum -- the
# numbers on the diagonal at the end are the numbers you wanted. But an eigenvector of
# that final triangular matrix belongs to THAT matrix. Getting back to an eigenvector
# of the original needs every transformation the eigenvalue routine discarded:
#
#     A  --balance-->  A'  --Hessenberg-->  H  --QR-->  T
#        <--D--            <--Q--              <--Z--
#
#     v_A  =  D . Q . Z . v_T
#
# So the whole pipeline was rebuilt to accumulate, and then the eigenvectors of the
# quasi-triangular T are recovered by back-substitution.
#
# THE QR ITERATION IS STILL ONE IMPLEMENTATION. Keeping the tested eigenvalue-only
# version and adding a second accumulating copy was the obvious move, and would have
# been this project's most-punished defect -- two definitions of one thing, agreeing
# until one is touched. EigenValues() is now a thin call into the same routine with
# accumulation switched off.
#
# TWO REAL BUGS SURFACED WHILE DOING IT, and both are worth recording because neither
# would show in the eigenvalues:
#
#   1. Restructuring dropped the balance-and-reduce calls from the eigenvalue path.
#      QR iterates on a HESSENBERG matrix; on a full one it is not merely slower, it
#      is a different computation.
#   2. A complex conjugate pair was stored as (-im, +im) where the back-substitution
#      detects a pair by finding a NEGATIVE imaginary part at the SECOND index. THE
#      EIGENVALUES WERE IDENTICAL EITHER WAY -- the set is the same set -- and the
#      vector pass silently skipped every complex block. A sign convention that is
#      invisible in one output and load-bearing in another.
#
# HOW ALL OF THIS IS CHECKED. Not against tabulated vectors, which would only test
# the cases someone had tabulated. Against the DEFINING PROPERTY:
#
#     A v = lambda v
#
# computed in complex arithmetic through the public surface, for every eigenpair, on
# every matrix below. That validates the eigenvalues, the eigenvectors, the
# accumulation and the back-transformation together, and it works on matrices nobody
# has ever written down.

Scenario("A v = lambda v -- the property that defines the answer")
	# A diagonal matrix, where the answer is obvious, so a failure here is a failure
	# of the plumbing rather than of the algorithm.
	Then("a diagonal matrix", Residual([ [3,0,0], [0,-1,0], [0,0,7] ]) < 0.0000000001, TRUE)

	# Upper triangular: non-symmetric, real spectrum. This is the case the first
	# pass could answer for values and not for vectors.
	Then("an upper-triangular matrix", Residual([ [1,2,3], [0,4,5], [0,0,6] ]) < 0.0000000001, TRUE)

	# Genuinely complex: a rotation has no real eigendirection at all.
	Then("a rotation, whose vectors are complex",
	     Residual([ [0,-1], [1,0] ]) < 0.0000000001, TRUE)

	# A general matrix with nothing special about it.
	Then("a general non-symmetric matrix",
	     Residual([ [1,-2,3], [4,5,-6], [7,8,9] ]) < 0.000000001, TRUE)

	# Symmetric, which must still work through the general path.
	Then("a symmetric matrix", Residual([ [4,1,0], [1,3,1], [0,1,2] ]) < 0.0000000001, TRUE)

	# A companion matrix -- its eigenvectors are the Vandermonde columns.
	Then("a companion matrix", Residual([ [6,-11,6], [1,0,0], [0,1,0] ]) < 0.00000001, TRUE)

	# Badly scaled entries, which is what the balancing step is for.
	Then("badly scaled entries", Residual([ [1,1000000,0], [0.000001,1,0], [0,0,2] ]) < 0.00000001, TRUE)

	# A defective matrix still satisfies A v = lambda v for the vectors it HAS.
	Then("even a defective matrix, for the vector it has",
	     Residual([ [1,1], [0,1] ]) < 0.0000000001, TRUE)
EndScenario()

Scenario("the rotation, checked by hand")
	# lambda = i means (A - iI)v = 0, so -i*v1 - v2 = 0 and v2 = -i*v1.
	# Normalised: v = (1, -i)/sqrt(2).
	oQ = new stzMatrix([ [0,-1], [1,0] ])
	aV = oQ.ComplexEigenVectors()
	aL = oQ.ComplexEigenValues()

	Then("the first eigenvalue is i or -i",
	     fabs(fabs(aL[1].ImaginaryPart()) - 1) < 0.000000001, TRUE)
	Then("...and it is purely imaginary", Rnd9(aL[1].RealPart()), 0)

	# the first component is real and positive by the normalisation rule
	Then("the first component is 1/sqrt(2)", Rnd6(aV[1][1].RealPart()), Rnd6(1/sqrt(2)))
	Then("...and real, as normalisation promises", Rnd9(aV[1][1].ImaginaryPart()), 0)
	# the second is +-i/sqrt(2)
	Then("the second component is purely imaginary", Rnd9(aV[2][1].RealPart()), 0)
	Then("...with magnitude 1/sqrt(2)", Rnd6(fabs(aV[2][1].ImaginaryPart())), Rnd6(1/sqrt(2)))
	# NOT `x^2`. In RING, `^` IS BITWISE XOR, NOT EXPONENTIATION -- `3^2` is 1, not
	# 9. Both of this file's first failures were that, and the symptom was a
	# magnitude of 0 rather than an error, because XOR of a float truncates to an
	# integer first. (The expression language stzMathFunction parses DOES use ^ for
	# power, which is the conventional mathematical reading and a deliberate
	# difference from Ring's own operator.)
	n1 = aV[1][1].Modulus()
	n2 = aV[2][1].Modulus()
	Then("the vector has unit length", Rnd6(sqrt(n1*n1 + n2*n2)), 1)
EndScenario()

Scenario("DEFECTIVE matrices are reported, not papered over")
	# [[1,1],[0,1]] has the eigenvalue 1 twice and only ONE independent eigenvector.
	# That is a fact about the matrix, not a shortcoming of the algorithm -- no
	# method can produce a second, because there is not one. Back-substitution
	# returns a near-duplicate, so the shortfall has to be reported or the caller
	# gets two vectors of which one is a copy and no indication.
	oD = new stzMatrix([ [1,1], [0,1] ])
	Then("two eigenvalues", len(oD.ComplexEigenValues()), 2)
	Then("...but only one independent eigenvector",
	     oD.NumberOfIndependentEigenVectors(), 1)
	Then("it says it is defective", oD.IsDefective(), TRUE)
	Then("...and therefore not diagonalizable", oD.IsDiagonalizable(), FALSE)
	Then("EigenVectors refuses rather than returning a duplicate", RaisesVec(oD), TRUE)
	Then("...saying how many there actually are",
	     StzFindFirst("only 1 independent", WhyVec(oD)) > 0, TRUE)

	# A repeated eigenvalue does NOT imply defective: the identity has one
	# eigenvalue with a full set of eigenvectors.
	oI = new stzMatrix([ [2,0], [0,2] ])
	Then("a repeated eigenvalue alone does not make a matrix defective",
	     oI.IsDefective(), FALSE)
	Then("...it has a full set", oI.NumberOfIndependentEigenVectors(), 2)
	Then("...and is diagonalizable", oI.IsDiagonalizable(), TRUE)
EndScenario()

Scenario("what EigenVectors returns, and what it still refuses")
	# non-symmetric with a real spectrum: answered now, where it used to raise
	oT = new stzMatrix([ [1,2,3], [0,4,5], [0,0,6] ])
	aV = oT.EigenVectors()
	Then("three columns of three", len(aV), 3)
	Then("...of the right width", len(aV[1]), 3)
	# eigenvalue 1 of an upper-triangular matrix has eigenvector e1
	Then("the first eigenvector is e1", Rnd6(aV[1][1]), 1)
	Then("...with the rest zero", Rnd6(aV[2][1]) = 0 and Rnd6(aV[3][1]) = 0, TRUE)

	# complex eigenvectors are still refused BY THIS METHOD, which returns numbers
	oQ = new stzMatrix([ [0,-1], [1,0] ])
	Then("a rotation is refused", RaisesVec(oQ), TRUE)
	Then("...pointing at the complex form",
	     StzFindFirst("ComplexEigenVectors", WhyVec(oQ)) > 0, TRUE)

	Then("a non-square matrix is refused",
	     RaisesVecOf(new stzMatrix([ [1,2,3], [4,5,6] ])), TRUE)
EndScenario()

Scenario("the symmetric path is untouched")
	# Phase 4's Jacobi routine still serves symmetric matrices. Lifting the refusal
	# must not have rerouted them through the general code, which is both slower and
	# less accurate on the small eigenvalues a condition number depends on.
	oS = new stzMatrix([ [2,1], [1,2] ])
	aV = oS.EigenVectors()
	Then("a symmetric matrix still answers", len(aV), 2)
	# for [[2,1],[1,2]] the eigenvectors are (1,1)/sqrt(2) and (1,-1)/sqrt(2)
	Then("...with orthonormal columns",
	     Rnd6(fabs(aV[1][1]*aV[1][2] + aV[2][1]*aV[2][2])), 0)
	Then("...of unit length", Rnd6(aV[1][1]*aV[1][1] + aV[2][1]*aV[2][1]), 1)
	Then("EigenValues is unchanged too", @@(oS.EigenValues()), "[ 3, 1 ]")
EndScenario()

Scenario("it is reproducible, which for an iterative method is not automatic")
	# An eigenvector is only defined up to scale, and a complex one up to phase, so
	# without a normalisation rule two runs could legitimately disagree. The rule is
	# unit length with the largest component rotated real and positive.
	aM = [ [1,-2,3], [4,5,-6], [7,8,9] ]
	o1 = new stzMatrix(aM)
	o2 = new stzMatrix(aM)
	a1 = o1.ComplexEigenVectors()
	a2 = o2.ComplexEigenVectors()
	bSame = TRUE
	for i = 1 to 3
		for j = 1 to 3
			if a1[i][j].RealPart() != a2[i][j].RealPart() or
			   a1[i][j].ImaginaryPart() != a2[i][j].ImaginaryPart()
				bSame = FALSE
			ok
		next
	next
	Then("two runs agree to the last bit", bSame, TRUE)

	# every column is a unit vector
	bUnit = TRUE
	for j = 1 to 3
		n = 0
		for i = 1 to 3
			n += a1[i][j].Modulus() * a1[i][j].Modulus()
		next
		if fabs(sqrt(n) - 1) > 0.000001
			bUnit = FALSE
		ok
	next
	Then("...and every eigenvector has unit length", bUnit, TRUE)
EndScenario()

Scenario("stzComplex follows the name-form laws too")
	# Same two laws, same fix: Conjugate() and Negated() both used to return new
	# objects from plain names. An ACTIVE verb mutates and returns nothing; a
	# PASSIVE ...ed form returns DATA; only a Q form returns a Softanza object.
	oZ = new stzComplex(3, 4)

	# passive: data out, receiver untouched
	aC = oZ.Conjugated()
	Then("Conjugated() returns a [re, im] pair", isList(aC), TRUE)
	Then("...with the imaginary part negated", aC[2], -4)
	Then("...and the original is UNCHANGED", oZ.ImaginaryPart(), 4)

	# fluent: an object, so it chains
	Then("ConjugatedQ() returns something chainable",
	     oZ.ConjugatedQ().Content(), "3-4i")
	Then("...and STILL did not change the original", oZ.ImaginaryPart(), 4)

	# active: mutates, returns nothing
	Then("Conjugate() returns nothing", isNull(oZ.Conjugate()), TRUE)
	Then("...and it DID change the original", oZ.ImaginaryPart(), -4)

	# arithmetic: plain gives data, Q gives an object
	oA = new stzComplex(1, 2)
	Then("Plus() returns data", isList(oA.Plus([3,4])), TRUE)
	Then("...the right data", @@(oA.Plus([3,4])), "[ 4, 6 ]")
	Then("PlusQ() returns a chainable object", oA.PlusQ([3,4]).Content(), "4+6i")
	Then("TimesQ() chains as well", oA.TimesQ(2).Content(), "2+4i")
	Then("DividedBy() returns data too", isList(oA.DividedBy(2)), TRUE)
EndScenario()

Scenario("INVERTING AN EIGENDECOMPOSITION IS ONE POWER AMONG SEVERAL")
	# A = Q L Q', so A^p = Q L^p Q' -- apply the power to the EIGENVALUES and reassemble.
	# Undoing the decomposition is p = 1, and the inverse is p = -1. But nothing in the
	# machinery cares which function reaches the diagonal, so the inverse arrives as a
	# special case rather than as the feature.
	aA = [ [6,2,1], [2,5,2], [1,2,4] ]
	oM = new stzMatrix(aA)
	aI = [ [1,0,0], [0,1,0], [0,0,1] ]

	Then("p = 1 rebuilds the matrix", SameMat(oM.MatrixPower(1), aA), TRUE)
	Then("p = -1 is the inverse", SameMat(MatMul(aA, oM.MatrixPower(-1)), aI), TRUE)

	# THE TWO THAT EARN THEIR KEEP, because no other decomposition here offers them.
	aRoot = oM.MatrixSquareRoot()
	Then("p = 0.5 squares back to the matrix", SameMat(MatMul(aRoot, aRoot), aA), TRUE)

	# AND IT IS SYMMETRIC, which is the difference that matters. Cholesky also gives a
	# "square root" -- L with L L' = A -- but that one is TRIANGULAR and one of many.
	# This is the principal square root: symmetric, positive semi-definite, unique.
	# Both square back to A; only this one is itself a covariance-shaped object.
	Then("...and unlike Cholesky's factor it is symmetric", SymmetricMat(aRoot), TRUE)

	aW = oM.WhiteningMatrix()
	Then("p = -0.5 whitens: W A W is the identity",
	     SameMat(MatMul(MatMul(aW, aA), aW), aI), TRUE)
EndScenario()

Scenario("...and Power() next door means something else entirely")
	# THE TRAP THIS SCENARIO EXISTS TO PIN. Power(n) raises every ELEMENT to a power;
	# MatrixPower(p) raises the MATRIX to one. They agree only for a diagonal matrix,
	# and they are one keystroke apart.
	#
	# MEASURED on the same matrix, first entry:
	#
	#     Power(0.5)        2.449490     which is sqrt(6), the element
	#     MatrixSquareRoot  2.406075     which is not
	#
	# Two plausible numbers, and nothing in either result announces which question was
	# asked. Hence two names that cannot be confused for one another.
	aA = [ [6,2,1], [2,5,2], [1,2,4] ]

	oElem = new stzMatrix(aA)
	oElem.Power(0.5)
	oMat = new stzMatrix(aA)

	Then("the elementwise power takes the root of each entry",
	     fabs(oElem.Content()[1][1] - sqrt(6)) < 0.000001, TRUE)
	Then("...and the matrix power does not",
	     fabs(oMat.MatrixSquareRoot()[1][1] - sqrt(6)) > 0.01, TRUE)

	# refused rather than returned as NaN, because a NaN travels quietly downstream
	Then("a non-symmetric matrix has no such decomposition",
	     RefusesPower([[1,2],[0,1]], 1), TRUE)
	Then("...and a fractional power of an indefinite one has no real answer",
	     RefusesPower([[1,2,0],[2,1,0],[0,0,1]], 0.5), TRUE)
	Then("...though an integer power of the very same matrix is fine",
	     RefusesPower([[1,2,0],[2,1,0],[0,0,1]], -1), FALSE)
EndScenario()

Scenario("THE SCHUR DECOMPOSITION -- and the one already here was not orthogonal")
	# A = Q T Q', with Q ORTHOGONAL and T quasi-upper-triangular: 1x1 blocks on the
	# diagonal for real eigenvalues, 2x2 for conjugate pairs. Every real matrix has one,
	# which is more than an eigendecomposition can claim -- a defective matrix has no
	# full set of eigenvectors, and this exists regardless.
	#
	# THE EIGENVALUE PATH ALREADY PRODUCED A TRIANGULAR T. What it does not produce is
	# an orthogonal transform: it reduces by Gaussian elimination, which is cheaper and
	# perfectly good for eigenvalues. Measured on this matrix:
	#
	#     elimination path    ||Z'Z - I|| = 0.607     ||Z T Z' - A|| = 3.38
	#     this one            ||Q'Q - I|| = 6.7e-16   ||Q T Q' - A|| = 7.1e-11
	#
	# A decomposition whose Q is not orthogonal is NOT a Schur decomposition -- it is a
	# similarity that happens to end in triangular form, and everything worth having
	# downstream rests on Q' being Q-inverse. Hence a second reduction, by Householder
	# reflections, on its own path so the eigenvalue numerics are untouched.
	aA = [ [4,1,2,0], [0,3,1,5], [2,0,6,1], [1,2,0,4] ]
	oA = new stzMatrix(aA)
	aI4 = [ [1,0,0,0], [0,1,0,0], [0,0,1,0], [0,0,0,1] ]

	aQ = oA.SchurQ()
	aT = oA.SchurT()
	Then("Q is orthogonal", SameMat(MatMul(MatTrans(aQ), aQ), aI4), TRUE)
	Then("...and Q T Q' rebuilds the matrix",
	     SameMat(MatMul(MatMul(aQ, aT), MatTrans(aQ)), aA), TRUE)
	Then("...with T quasi-upper-triangular", QuasiTriangular(aT), TRUE)
EndScenario()

Scenario("...and its inverse is correct, and the wrong route to use")
	aA = [ [4,1,2,0], [0,3,1,5], [2,0,6,1], [1,2,0,4] ]
	oA = new stzMatrix(aA)
	aI4 = [ [1,0,0,0], [0,1,0,0], [0,0,1,0], [0,0,0,1] ]

	aSi = oA.SchurInverse()
	Then("it is the inverse", SameMat(MatMul(aA, aSi), aI4), TRUE)
	Then("...a SIXTH route to the same matrix", SameMat(aSi, oA.LUInverse()), TRUE)

	# IT IS THE ONE NOT TO REACH FOR. This runs an ITERATIVE QR to arrive where
	# LUInverse() arrives by direct factorisation. It is here because the decomposition
	# is worth having and an inverse is the obvious thing to ask of one -- so it should
	# exist, and it should say what it is.
	#
	# WHAT THE SCHUR FORM IS ACTUALLY FOR is f(A) for a NON-SYMMETRIC matrix: the square
	# root, the exponential, a general power. MatrixPower() refuses every non-symmetric
	# matrix by construction, and an eigendecomposition cannot always supply one.
	Then("MatrixPower still refuses the very matrix Schur handles",
	     RefusesPower(aA, -1), TRUE)
EndScenario()

Scenario("...and the 2x2 blocks are real, not a formality")
	# A rotation: eigenvalues 2 +/- 3i, plus 1 and 5. T MUST carry a 2x2 block, because
	# a real quasi-triangular form cannot put a complex number on its diagonal.
	aRot = [ [2,-3,0,0], [3,2,0,0], [0,0,1,0], [0,0,0,5] ]
	oRot = new stzMatrix(aRot)
	aI4 = [ [1,0,0,0], [0,1,0,0], [0,0,1,0], [0,0,0,1] ]

	Then("T carries a genuine 2x2 block", HasTwoByTwo(oRot.SchurT()), TRUE)

	# The back-substitution solves that block as a PAIR. Dividing through one diagonal
	# entry at a time would return a plausible-looking matrix and the wrong answer --
	# a real matrix with complex eigenvalues is perfectly invertible.
	Then("...and the inverse is right anyway",
	     SameMat(MatMul(aRot, oRot.SchurInverse()), aI4), TRUE)
EndScenario()

Scenario("MATRIX FUNCTIONS OF A NON-SYMMETRIC MATRIX: f(A) = Q f(T) Q'")
	# MatrixSquareRoot() applies f to a DIAGONAL and is done, which is exactly why it
	# refuses every non-symmetric matrix. Here T is only quasi-triangular, so f(T) is
	# built block by block -- and that block recurrence is the whole algorithm.
	aA = [ [4,1,2,0], [0,3,1,5], [2,0,6,1], [1,2,0,4] ]
	oA = new stzMatrix(aA)

	Then("the symmetric route refuses this matrix", RefusesPower(aA, 0.5), TRUE)

	aR = oA.GeneralSquareRoot()
	Then("...and the general one squares back to it",
	     SameMat(MatMul(aR, aR), aA), TRUE)

	# and where BOTH apply they agree -- two algorithms with nothing in common below the
	# matrix (a Householder Schur reduction with a block recurrence, against a Jacobi
	# eigendecomposition), reaching one answer
	aSym = [ [6,2,1], [2,5,2], [1,2,4] ]
	oSym = new stzMatrix(aSym)
	Then("on symmetric input the two routes agree",
	     SameMat(oSym.GeneralSquareRoot(), oSym.MatrixSquareRoot()), TRUE)
EndScenario()

Scenario("...and a DEFECTIVE matrix has no eigendecomposition and a fine square root")
	# [[1,1],[0,1]] is the smallest defective matrix: one eigenvalue, ONE eigenvector.
	# f(A) = V f(L) V^-1 needs a full set and this has not got one -- while its square
	# root is perfectly ordinary, and the Schur form reaches it because EVERY real
	# matrix has a Schur form.
	#
	# This is the case that justifies the whole apparatus. Everything else here could
	# have been done by diagonalising.
	aDef = [ [1,1], [0,1] ]
	oDef = new stzMatrix(aDef)
	aRoot = oDef.GeneralSquareRoot()

	Then("the square root is exactly [[1,0.5],[0,1]]",
	     fabs(aRoot[1][1] - 1) < 0.000001 and fabs(aRoot[1][2] - 0.5) < 0.000001 and
	     fabs(aRoot[2][1]) < 0.000001 and fabs(aRoot[2][2] - 1) < 0.000001, TRUE)
	Then("...and it squares back", SameMat(MatMul(aRoot, aRoot), aDef), TRUE)

	# a complex PAIR is fine -- inside a 2x2 block the arithmetic is ordinary complex
	# arithmetic wearing a real basis
	aRot = [ [2,-3,0,0], [3,2,0,0], [0,0,1,0], [0,0,0,5] ]
	oRot = new stzMatrix(aRot)
	Then("a complex eigenvalue pair is no obstacle",
	     SameMat(MatMul(oRot.GeneralSquareRoot(), oRot.GeneralSquareRoot()), aRot), TRUE)

	# a lone NEGATIVE REAL eigenvalue is, because its root is complex
	Then("but a negative real eigenvalue is refused, not returned as NaN",
	     RefusesGeneralRoot([ [-4,0], [0,1] ]), TRUE)
EndScenario()

Scenario("...and the exponential does NOT want a Schur decomposition")
	# Scaling and squaring with a Pade approximant, which is what every serious library
	# uses and needs no decomposition at all.
	#
	# WORTH SAYING NEXT TO THE SQUARE ROOT: not every matrix function wants a Schur
	# form. The square root does -- the block recurrence IS the algorithm. The
	# exponential does not, and routing it through one would be slower and no more
	# accurate. A decomposition is a tool, not a house style.
	aNil = [ [0,1,0], [0,0,1], [0,0,0] ]
	oNil = new stzMatrix(aNil)
	aE = oNil.MatrixExp()

	# A NILPOTENT MATRIX gives an EXACT polynomial: N^3 = 0, so exp(N) = I + N + N^2/2
	# and nothing after. A hard check -- an approximation that was merely close would
	# miss the exact 0.5.
	Then("exp of a nilpotent matrix is an exact polynomial",
	     SameMat(aE, [ [1,1,0.5], [0,1,1], [0,0,1] ]), TRUE)

	aA = [ [4,1,2,0], [0,3,1,5], [2,0,6,1], [1,2,0,4] ]
	oA = new stzMatrix(aA)
	oNeg = new stzMatrix(Negated(aA))
	aI4 = [ [1,0,0,0], [0,1,0,0], [0,0,1,0], [0,0,0,1] ]

	# exp(A) exp(-A) = I. The scaling-and-squaring runs twice on genuinely different
	# inputs, so agreeing is a statement about the algorithm rather than about one lucky
	# evaluation.
	Then("exp(A) exp(-A) is the identity",
	     SameMat(MatMul(oA.MatrixExp(), oNeg.MatrixExp()), aI4), TRUE)
EndScenario()

Scenario("THE MATRIX LOGARITHM: inverse scaling and squaring")
	# A series for log converges only near the identity, and a general matrix is not
	# near it. So: take repeated SQUARE ROOTS until it is, evaluate the series there,
	# and multiply back by 2^k -- since log(A) = 2^k * log(A^(1/2^k)).
	#
	# THE SQUARE ROOTS ARE THE SCHUR ONES. This is the third layer of one construction:
	# the Schur form gives the square root, the square root gives the logarithm, and the
	# logarithm with the exponential gives every real power. Each is short because the
	# one beneath it did the work.
	aA = [ [4,1,2,0], [0,3,1,5], [2,0,6,1], [1,2,0,4] ]
	oA = new stzMatrix(aA)
	oL = new stzMatrix(oA.MatrixLog())

	# THE DEFINING PROPERTY, and the only one worth asserting: the logarithm is what the
	# exponential undoes. Checked through genuinely different algorithms -- inverse
	# scaling and squaring going out, Pade scaling and squaring coming back -- so
	# agreeing is not two halves of one routine cancelling.
	Then("exp(log(A)) is A", SameMat(oL.MatrixExp(), aA), TRUE)

	# the identity and a diagonal are the cases with closed-form answers to check
	oEye = new stzMatrix([ [1,0,0], [0,1,0], [0,0,1] ])
	Then("log of the identity is zero",
	     SameMat(oEye.MatrixLog(), [ [0,0,0], [0,0,0], [0,0,0] ]), TRUE)
	oDiag = new stzMatrix([ [2,0,0], [0,7,0], [0,0,0.5] ])
	Then("...and log of a diagonal is entrywise",
	     SameMat(oDiag.MatrixLog(), [ [log(2),0,0], [0,log(7),0], [0,0,log(0.5)] ]), TRUE)
EndScenario()

Scenario("...and the defective matrix has an EXACT logarithm")
	# exp([[0,1],[0,0]]) = [[1,1],[0,1]] exactly, since the nilpotent series stops after
	# one term. So the logarithm of [[1,1],[0,1]] is [[0,1],[0,0]] and nothing else --
	# an exact target on a matrix with only ONE eigenvector, where no eigendecomposition
	# exists to compute it from.
	oDef = new stzMatrix([ [1,1], [0,1] ])
	Then("log([[1,1],[0,1]]) is exactly [[0,1],[0,0]]",
	     SameMat(oDef.MatrixLog(), [ [0,1], [0,0] ]), TRUE)

	# A SINGULAR matrix has no logarithm at all -- the exponential is never singular, so
	# nothing maps to one. That is a different refusal from the negative-real-eigenvalue
	# case, which has a logarithm that is merely COMPLEX.
	Then("a singular matrix has no logarithm at all",
	     RefusesLog([ [1,2,3], [4,5,6], [5,7,9] ]), TRUE)
	Then("...and the message says why", StzFindFirst("SINGULAR", WhyNoLog()) > 0, TRUE)
	Then("a negative real eigenvalue has only a complex one",
	     RefusesLog([ [-4,0], [0,1] ]), TRUE)
EndScenario()

Scenario("...and then ANY real power follows, which MatrixPower could not give")
	# A^p = exp(p log A). Two lines in the engine, because the logarithm and the
	# exponential did the work -- which is what a foundation is supposed to look like.
	aA = [ [4,1,2,0], [0,3,1,5], [2,0,6,1], [1,2,0,4] ]
	oA = new stzMatrix(aA)

	Then("the symmetric route still refuses this matrix", RefusesPower(aA, 0.5), TRUE)

	aHalf = oA.GeneralPower(0.5)
	Then("...and A^0.5 squares back to A", SameMat(MatMul(aHalf, aHalf), aA), TRUE)

	# AND IT AGREES WITH THE SCHUR SQUARE ROOT, which reached the same matrix by an
	# entirely different road: a block recurrence rather than exp(0.5 log A). Two
	# algorithms, one answer.
	Then("...and matches the Schur square root",
	     SameMat(aHalf, oA.GeneralSquareRoot()), TRUE)

	# a quarter power COMPOSES -- a routine that was not really exponentiating would
	# pass the squares-back test and fail this one
	aQuarter = oA.GeneralPower(0.25)
	Then("...and (A^0.25)^2 is A^0.5", SameMat(MatMul(aQuarter, aQuarter), aHalf), TRUE)
EndScenario()

Scenario("THE MATRIX SINE AND COSINE -- and these need nothing beneath them")
	# Scaling with the double-angle recurrences: scale A down until its norm is small,
	# where a handful of Taylor terms is exact to rounding, then climb back with
	#
	#     cos(2X) = 2 cos(X)^2 - I        sin(2X) = 2 sin(X) cos(X)
	#
	# GeneralSquareRoot() needed a Schur form, MatrixLog() needed the square root, and
	# GeneralPower() needed the logarithm. THESE NEED NONE OF IT -- no eigenvalues, no
	# triangularisation, no factorisation at all. Worth saying, because three scenarios
	# in a row might suggest a house style: a decomposition is reached for when the
	# algorithm requires one, and here it does not.
	aA = [ [4,1,2,0], [0,3,1,5], [2,0,6,1], [1,2,0,4] ]
	oA = new stzMatrix(aA)
	aI4 = [ [1,0,0,0], [0,1,0,0], [0,0,1,0], [0,0,0,1] ]

	aS = oA.MatrixSin()
	aC = oA.MatrixCos()

	# THE STRONGEST CHECK AVAILABLE for this pair, and it cannot be satisfied by
	# accident: both come from a scaled Taylor series climbed back through nine
	# doublings, so anything wrong in either the series or the recurrence surfaces here
	# rather than hiding in a plausible-looking matrix.
	#
	# Note it is the MATRIX identity: sin(A)^2 is the matrix squared, which for a
	# non-symmetric A is a very different object from squaring each entry.
	Then("sin(A)^2 + cos(A)^2 is the identity",
	     SameMat(MatAdd(MatMul(aS, aS), MatMul(aC, aC)), aI4), TRUE)

	oZero = new stzMatrix([ [0,0], [0,0] ])
	Then("cos(0) is the identity", SameMat(oZero.MatrixCos(), [ [1,0], [0,1] ]), TRUE)
	Then("...and sin(0) is zero", SameMat(oZero.MatrixSin(), [ [0,0], [0,0] ]), TRUE)
EndScenario()

Scenario("...with exact answers on a nilpotent matrix, and the right parity")
	# N^3 = 0 truncates both series exactly: sin(N) = N, and cos(N) = I - N^2/2. A hard
	# target -- an approximation that was merely close would miss the exact -0.5, and a
	# series that had quietly stopped one term early would miss it too.
	aNil = [ [0,1,0], [0,0,1], [0,0,0] ]
	oNil = new stzMatrix(aNil)
	Then("sin of a nilpotent matrix is the matrix itself",
	     SameMat(oNil.MatrixSin(), aNil), TRUE)
	Then("...and its cosine is I - N^2/2 exactly",
	     SameMat(oNil.MatrixCos(), [ [1,0,-0.5], [0,1,0], [0,0,1] ]), TRUE)

	# even and odd, as functions of a MATRIX
	aA = [ [0.9,1.4,-0.3], [0.0,0.6,1.1], [-0.7,0.1,0.8] ]
	oA = new stzMatrix(aA)
	oNeg = new stzMatrix(Negated(aA))
	Then("cosine is even", SameMat(oA.MatrixCos(), oNeg.MatrixCos()), TRUE)
	Then("...and sine is odd", SameMat(oA.MatrixSin(), Negated(oNeg.MatrixSin())), TRUE)
EndScenario()

Scenario("...and on a SYMMETRIC matrix they agree with the eigendecomposition")
	# Q cos(L) Q' -- a completely different algorithm, available only because this
	# particular matrix happens to be symmetric. Scaled Taylor with double-angle
	# recurrences against a Jacobi eigendecomposition: nothing shared below the matrix,
	# and one answer.
	#
	# It is the same cross-check the square root got, and it is the one that says these
	# are computing the standard thing rather than something adjacent to it.
	aSym = [ [6,2,1], [2,5,2], [1,2,4] ]
	oSym = new stzMatrix(aSym)
	Then("the cosine matches Q cos(L) Q'",
	     SameMat(oSym.MatrixCos(), CosViaEigen(oSym)), TRUE)
EndScenario()

Scenario("THE HYPERBOLIC PAIR -- the same routine with one sign changed")
	# Write the two families out and the difference is a single alternating sign:
	#
	#     cos(X)  = I - X^2/2! + X^4/4! - ...    cosh(X) = I + X^2/2! + X^4/4! + ...
	#     sin(X)  = X - X^3/3! + X^5/5! - ...    sinh(X) = X + X^3/3! + X^5/5! + ...
	#
	# And the double-angle recurrences that climb back from the scaled matrix are not
	# merely similar, they are IDENTICAL. So underneath there is ONE routine and a flag:
	# a second copy would be a second transcription of one algorithm, and two copies
	# drift.
	aA = [ [0.9,1.4,-0.3,0.2], [0.0,0.6,1.1,0.5], [-0.7,0.1,0.8,1.0], [0.3,-0.5,0.0,1.2] ]
	oA = new stzMatrix(aA)
	aI4 = [ [1,0,0,0], [0,1,0,0], [0,0,1,0], [0,0,0,1] ]

	aSh = oA.MatrixSinh()
	aCh = oA.MatrixCosh()

	# THE MINUS is what makes this a different check rather than the same one twice --
	# a sign error anywhere would satisfy one of the two identities and fail the other.
	Then("cosh(A)^2 - sinh(A)^2 is the identity",
	     SameMat(MatSub(MatMul(aCh, aCh), MatMul(aSh, aSh)), aI4), TRUE)

	oZero = new stzMatrix([ [0,0], [0,0] ])
	Then("cosh(0) is the identity", SameMat(oZero.MatrixCosh(), [ [1,0], [0,1] ]), TRUE)
	Then("...and sinh(0) is zero", SameMat(oZero.MatrixSinh(), [ [0,0], [0,0] ]), TRUE)
	Then("cosh is even and sinh is odd", HyperbolicParity(aA), TRUE)
EndScenario()

Scenario("...and cosh + sinh = exp, across two unrelated algorithms")
	# THE BEST CROSS-CHECK IN THIS FAMILY. The hyperbolic pair comes from a scaled
	# TAYLOR series climbed back through double-angle recurrences; MatrixExp() comes
	# from a PADE approximant climbed back through squaring. Nothing is shared between
	# them but the matrix itself, and the defining relation still holds -- on entries
	# that reach the hundreds.
	aA = [ [4,1,2,0], [0,3,1,5], [2,0,6,1], [1,2,0,4] ]
	oA = new stzMatrix(aA)
	Then("cosh(A) + sinh(A) is exp(A)",
	     SameMat(MatAdd(oA.MatrixCosh(), oA.MatrixSinh()), oA.MatrixExp()), TRUE)
EndScenario()

Scenario("...and a nilpotent matrix separates the families by exactly that sign")
	# N^3 = 0 truncates both series exactly. The circular and hyperbolic answers differ
	# in ONE character:
	#
	#     cos(N)  = I - N^2/2        cosh(N) = I + N^2/2
	#     sin(N)  = N               sinh(N) = N
	#
	# So this pair of assertions pins the shared routine's one branch FROM BOTH SIDES.
	# A routine that ignored the flag would pass one of them and fail the other, which
	# is more than either test could say alone.
	aNil = [ [0,1,0], [0,0,1], [0,0,0] ]
	oNil = new stzMatrix(aNil)

	Then("cos of a nilpotent matrix is I - N^2/2",
	     SameMat(oNil.MatrixCos(), [ [1,0,-0.5], [0,1,0], [0,0,1] ]), TRUE)
	Then("...and cosh of it is I + N^2/2",
	     SameMat(oNil.MatrixCosh(), [ [1,0,0.5], [0,1,0], [0,0,1] ]), TRUE)
	Then("...while both sines are the matrix itself",
	     SameMat(oNil.MatrixSin(), aNil) and SameMat(oNil.MatrixSinh(), aNil), TRUE)
EndScenario()

Scenario("THE MATRIX TANGENT, and the side does not matter")
	# tan(A) = sin(A) * cos(A)^-1.
	#
	# FOR TWO ARBITRARY MATRICES X*Y^-1 AND Y^-1*X ARE DIFFERENT THINGS, and writing one
	# where the other was meant is a classic way to be quietly wrong. Here they are
	# EQUAL, because sin(A) and cos(A) are both functions of the SAME A -- limits of
	# polynomials in it -- and any two such functions commute.
	#
	# So there is no left-tangent and right-tangent to choose between. Asserted rather
	# than assumed, because it is exactly the kind of fact that is true, easy to lean
	# on, and worth checking once.
	aA = [ [0.9,1.4,-0.3,0.2], [0.0,0.6,1.1,0.5], [-0.7,0.1,0.8,1.0], [0.3,-0.5,0.0,1.2] ]
	oA = new stzMatrix(aA)
	aT = oA.MatrixTan()

	Then("tan(A) cos(A) is sin(A)",
	     SameMat(MatMul(aT, oA.MatrixCos()), oA.MatrixSin()), TRUE)
	Then("...and the other order gives the same matrix",
	     SameMat(aT, MatMul(InverseOf(oA.MatrixCos()), oA.MatrixSin())), TRUE)

	# (I + tan^2) cos^2 = I -- sec^2 = 1 + tan^2 rearranged so nothing is inverted twice
	Then("(I + tan^2) cos^2 is the identity",
	     SameMat(MatMul(MatAdd(MatMul(aT,aT), IdentityOf(4)), MatMul(oA.MatrixCos(), oA.MatrixCos())),
	             IdentityOf(4)), TRUE)
EndScenario()

Scenario("...and UNLIKE the sine and cosine, the tangent can fail to exist")
	# cos(A) is singular exactly when A has an eigenvalue at pi/2 + k*pi, and there the
	# tangent is undefined for the same reason tan(pi/2) is. MatrixSin() and MatrixCos()
	# refuse nothing at all; THIS refusal is the mathematics rather than a limitation of
	# the method, which is a distinction worth keeping visible.
	Then("an eigenvalue at pi/2 is refused",
	     RefusesTan([ [1.5707963267948966, 0], [0, 0.5] ]), TRUE)
	Then("...and the message says why", StzFindFirst("pi/2", WhyNoTan()) > 0, TRUE)

	# a matrix comfortably away from it is fine, and goes entrywise on a diagonal
	oOk = new stzMatrix([ [0.7,0,0], [0,-1.1,0], [0,0,0.3] ])
	Then("a diagonal goes entrywise",
	     fabs(oOk.MatrixTan()[1][1] - tan(0.7)) < 0.0000001, TRUE)

	# N^3 = 0 gives sin(N) = N and cos(N) = I - N^2/2, whose inverse is I + N^2/2
	# EXACTLY -- N^4 = 0 makes that product the identity. So tan(N) = N(I + N^2/2) = N,
	# because N^3 is already gone. An exact target that catches an inverse computed even
	# slightly wrong.
	aNil = [ [0,1,0], [0,0,1], [0,0,0] ]
	oNil = new stzMatrix(aNil)
	Then("and a nilpotent matrix is its own tangent, exactly",
	     SameMat(oNil.MatrixTan(), aNil), TRUE)
EndScenario()

Scenario("...and the hyperbolic tangent fails in a place a real spectrum cannot reach")
	aA = [ [0.9,1.4,-0.3,0.2], [0.0,0.6,1.1,0.5], [-0.7,0.1,0.8,1.0], [0.3,-0.5,0.0,1.2] ]
	oA = new stzMatrix(aA)

	Then("tanh(A) cosh(A) is sinh(A)",
	     SameMat(MatMul(oA.MatrixTanh(), oA.MatrixCosh()), oA.MatrixSinh()), TRUE)

	# (I - tanh^2) cosh^2 = I. NOTE THE MINUS -- it is what stops this being the
	# circular assertion a second time.
	aTh = oA.MatrixTanh()
	Then("(I - tanh^2) cosh^2 is the identity",
	     SameMat(MatMul(MatSub(IdentityOf(4), MatMul(aTh,aTh)),
	                    MatMul(oA.MatrixCosh(), oA.MatrixCosh())), IdentityOf(4)), TRUE)

	# cosh is singular only at PURELY IMAGINARY eigenvalues, so a real matrix with a
	# real spectrum can never break this -- while a single diagonal entry of pi/2 breaks
	# the circular tangent. Same two lines of code, genuinely different domains.
	oBig = new stzMatrix([ [5,0], [0,-3] ])
	Then("a large real spectrum is no obstacle at all",
	     fabs(oBig.MatrixTanh()[1][1] - 0.9999092042625951) < 0.0000001, TRUE)
EndScenario()

Scenario("THE MATRIX ARCTANGENT -- the first inverse, and it needed a different idea")
	# Everything before it had either a series that converges after scaling (MatrixExp,
	# MatrixSin, MatrixCos) or a decomposition handing the answer over block by block
	# (GeneralSquareRoot). The arctangent has neither: its Taylor series converges only
	# for ||X|| < 1, and there is no doubling recurrence to climb back with.
	#
	# What it has is a HALVING one -- the half-angle formula read backwards:
	#
	#     atan(A) = 2 * atan( A * (I + sqrt(I + A^2))^-1 )
	#
	# Apply it until the argument is small, take the series there, multiply by 2^k on
	# the way out. So the scaling is done by the identity itself, and each step costs a
	# MATRIX SQUARE ROOT -- another layer on the same construction.
	aA = [ [0.9,1.4,-0.3,0.2], [0.0,0.6,1.1,0.5], [-0.7,0.1,0.8,1.0], [0.3,-0.5,0.0,1.2] ]
	oA = new stzMatrix(aA)
	oAt = new stzMatrix(oA.MatrixAtan())

	# THE DEFINING IDENTITY, and the two sides share nothing: the arctangent halves
	# through matrix square roots and a Taylor series, the tangent is a scaled sine over
	# a scaled cosine with an LU inverse.
	Then("tan(atan(A)) is A", SameMat(oAt.MatrixTan(), aA), TRUE)

	# atan(N) = N - N^3/3 + ... and N^3 is already zero, so the answer is N itself --
	# exact, and it exercises the halving recurrence rather than short-circuiting it,
	# since the norm starts at 1
	aNil = [ [0,1,0], [0,0,1], [0,0,0] ]
	oNil = new stzMatrix(aNil)
	Then("...and a nilpotent matrix gives back itself, exactly",
	     SameMat(oNil.MatrixAtan(), aNil), TRUE)
EndScenario()

Scenario("...and what it refuses is the BRANCH POINT, not a limitation")
	# sqrt(I + A^2) needs I + A^2 to have no negative real eigenvalue. A real eigenvalue
	# L gives 1 + L^2, comfortably positive; a PURELY IMAGINARY one i*b gives 1 - b^2,
	# which turns negative once |b| passes one.
	#
	# That is the mathematics rather than the method. atan has branch points at exactly
	# +i and -i, so a matrix with an eigenvalue on the imaginary axis beyond them has no
	# principal arctangent to return.
	aBeyond = [ [0,-2], [2,0] ]      # eigenvalues +/- 2i
	oBeyond = new stzMatrix(aBeyond)
	Then("an eigenvalue past i has no principal arctangent",
	     RefusesAtan(aBeyond), TRUE)

	aWithin = [ [0,-0.5], [0.5,0] ]  # eigenvalues +/- 0.5i
	Then("...while one inside is answered", RefusesAtan(aWithin), FALSE)
	Then("...and the message names the branch points",
	     StzFindFirst("BRANCH POINTS", WhyNoAtan(aBeyond)) > 0, TRUE)
EndScenario()

Scenario("...and the hyperbolic twin needed no new idea, which is the asymmetry")
	# (1/2)[ log(I + A) - log(I - A) ] -- a closed form in the logarithm, which was
	# already here. Two logs and a subtraction.
	#
	# THE TWO FAMILIES HAVE MATCHED EACH OTHER LINE FOR LINE all the way up: sin against
	# sinh, cos against cosh, tan against tanh, each differing by one sign. AT THE
	# INVERSE THEY STOP -- atanh has a real closed form and atan does not, because the
	# logarithm expressing atan wants complex arguments and the one expressing atanh
	# does not.
	aSmall = [ [0.30,0.20,-0.10,0.05], [0.00,0.25,0.15,0.10],
		   [-0.10,0.00,0.20,0.15], [0.05,-0.10,0.00,0.30] ]
	oSmall = new stzMatrix(aSmall)
	oAh = new stzMatrix(oSmall.MatrixAtanh())
	Then("tanh(atanh(A)) is A", SameMat(oAh.MatrixTanh(), aSmall), TRUE)

	# and it runs to infinity at 1, exactly as atanh(1) does -- refused rather than
	# returned as a huge number that looks like an answer
	Then("an eigenvalue of 1 is refused", RefusesAtanh([ [1,0], [0,0.5] ]), TRUE)
	Then("...and so is -1", RefusesAtanh([ [-1,0], [0,0.5] ]), TRUE)
EndScenario()

Scenario("THE MATRIX ARCSINE AND ARCCOSINE")
	#     asin(A) = MatrixAtan( A * (I - A^2)^(-1/2) )
	#     acos(A) = (pi/2) I - asin(A)
	#
	# The scalar identities lifted. Everything commutes -- A and any function of A -- so
	# the lift is the same expression with matrix inverses where the divisions were, and
	# nothing has to be reordered. The arccosine is EXACT rather than a second
	# algorithm: acos + asin = pi/2 holds term by term, so it is a subtraction.
	aA = [ [0.30,0.20,-0.10,0.05], [0.00,0.25,0.15,0.10],
	       [-0.10,0.00,0.20,0.15], [0.05,-0.10,0.00,0.30] ]
	oA = new stzMatrix(aA)
	oAsin = new stzMatrix(oA.MatrixAsin())
	oAcos = new stzMatrix(oA.MatrixAcos())

	Then("sin(asin(A)) is A", SameMat(oAsin.MatrixSin(), aA), TRUE)
	Then("cos(acos(A)) is A", SameMat(oAcos.MatrixCos(), aA), TRUE)
	Then("...and asin + acos is exactly (pi/2) I",
	     SameMat(MatAdd(oA.MatrixAsin(), oA.MatrixAcos()), PiOverTwo(4)), TRUE)

	# asin(N) = N + N^3/6 + ... and N^3 is already zero
	aNil = [ [0,1,0], [0,0,1], [0,0,0] ]
	oNil = new stzMatrix(aNil)
	Then("a nilpotent matrix gives back itself, exactly",
	     SameMat(oNil.MatrixAsin(), aNil), TRUE)
EndScenario()

Scenario("...and the branch point is the OTHER one this time")
	# sqrt(I - A^2) needs no negative real eigenvalue, and for a real L that is 1 - L^2
	# -- negative exactly when |L| passes ONE. Which is where asin stops being real:
	# asin(2) has no real value, and neither has the arcsine of a matrix with an
	# eigenvalue at 2.
	#
	# Compare MatrixAtan(), whose obstacle was |b| > 1 on the IMAGINARY axis. Same
	# square root, same mechanism, DIFFERENT BRANCH POINTS -- because they belong to
	# different functions.
	Then("an eigenvalue at 2 has no real arcsine", RefusesArc([ [2,0], [0,0.5] ], "asin"), TRUE)
	Then("...nor a real arccosine", RefusesArc([ [2,0], [0,0.5] ], "acos"), TRUE)
	Then("...while one inside is answered", RefusesArc([ [0.5,0], [0,0.25] ], "asin"), FALSE)

	# AND acosh WANTS THE OPPOSITE HALF OF THE LINE. A^2 - I gives L^2 - 1, negative
	# exactly when |L| falls BELOW one. Two functions one character apart in the source
	# -- a plus against a minus -- refusing mirror-image domains.
	Then("acosh refuses an eigenvalue INSIDE the unit interval",
	     RefusesArc([ [0.5,0], [0,0.25] ], "acosh"), TRUE)
	Then("...and answers one outside it", RefusesArc([ [3,0], [0,4] ], "acosh"), FALSE)
EndScenario()

Scenario("...and every hyperbolic inverse is a closed form in the logarithm")
	#     asinh(A) = MatrixLog( A + sqrt(A^2 + I) )
	#     acosh(A) = MatrixLog( A + sqrt(A^2 - I) )
	#     atanh(A) = (1/2) [ MatrixLog(I + A) - MatrixLog(I - A) ]
	#
	# WHICH COMPLETES A PATTERN WORTH STATING. Every hyperbolic inverse is a closed form
	# in the logarithm, while each circular one had to be BUILT -- MatrixAtan() needed a
	# halving recurrence, and MatrixAsin() is defined through it. The two families
	# matched sign for sign all the way up, to the point of sharing one routine, and
	# they part company at the inverses.
	aReal = [ [3,0.4,0.1], [0,-5,0.2], [0,0,0.25] ]   # TRIANGULAR: a real spectrum
	oReal = new stzMatrix(aReal)
	oAsinh = new stzMatrix(oReal.MatrixAsinh())
	Then("sinh(asinh(A)) is A", SameMat(oAsinh.MatrixSinh(), aReal), TRUE)

	# the same matrix the circular arcsine declines, since its eigenvalues run past 1
	Then("...on a matrix the arcsine refuses outright",
	     RefusesArc(aReal, "asin"), TRUE)

	# AND "REFUSES NOTHING" IS ABOUT A REAL SPECTRUM, NOT REAL ENTRIES. The two are easy
	# to conflate -- the engine test above conflated them and failed for it. A real
	# matrix may have complex eigenvalues, and then A^2 + I can carry a negative real
	# one and the square root inside has no real answer.
	aComplex = [ [0.9,1.4,-0.3,0.2], [0.0,0.6,1.1,0.5],
	             [-0.7,0.1,0.8,1.0], [0.3,-0.5,0.0,1.2] ]   # a pair at 1.2692 +/- 1.0113i
	Then("a complex pair can put even asinh out of reach",
	     RefusesArc(aComplex, "asinh"), TRUE)
EndScenario()










Summary()

func Rnd9(n)
	return ceil(n * 1000000000 - 0.5) / 1000000000

func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000

# max over j of || A v_j - lambda_j v_j ||, relative to ||A|| -- computed in complex
# arithmetic through the public surface, so it tests what a caller would get
func Residual(aM)
	oM = new stzMatrix(aM)
	n = len(aM)
	aL = oM.ComplexEigenValues()
	aV = oM.ComplexEigenVectors()

	nNorm = 0
	for i = 1 to n
		for j = 1 to n
			nNorm += fabs(aM[i][j])
		next
	next
	if nNorm = 0
		nNorm = 1
	ok

	nWorst = 0
	for j = 1 to n
		for i = 1 to n
			# CHAINS GO THROUGH THE Q FORMS. The plain Plus/Times/Minus return
			# [re, im] DATA -- a Softanza plain method never returns an object --
			# so a chain that keeps calling methods must use the Q twins.
			oAcc = new stzComplex(0, 0)
			for k = 1 to n
				oAcc = oAcc.PlusQ(aV[k][j].TimesQ(aM[i][k]))
			next
			oRhs = aL[j].TimesQ(aV[i][j])
			nD = oAcc.MinusQ(oRhs).Modulus()
			if nD > nWorst
				nWorst = nD
			ok
		next
	next
	return nWorst / nNorm

func RaisesVec(oM)
	b = FALSE
	try
		v = oM.EigenVectors()
	catch
		b = TRUE
	done
	return b

func RaisesVecOf(oM)
	b = FALSE
	try
		v = oM.ComplexEigenVectors()
	catch
		b = TRUE
	done
	return b

func WhyVec(oM)
	s = ""
	try
		v = oM.EigenVectors()
	catch
		s = cCatchError
	done
	return s

func SameMat(aX, aY)
	for _smI_ = 1 to len(aX)
		for _smJ_ = 1 to len(aX[1])
			if fabs(aX[_smI_][_smJ_] - aY[_smI_][_smJ_]) > 0.000001
				return FALSE
			ok
		next
	next
	return TRUE

func SymmetricMat(aX)
	for _syI_ = 1 to len(aX)
		for _syJ_ = _syI_+1 to len(aX)
			if fabs(aX[_syI_][_syJ_] - aX[_syJ_][_syI_]) > 0.000001
				return FALSE
			ok
		next
	next
	return TRUE

func MatMul(aX, aY)
	_mmR_ = []
	for _mmI_ = 1 to len(aX)
		_mmRow_ = []
		for _mmJ_ = 1 to len(aY[1])
			_mmS_ = 0
			for _mmT_ = 1 to len(aY)
				_mmS_ += aX[_mmI_][_mmT_] * aY[_mmT_][_mmJ_]
			next
			_mmRow_ + _mmS_
		next
		_mmR_ + _mmRow_
	next
	return _mmR_

func RefusesPower(aX, p)
	_rpB_ = FALSE
	try
		_rpO_ = new stzMatrix(aX)
		_rpO_.MatrixPower(p)
	catch
		_rpB_ = TRUE
	done
	return _rpB_

func MatTrans(aX)
	_mtR_ = []
	for _mtI_ = 1 to len(aX[1])
		_mtRow_ = []
		for _mtJ_ = 1 to len(aX)
			_mtRow_ + aX[_mtJ_][_mtI_]
		next
		_mtR_ + _mtRow_
	next
	return _mtR_

func QuasiTriangular(aX)
	for _qtI_ = 3 to len(aX)
		for _qtJ_ = 1 to _qtI_-2
			if fabs(aX[_qtI_][_qtJ_]) > 0.00001
				return FALSE
			ok
		next
	next
	return TRUE

func HasTwoByTwo(aX)
	for _htI_ = 2 to len(aX)
		if fabs(aX[_htI_][_htI_-1]) > 0.00001
			return TRUE
		ok
	next
	return FALSE

func RefusesGeneralRoot(aX)
	_rgB_ = FALSE
	try
		_rgO_ = new stzMatrix(aX)
		_rgO_.GeneralSquareRoot()
	catch
		_rgB_ = TRUE
	done
	return _rgB_

func Negated(aX)
	_ngR_ = []
	for _ngI_ = 1 to len(aX)
		_ngRow_ = []
		for _ngJ_ = 1 to len(aX[1])
			_ngRow_ + (-aX[_ngI_][_ngJ_])
		next
		_ngR_ + _ngRow_
	next
	return _ngR_

func RefusesLog(aX)
	_rlB_ = FALSE
	try
		_rlO_ = new stzMatrix(aX)
		_rlO_.MatrixLog()
	catch
		_rlB_ = TRUE
	done
	return _rlB_

func WhyNoLog()
	_wlS_ = ""
	try
		_wlO_ = new stzMatrix([ [1,2,3], [4,5,6], [5,7,9] ])
		_wlO_.MatrixLog()
	catch
		_wlS_ = cCatchError
	done
	return _wlS_

func MatAdd(aX, aY)
	_adR_ = []
	for _adI_ = 1 to len(aX)
		_adRow_ = []
		for _adJ_ = 1 to len(aX[1])
			_adRow_ + (aX[_adI_][_adJ_] + aY[_adI_][_adJ_])
		next
		_adR_ + _adRow_
	next
	return _adR_

# Q cos(L) Q' from the symmetric eigendecomposition -- the independent route
func CosViaEigen(oM)
	_ceV_ = oM.EigenValues()
	_ceQ_ = oM.EigenVectors()
	_ceN_ = len(_ceV_)
	_ceR_ = []
	for _ceI_ = 1 to _ceN_
		_ceRow_ = []
		for _ceJ_ = 1 to _ceN_
			_ceS_ = 0
			for _ceT_ = 1 to _ceN_
				_ceS_ += _ceQ_[_ceI_][_ceT_] * cos(_ceV_[_ceT_]) * _ceQ_[_ceJ_][_ceT_]
			next
			_ceRow_ + _ceS_
		next
		_ceR_ + _ceRow_
	next
	return _ceR_

func MatSub(aX, aY)
	_sbR_ = []
	for _sbI_ = 1 to len(aX)
		_sbRow_ = []
		for _sbJ_ = 1 to len(aX[1])
			_sbRow_ + (aX[_sbI_][_sbJ_] - aY[_sbI_][_sbJ_])
		next
		_sbR_ + _sbRow_
	next
	return _sbR_

func HyperbolicParity(aX)
	_hpA_ = new stzMatrix(aX)
	_hpB_ = new stzMatrix(Negated(aX))
	if NOT SameMat(_hpA_.MatrixCosh(), _hpB_.MatrixCosh())
		return FALSE
	ok
	return SameMat(_hpA_.MatrixSinh(), Negated(_hpB_.MatrixSinh()))

func IdentityOf(n)
	_idR_ = []
	for _idI_ = 1 to n
		_idRow_ = []
		for _idJ_ = 1 to n
			if _idI_ = _idJ_
				_idRow_ + 1
			else
				_idRow_ + 0
			ok
		next
		_idR_ + _idRow_
	next
	return _idR_

func InverseOf(aX)
	_ivO_ = new stzMatrix(aX)
	return _ivO_.LUInverse()

func RefusesTan(aX)
	_rtB_ = FALSE
	try
		_rtO_ = new stzMatrix(aX)
		_rtO_.MatrixTan()
	catch
		_rtB_ = TRUE
	done
	return _rtB_

func WhyNoTan()
	_wtS_ = ""
	try
		_wtO_ = new stzMatrix([ [1.5707963267948966, 0], [0, 0.5] ])
		_wtO_.MatrixTan()
	catch
		_wtS_ = cCatchError
	done
	return _wtS_

func RefusesAtan(aX)
	_raB_ = FALSE
	try
		_raO_ = new stzMatrix(aX)
		_raO_.MatrixAtan()
	catch
		_raB_ = TRUE
	done
	return _raB_

func WhyNoAtan(aX)
	_waS_ = ""
	try
		_waO_ = new stzMatrix(aX)
		_waO_.MatrixAtan()
	catch
		_waS_ = cCatchError
	done
	return _waS_

func RefusesAtanh(aX)
	_rhB_ = FALSE
	try
		_rhO_ = new stzMatrix(aX)
		_rhO_.MatrixAtanh()
	catch
		_rhB_ = TRUE
	done
	return _rhB_

func PiOverTwo(n)
	_phR_ = []
	for _phI_ = 1 to n
		_phRow_ = []
		for _phJ_ = 1 to n
			if _phI_ = _phJ_
				_phRow_ + (3.14159265358979 / 2)
			else
				_phRow_ + 0
			ok
		next
		_phR_ + _phRow_
	next
	return _phR_

func RefusesArc(aX, cWhich)
	_rcB_ = FALSE
	try
		_rcO_ = new stzMatrix(aX)
		if cWhich = "asin"
			_rcO_.MatrixAsin()
		but cWhich = "acos"
			_rcO_.MatrixAcos()
		but cWhich = "asinh"
			_rcO_.MatrixAsinh()
		else
			_rcO_.MatrixAcosh()
		ok
	catch
		_rcB_ = TRUE
	done
	return _rcB_
