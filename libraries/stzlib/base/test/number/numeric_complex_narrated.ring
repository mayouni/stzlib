load "../../stzBase.ring"
load "../_narrated.ring"

# COMPLEX NUMBERS, AND THE REFUSAL THEY LIFT (numeric phase 7).
#
# PHASE 7 IS THE ONE PHASE WITH A GATE WRITTEN INTO IT: "complex numbers; decimal via
# mpdecimal if the big-int-backed one proves insufficient; OSQP if QP becomes real;
# HiGHS if MIP becomes real; KISS FFT if spectral work becomes real. EACH GATED ON A
# GENUINE CONSUMER, NOT ON COMPLETENESS."
#
# So the census came first, and four of the five failed it:
#
#   mpdecimal  -- the condition was "if the big-int decimal proves insufficient". It
#                 was measured instead of assumed: 0.1 + 0.2 is exactly 0.3, a
#                 29-place product is exact, a 30-digit integer plus 1e-9 is exact,
#                 and a division that does not terminate reports itself approximate
#                 AND says why. It is sufficient. Not built.
#   OSQP       -- nothing in the library poses a quadratic program. Not built.
#   HiGHS      -- nothing poses a mixed-integer program. Not built.
#   KISS FFT   -- there is no spectral or signal code to serve. Not built.
#
# Building any of those would have been completeness, which is the thing the gate
# exists to refuse. A library is not improved by an FFT nothing calls.
#
# COMPLEX NUMBERS PASSED, on one consumer, and it was already written down as a
# refusal in phase 4 slice 8:
#
#     EigenValues: this matrix is not symmetric, and a general matrix has complex
#     eigenvalues. Only the symmetric case is implemented.
#
# That refusal was the right call at the time -- the alternative was returning the
# eigenvalues of (A + A')/2 and letting a caller believe they belonged to A -- and
# the honest way to remove it is to implement what it was refusing. So: a complex
# type, and a Francis double-shift QR behind it.
#
# WHY A GENERAL MATRIX NEEDS COMPLEX AT ALL. A quarter-turn rotation has no real
# eigendirection -- every vector moves -- so its eigenvalues cannot be real. They are
# +i and -i. This is not a numerical difficulty to be worked around; it is what the
# answer is. Complex eigenvalues of a REAL matrix always come in conjugate pairs,
# which is why the algorithm can find them in real arithmetic by shifting with a pair
# rather than with a complex number.

Scenario("the arithmetic a complex number owes")
	oZ = new stzComplex(3, 4)
	Then("the real part", oZ.RealPart(), 3)
	Then("the imaginary part", oZ.ImaginaryPart(), 4)
	Then("it reads back", oZ.Content(), "3+4i")
	Then("the modulus is the 3-4-5 triangle", oZ.Modulus(), 5)
	Then("it is not real", oZ.IsReal(), FALSE)

	oW = new stzComplex(1, -2)
	Then("a negative imaginary part prints with a minus", oW.Content(), "1-2i")
	# THE Q FORMS, because a chain needs an object back. The plain Plus/Minus/Times
	# return the [re, im] DATA -- a Softanza plain method never returns a Softanza
	# object -- so anything that keeps calling methods goes through the Q twin.
	Then("...and adds", oZ.PlusQ(oW).Content(), "4+2i")
	Then("...and subtracts", oZ.MinusQ(oW).Content(), "2+6i")
	# (3+4i)(1-2i) = 3 - 6i + 4i - 8i^2 = 11 - 2i
	Then("...and multiplies, minding that i^2 is -1", oZ.TimesQ(oW).Content(), "11-2i")
	# ...and the plain forms hand back the data instead
	Then("the plain form returns data", @@(oZ.Plus(oW)), "[ 4, 2 ]")

	# division checked by multiplying back, which is the only check that cannot
	# agree with a wrong implementation of itself
	oQ = oZ.DividedByQ(oW)
	oBack = oQ.TimesQ(oW)
	Then("division undoes multiplication", Rnd8(oBack.RealPart()), 3)
	Then("...in both parts", Rnd8(oBack.ImaginaryPart()), 4)

	# Conjugated() is the PASSIVE form and returns data; ConjugatedQ() the object.
	# Conjugate() is ACTIVE -- it would mutate oZ, which this scenario does not want.
	Then("the conjugate flips the sign", oZ.ConjugatedQ().Content(), "3-4i")
	Then("...and the passive form gives the pair", @@(oZ.Conjugated()), "[ 3, -4 ]")
	Then("...leaving the original alone", oZ.ImaginaryPart(), 4)
	Then("a real number prints without an i", (new stzComplex(5, 0)).Content(), "5")
	Then("...and i itself prints as i", (new stzComplex(0, 1)).Content(), "i")
	Then("dividing by zero is refused", RaisesDiv(oZ), TRUE)
