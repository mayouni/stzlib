load "../../stzBase.ring"
load "../_narrated.ring"

# THE SVD OF A GENERAL MATRIX (numeric phase 7).
#
# Phase 4 slice 9 built a singular value decomposition, and it was doing real work:
# rank, the condition number, least squares and the pseudo-inverse all rest on it.
# But TWO things were missing, and asking for "the SVD of a general matrix" is asking
# for both.
#
# FIRST: ONLY THE SINGULAR VALUES REACHED RING. U and V were computed by the engine
# and then discarded at the boundary -- SingularValues() returned a list of numbers
# and there was no way to get the factors at all. That is enough for everything phase
# 4 wanted, because rank and conditioning are questions about MAGNITUDES. It is not
# enough for anything that needs DIRECTIONS: a principal-component analysis, a
# low-rank approximation, an orthonormal basis for the range or the null space. The
# values say how much; the vectors say where.
#
# SECOND: A WIDE MATRIX WAS REFUSED. SingularValues() and Rank() both raised for
# m < n, advising "transpose it -- the singular values are the same". The advice is
# true and the refusal was never defensible: rank(A) = rank(A') and cond(A) = cond(A')
# always, so which orientation you happen to hold is a fact about your data layout,
# not about the matrix.
#
# AND THE ADVICE HID A TRAP that only appears once the factors are exposed:
#
#     THE SINGULAR VALUES OF A AND A' ARE THE SAME.
#     U AND V SWAP.
#
# A caller who followed "transpose it" to obtain a DECOMPOSITION got one that
# multiplies back to A', not to A. So the transpose now happens inside the engine,
# once, with the swap done correctly -- rather than being left to a caller who was
# told only half of what the transpose does.
#
# HOW THIS IS CHECKED: against the defining property, A = U S V', computed through the
# public surface on every shape below. That validates the values, both factors and the
# shape handling together, and it works on matrices nobody has tabulated. Tabulated
# reference factors would only test the cases someone had already written down -- and
# would not have caught the U/V swap, because both orderings reproduce the same
# singular VALUES.

Scenario("A = U S V' -- the property that defines the decomposition")
	Then("a tall matrix", Recon([ [1,2], [3,4], [5,6] ]) < 0.0000000001, TRUE)
	Then("a WIDE matrix -- refused before phase 7",
	     Recon([ [1,2,3], [4,5,6] ]) < 0.0000000001, TRUE)
	Then("a square symmetric one", Recon([ [4,1,0], [1,3,1], [0,1,2] ]) < 0.0000000001, TRUE)
	Then("a square non-symmetric one",
	     Recon([ [1,-2,3], [4,5,-6], [7,8,9] ]) < 0.0000000001, TRUE)
	Then("a rank-deficient one -- row 2 is twice row 1",
	     Recon([ [1,2,3], [2,4,6] ]) < 0.0000000001, TRUE)
	Then("a single row", Recon([ [3,4] ]) < 0.0000000001, TRUE)
	Then("a single column", Recon([ [3], [4] ]) < 0.0000000001, TRUE)
	Then("badly scaled entries",
	     Recon([ [1000000,1], [0.000001,1] ]) < 0.00000001, TRUE)
EndScenario()

Scenario("the factors are orthonormal, which is what makes them a BASIS")
	# U's columns are an orthonormal basis for the column space and V's for the row
	# space. If they were merely independent the decomposition would still multiply
	# back correctly, and would be useless for projection -- which is most of what
	# an SVD is for.
	oM = new stzMatrix([ [1,2,3], [4,5,6], [7,8,10] ])
	aD = oM.SVD()

	Then("U has orthonormal columns", MaxGram(aD[:u]) < 0.0000000001, TRUE)
	Then("V has orthonormal columns", MaxGram(aD[:v]) < 0.0000000001, TRUE)

	# and on a wide matrix, where U and V have different shapes
	oW = new stzMatrix([ [1,2,3], [4,5,6] ])
	aW = oW.SVD()
	Then("U is rows x k", len(aW[:u]) = 2 and len(aW[:u][1]) = 2, TRUE)
	Then("V is cols x k", len(aW[:v]) = 3 and len(aW[:v][1]) = 2, TRUE)
	Then("...and both are still orthonormal",
	     MaxGram(aW[:u]) < 0.0000000001 and MaxGram(aW[:v]) < 0.0000000001, TRUE)
EndScenario()

Scenario("the singular values themselves")
	# A singular value has no sign -- it is a magnitude. They come back descending,
	# so the first is the largest and first/last is the condition number.
	oM = new stzMatrix([ [1,2], [3,4], [5,6] ])
	aS = oM.SingularValues()
	Then("min(rows, cols) of them", len(aS), 2)
	Then("none is negative", aS[1] >= 0 and aS[2] >= 0, TRUE)
	Then("...and they descend", aS[1] >= aS[2], TRUE)
	Then("the largest over the smallest IS the condition number",
	     Rnd6(aS[1] / aS[2]), Rnd6(oM.ConditionNumber()))

	# a rank-deficient matrix has a negligible last singular value, and the rank
	# counts the ones that are not negligible
	oRankOne = new stzMatrix([ [1,2,3], [2,4,6], [3,6,9] ])
	Then("a rank-1 matrix has rank 1", oRankOne.Rank(), 1)
	aRankS = oRankOne.SingularValues()
	Then("...and its second singular value is negligible",
	     aRankS[2] < aRankS[1] * 0.000000001, TRUE)
