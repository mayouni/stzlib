# GK2b's matmul leg -- the matmul op's variants through the foundry, under
# GK0's checker, on the shapes the neural backbone dispatches
# (SOFTANZA_GPU_PLAN.md, section GK).
#
# C(m x n) = A(m x k) B(k x n). Four kernels on one contract, every one on a
# LINEAR workgroup grid so the checker can judge them all: tile16 (the G0
# spike kernel, the generic), tile8, reg2 (each thread a 2x2 block), reg4
# (4x4). A broken sibling (reg2 with one element wrong) exists for the
# checker to refuse. The winner per (m, n, k) class lands in the variant
# table under "matmul", is persisted beside pairdist's rows, and the
# backbone compiles that winner with its bias fused for its own shapes.
#
# What this guard asserts, mechanism first, negative sibling beside each:
#   - at the backbone's shapes (tokens x 384 x 384, tokens x 384 x 1536,
#     tokens x 1536 x 384) every variant is VERIFIED at the visible shape and
#     the hidden one, and the verdict per cell is printed
#   - the broken sibling is REFUSED through the mask; the table rejects it
#   - a set variant DISPATCHES through the op (the variant counter moves) and
#     answers the generic's product within f32; cleared, the counter stays
#   - the neural DLL's own table takes a row and answers it for that class
#   - the backbone (MiniLM, 130 tokens) dispatches the synced winners with
#     the bias fused: the forward is faster and the embedding unchanged

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

decimals(4)

if StzEngineGpuInit($cStzGpuRuntime) = 0 or StzEngineGpuIsAvailable() = 0
	? "  NO GPU ON THIS MACHINE -- the foundry cannot run; the table's refusals are the coverage"
	chk("the table refuses the broken matmul variant without a device", StzEngineGpuVariantSet("matmul", 256, 384, 384, 4) != 0)
