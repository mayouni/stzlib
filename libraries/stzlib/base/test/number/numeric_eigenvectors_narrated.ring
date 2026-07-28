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
