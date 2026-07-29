# THE REFERENCE-ORACLE TIER -- checked against LAPACK, on an ill-conditioned corpus.
#
# This is the half of the robustness work that numeric_robustness_narrated.ring
# deliberately did NOT do. That file says, at its top, "the oracle is
# self-contained -- no external library to compare against", and it proves
# correctness from closed-form answers and cross-method agreement. Good, but it
# cannot tell you whether this library is as accurate as the industry's.
#
# So: every reference value below was produced by NumPy (i.e. LAPACK) and by
# EXACT RATIONAL ARITHMETIC, by _gen_numpy_reference.py, and checked in as
# _numpy_reference.ring. The generator stays committed so any number here can be
# audited or regenerated. The guard itself needs no Python -- it runs wherever
# Ring runs.
#
# -- THE CORPUS IS DELIBERATELY ILL-CONDITIONED --
#
#     hilbert4/5/6   kappa 1.6e4 / 4.8e5 / 1.5e7   the textbook hard case
#     vander4        kappa 1.2e3                   non-symmetric, ill-conditioned
#     nearsing2      kappa 4.0e7                   almost singular
#     tridiag5       kappa 1.4e1                   closed-form spectrum
#     spd3           kappa 4.3                     an easy control
#     rot3                                         a genuinely COMPLEX spectrum
#
# A numeric library is judged on Hilbert and Vandermonde matrices, not on tidy
# 3x3 examples.
#
# -- AND THE TOLERANCES ARE DERIVED, NOT INVENTED --
#
# The retro's criticism of this codebase was that tolerances are "fixed literals
# with no analysis of why". So the solve tolerance here is not a literal: it is
#
#     kappa(A) * eps
#
# the classical bound on the relative error of a linear solve. An ill-conditioned
# problem is ALLOWED to lose digits -- that is the mathematics, not a defect --
# and the guard asserts the loss stays within what the conditioning permits.
#
# Everything below is run for real against the built library.

load "../../stzBase.ring"
load "_numpy_reference.ring"
load "../_narrated.ring"

decimals(14)

Scenario("Eigenvalues agree with LAPACK, even where the matrix is nasty")
	# Hilbert's eigenvalues span four orders of magnitude at n=4 and seven at
	# n=6, so this is a real test of the symmetric solver and not a formality.
	Then("hilbert4 eigenvalues match LAPACK to 1e-12",
	     OraRelEig(RefMat_hilbert4(), RefEig_hilbert4()) < 0.000000000001, TRUE)
	Then("hilbert5 too, at kappa 4.8e5",
	     OraRelEig(RefMat_hilbert5(), RefEig_hilbert5()) < 0.0000000001, TRUE)
	Then("hilbert6 too, at kappa 1.5e7",
	     OraRelEig(RefMat_hilbert6(), RefEig_hilbert6()) < 0.000000001, TRUE)
	# the well-conditioned cases agree to the last bit LAPACK printed
	Then("tridiag5 agrees essentially exactly",
	     OraRelEig(RefMat_tridiag5(), RefEig_tridiag5()) < 0.0000000000001, TRUE)
	Then("...and so does the easy control",
	     OraRelEig(RefMat_spd3(), RefEig_spd3()) < 0.0000000000001, TRUE)
EndScenario()

Scenario("Singular values and condition numbers agree with LAPACK")
	Then("hilbert6 singular values match to 1e-9",
	     OraRelSv(RefMat_hilbert6(), RefSv_hilbert6()) < 0.000000001, TRUE)
	Then("vander4 singular values match to 1e-12",
	     OraRelSv(RefMat_vander4(), RefSv_vander4()) < 0.000000000001, TRUE)

	# the condition number is the single most important number a numeric library
	# reports, because it is the warning that a solve is about to lose digits
	Then("hilbert4's condition number matches LAPACK",
	     OraRelCond(RefMat_hilbert4(), RefCond_hilbert4()) < 0.0000000001, TRUE)
	Then("hilbert6's does too, at 1.5e7",
	     OraRelCond(RefMat_hilbert6(), RefCond_hilbert6()) < 0.000000001, TRUE)
	Then("...and the near-singular matrix's, at 4.0e7",
	     OraRelCond(RefMat_nearsing2(), RefCond_nearsing2()) < 0.0000001, TRUE)
EndScenario()