EndScenario()

Scenario("a matrix and its transpose: same values, SWAPPED factors")
	# THIS IS THE TRAP the old "just transpose it" advice hid, and it is why the
	# transpose had to move inside the engine. The singular values agree exactly --
	# which is what made the advice sound right -- while U and V exchange roles.
	aM = [ [1,2,3], [4,5,6] ]
	aT = [ [1,4], [2,5], [3,6] ]
	oM = new stzMatrix(aM)
	oT = new stzMatrix(aT)

	aSm = oM.SingularValues()
	aSt = oT.SingularValues()
	Then("the singular values are identical", Rnd8(aSm[1]), Rnd8(aSt[1]))
	Then("...both of them", Rnd8(aSm[2]), Rnd8(aSt[2]))

	# U of A equals V of A', column for column, up to the sign of each column --
	# which is free, because (-u)(s)(-v)' = u s v'
	dM = oM.SVD()
	dT = oT.SVD()
	Then("U of A matches V of A' (up to a per-column sign)",
	     ColumnsMatchUpToSign(dM[:u], dT[:v]), TRUE)
	Then("...and V of A matches U of A'",
	     ColumnsMatchUpToSign(dM[:v], dT[:u]), TRUE)

	# and both decompositions reconstruct THEIR OWN matrix, which is the thing that
	# would have broken for a caller who transposed by hand and forgot the swap
	Then("each reconstructs its own matrix", Recon(aM) < 0.0000000001 and
	     Recon(aT) < 0.0000000001, TRUE)
EndScenario()

Scenario("wide matrices are answered everywhere, not just in SVD()")
	# Rank and the condition number ask questions whose answers cannot depend on
	# orientation. Both used to raise for m < n.
	oW = new stzMatrix([ [1,2,3], [4,5,6] ])
	oT = new stzMatrix([ [1,4], [2,5], [3,6] ])

	Then("a wide matrix has a rank", oW.Rank(), 2)
	Then("...the same as its transpose's", oW.Rank(), oT.Rank())
	Then("a wide matrix has a condition number",
	     Rnd6(oW.ConditionNumber()), Rnd6(oT.ConditionNumber()))
	Then("...and singular values", len(oW.SingularValues()), 2)

	# a wide RANK-DEFICIENT matrix
	oD = new stzMatrix([ [1,2,3], [2,4,6] ])
	Then("a wide rank-deficient matrix is seen as such", oD.Rank(), 1)
EndScenario()

Scenario("what it still refuses")
	Then("a matrix with no entries", RaisesSvd([ [] ]), TRUE)
EndScenario()

Summary()

func Rnd8(n)
	return ceil(n * 100000000 - 0.5) / 100000000

func Rnd6(n)
	return ceil(n * 1000000 - 0.5) / 1000000

# max |A - U S V'| over all entries, relative to |A|
func Recon(aM)
	oM = new stzMatrix(aM)
	nR = len(aM)
	nC = len(aM[1])
	aD = oM.SVD()
	aU = aD[:u]
	aS = aD[:singularValues]
	aV = aD[:v]
	nK = len(aS)

	nNorm = 0
	for i = 1 to nR
		for j = 1 to nC
			nNorm += fabs(aM[i][j])
		next
	next
	if nNorm = 0
		nNorm = 1
	ok

	nWorst = 0
	for i = 1 to nR
		for j = 1 to nC
			nAcc = 0
			for t = 1 to nK
				nAcc += aU[i][t] * aS[t] * aV[j][t]
			next
			nE = fabs(nAcc - aM[i][j])
			if nE > nWorst
				nWorst = nE
			ok
		next
	next
	return nWorst / nNorm

# max deviation of M'M from the identity -- zero exactly when the columns are
# orthonormal
func MaxGram(aM)
	nR = len(aM)
	nK = len(aM[1])
	nWorst = 0
	for p = 1 to nK
		for q = 1 to nK
			nD = 0
			for i = 1 to nR
				nD += aM[i][p] * aM[i][q]
			next
			nWant = 0
			if p = q
				nWant = 1
			ok
			if fabs(nD - nWant) > nWorst
				nWorst = fabs(nD - nWant)
			ok
		next
	next
	return nWorst

# an eigen/singular vector is defined up to sign, so columns match if they agree
# either way round
func ColumnsMatchUpToSign(aA, aB)
	nR = len(aA)
	nK = len(aA[1])
	if len(aB) != nR or len(aB[1]) != nK
		return FALSE
	ok
	for j = 1 to nK
		bPlus = TRUE
		bMinus = TRUE
		for i = 1 to nR
			if fabs(aA[i][j] - aB[i][j]) > 0.000001
				bPlus = FALSE
			ok
			if fabs(aA[i][j] + aB[i][j]) > 0.000001
				bMinus = FALSE
			ok
		next
		if NOT (bPlus or bMinus)
			return FALSE
		ok
	next
	return TRUE

func RaisesSvd(aM)
	b = FALSE
	try
		o = new stzMatrix(aM)
		v = o.SVD()
	catch
		b = TRUE
	done
	return b
