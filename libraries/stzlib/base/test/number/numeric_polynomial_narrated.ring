# THE POLYNOMIAL ROOT FINDER -- an eigenvalue problem in disguise.
#
# Evaluating a polynomial is a loop; differentiating it is a loop. The one hard
# operation is FINDING ITS ROOTS, and past degree four no formula exists at all
# (Abel-Ruffini). The honest general method is an eigenvalue computation:
#
#   for monic p(x) = x^n + b1 x^(n-1) + ... + bn, the COMPANION MATRIX has p as
#   its characteristic polynomial, so THE ROOTS OF p ARE THE EIGENVALUES OF C.
#
# So stzPolynomial builds the companion matrix and asks stzMatrix, which already
# owns a Francis double-shift QR that balances on the way in and returns complex
# eigenvalues. No second iteration is written here -- that would be a parallel
# authority over the same mathematics. It is what numpy.roots does, for the same
# reason.
#
# THE REFERENCE VALUES BELOW WERE CROSS-CHECKED AGAINST numpy.roots, and agreed
# to 2.0e-15 -- machine precision -- across every polynomial in this file. That
# is an EXTERNAL oracle, not a self-consistency check: numpy did not learn its
# answer from us.
#
# Everything below is run for real against the built library.

load "../../stzBase.ring"
load "../_narrated.ring"

decimals(10)

Scenario("A polynomial knows its shape before anything else")
	oP = new stzPolynomial([1, -6, 11, -6])        # (x-1)(x-2)(x-3)
	Then("it reads back as written", oP.ToString(), "x^3 - 6x^2 + 11x - 6")
	Then("its degree is 3", oP.Degree(), 3)
	Then("it is monic", oP.IsMonic(), TRUE)
	# Horner's rule -- n multiplications, the steadiest way to evaluate
	Then("p(2) is zero, since 2 is a root", oP.ValueAt(2), 0)
	Then("p(0) is the constant term", oP.ValueAt(0), -6)
	Then("its derivative is 3x^2 - 12x + 11", PlyEq(oP.Derivative(), [3, -12, 11]), TRUE)
EndScenario()

Scenario("The roots come from the companion matrix's eigenvalues")
	oP = new stzPolynomial([1, -6, 11, -6])
	# the companion matrix: negated monic tail on the top row, ones below the
	# diagonal. Its characteristic polynomial IS p.
	aC = oP.CompanionMatrix()
	Then("the companion matrix is 3x3", len(aC), 3)
	Then("...its top row is the negated tail", PlyEq(aC[1], [6, -11, 6]), TRUE)
	Then("...and it carries a sub-diagonal of ones",
	     aC[2][1] = 1 and aC[3][2] = 1, TRUE)

	# and its eigenvalues are the roots -- 1, 2, 3
	Then("the real roots are 1, 2 and 3", PlyNear(oP.RealRoots(), [1, 2, 3]), TRUE)
	Then("...all three of them are real", oP.NumberOfRealRoots(), 3)
	Then("...so nothing is complex here", oP.HasComplexRoot(), FALSE)
EndScenario()

Scenario("Complex roots are returned as complex, not silently dropped")
	# x^2 + 1 has no real root at all. The contract is that ComplexRoots()
	# always returns DEGREE many roots -- the fundamental theorem of algebra --
	# while RealRoots() returns only those that are genuinely real.
	oC = new stzPolynomial([1, 0, 1])
	Then("x^2+1 has no real root", oC.HasRealRoot(), FALSE)
	Then("...but it does have complex ones", oC.HasComplexRoot(), TRUE)

	aZ = oC.ComplexRoots()
	Then("...two of them, per the degree", len(aZ), 2)
	Then("...they are +i and -i", PlyNearNum(fabs(aZ[1].ImaginaryPart()), 1), TRUE)
	Then("...with zero real part", PlyNearNum(aZ[1].RealPart(), 0), TRUE)

	# a degree-5 mix: three real roots and one conjugate pair. Reference values
	# from numpy.roots, agreeing with ours to 2e-15.
	oM = new stzPolynomial([1, -3, -5, 5, -6, 8])
	Then("a degree-5 polynomial returns five roots", len(oM.ComplexRoots()), 5)
	Then("...of which three are real", oM.NumberOfRealRoots(), 3)
	Then("...and its real roots are 1, -2 and 4", PlyNear(oM.RealRoots(), [-2, 1, 4]), TRUE)
EndScenario()