Scenario("A LINEAR SOLVE stays inside the accuracy its conditioning permits")
	# The yardstick is the EXACT answer, computed in rational arithmetic, to the
	# matrix the library was actually handed. The tolerance is kappa * eps -- what
	# the problem permits -- and not a number chosen to make the test pass.
	Then("hilbert4's solve is within kappa*eps",
	     OraSolveRel(RefMat_hilbert4(), RefExactSolveOnes_hilbert4())
	         < RefKappaEpsBound_hilbert4(), TRUE)
	Then("hilbert5's solve is within kappa*eps",
	     OraSolveRel(RefMat_hilbert5(), RefExactSolveOnes_hilbert5())
	         < RefKappaEpsBound_hilbert5(), TRUE)
	Then("hilbert6's solve is within kappa*eps, at kappa 1.5e7",
	     OraSolveRel(RefMat_hilbert6(), RefExactSolveOnes_hilbert6())
	         < RefKappaEpsBound_hilbert6(), TRUE)

	# AND IT IS AT LEAST AS ACCURATE AS LAPACK ON THE SAME PROBLEM. Measured, not
	# claimed: ours 6e-14 / 2.1e-12 / 4.5e-11 against LAPACK's 3.4e-13 / 1.3e-11
	# / 7.1e-11 for n = 4, 5, 6. Same algorithm class, and we are not behind.
	Then("...and no worse than LAPACK at n=4",
	     OraSolveRel(RefMat_hilbert4(), RefExactSolveOnes_hilbert4())
	         <= RefLapackRelErr_hilbert4(), TRUE)
	Then("...nor at n=5",
	     OraSolveRel(RefMat_hilbert5(), RefExactSolveOnes_hilbert5())
	         <= RefLapackRelErr_hilbert5(), TRUE)
	Then("...nor at n=6",
	     OraSolveRel(RefMat_hilbert6(), RefExactSolveOnes_hilbert6())
	         <= RefLapackRelErr_hilbert6(), TRUE)
EndScenario()

Scenario("...and WRITING the matrix down costs more than solving it does")
	# There are two different truths for a Hilbert solve, and conflating them
	# would misjudge every solver ever written.
	#
	#   the TRUE matrix (entries 1/(i+j-1) exactly) solves to INTEGERS
	#   the F64 matrix (what any library is actually handed) solves to something
	#     ~1e-10 away from those integers, no matter how perfect the solver
	#
	# The gap is the input's representation error, and at n=6 IT IS LARGER THAN
	# LAPACK'S ENTIRE ALGORITHMIC ERROR (1.42e-10 against 7.09e-11). So most of
	# the "inaccuracy" of an ill-conditioned solve is already baked in before any
	# arithmetic happens.
	Then("the true Hilbert-6 solve is exactly the integers -6, 210, -1680, ...",
	     OraIsIntegerVector(RefTrueSolveOnes_hilbert6()), TRUE)
	Then("...yet the f64 matrix's own exact answer is NOT those integers",
	     OraIsIntegerVector(RefExactSolveOnes_hilbert6()), FALSE)
	Then("...and that representation error exceeds LAPACK's algorithmic error",
	     RefReprErr_hilbert6() > RefLapackRelErr_hilbert6(), TRUE)
	# which is why the solve above is judged against the f64 matrix's exact
	# answer, and not against the integers
	Then("...but both stay inside the conditioning bound",
	     RefReprErr_hilbert6() < RefKappaEpsBound_hilbert6(), TRUE)
EndScenario()

Scenario("Determinants, rank and a complex spectrum agree with LAPACK")
	# a tiny determinant must come back tiny and POSITIVE, not rounded to zero
	Then("hilbert6's determinant matches LAPACK",
	     OraRelNum(OraDet(RefMat_hilbert6()), RefDet_hilbert6()) < 0.000001, TRUE)
	Then("vander4's determinant is exactly 12",
	     OraDet(RefMat_vander4()), RefDet_vander4())

	# rank: full for the ill-conditioned-but-invertible, and LAPACK agrees
	Then("hilbert6 is full rank despite kappa 1.5e7",
	     OraRank(RefMat_hilbert6()), RefRank_hilbert6())
	Then("...and the near-singular matrix is still full rank numerically",
	     OraRank(RefMat_nearsing2()), RefRank_nearsing2())

	# rot3 has eigenvalues 2 and the conjugate pair +/- i. The complex path has
	# to agree with LAPACK on both parts.
	Then("rot3's real parts match LAPACK",
	     OraRelEigComplexRe(RefMat_rot3(), RefEigRe_rot3()) < 0.0000000001, TRUE)
	Then("...and the imaginary parts are +/- 1",
	     OraImagMagnitudesMatch(RefMat_rot3(), RefEigIm_rot3()), TRUE)
EndScenario()

