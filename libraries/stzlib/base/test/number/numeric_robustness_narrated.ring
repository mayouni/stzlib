# NUMERIC ROBUSTNESS -- the tier that earns "industry-strength".
#
# The rest of the numeric suite proves the LA core is CORRECT on well-behaved
# input. This one proves it stays honest where numerics are actually judged: on
# ill-conditioned matrices, against analytically KNOWN answers, and by making
# INDEPENDENT methods agree.
#
# The oracle HERE is deliberately self-contained -- no external library -- so this
# file runs and proves something anywhere Ring runs. The companion guard
# numeric_reference_oracle_narrated.ring does the other half: it checks the same
# core against LAPACK (via NumPy) and against exact rational arithmetic on an
# ill-conditioned corpus, with tolerances derived from kappa*eps. Read the two
# together; neither is sufficient alone.
#
# Two kinds of ground truth are used below, and they matter because a
# reconstruction test (build A, factor it, multiply back, compare) only proves
# SELF-consistency. Real robustness needs a truth the code did not itself produce:
#
#   (1) matrices with a CLOSED-FORM answer -- the tridiagonal Laplacian's
#       eigenvalues, the Hilbert matrix's notorious conditioning;
#   (2) two INDEPENDENT computations of one quantity -- a determinant from LU
#       against the product of the eigenvalues; an inverse from LU against the
#       pseudo-inverse from the SVD.
#
# Everything below is run for real against the built library.

load "../../stzBase.ring"
load "../_narrated.ring"

decimals(8)

Scenario("A closed-form oracle: the tridiagonal Laplacian")
	# The n-by-n matrix with 2 on the diagonal and -1 either side has eigenvalues
	# known in closed form: lambda_k = 2 - 2 cos(k*pi/(n+1)). Nothing here trusts
	# the eigensolver to check itself -- the answer comes from trigonometry.
	aT = RbtTridiag(4)
	oT = new stzMatrix(aT)
	aGot = sort(oT.EigenValues())          # ascending
	aWant = RbtClosedTridiag(4)               # ascending, from the formula
	Then("the eigenvalues match the closed form", RbtVecsNear(aGot, aWant), TRUE)
	Then("...and the determinant is their product, 5", RbtNearEq(oT.Determinant(), 5), TRUE)
	Then("...and the condition number is lmax/lmin ~ 9.472",
	     RbtNearEq(oT.ConditionNumber(), 9.47213595), TRUE)
EndScenario()

Scenario("The Hilbert matrix is ill-conditioned, and the library says so")
	# H[i][j] = 1/(i+j-1) is the textbook ill-conditioned SPD matrix. Its condition
	# number grows explosively with n -- the single most important thing a
	# condition estimator must get right, since it is the warning that a solve is
	# about to lose most of its digits.
	oH4 = new stzMatrix(RbtHilbert(4))
	oH5 = new stzMatrix(RbtHilbert(5))
	oH6 = new stzMatrix(RbtHilbert(6))
	nC4 = oH4.ConditionNumber()
	nC5 = oH5.ConditionNumber()
	nC6 = oH6.ConditionNumber()
	Then("Hilbert-4 is already badly conditioned (> 1e3)", nC4 > 1000, TRUE)
	Then("...and conditioning worsens strictly with size", nC4 < nC5 and nC5 < nC6, TRUE)
	# the determinant is tiny but POSITIVE -- the matrix is near-singular, not
	# singular, and the library must not round it to zero
	nDet = oH4.Determinant()
	Then("...its determinant is tiny but still positive", nDet > 0 and nDet < 0.00001, TRUE)
EndScenario()

Scenario("Independent methods agree on the same truth")
	# An identity is not a self-check (a reconstruction can be self-consistent and
	# still wrong). These compare answers reached by DIFFERENT routes.
	aA = [ [4,1,2], [1,5,3], [2,3,6] ]     # SPD, well-conditioned
	oA = new stzMatrix(aA)

	# det from the LU factorisation vs the product of the eigenvalues
	Then("determinant equals the product of the eigenvalues",
	     RbtNearEq(oA.Determinant(), RbtProd(oA.EigenValues())), TRUE)

	# |det| vs the product of the singular values (a different decomposition)
	Then("...and equals the product of the singular values",
	     RbtNearEq(fabs(oA.Determinant()), RbtProd(oA.SingularValues())), TRUE)

	# the inverse by Gaussian elimination vs by the SVD pseudo-inverse
	Then("the LU inverse and the SVD pseudo-inverse coincide",
	     RbtMaxDiff(oA.LUInverse(), oA.PseudoInverse()) < 0.000001, TRUE)
