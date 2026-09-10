# GK2c -- the backbone's fused attention through the foundry, under GK0's
# checker, on the neural DLL's device (SOFTANZA_GPU_PLAN.md, section GK).
#
# One workgroup per (head, query row): scores, softmax, context. The generic
# had every thread scan max and sum over the tokens serially and used head_dim
# threads of 64 for the context; the RED variants reduce through workgroup
# memory and split the context's token range across the idle threads, at
# widths 64, 128 and 256. A broken sibling (one output nudged) exists for the
# checker to refuse. The winner per (tokens, width, head_dim) class lands in
# the variant table under "attention", is persisted beside the matmul rows,
# and the next forward dispatches it.
#
# What this guard asserts, mechanism first, negative sibling beside each:
#   - at the backbone's shapes (64 / 130 / 256 tokens, 384 wide, 12 heads)
#     every eligible variant is VERIFIED at the visible and hidden token counts
#   - the broken sibling is REFUSED through the mask; the table rejects it
#   - the backbone reports WHICH variant its last forward dispatched: the
#     generic with the table cleared, the winner with it set, and the
#     embedding is unchanged within f32
#   - the forward is faster with the winner (MiniLM, 130 tokens)

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

decimals(4)

if StzEngineGpuInit($cStzGpuRuntime) = 0 or StzEngineGpuIsAvailable() = 0
	? "  NO GPU ON THIS MACHINE -- the foundry cannot run; the table's refusal is the coverage"
	chk("the neural table refuses the broken attention variant without a device", StzEngineNeuralVariantSet("attention", 130, 384, 32, 4) != 0)
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
	cModel = "../../../models/all-MiniLM-L6-v2.Q8_0.gguf"
	bModel = fexists(cModel)
	if bModel
		StzEngineNeuralModelLoad(cModel)
	ok

	? "-- Scene 1: the backbone's shapes, every variant under the checker --"
	nCells = 0
	nAllOk = 0
	for aCell in [ [64, 384, 12], [130, 384, 12], [256, 384, 12] ]
		aR = oG.FoundryAttentionWith(aCell[1], aCell[2], aCell[3], 7)
		cRow = "  " + aCell[1] + " tokens x " + aCell[2] + " / " + aCell[3] + " heads: generic " + aR[:refgpums] + " ms |"
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
	chk("every variant is VERIFIED in every cell (right at every token count it was shown and hidden)", nAllOk = nCells)
	chk("the hidden token count is another, odd one", aR[:hiddenn] != 256 and (aR[:hiddenn] % 2) = 1)

	? ""
	? "-- Scene 2: the broken sibling is refused, and the table will not take it --"
	nSt = StzEngineNeuralAttentionFoundry(130, 384, 12, 3, 16)
	nBroken = StzEngineNeuralAttentionFoundryResult(8 + 4 * 5)
	? "  broken (mask bit 4): verified flag " + nBroken + "   winner " + StzEngineNeuralAttentionFoundryResult(3)
	chk("the foundry ran the broken variant when asked", nSt = 0 and nBroken != -2)
	chk("...and the checker REFUSED it (one output nudged is not the same attention)", nBroken = 0)
	chk("...so it cannot be the winner", StzEngineNeuralAttentionFoundryResult(3) = 0)
	chk("...and the table refuses it outright", StzEngineNeuralVariantSet("attention", 130, 384, 32, 4) != 0)

	? ""
	? "-- Scene 3: the backbone dispatches the table's variant, and says which --"
	if NOT bModel
		? "  no local MiniLM -- the backbone scenes need models/; the op-level scenes above are the coverage"
	else
		cText = ""
		for i = 1 to 12
			cText += "the quick brown fox jumps over the lazy dog and runs away "
		next
		StzEngineNeuralGpuSetThreshold(1000000)
		# three forwards: everything generic; the matmul winners (GK2b, from
		# the persisted rows) with the generic attention; then both winners
		StzEngineNeuralVariantClear()
		StzEngineNeuralEmbed(cText)
		nAllGen = 1000000000
		for r = 1 to 7
			nT0 = StzEngineWatchTimestampNs()
			StzEngineNeuralEmbed(cText)
			nMs = (StzEngineWatchTimestampNs() - nT0) / 1000000
			if nMs < nAllGen nAllGen = nMs ok
		next
		$bStzNeuralVariantsSynced_ = 0
		StzNeuralVariantsSync()
		StzEngineNeuralVariantSet("attention", 130, 384, 32, 0)
		StzEngineNeuralEmbed(cText)
		nUsed0 = StzEngineNeuralAttentionVariantUsed()
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
		chk("with the attention row at the generic, the forward reports the generic (scan64)", nUsed0 = 0)
		# now the winner the foundry found for 130 tokens (Scene 1 stored it)
		aR130 = oG.FoundryAttentionWith(130, 384, 12, 5)
		nW = StzEngineNeuralVariantGet("attention", 130, 384, 32)
		? "  the table's row for 130 x 384 / 32: " + nW + " (" + StzEngineNeuralAttentionVariantName(nW) + ")"
		StzEngineNeuralEmbed(cText)
		nUsed1 = StzEngineNeuralAttentionVariantUsed()
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
		? "  forward at 130 tokens, warm-min of 7: all generic " + nAllGen + " ms   matmul winners " + nBefore + " ms   matmul + attention winners " + nAfter + " ms   (attention alone " + (nBefore / nAfter) + "x, all winners " + (nAllGen / nAfter) + "x)   max |embedding difference| " + nMaxD + "   variant used: " + StzEngineNeuralAttentionVariantName(nUsed1)
		chk("the foundry found a winner for the backbone's own shape", nW > 0)
		chk("...and the forward reports dispatching THAT variant", nUsed1 = nW)
		chk("...with the same embedding within f32 (max difference < 1e-4 on unit vectors)", nDimA = nDimB and nMaxD < 0.0001)
		chk("...and the forward is not slower (the attention is 40% of it; the win is bounded by that share)", nAfter <= nBefore * 1.02)
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
	StzEngineNeuralVariantClear()
	$bStzNeuralVariantsSynced_ = 0
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