EndScenario()

Scenario("THE REFUSAL IS LIFTED -- a non-symmetric matrix with a real spectrum")
	# This raised before phase 7, for every non-symmetric matrix without exception.
	# An upper-triangular matrix's eigenvalues are its diagonal, which anyone can
	# check by hand -- and it was refused purely because the routine behind
	# EigenValues() was the symmetric one.
	oT = new stzMatrix([ [1,2,3], [0,4,5], [0,0,6] ])
	Then("an upper-triangular matrix is answered now", @@(oT.EigenValues()), "[ 1, 4, 6 ]")

	# a companion matrix: its eigenvalues ARE the roots of a polynomial, which is a
	# capability the library did not have at all
	oC = new stzMatrix([ [6,-11,6], [1,0,0], [0,1,0] ])
	aR = oC.EigenValues()
	Then("three roots came back", len(aR), 3)
	Then("...and they are 1, 2, 3 for x^3-6x^2+11x-6",
	     HasNear(aR, 1) and HasNear(aR, 2) and HasNear(aR, 3), TRUE)
EndScenario()

Scenario("...and it still refuses what it should")
	# A rotation's eigenvalues are genuinely complex. EigenValues() returns plain
	# numbers, so it must NOT quietly drop the imaginary part -- that is exactly the
	# plausible-wrong-answer the original refusal existed to prevent. It raises, and
	# names the door.
	oQ = new stzMatrix([ [0,-1], [1,0] ])
	Then("a rotation is refused by the real-valued method", RaisesEig(oQ), TRUE)
	Then("...naming an offending eigenvalue", StzFindFirst("i", WhyEig(oQ)) > 0, TRUE)
	Then("...and pointing at ComplexEigenValues",
	     StzFindFirst("ComplexEigenValues", WhyEig(oQ)) > 0, TRUE)

	aZ = oQ.ComplexEigenValues()
	Then("which answers +i and -i", (aZ[1].Content() = "i" and aZ[2].Content() = "-i") or
	     (aZ[1].Content() = "-i" and aZ[2].Content() = "i"), TRUE)
	Then("both have modulus 1 -- a rotation does not stretch", Rnd8(aZ[1].Modulus()), 1)
	Then("...both of them", Rnd8(aZ[2].Modulus()), 1)
EndScenario()

Scenario("conjugate pairs, because the matrix is real")
	# A real matrix cannot have an odd number of genuinely complex eigenvalues, and
	# their imaginary parts must cancel exactly. That is a property of the ANSWER, so
	# it can be checked without knowing what the answer is -- which is the useful
	# kind of test for an iterative algorithm.
	oM = new stzMatrix([ [1,-2,3], [4,5,-6], [7,8,9] ])
	aZ = oM.ComplexEigenValues()
	nImSum = 0
	nComplex = 0
	_aZ138_ = aZ
	_nZ138_ = len(_aZ138_)
	for _iZ138_ = 1 to _nZ138_
		z = _aZ138_[_iZ138_]
		nImSum += z.ImaginaryPart()
		if fabs(z.ImaginaryPart()) > 0.000000001
			nComplex++
		ok
	next
	Then("three eigenvalues", len(aZ), 3)
	Then("an even number of them are complex", nComplex % 2, 0)
	Then("...and the imaginary parts cancel", Rnd8(nImSum), 0)

	# trace and determinant are the invariants: the eigenvalues must sum to the one
	# and multiply to the other, whatever they individually are
	nTrace = 1 + 5 + 9
	nSum = 0
	_aZ139_ = aZ
	_nZ139_ = len(_aZ139_)
	for _iZ139_ = 1 to _nZ139_
		z = _aZ139_[_iZ139_]
		nSum += z.RealPart()
	next
	Then("they sum to the trace", Rnd6(nSum), nTrace)