EndScenario()

Scenario("Ill-conditioning is flagged, and singularity is not swallowed")
	# A near-singular matrix must report a huge condition number rather than a
	# plausible small one -- otherwise a caller trusts a solve it should not.
	oN = new stzMatrix([ [1, 1], [1, 1.0000001] ])
	Then("a near-singular matrix reports a huge condition number",
	     oN.ConditionNumber() > 1000000, TRUE)

	# an exactly singular matrix: determinant zero, and rank BELOW its size --
	# the library sees the dependency rather than pretending to full rank
	oS = new stzMatrix([ [1,2,3], [4,5,6], [7,8,9] ])
	Then("a singular matrix has determinant zero", RbtNearEq(oS.Determinant(), 0), TRUE)
	Then("...and is correctly rank-deficient (2, not 3)", oS.Rank(), 2)

	# a well-conditioned solve leaves a negligible backward residual ||Ax - b||
	aW = [ [4,1,2], [1,5,3], [2,3,6] ]
	oW = new stzMatrix(aW)
	aB = [7, 8, 9]
	aX = oW.SolveFor(aB)
	Then("a well-conditioned solve has a negligible residual",
	     RbtResidual(aW, aX, aB) < 0.0000001, TRUE)
EndScenario()

Summary()

#-- oracles and helpers (file scope) -----------------------------------------

func RbtNearEq(nX, nY)
	return fabs(nX - nY) < 0.0001

# H[i][j] = 1/(i+j-1) -- the classic ill-conditioned SPD matrix
func RbtHilbert(pn)
	_hR_ = []
	for _hi_ = 1 to pn
		_hRow_ = []
		for _hj_ = 1 to pn
			_hRow_ + (1.0 / (_hi_ + _hj_ - 1))
		next
		_hR_ + _hRow_
	next
	return _hR_

# 2 on the diagonal, -1 on the first off-diagonals (the 1-D Laplacian)
func RbtTridiag(pn)
	_tR_ = []
	for _ti_ = 1 to pn
		_tRow_ = []
		for _tj_ = 1 to pn
			if _ti_ = _tj_
				_tRow_ + 2
			but fabs(_ti_ - _tj_) = 1
				_tRow_ + (-1)
			else
				_tRow_ + 0
			ok
		next
		_tR_ + _tRow_
	next
	return _tR_

# its eigenvalues in closed form, ascending: 2 - 2 cos(k*pi/(n+1))
func RbtClosedTridiag(pn)
	_cR_ = []
	for _ck_ = 1 to pn
		_cR_ + (2 - 2 * cos(_ck_ * 3.14159265358979 / (pn + 1)))
	next
	return _cR_

func RbtVecsNear(paA, paB)
	if len(paA) != len(paB)
		return FALSE
	ok
	_vn_ = len(paA)
	for _vi_ = 1 to _vn_
		if fabs(paA[_vi_] - paB[_vi_]) > 0.001
			return FALSE
		ok
	next
	return TRUE

func RbtProd(paL)
	_pp_ = 1
	_pn_ = len(paL)
	for _pi_ = 1 to _pn_
		_pp_ *= paL[_pi_]
	next
	return _pp_

func RbtMaxDiff(paA, paB)
	_md_ = 0
	_mn_ = len(paA)
	for _mi_ = 1 to _mn_
		_mm_ = len(paA[_mi_])
		for _mj_ = 1 to _mm_
			_dd_ = fabs(paA[_mi_][_mj_] - paB[_mi_][_mj_])
			if _dd_ > _md_
				_md_ = _dd_
			ok
		next
	next
	return _md_

func RbtResidual(paMat, paX, paB)
	_rs_ = 0
	_rn_ = len(paMat)
	for _ri_ = 1 to _rn_
		_rr_ = 0
		_rk_ = len(paX)
		for _rj_ = 1 to _rk_
			_rr_ += paMat[_ri_][_rj_] * paX[_rj_]
		next
		_rs_ += (_rr_ - paB[_ri_]) * (_rr_ - paB[_ri_])
	next
	return sqrt(_rs_)
