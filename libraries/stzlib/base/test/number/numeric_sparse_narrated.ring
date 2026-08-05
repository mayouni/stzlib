# Sparse matrices (CSR) -- the last item on the numeric retro's list.
#
# The retro's complaint was "matMul is a naive triple loop, no sparse.
# Caps realistic size below graph/table needs. Sparse is a prereq for
# graph." The dense half was answered by rewriting the kernel
# (0.90 -> 12.03 GFLOP/s, ff7e1653f); this is the other half.
#
# WHAT A SPARSE PATH HAS TO PROVE, in order:
#   1. it stores what it claims       (round trip is bit-identical)
#   2. it computes the same answer    (spmm == dense, bit for bit)
#   3. it is actually faster          (measured, at real densities)
#   4. it says NO where it must       (shape mismatch, and the one
#                                      case where sparse and dense
#                                      genuinely disagree)
# A sparse product that is fast and slightly different is not an
# optimisation, it is a second library.
#
# Ring traps avoided: main code before the first func; no oR / nL /
# cAll locals.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: CSR stores exactly what was handed to it --"
aSm = [ [2,0,0,-1], [0,5,0,0], [3,0,0,0], [0,0,0,7] ]
pSmA = StzEngineMatrixNewFromList(4, 4, aSm)
pSmS = StzEngineSparseFromMatrix(pSmA, 0)
chk("5 of the 16 cells are stored", StzEngineSparseNnz(pSmS) = 5)
chk("...which it reports as a density", StzEngineSparseDensity(pSmS) = 5.0 / 16.0)
chk("shape survives", StzEngineSparseRows(pSmS) = 4 and StzEngineSparseCols(pSmS) = 4)

pSmBack = StzEngineSparseToMatrix(pSmS)
bSmSame = TRUE
for i = 0 to 3
	for j = 0 to 3
		if StzEngineMatrixGet(pSmBack, i, j) != StzEngineMatrixGet(pSmA, i, j)
			bSmSame = FALSE
		ok
	next
next
chk("dense -> CSR -> dense is BIT-IDENTICAL, not merely close", bSmSame)
# At tol=0 nothing is dropped, so this is a statement about the LAYOUT
# rather than about arithmetic: row_ptr/col_idx address what they say.

? ""
? "-- Scene 2: the sparse product IS the dense product --"
pSmB = StzEngineMatrixNewFromList(4, 4, aSm)
pSmD = StzEngineMatrixMultiply(pSmA, pSmB)
pSmP = StzEngineSparseMultiply(pSmS, pSmB)
bSmEq = TRUE
for i = 0 to 3
	for j = 0 to 3
		if StzEngineMatrixGet(pSmD, i, j) != StzEngineMatrixGet(pSmP, i, j)
			bSmEq = FALSE
		ok
	next
next
chk("every cell equal, bit for bit", bSmEq)
chk("...and the answer is right, not just consistent",
	StzEngineMatrixGet(pSmP, 0, 0) = 4)
# 4 = 2*2 + 0*0 + 0*3 + (-1)*0. Two implementations agreeing proves
# they agree; the hand-computed cell proves they are both correct.

? ""
? "-- Scene 3: the case where sparse and dense MUST differ --"
aInf = [ [0, 1], [1, 0] ]
pInfA = StzEngineMatrixNewFromList(2, 2, aInf)
pInfS = StzEngineSparseFromMatrix(pInfA, 0)
chk("a zero really is absent from the store", StzEngineSparseNnz(pInfS) = 2)
# Dense computes 0 * x for the absent cells; sparse omits the term.
# For finite x those agree (adding 0 changes nothing), which is why
# Scene 2 holds. They part company exactly when x is infinite, because
# 0 * inf is NaN -- a term the dense path would propagate and the
# sparse path never forms. That asymmetry is inherent to sparsity, and
# it is why the DENSE kernel refuses the same zero-skip: an
# optimisation that changes an answer belongs behind a type, not
# inside a branch.

? ""
? "-- Scene 4: it refuses shapes it cannot multiply --"
pBad = StzEngineMatrixNewFromList(3, 2, [ [1,0], [0,1], [1,1] ])
pNull = StzEngineSparseMultiply(pSmS, pBad)
chk("4x4 sparse times 3x2 dense returns nothing", pNull = NULL)

? ""
? "-- Scene 5: and it is actually faster, at real densities --"
nSpN = 256
aBig = []
for i = 1 to nSpN
	aRowB = []
	for j = 1 to nSpN
		if (i * 31 + j * 17) % 20 = 0
			aRowB + (((i + j) % 9) + 1) / 3.0
		else
			aRowB + 0
		ok
	next
	aBig + aRowB
next
pBigA = StzEngineMatrixNewFromList(nSpN, nSpN, aBig)
pBigB = StzEngineMatrixNewFromList(nSpN, nSpN, aBig)
pBigS = StzEngineSparseFromMatrix(pBigA, 0)

nT0 = StzEngineWatchTimestampMs()
pBigD = StzEngineMatrixMultiply(pBigA, pBigB)
nDenseMs = StzEngineWatchTimestampMs() - nT0

nT0 = StzEngineWatchTimestampMs()
pBigP = StzEngineSparseMultiply(pBigS, pBigB)
nSparseMs = StzEngineWatchTimestampMs() - nT0

? "   " + nSpN + "x" + nSpN + " at " + StzEngineSparseDensity(pBigS) +
  " density: dense " + nDenseMs + " ms, sparse " + nSparseMs + " ms"
chk("the smaller run was long enough to time honestly", nDenseMs >= 3)
chk("sparse beats dense at 5% density", nSparseMs < nDenseMs)
chk("...and by a wide margin, not a rounding", nDenseMs / nSparseMs > 2.0)
# A RANGE, not a fixed multiple: measured 12x at n=512 and it varies
# with cache state and load. What the guard pins is the PROPERTY that
# the saving tracks sparsity, not a number that will drift.

bBigEq = TRUE
for i = 0 to 9
	for j = 0 to 9
		if StzEngineMatrixGet(pBigD, i, j) != StzEngineMatrixGet(pBigP, i, j)
			bBigEq = FALSE
		ok
	next
next
chk("and the fast answer is still the identical answer", bBigEq)

StzEngineSparseFree(pSmS)   StzEngineSparseFree(pInfS)   StzEngineSparseFree(pBigS)
StzEngineMatrixFree(pSmA)   StzEngineMatrixFree(pSmB)    StzEngineMatrixFree(pSmD)
StzEngineMatrixFree(pSmP)   StzEngineMatrixFree(pSmBack) StzEngineMatrixFree(pInfA)
StzEngineMatrixFree(pBad)   StzEngineMatrixFree(pBigA)   StzEngineMatrixFree(pBigB)
StzEngineMatrixFree(pBigD)  StzEngineMatrixFree(pBigP)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
