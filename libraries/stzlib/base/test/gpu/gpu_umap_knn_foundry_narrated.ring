# GS6e -- the UMAP k-NN kernel through GK2's foundry, under GK0's checker
# (SOFTANZA_GPU_PLAN.md; cuML's paper puts the k-NN at 98% of a 3M-point
# run -- it is the ceiling at scale, and ours was the naive scan).
#
# Four kernels answer one contract -- the k nearest of every row, ties to the
# lower index -- and a for-loop proposes them: generic, tile, tile4, chunk.
# GK0's checker verifies each against the generic on the same device buffers
# at the asked shape and at a hidden one (a different, odd n, different
# data), times both on the GPU clock with the device awake, and the winner,
# if it clears 1.3x, is recorded for the shape class in the stats DLL's
# variant table and persisted beside pairdist's rows. A variant the checker
# refuses cannot win, whatever it timed.
#
# What this guard asserts, mechanism first, negative sibling beside each:
#   - the enumeration runs at 4,096 x 8 x 15 and every eligible variant is
#     either VERIFIED or refused by name; the chunk variant is the only one
#     eligible at d = 128
#   - the broken sibling (right in shape, one index off) is REFUSED through
#     the mask and can never be set in the table
#   - a set variant DISPATCHES: the counter moves and the table answers the
#     generic's rows exactly; cleared, the counter stays still
#   - the verdict persisted under "umap_knn" survives the sync into the
#     stats DLL's table
#   - the numbers, printed: the ceiling this desk now has

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

decimals(4)

if StzEngineGpuInit($cStzGpuRuntime) = 0 or StzEngineGpuIsAvailable() = 0
	? "  NO GPU ON THIS MACHINE -- the foundry cannot run; the table's refusals are the coverage"
	chk("the table refuses the broken variant without a device", StzEngineUmapKnnVariantSet(4096, 8, 15, 4) != 0)
	chk("...and answers 0 (the generic) for an unset class", StzEngineUmapKnnVariantGet(4096, 8, 15) = 0)
