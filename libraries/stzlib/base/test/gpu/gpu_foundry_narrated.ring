# GK2 -- THE FOUNDRY: op variants by enumeration, under GK0's checker
# (SOFTANZA_GPU_PLAN.md, GK2).
#
# The op library carries VARIANTS of pairdist beside its generic 16x16 tile:
# a straight row kernel, a vec4 one, one with the query staged in workgroup
# memory. The foundry enumerates them: each verified against the generic on
# the same device buffers at the visible shape AND a hidden one (different
# size, different data), timed on the GPU clock with the device awake; the
# winner -- if it beats the generic by 1.3x -- is recorded for the SHAPE
# CLASS in the variant table the op consults at dispatch. Proteus's loop
# with a for-loop as the proposer.
#
# What this guard asserts, mechanism first, negative siblings beside:
#   - the variant TABLE classes shapes (powers of two), degrades to an
#     eligible variant when the actual shape does not fit the class's pick,
#     refuses the test-only variant, and clears -- device-free
#   - the foundry runs: every real variant VERIFIED (the checker passed each
#     on both shapes), timed on two clocks, a winner named or the generic kept
#   - THE CHECKER GATES THE TABLE: a deliberately wrong variant, reachable
#     only through the foundry's mask, is REFUSED and cannot win
#   - the table CHANGES THE DISPATCH: with a class pointing at a variant, the
#     op's variant counter moves and the distances equal the generic's within
#     the band; cleared, the counter stays still
#   - persistence round-trips a variant row; the machine's files are kept
#   - the KILL LINE on a small grid is reported, not assumed

load "../../stzBase.ring"

nPass = 0
nFail = 0

C_VAR = 14

pr()

decimals(4)

? "-- Scene 1: the variant table, device-free --"
StzEngineGpuVariantClear()
chk("an empty table answers the generic (0)", StzEngineGpuVariantGet("pairdist", 1, 4096, 384) = 0)
chk("names: 0 is tile16, 1 row, 2 row4, 3 row4s",
	StzEngineGpuVariantName(0) = "tile16" and StzEngineGpuVariantName(1) = "row" and
	StzEngineGpuVariantName(2) = "row4" and StzEngineGpuVariantName(3) = "row4s")
chk("a class takes a variant", StzEngineGpuVariantSet("pairdist", 1, 4096, 384, 3) = 0 and StzEngineGpuVariantGet("pairdist", 1, 4096, 384) = 3)
chk("...and the same CLASS answers it for another shape (3000 x 300 shares the classes)", StzEngineGpuVariantGet("pairdist", 1, 3000, 300) = 3)
chk("...while a different class keeps the generic", StzEngineGpuVariantGet("pairdist", 1, 64, 384) = 0)
chk("the test-only variant is REFUSED by the table", StzEngineGpuVariantSet("pairdist", 1, 4096, 384, 4) != 0)
StzEngineGpuVariantClear()
chk("cleared: the generic again", StzEngineGpuVariantGet("pairdist", 1, 4096, 384) = 0)

oG = new stzGpu
if NOT oG.IsAvailable()
	? ""
	? "  NO GPU ON THIS MACHINE -- the foundry needs a device; scene 1 is the CI coverage"
	chk("the foundry refuses without a device (fallback, counted)", StzEngineGpuFoundryPairdist(1, 4096, 384, 3, 0) != 0)