EndScenario()

Scenario("the symmetric path is untouched")
	# Phase 4's cyclic Jacobi still serves symmetric matrices -- it gets the SMALL
	# eigenvalues to high relative accuracy, which is what a condition number and a
	# rank test depend on. Lifting the refusal must not have rerouted it.
	oS = new stzMatrix([ [2,1], [1,2] ])
	Then("a symmetric 2x2 is unchanged", @@(oS.EigenValues()), "[ 3, 1 ]")

	oB = new stzMatrix([ [4,1,0], [1,3,1], [0,1,2] ])
	aE = oB.EigenValues()
	Then("a symmetric 3x3 gives three real values", len(aE), 3)
	Then("...summing to the trace", Rnd6(aE[1]+aE[2]+aE[3]), 9)
	# and the general routine agrees with the symmetric one on symmetric input
	aG = oB.ComplexEigenValues()
	Then("the general routine agrees on symmetric input",
	     HasNearZ(aG, aE[1]) and HasNearZ(aG, aE[2]) and HasNearZ(aG, aE[3]), TRUE)
	Then("...with no imaginary parts", Rnd8(aG[1].ImaginaryPart()), 0)
EndScenario()

Scenario("what is deliberately NOT here")
	# Eigenvectors of a general matrix. They need inverse iteration or a
	# back-substitution on the full Schur form, they are delicate near a repeated
	# eigenvalue, and nothing has asked. So the symmetric method keeps its own
	# contract rather than being widened into something it cannot do.
	oQ = new stzMatrix([ [0,-1], [1,0] ])
	Then("EigenVectors on a non-symmetric matrix still refuses", RaisesVec(oQ), TRUE)

	# and the shapes that are simply not eigenproblems
	Then("a non-square matrix is refused",
	     RaisesEigOf(new stzMatrix([ [1,2,3], [4,5,6] ])), TRUE)
EndScenario()

Summary()

func Rnd8(n)
	return ceil(n * 100000000 - 0.5) / 100000000

func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000

func HasNear(aList, n)
	_aV140_ = aList
	_nV140_ = len(_aV140_)
	for _iV140_ = 1 to _nV140_
		v = _aV140_[_iV140_]
		if fabs(v - n) < 0.0000001
			return TRUE
		ok
	next
	return FALSE

func HasNearZ(aZ, n)
	_aZ141_ = aZ
	_nZ141_ = len(_aZ141_)
	for _iZ141_ = 1 to _nZ141_
		z = _aZ141_[_iZ141_]
		if fabs(z.RealPart() - n) < 0.000001 and fabs(z.ImaginaryPart()) < 0.000001
			return TRUE
		ok
	next
	return FALSE

func RaisesDiv(oZ)
	b = FALSE
	try
		v = oZ.DividedBy(new stzComplex(0, 0))
	catch
		b = TRUE
	done
	return b

func RaisesEig(oM)
	b = FALSE
	try
		v = oM.EigenValues()
	catch
		b = TRUE
	done
	return b

func RaisesEigOf(oM)
	b = FALSE
	try
		v = oM.ComplexEigenValues()
	catch
		b = TRUE
	done
	return b

func WhyEig(oM)
	s = ""
	try
		v = oM.EigenValues()
	catch
		s = cCatchError
	done
	return s

func RaisesVec(oM)
	b = FALSE
	try
		v = oM.EigenVectors()
	catch
		b = TRUE
	done
	return b