else
	oG = new stzGpu
	oG.Wake(400)
	# a clean table for the scenes; the persisted rows are put back at the end,
	# and the calibration files the foundry writes are restored byte for byte --
	# a guard measures, it does not leave verdicts behind (the shaped guard's rule)
	aSaved = StzGpuVariants()
	aCalFiles = [ StzGpuCalibFileDefault(), StzGpuCalibFileForAdapter() ]
	aCalBackup = []
	for cF in aCalFiles
		if cF != "" and fexists(cF)
			aCalBackup + [ cF, read(cF) ]
		else
			aCalBackup + [ cF, "" ]
		ok
	next
	StzEngineUmapKnnVariantClear()

	? "-- Scene 1: the enumeration at 4,096 x 8 x 15 --"
	aR = oG.FoundryUmapKnnWith(4096, 8, 15, 7)
	? "  hidden n " + aR[:hiddenn] + "   clocks " + aR[:clocks] + "   generic: GPU " + aR[:refgpums] + " ms, wall " + aR[:refwallms] + " ms"
	nVerified = 0
	nRefused = 0
	for v in aR[:variants]
		cState = "not asked"
		if v[2] = 1 cState = "VERIFIED" but v[2] = 0 cState = "REFUSED" but v[2] = -1 cState = "not eligible" ok
		? "  " + v[1] + ": " + cState + "   GPU " + v[3] + " ms   wall " + v[4] + " ms   ratio GPU " + v[5] + "x   wall " + v[6] + "x"
		if v[2] = 1 nVerified++ ok
		if v[2] = 0 nRefused++ ok
	next
	? "  winner: " + aR[:winner] + " at " + aR[:ratio] + "x   stored: " + aR[:stored]
	chk("three real variants were proposed", len(aR[:variants]) = 3)
	chk("every eligible variant was VERIFIED (right at the visible shape and the hidden one)", nVerified = 3 and nRefused = 0)
	chk("the hidden shape is another, odd n", aR[:hiddenn] != 4096 and (aR[:hiddenn] % 2) = 1)
	nW8 = StzEngineUmapKnnVariantGet(4096, 8, 15)
	chk("the table holds the winner for the class, or the generic (0) when nothing cleared 1.3x", (aR[:ratio] >= 1.3 and nW8 > 0) or (aR[:ratio] < 1.3 and nW8 = 0))

	? ""
	? "-- Scene 2: d = 128, where only the chunk variant can answer --"
	aR2 = oG.FoundryUmapKnnWith(4096, 128, 15, 5)
	for v in aR2[:variants]
		cState = "not asked"
		if v[2] = 1 cState = "VERIFIED" but v[2] = 0 cState = "REFUSED" but v[2] = -1 cState = "not eligible" ok
		? "  " + v[1] + ": " + cState + "   ratio GPU " + v[5] + "x"
	next
	? "  winner: " + aR2[:winner] + " at " + aR2[:ratio] + "x"
	chk("tile and tile4 are not eligible at d = 128 (they stage the point in 64 registers)", aR2[:variants][1][2] = -1 and aR2[:variants][2][2] = -1)
	chk("the chunk variant is VERIFIED at d = 128", aR2[:variants][3][2] = 1)

	? ""
	? "-- Scene 3: the broken sibling is refused by the checker, and the table will not take it --"
	nSt = StzEngineUmapKnnFoundry(2048, 8, 10, 3, 16)
	nBroken = StzEngineUmapKnnFoundryResult(8 + 4 * 5)
	? "  broken (mask bit 4): verified flag " + nBroken + "   winner " + StzEngineUmapKnnFoundryResult(3)
	chk("the foundry ran the broken variant when asked", nSt = 0 and nBroken != -2)
	chk("...and the checker REFUSED it (one index off is not the same answer)", nBroken = 0)
	chk("...so it cannot be the winner", StzEngineUmapKnnFoundryResult(3) = 0)
	chk("...and the table refuses it outright", StzEngineUmapKnnVariantSet(2048, 8, 10, 4) != 0)

	? ""
	? "-- Scene 4: a set variant dispatches, and answers the generic's rows --"
	nN = 3000
	nD = 8
	nK = 15
	aX = []
	for i = 1 to nN
		for t = 1 to nD
			aX + (((i - 1) % 4) * 4 * ((t + (i - 1) % 4) % 2) + sin(i * 0.731 + t * 1.37) * 0.5)
		next
	next
	StzEngineUmapKnnVariantClear()
	StzEngineUmapGpuCountersReset()
	aGen = StzEngineUmapKnn(aX, nN, nD, nK, 1)
	chk("with the table cleared, the generic answered (variant counter still)", StzEngineUmapGpuCounter(4) = 0 and len(aGen) = nN * nK)
	for cV in [ 1, 2, 3 ]
		StzEngineUmapKnnVariantSet(nN, nD, nK, cV)
		StzEngineUmapGpuCountersReset()
		aVar = StzEngineUmapKnn(aX, nN, nD, nK, 1)
		nDiff = 0
		for j = 1 to nN * nK
			if aVar[j] != aGen[j] nDiff++ ok
		next
		? "  " + StzEngineUmapKnnVariantName(cV) + ": variant dispatches " + StzEngineUmapGpuCounter(4) + "   entries differing from the generic: " + nDiff
		chk(StzEngineUmapKnnVariantName(cV) + " dispatched (the counter moved once)", StzEngineUmapGpuCounter(4) = 1)
		chk("...and answered the generic's rows exactly", nDiff = 0)
	next
	StzEngineUmapKnnVariantClear()
	StzEngineUmapGpuCountersReset()
	StzEngineUmapKnn(aX, nN, nD, nK, 1)
	chk("cleared, the counter stays still", StzEngineUmapGpuCounter(4) = 0)

	? ""
	? "-- Scene 5: the persisted verdict reaches the stats DLL through the sync --"
	StzGpuVariantSet("umap_knn", 15, 4096, 8, 3)
	$bStzUmapKnnVariantsSynced_ = 0
	StzEngineUmapKnnVariantClear()
	StzUmapKnnVariantsSync()
	chk("a persisted umap_knn row lands in the stats DLL's table after the sync", StzEngineUmapKnnVariantGet(4096, 8, 15) = 3)
	chk("...for that class only (a class nobody measured stays generic)", StzEngineUmapKnnVariantGet(512, 8, 15) = 0)

	? ""
	? "-- Scene 6: the kill line, per d-class -- the grid the plan reads --"
	nCells = 0
	nAllVerified = 0
	for aCell in [ [16384, 8], [8192, 32], [8192, 64], [4096, 256] ]
		aRg = oG.FoundryUmapKnnWith(aCell[1], aCell[2], 15, 5)
		cRow = "  " + aCell[1] + " x " + aCell[2] + ": generic " + aRg[:refgpums] + " ms |"
		bAll = TRUE
		for v in aRg[:variants]
			if v[2] = 1
				cRow += " " + v[1] + " " + v[5] + "x"
			but v[2] = 0
				cRow += " " + v[1] + " REFUSED"
				bAll = FALSE
			ok
		next
		cRow += " | winner " + aRg[:winner] + " " + aRg[:ratio] + "x"
		? cRow
		nCells++
		if bAll nAllVerified++ ok
	next
	chk("every eligible variant is VERIFIED in every cell of the grid (right at every shape it was shown and hidden)", nAllVerified = nCells)

	# the machine's own verdicts back, and the files as they were
	nB = len(aCalBackup)
	for i = 1 to nB
		if aCalBackup[i][1] != ""
			if aCalBackup[i][2] != ""
				write(aCalBackup[i][1], aCalBackup[i][2])
			but fexists(aCalBackup[i][1])
				remove(aCalBackup[i][1])
			ok
		ok
	next
	StzEngineUmapKnnVariantClear()
	$bStzUmapKnnVariantsSynced_ = 0
	nS = len(aSaved)
	for i = 1 to nS
		if aSaved[i][1] = "umap_knn"
			StzGpuVariantSet("umap_knn", aSaved[i][2], aSaved[i][3], aSaved[i][4], aSaved[i][5])
		ok
	next
	StzUmapKnnVariantsSync()
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