Scenario("...and one inconsistency this pass uncovered")
	# stzMatrix.Inverse() MUTATES the receiver and returns nothing, while its four
	# siblings -- LUInverse, QRInverse, CholeskyInverse, PseudoInverse -- return
	# the inverse as data and leave the receiver alone. A caller who writes
	# `aInv = oM.Inverse()` gets an empty value AND loses the original matrix.
	#
	# That is a public-API decision, not an accuracy question, so it is not
	# changed here. The CURRENT behaviour is pinned instead, so it cannot drift
	# unnoticed, and the fix is tracked separately.
	aA = [ [4,1,2], [1,5,3], [2,3,6] ]
	oM = new stzMatrix(aA)
	xR = oM.Inverse()
	Then("Inverse() returns no data at all", isList(xR), FALSE)
	Then("...having overwritten the matrix in place",
	     OraNear(oM.Content()[1][1], 0.3), TRUE)

	# while the siblings behave as a reader expects, and agree with LAPACK
	oN = new stzMatrix(RefMat_spd3())
	Then("PseudoInverse() returns data and matches LAPACK",
	     OraRelMat(oN.PseudoInverse(), RefInv_spd3()) < 0.0000000001, TRUE)
	Then("...and leaves the matrix untouched", OraNear(oN.Content()[1][1], 4), TRUE)
	Then("LUInverse() matches LAPACK on hilbert4 within its conditioning",
	     OraRelMat((new stzMatrix(RefMat_hilbert4())).LUInverse(), RefInv_hilbert4())
	         < 0.0000001, TRUE)
EndScenario()

Summary()

#-- helpers (uniquely prefixed: short names collide with library globals) ------

func OraNear(nX, nY)
	return fabs(nX - nY) < 0.0001

func OraRelNum(nGot, nRef)
	if nRef = 0
		return fabs(nGot)
	ok
	return fabs(nGot - nRef) / fabs(nRef)

func OraRelList(paGot, paRef)
	if len(paGot) != len(paRef)
		return 1
	ok
	_om_ = 0
	_on_ = len(paRef)
	for _oi_ = 1 to _on_
		_od_ = OraRelNum(paGot[_oi_], paRef[_oi_])
		if _od_ > _om_
			_om_ = _od_
		ok
	next
	return _om_

func OraRelEig(paMat, paRef)
	return OraRelList(sort((new stzMatrix(paMat)).EigenValues()), paRef)

func OraRelSv(paMat, paRef)
	return OraRelList((new stzMatrix(paMat)).SingularValues(), paRef)

func OraRelCond(paMat, nRef)
	return OraRelNum((new stzMatrix(paMat)).ConditionNumber(), nRef)

func OraDet(paMat)
	return (new stzMatrix(paMat)).Determinant()

func OraRank(paMat)
	return (new stzMatrix(paMat)).Rank()

# relative error of the solve of A x = [1,1,...] against a reference vector
func OraSolveRel(paMat, paRef)
	_ob_ = []
	_on2_ = len(paRef)
	for _oi2_ = 1 to _on2_
		_ob_ + 1
	next
	return OraRelList((new stzMatrix(paMat)).SolveFor(_ob_), paRef)

func OraRelMat(paGot, paRef)
	_omm_ = 0
	_onr_ = len(paRef)
	for _oir_ = 1 to _onr_
		_onc_ = len(paRef[_oir_])
		for _oic_ = 1 to _onc_
			_odd_ = OraRelNum(paGot[_oir_][_oic_], paRef[_oir_][_oic_])
			if _odd_ > _omm_
				_omm_ = _odd_
			ok
		next
	next
	return _omm_

func OraIsIntegerVector(paV)
	_onv_ = len(paV)
	for _oiv_ = 1 to _onv_
		if fabs(paV[_oiv_] - floor(paV[_oiv_] + 0.5)) > 0.0000000000001
			return FALSE
		ok
	next
	return TRUE

func OraRelEigComplexRe(paMat, paRef)
	_aZ_ = (new stzMatrix(paMat)).ComplexEigenValues()
	_aRe_ = []
	_onz_ = len(_aZ_)
	for _oiz_ = 1 to _onz_
		_aRe_ + _aZ_[_oiz_].RealPart()
	next
	return OraRelList(sort(_aRe_), sort(paRef))

# the conjugate pair's ORDER is a solver's own business, so compare the sorted
# magnitudes rather than demanding LAPACK's sign order
func OraImagMagnitudesMatch(paMat, paRef)
	_aZ2_ = (new stzMatrix(paMat)).ComplexEigenValues()
	_aG_ = []
	_onz2_ = len(_aZ2_)
	for _oiz2_ = 1 to _onz2_
		_aG_ + fabs(_aZ2_[_oiz2_].ImaginaryPart())
	next
	_aR_ = []
	_onr2_ = len(paRef)
	for _oir2_ = 1 to _onr2_
		_aR_ + fabs(paRef[_oir2_])
	next
	return OraRelList(sort(_aG_), sort(_aR_)) < 0.0000000001
