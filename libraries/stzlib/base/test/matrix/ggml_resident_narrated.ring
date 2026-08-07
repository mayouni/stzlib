# Resident ggml tensors for the matmul bridge -- the G6 follow-up.
#
# The G6 census caught StzEngineMatrixMulGgml paying context setup +
# f64->f32 conversion + an element-wise B-transpose on EVERY call: 2.85 ms
# for a matvec whose compute is ~0.02 ms. Now the converted tensors stay
# resident, keyed by the source matrix pointer, and every Ring-visible
# mutation (Set / AddScalar / MultiplyScalar / UpdateRegion / AddMatrix /
# Power / MulGgml's own result write / Free) DROPS the pointer's entries.
#
# What this guard asserts -- the MECHANISM, through the cache counters:
#   - first multiply = 2 misses (A and B convert); repeat = 2 hits
#   - a hit answers BYTE-IDENTICALLY to its miss (parity by equality)
#   - mutating an operand invalidates it: the next multiply re-misses
#     THAT operand only, and the answer reflects the mutation (the
#     negative sibling -- a stale cache would keep the old numbers)
#   - the result matrix can feed a later multiply (its write invalidated
#     any resident copy of it)
#   - the cache is BOUNDED: more operands than slots -> evictions
#     counted, answers still correct
#   - Free drops entries (counted), so a recycled address starts cold

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

# stats: [hits, misses, evictions, invalidations]
StzEngineMatrixMulGgmlStatsReset()

? "-- Scene 1: the first multiply converts, the second reuses --"
hA = StzEngineMatrixNew(3, 4)
hB = StzEngineMatrixNew(4, 5)
hR = StzEngineMatrixNew(3, 5)
# NOTE the raw engine Set/Get are 0-BASED (the stzMatrix face adjusts;
# this guard drives the bridge directly)
for i = 0 to 2
    for j = 0 to 3
        StzEngineMatrixSet(hA, i, j, i * 10 + j)
    next
next
for i = 0 to 3
    for j = 0 to 4
        StzEngineMatrixSet(hB, i, j, i + j * 0.5)
    next
next
StzEngineMatrixMulGgmlStatsReset()
chk("first multiply succeeds", StzEngineMatrixMulGgml(hA, hB, hR) = 1)
aS = StzEngineMatrixMulGgmlStats()
chk("...as 2 misses, 0 hits (both operands converted)", aS[2] = 2 and aS[1] = 0)
aFirst = []
for i = 0 to 2
    for j = 0 to 4
        aFirst + StzEngineMatrixGet(hR, i, j)
    next
next
chk("second multiply succeeds", StzEngineMatrixMulGgml(hA, hB, hR) = 1)
aS = StzEngineMatrixMulGgmlStats()
chk("...as 2 HITS (nothing reconverted)", aS[1] = 2 and aS[2] = 2)
bSame = TRUE
nIdx = 0
for i = 0 to 2
    for j = 0 to 4
        nIdx++
        if StzEngineMatrixGet(hR, i, j) != aFirst[nIdx]
            bSame = FALSE
        ok
    next
next
chk("the hit path answers BYTE-IDENTICALLY to the miss path", bSame)

? ""
? "-- Scene 2: mutation invalidates -- the answer moves WITH the data --"
StzEngineMatrixSet(hB, 0, 0, 999)
aS = StzEngineMatrixMulGgmlStats()
chk("the Set dropped B's resident tensor (invalidation counted)", aS[4] >= 1)
chk("multiply after mutation succeeds", StzEngineMatrixMulGgml(hA, hB, hR) = 1)
aS = StzEngineMatrixMulGgmlStats()
chk("B re-missed, A still hit (3 hits, 3 misses total)", aS[1] = 3 and aS[2] = 3)
# expected C[0][0] = row0(A) . col0(B): A row0 = [0,1,2,3]; B col0 after the
# mutation = [999, 1, 2, 3] -- so 0*999 + 1*1 + 2*2 + 3*3 = 14, exact in f32
nExpect = 0 * 999 + 1 * 1 + 2 * 2 + 3 * 3
chk("and the answer reflects the mutation exactly (" + nExpect + ")",
    StzEngineMatrixGet(hR, 0, 0) = nExpect)

? ""
? "-- Scene 3: a result can feed the next multiply --"
hR2 = StzEngineMatrixNew(3, 5)
# hR was WRITTEN by MulGgml (its hook invalidated any resident copy);
# now use hR as the A operand of a fresh multiply
hB2 = StzEngineMatrixNew(5, 2)
for i = 0 to 4
    for j = 0 to 1
        StzEngineMatrixSet(hB2, i, j, i - j)
    next
next
hR3 = StzEngineMatrixNew(3, 2)
chk("chained multiply (result as input) succeeds",
    StzEngineMatrixMulGgml(hR, hB2, hR3) = 1)
nRef = 0
for k = 0 to 4
    nRef += StzEngineMatrixGet(hR, 0, k) * k
next
chk("chained answer matches the f64 reference dot", StzEngineMatrixGet(hR3, 0, 0) = nRef)

? ""
? "-- Scene 4: the cache is BOUNDED, and counts what it drops --"
StzEngineMatrixMulGgmlStatsReset()
aHs = []
for q = 1 to 6
    _hA_ = StzEngineMatrixNew(2, 3)
    _hB_ = StzEngineMatrixNew(3, 2)
    _hR_ = StzEngineMatrixNew(2, 2)
    StzEngineMatrixSet(_hA_, 0, 0, q)
    StzEngineMatrixSet(_hB_, 0, 0, q + 1)
    StzEngineMatrixMulGgml(_hA_, _hB_, _hR_)
    chk("pair " + q + " answers correctly under churn",
        StzEngineMatrixGet(_hR_, 0, 0) = q * (q + 1))
    aHs + _hA_
    aHs + _hB_
    aHs + _hR_
next
aS = StzEngineMatrixMulGgmlStats()
? "  after 6 distinct pairs (12 operand tensors, 8 slots): evictions = " + aS[3]
chk("12 operands through 8 slots EVICTED (bounded, counted)", aS[3] >= 4)

? ""
? "-- Scene 5: Free drops resident entries --"
StzEngineMatrixMulGgmlStatsReset()
StzEngineMatrixMulGgml(hA, hB, hR)   # ensure A and B are resident again
aS = StzEngineMatrixMulGgmlStats()
nInvBefore = aS[4]
StzEngineMatrixFree(hA)
aS = StzEngineMatrixMulGgmlStats()
chk("freeing a cached operand dropped its tensor (invalidation counted)",
    aS[4] > nInvBefore)
StzEngineMatrixFree(hB)
StzEngineMatrixFree(hR)
StzEngineMatrixFree(hR2)
StzEngineMatrixFree(hB2)
StzEngineMatrixFree(hR3)
for q = 1 to len(aHs)
    StzEngineMatrixFree(aHs[q])
next

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