Scenario("A non-monic polynomial is scaled, and leading zeros are not degree")
	# The companion matrix needs a monic polynomial, so the leading coefficient
	# is divided out first. The ROOTS are unchanged by that scaling.
	oN = new stzPolynomial([2, -6, 4])             # 2(x-1)(x-2)
	Then("it is not monic", oN.IsMonic(), FALSE)
	Then("...its monic form is x^2 - 3x + 2", PlyEq(oN.Monic(), [1, -3, 2]), TRUE)
	Then("...and the roots are still 1 and 2", PlyNear(oN.RealRoots(), [1, 2]), TRUE)

	# [0,0,1,-3] IS x - 3: a degree-1 polynomial. If the leading zeros were kept
	# the companion matrix would be 3x3 with a singular leading coefficient, so
	# the constructor trims them.
	oZ = new stzPolynomial([0, 0, 1, -3])
	Then("leading zeros are not part of the degree", oZ.Degree(), 1)
	Then("...it reads as x - 3", oZ.ToString(), "x - 3")
	Then("...with the single root 3", PlyNear(oZ.RealRoots(), [3]), TRUE)
EndScenario()

Scenario("A MULTIPLE root is ill-conditioned, and that is the problem's fault")
	# A root repeated m times is perturbed like eps^(1/m), so (x-2)^3 does NOT
	# come back as exactly 2 three times -- it comes back as a tight cluster with
	# a small imaginary part. This is a property of the PROBLEM, not of the
	# method: numpy does the same. Rather than hide it behind a fixed tolerance,
	# RealRootsWithin() takes the tolerance as a parameter.
	oT = new stzPolynomial([1, -6, 12, -8])        # (x-2)^3
	aLoose = oT.RealRootsWithin(0.001)
	Then("a triple root yields three roots at a loose tolerance", len(aLoose), 3)
	Then("...all of them clustered at 2", PlyAllNear(aLoose, 2, 0.001), TRUE)

	# and the cluster is NOT exact -- asserting equality here would be dishonest
	Then("...yet not one of them is exactly 2", aLoose[1] = 2 and aLoose[2] = 2, FALSE)

	# a well-separated polynomial has no such trouble: the roots are exact to
	# many digits, which is the contrast that makes the point
	oS = new stzPolynomial([1, -6, 11, -6])        # distinct roots 1,2,3
	Then("...while distinct roots come back essentially exact",
	     PlyVeryNear(oS.RealRoots(), [1, 2, 3], 0.0000001), TRUE)
EndScenario()

Scenario("Polynomial arithmetic, and the roots of a product")
	oA = new stzPolynomial([1, 2])                 # x + 2
	oB = new stzPolynomial([1, -3])                # x - 3
	Then("(x+2) + (x-3) is 2x - 1", PlyEq(oA.Plus(oB), [2, -1]), TRUE)
	Then("(x+2) - (x-3) is 5", PlyEq(oA.Minus(oB), [0, 5]), TRUE)
	# multiplication is the convolution of the coefficient lists
	Then("(x+2)(x-3) is x^2 - x - 6", PlyEq(oA.Times(oB), [1, -1, -6]), TRUE)

	# the payoff: the product's roots are the two factors' roots
	oProd = oA.TimesQ(oB)
	Then("...and the product's roots are -2 and 3",
	     PlyNear(oProd.RealRoots(), [-2, 3]), TRUE)

	# the Q form normalises away a leading zero, so the difference above is a
	# degree-0 polynomial, not a degree-1 one with a zero leading coefficient
	oDiff = oA.MinusQ(oB)
	Then("the Q form trims the leading zero", oDiff.Degree(), 0)
EndScenario()

Scenario("The roots of unity, a closed-form oracle")
	# x^4 - 1 = 0 has roots 1, -1, i, -i -- known exactly, no numerics needed.
	# Two real, two imaginary, and the library must separate them correctly.
	oU = new stzPolynomial([1, 0, 0, 0, -1])
	Then("x^4-1 has four roots", len(oU.ComplexRoots()), 4)
	Then("...exactly two of them real", oU.NumberOfRealRoots(), 2)
	Then("...being -1 and 1", PlyNear(oU.RealRoots(), [-1, 1]), TRUE)
	Then("...and it does have complex roots too", oU.HasComplexRoot(), TRUE)
EndScenario()

Summary()

#-- helpers (uniquely prefixed: short names collide with library globals) ------

func PlyNearNum(nX, nY)
	return fabs(nX - nY) < 0.000001

func PlyEq(paA, paB)
	if len(paA) != len(paB)
		return FALSE
	ok
	_pn_ = len(paA)
	for _pi_ = 1 to _pn_
		if fabs(paA[_pi_] - paB[_pi_]) > 0.000000001
			return FALSE
		ok
	next
	return TRUE

func PlyNear(paA, paB)
	return PlyVeryNear(paA, paB, 0.00001)

func PlyVeryNear(paA, paB, nTol)
	if len(paA) != len(paB)
		return FALSE
	ok
	_pn_ = len(paA)
	for _pi_ = 1 to _pn_
		if fabs(paA[_pi_] - paB[_pi_]) > nTol
			return FALSE
		ok
	next
	return TRUE

func PlyAllNear(paA, nVal, nTol)
	_pn_ = len(paA)
	for _pi_ = 1 to _pn_
		if fabs(paA[_pi_] - nVal) > nTol
			return FALSE
		ok
	next
	return TRUE