else
	? ""
	? "  device: " + oG.DeviceName()
	? ""
	? "-- Scene 2: the foundry runs at the single-query shape 1 x 4096 x 384 --"
	StzEngineGpuVariantClear()
	aR = oG.FoundryPairdistWith(1, 4096, 384, 5)
	? "  generic: " + aR[:refgpums] + " ms GPU clock, " + aR[:refwallms] + " ms wall   clocks " + aR[:clocks] + "   hidden n " + aR[:hiddenn]
	nV = len(aR[:variants])
	bAllVerified = TRUE
	for i = 1 to nV
		v = aR[:variants][i]
		? "  " + v[1] + ": verified " + v[2] + "   " + v[3] + " ms GPU, " + v[4] + " ms wall   ratio (GPU clock) " + v[5] + "   (wall " + v[6] + ")"
		if v[2] != 1 bAllVerified = FALSE ok
	next
	? "  winner: " + aR[:winner] + " at " + aR[:ratio] + "x   stored " + aR[:stored]
	chk("three real variants enumerated", nV = 3)
	chk("EVERY real variant was VERIFIED by the checker (right on the visible AND the hidden shape)", bAllVerified)
	chk("the hidden size is odd, tile-uneven and smaller", aR[:hiddenn] % 2 = 1 and aR[:hiddenn] < 4096)
	chk("the generic was timed (> 0 on the wall)", aR[:refwallms] > 0)
	if aR[:ratio] >= 1.3
		chk("a winner above the margin was STORED for the class", aR[:stored] and StzEngineGpuVariantGet("pairdist", 1, 4096, 384) > 0)
		chk("...and it is a real variant (never the test one)", StzEngineGpuVariantGet("pairdist", 1, 4096, 384) < 4)
	else
		chk("no variant reached the margin: the table keeps the generic", NOT aR[:stored] and StzEngineGpuVariantGet("pairdist", 1, 4096, 384) = 0)
		chk("(the same verdict, said twice: the winner name is the generic)", aR[:winner] = "tile16")
	ok

	? ""
	? "-- Scene 3: THE CHECKER GATES THE TABLE -- a wrong variant cannot win --"
	# mask 16 = the test-only broken kernel alone (right shape, wrong answer)
	nSt = StzEngineGpuFoundryPairdist(1, 4096, 384, 3, 16)
	chk("the foundry ran the broken variant", nSt = 0)
	chk("...and the checker REFUSED it (verified = 0)", StzEngineGpuFoundryResult(8 + 4 * 5) = 0)
	chk("...so there is no winner", StzEngineGpuFoundryResult(3) = 0)

	? ""
	? "-- Scene 4: the table changes the DISPATCH, and only the dispatch --"
	nN = 2048  nD = 128
	aA = []
	for k = 1 to nD
		aA + (k % 7) * 0.5
	next
	aB = []
	for j = 1 to nN
		for k = 1 to nD
			aB + ((j * 3 + k) % 11) * 0.25
		next
	next
	hA = StzEngineGpuBufferNew(nD * 4)
	hB = StzEngineGpuBufferNew(nN * nD * 4)
	hD1 = StzEngineGpuBufferNew(nN * 4)
	hD2 = StzEngineGpuBufferNew(nN * 4)
	StzEngineGpuBufferUploadList(hA, aA)
	StzEngineGpuBufferUploadList(hB, aB)
	StzEngineGpuVariantClear()
	StzEngineGpuCountersReset()
	chk("generic dispatch answers", StzEngineGpuOpPairDist(hA, hB, hD1, 1, nN, nD) = 0)
	chk("...and the variant counter did NOT move (the negative sibling)", StzEngineGpuCounter(C_VAR) = 0)
	StzEngineGpuVariantSet("pairdist", 1, nN, nD, 2)     # row4 for this class
	chk("with the class pointing at row4, the dispatch answers", StzEngineGpuOpPairDist(hA, hB, hD2, 1, nN, nD) = 0)
	chk("...and the variant counter MOVED by one (the mechanism)", StzEngineGpuCounter(C_VAR) = 1)
	aD1 = StzEngineGpuBufferDownloadList(hD1, nN)
	aD2 = StzEngineGpuBufferDownloadList(hD2, nN)
	nMax = 0
	for j = 1 to nN
		_d_ = fabs(aD1[j] - aD2[j])
		if _d_ > nMax nMax = _d_ ok
	next
	? "  max |generic - row4| over " + nN + " distances: " + nMax
	chk("the variant's distances equal the generic's (quarter-grid data: exactly)", nMax = 0)
	StzEngineGpuVariantSet("pairdist", 1, nN, nD, 1)     # row: same answer, counter moves again
	StzEngineGpuOpPairDist(hA, hB, hD2, 1, nN, nD)
	chk("row too: the counter moved again", StzEngineGpuCounter(C_VAR) = 2)
	StzEngineGpuVariantSet("pairdist", 1, nN, 127, 2)    # a class where d % 4 != 0: row4 must DEGRADE to row
	hB2 = StzEngineGpuBufferNew(nN * 127 * 4)
	hD3 = StzEngineGpuBufferNew(nN * 4)
	chk("a row4 pick at d = 127 still answers (degraded to row, not refused)", StzEngineGpuOpPairDist(hA, hB2, hD3, 1, nN, 127) = 0)
	StzEngineGpuVariantClear()
	StzEngineGpuBufferFree(hA)  StzEngineGpuBufferFree(hB)  StzEngineGpuBufferFree(hB2)
	StzEngineGpuBufferFree(hD1)  StzEngineGpuBufferFree(hD2)  StzEngineGpuBufferFree(hD3)

	? ""
	? "-- Scene 5: persistence round-trips a variant row (files kept and restored) --"
	cBakA = ""
	cBakD = ""
	if fexists(StzGpuCalibFileForAdapter())
		cBakA = read(StzGpuCalibFileForAdapter())
	ok
	if fexists(StzGpuCalibFileDefault())
		cBakD = read(StzGpuCalibFileDefault())
	ok
	StzEngineGpuCalibSet("pairdist", 256000)
	StzGpuVariantSet("pairdist", 1, 4096, 384, 3)
	StzGpuSaveCalibration(["pairdist"])
	cF = read(StzGpuCalibFileForAdapter())
	chk("the file carries the variant row", StzFindFirst("variant" + char(9) + "pairdist" + char(9) + "1" + char(9) + "4096" + char(9) + "384" + char(9) + "3", cF) > 0)
	StzEngineGpuVariantClear()
	_StzGpuCalibLoadFile(StzGpuCalibFileForAdapter())
	chk("...and it is restored from disk", StzEngineGpuVariantGet("pairdist", 1, 4096, 384) = 3)
	if cBakA != ""
		write(StzGpuCalibFileForAdapter(), cBakA)
	else
		remove(StzGpuCalibFileForAdapter())
	ok
	if cBakD != ""
		write(StzGpuCalibFileDefault(), cBakD)
	ok
	StzEngineGpuVariantClear()

	? ""
	? "-- Scene 6: the kill line on a small grid (reported, not assumed) --"
	aK = oG.FoundryPairdistGrid([1024, 4096], [128, 384])
	nCells = len(aK[:cells])
	for i = 1 to nCells
		c = aK[:cells][i]
		? "  1 x " + c[:n] + " x " + c[:d] + ": winner " + c[:winner] + " at " + c[:ratio] + "x (GPU clock)"
	next
	? "  any class with a variant above the margin on " + aK[:adapter] + ": " + aK[:anywin]
	chk("four cells reported", nCells = 4)
	chk("the verdict is a boolean the plan can quote", aK[:anywin] = TRUE or aK[:anywin] = FALSE)
	StzEngineGpuVariantClear()
	# the grid persisted its winners into the calibration files: put them back
	if cBakA != ""
		write(StzGpuCalibFileForAdapter(), cBakA)
	ok
	if cBakD != ""
		write(StzGpuCalibFileDefault(), cBakD)
	ok
ok

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

func fabs n
	if n < 0 return -n ok
	return n