else
	oG = new stzGpu
	oG.Wake(400)
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
	StzEngineGpuVariantClear()

	? "-- Scene 1: the backbone's shapes, every variant under the checker --"
	nCells = 0
	nAllOk = 0
	for aCell in [ [64, 384, 384], [256, 384, 384], [256, 384, 1536], [256, 1536, 384], [512, 384, 1536] ]
		aR = oG.FoundryMatmulWith(aCell[1], aCell[2], aCell[3], 7)
		cRow = "  " + aCell[1] + " x " + aCell[2] + " x " + aCell[3] + ": generic " + aR[:refgpums] + " ms |"
		bAll = TRUE
		for v in aR[:variants]
			if v[2] = 1
				cRow += " " + v[1] + " " + v[5] + "x"
			but v[2] = 0
				cRow += " " + v[1] + " REFUSED"
				bAll = FALSE
			ok
		next
		cRow += " | winner " + aR[:winner] + " " + aR[:ratio] + "x"
		? cRow
		nCells++
		if bAll nAllOk++ ok
	next
	chk("three real variants were proposed", len(aR[:variants]) = 3)
	chk("every variant is VERIFIED in every cell (right at every shape it was shown and hidden)", nAllOk = nCells)
	chk("the hidden shape is another, odd n", aR[:hiddenn] != 1536 and (aR[:hiddenn] % 2) = 1)

	? ""
	? "-- Scene 2: the broken sibling is refused, and the table will not take it --"
	nSt = StzEngineGpuFoundryMatmul(64, 384, 384, 3, 16)
	nBroken = StzEngineGpuFoundryResult(8 + 4 * 5)
	? "  broken (mask bit 4): verified flag " + nBroken + "   winner " + StzEngineGpuFoundryResult(3)
	chk("the foundry ran the broken variant when asked", nSt = 0 and nBroken != -2)
	chk("...and the checker REFUSED it (one element off is not the same product)", nBroken = 0)
	chk("...so it cannot be the winner", StzEngineGpuFoundryResult(3) = 0)
	chk("...and the table refuses it outright", StzEngineGpuVariantSet("matmul", 64, 384, 384, 4) != 0)

	? ""
	? "-- Scene 3: a set variant dispatches through the op, and multiplies like the generic --"
	nM = 96
	nK = 384
	nN = 512
	hA = StzEngineGpuBufferNew(nM * nK * 4)
	hB = StzEngineGpuBufferNew(nK * nN * 4)
	hC = StzEngineGpuBufferNew(nM * nN * 4)
	StzEngineGpuBufferFillLcg(hA, nM * nK, 11)
	StzEngineGpuBufferFillLcg(hB, nK * nN, 22)
	StzEngineGpuVariantClear()
	nV0 = StzEngineGpuCounter(14)
	StzEngineGpuOpMatmul(hA, hB, hC, nM, nK, nN)
	aGen = StzEngineGpuBufferDownloadList(hC, nM * nN)
	chk("with the table cleared, the generic multiplied (the variant counter still)", StzEngineGpuCounter(14) = nV0 and len(aGen) = nM * nN)
	for cV in [ 1, 2, 3 ]
		StzEngineGpuVariantSet("matmul", nM, nN, nK, cV)
		nV0 = StzEngineGpuCounter(14)
		StzEngineGpuOpMatmul(hA, hB, hC, nM, nK, nN)
		aVar = StzEngineGpuBufferDownloadList(hC, nM * nN)
		nMax = 0
		for j = 1 to nM * nN
			_d_ = fabs(aVar[j] - aGen[j])
			if _d_ > nMax nMax = _d_ ok
		next
		? "  " + StzEngineGpuMmVariantName(cV) + ": variant dispatches " + (StzEngineGpuCounter(14) - nV0) + "   max |variant - generic| " + nMax
		chk(StzEngineGpuMmVariantName(cV) + " dispatched (the counter moved once)", StzEngineGpuCounter(14) - nV0 = 1)
		chk("...and the product agrees with the generic within f32 (k = 384 terms in [0,1))", nMax < 0.01)
	next
	StzEngineGpuVariantClear()
	nV0 = StzEngineGpuCounter(14)
	StzEngineGpuOpMatmul(hA, hB, hC, nM, nK, nN)
	chk("cleared, the counter stays still", StzEngineGpuCounter(14) = nV0)
	StzEngineGpuBufferFree(hA)
	StzEngineGpuBufferFree(hB)
	StzEngineGpuBufferFree(hC)

	? ""
	? "-- Scene 4: the neural DLL's own table takes the persisted verdict --"
	StzEngineNeuralVariantClear()
	StzEngineNeuralVariantSet("matmul", 256, 1536, 384, 3)
	chk("the neural DLL's table answers the row for its class", StzEngineNeuralVariantGet("matmul", 256, 1536, 384) = 3)
	chk("...and the generic for a class nobody set", StzEngineNeuralVariantGet("matmul", 64, 384, 384) = 0)
	chk("...and refuses the broken sibling too", StzEngineNeuralVariantSet("matmul", 256, 1536, 384, 4) != 0)
	StzEngineNeuralVariantClear()

	? ""
	? "-- Scene 5: the backbone dispatches the winners, bias fused, and the forward is faster --"
	cModel = "../../../models/all-MiniLM-L6-v2.Q8_0.gguf"
	if NOT fexists(cModel)
		? "  no local MiniLM -- the backbone scene needs models/; the op-level scenes above are the coverage"
	else
		StzEngineNeuralModelLoad(cModel)
		cText = ""
		for i = 1 to 12
			cText += "the quick brown fox jumps over the lazy dog and runs away "
		next
		StzEngineNeuralGpuSetThreshold(1000000)
		# the winners for the backbone's three shapes, measured here and now
		oG.FoundryMatmulWith(130, 384, 384, 5)
		oG.FoundryMatmulWith(130, 384, 1536, 5)
		oG.FoundryMatmulWith(130, 1536, 384, 5)
		# BEFORE: the neural DLL's own table empty, the sync held off
		StzEngineNeuralVariantClear()
		$bStzNeuralVariantsSynced_ = 1
		StzEngineNeuralEmbed(cText)
		nBefore = 1000000000
		for r = 1 to 7
			nT0 = StzEngineWatchTimestampNs()
			StzEngineNeuralEmbed(cText)
			nMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
			if nMs < nBefore nBefore = nMs ok
		next
		aVecB = []
		nDimB = StzEngineNeuralEmbed(cText)
		for i = 1 to nDimB
			aVecB + StzEngineNeuralEmbedAt(i - 1)
		next
		# AFTER: the verdicts synced across
		$bStzNeuralVariantsSynced_ = 0
		StzNeuralVariantsSync()
		nRow = StzEngineNeuralVariantGet("matmul", 130, 1536, 384)
		StzEngineNeuralEmbed(cText)
		nAfter = 1000000000
		for r = 1 to 7
			nT0 = StzEngineWatchTimestampNs()
			StzEngineNeuralEmbed(cText)
			nMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
			if nMs < nAfter nAfter = nMs ok
		next
		aVecA = []
		nDimA = StzEngineNeuralEmbed(cText)
		for i = 1 to nDimA
			aVecA + StzEngineNeuralEmbedAt(i - 1)
		next
		nMaxD = 0
		for i = 1 to nDimA
			_d_ = fabs(aVecA[i] - aVecB[i])
			if _d_ > nMaxD nMaxD = _d_ ok
		next
		? "  backbone forward at 130 tokens, warm-min of 7: generic " + nBefore + " ms   winners " + nAfter + " ms   = " + (nBefore / nAfter) + "x   max |embedding difference| " + nMaxD
		chk("the sync landed a winner for the backbone's FFN class in the neural DLL's table", nRow > 0)
		chk("the backbone forward is at least 1.5x faster with the winners (bias fused, same answer)", nBefore / nAfter >= 1.5)
		chk("...and the embedding is the same within f32 (max difference < 1e-4 on unit vectors)", nDimA = nDimB and nMaxD < 0.0001)
		StzEngineNeuralVariantClear()
		$bStzNeuralVariantsSynced_ = 0
		StzEngineNeuralModelFree()
	ok

	# the files and the tables as they were
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
	StzEngineGpuVariantClear()
	nS = len(aSaved)
	for i = 1 to nS
		StzGpuVariantSet(aSaved[i][1], aSaved[i][2], aSaved[i][3], aSaved[i][4], aSaved[i][5])
	next
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
