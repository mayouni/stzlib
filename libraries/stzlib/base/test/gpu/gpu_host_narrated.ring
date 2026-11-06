# GL0 -- THE HOST CONTRACT (SOFTANZA_GPU_HOST_CONTRACT.md).
#
# A kernel in the spec language is run by a HOST: this engine's checker, the
# Ring face, the browser page, and any host a language written later will
# have -- Haro's, which now lives in its own repository and cannot lean on the
# Ring face. The engine compiles and transpiles; the host owns buffers and
# dispatch, which are the platform's. Between them lay a handful of NUMBERS
# every host derived for itself, four times over (the face twice, the puzzle
# grader, the page): the NaN margin, the workgroup count, the hidden shape's
# size and data, the default band. A copy that drifts is a verdict that
# differs between hosts. They are the engine's now (gpu_host.zig) and every
# host asks.
#
# This guard holds the contract three ways:
#   1. the numbers, pinned, and the old rules replayed to show nothing moved;
#   2. a source scan: no host file spells a contract number again;
#   3. THE PROOF: a host written from the document alone -- it parses the
#      declaration lines itself, asks the engine for every number, and calls
#      only the engine's own entry points, never stzGpu, stzKernelMaker or
#      stzKernelPuzzle -- reaches the SAME verdict words as the face, on
#      puzzles from every admission, including the margin, a declared hidden
#      shape, vector buffers and atomic counters.
#
# One approximation, named: this host reads the interpreter's list, where the
# checker also keeps a mask; so an element the BODY computed as NaN is not
# told from one a guard left unwritten. No puzzle computes a NaN.
#
# Run with Ring++: rnxc gpu_host_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(4)
NLc = char(10)

? "-- Scene 1: the numbers, from the engine --"
$t0 = clock()
chk("the contract is version " + StzEngineGpuHostVersion(), StzEngineGpuHostVersion() = 1)
chk("a group is 256 threads, the margin 256 floats of NaN, the band 0.000001, 7 timed repetitions",
	StzEngineGpuHostGroup() = 256 and StzEngineGpuHostMargin() = 256 and StzEngineGpuHostDefaultBand() = 0.000001 and StzEngineGpuHostDefaultReps() = 7)
chk("workgroups: 1 element 1, 256 elements 1, 257 elements 2, 4000 elements 16",
	StzEngineGpuHostGroups(1) = 1 and StzEngineGpuHostGroups(256) = 1 and StzEngineGpuHostGroups(257) = 2 and StzEngineGpuHostGroups(4000) = 16)
chk("the hidden shape: 7 gives 5, 256 gives 181 (182 is even, one less), 4000 gives 2857, 1 and 2 give 1",
	StzEngineGpuHostHiddenCount(7) = 5 and StzEngineGpuHostHiddenCount(256) = 181 and StzEngineGpuHostHiddenCount(4000) = 2857 and StzEngineGpuHostHiddenCount(1) = 1 and StzEngineGpuHostHiddenCount(2) = 1)
nDiff = 0
for n = 1 to 6000
	nOld = floor(n * 5 / 7)
	if nOld < 1
		nOld = 1
	ok
	if nOld > 1 and nOld % 2 = 0
		nOld--
	ok
	if nOld != StzEngineGpuHostHiddenCount(n)
		nDiff++
	ok
next
chk("the engine's hidden count equals the rule every host used to carry, for every n from 1 to 6000 (" + nDiff + " differ)", nDiff = 0)
chk("the params uniform: no scalar 8 bytes, 3 scalars 20, 14 scalars 64, and never over 64",
	StzEngineGpuHostParamsBytes(0) = 8 and StzEngineGpuHostParamsBytes(3) = 20 and StzEngineGpuHostParamsBytes(14) = 64 and StzEngineGpuHostParamsBytes(40) = 64)
cV3 = "in p vec3" + NLc + "in k int" + NLc + "out q vec2" + NLc + "body { @q = vec2(@p.x, @p.y) * float(@k) }"
cAt = "in a" + NLc + "out h atomic 13" + NLc + "body { @h[@a] += 1 }"
chk("what a description makes of the shape: a vec3 input holds 3 floats per element, a vec2 output 2",
	StzEngineGpuSpecInLen(cV3, 1, 10) = 30 and StzEngineGpuSpecInLen(cV3, 2, 10) = 10 and StzEngineGpuSpecOutLen(cV3, 10) = 20)
chk("...and an atomic output is its 13 counters, whatever n is", StzEngineGpuSpecOutLen(cAt, 10) = 13 and StzEngineGpuSpecOutLen(cAt, 100000) = 13)
chk("the reversed tail, element by element: [1..6] as vec2s kept 2 of 3 is (5,6) then (3,4)",
	_Same(StzEngineGpuHostHiddenInput([ 1, 2, 3, 4, 5, 6 ], 2, 3, 2), [ 5, 6, 3, 4 ]))
aVis = [ [ 1, 2 ], [ 3, 4 ], [ 5, 6 ], [ 7, 8 ], [ 9, 10 ] ]
aTail = _StzKernelHiddenTail(aVis, 5, 3)
aFlatTail = []
for q = 1 to len(aTail)
	aFlatTail + aTail[q][1]
	aFlatTail + aTail[q][2]
next
chk("the face's own tail helper keeps the engine's elements, in the engine's order, for rows",
	_Same(aFlatTail, StzEngineGpuHostHiddenInput([ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ], 2, 5, 3)))
aNum = [ 5, 1, 4, 1, 5, 9, 2, 6, 5, 3 ]
chk("...and for plain numbers", _Same(_StzKernelHiddenTail(aNum, 10, 7), StzEngineGpuHostHiddenInput(aNum, 1, 10, 7)))
? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

? ""
? "-- Scene 2: no host spells a contract number any more --"
$t0 = clock()
acFiles = [ "../../gpu/stzGpu.ring", "../../gpu/stzGpuBuffer.ring", "../../gpu/stzKernelPuzzle.ring",
	"../../education/program/courses/kernel-puzzles/runner/puzzle.html" ]
acBanned = [ "/ 256.0)", "* 5 / 7", "n * 5 / 7", "Math.ceil(n / 256)", "const MARGIN = 256", "_nMargin_ = 256", "return 0.000001", "_nBand_ = 0.000001", "_nReps_ = 7", ": 1e-6" ]
for cF in acFiles
	cT = read(cF)
	acHit = []
	for cB in acBanned
		if StzFindFirst(cB, cT) > 0
			acHit + cB
		ok
	next
	cWhich = ""
	if len(acHit) > 0
		cWhich = ": " + acHit[1]
	ok
	chk(cF + " carries none of the numbers (" + len(acHit) + " found" + cWhich + ")", len(acHit) = 0)
next
? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

oG = new stzGpu
bDevice = oG.IsAvailable()
if bDevice
	? ""
	? "-- Scene 3: a host written from the document, against the face --"
	$t0 = clock()
	aCases = [
		[ "kp-05", "in a" + NLc + "out c" + NLc + "guard none" + NLc + "body { @c = @a * 2 }" ],
		[ "kp-05", "in a" + NLc + "out c" + NLc + "guard { @i < n }" + NLc + "body { @c = @a * 2 }" ],
		[ "kp-06", "REF" ],
		[ "kp-06", "in a" + NLc + "out c" + NLc + "body { @c = (@a[@i - 1] + @a + @a[@i + 1]) / 3 }" ],
		[ "kp-10", "REF" ],
		[ "kp-10", "REPLACE tiles t { k / 16 } => tiles t { 1 }" ],
		[ "kp-13", "REF" ],
		[ "kp-13", "REPLACE when(@a <= t, @a, t + 2 * (@a - t)) => when(@a <= t, t + 2 * (@a - t), @a)" ],
		[ "kp-14", "REF" ],
		[ "kp-14", "in a" + NLc + "out c" + NLc + "body { @c = (@a * 1664525 + 1013904223) % 1000 }" ],
		[ "kp-15", "REF" ],
		[ "kp-15", "REPLACE normalize(vec3(@nx, @ny, @nz)) => vec3(@nx, @ny, @nz)" ],
		[ "kp-16", "REF" ],
		[ "kp-16", "REPLACE vec2(c * @p.x - s * @p.y, s * @p.x + c * @p.y) => vec2(c * @p.x, s * @p.x)" ],
		[ "kp-17", "REF" ],
		[ "kp-17", "REPLACE @h[@a] += 1 => @h[@a - 1] += 1" ],
		[ "kp-17", "REPLACE @h[@a] += 1 => @h[@a] max= 1" ]
	]
	nAgree = 0
	nAll = len(aCases)
	for aC in aCases
		oQ = StzKernelPuzzleQ(aC[1])
		cRef = oQ.Reference()
		cL = aC[2]
		if cL = "REF"
			cL = cRef
		but StzLeft(cL, 8) = "REPLACE "
			acP = StzSplit(StzRight(cL, len(cL) - 8), " => ")
			cL = StzReplace(cRef, acP[1], acP[2])
		ok
		cFace = oQ.Grade(cL)
		if oQ.HiddenElements() > 0
			cMini = _MiniVerdict(cRef, cL, oQ.Bindings(), oQ.Elements(), oQ.HiddenBindings(), oQ.HiddenElements(), oQ.Band())
		else
			cMini = _MiniVerdict(cRef, cL, oQ.Bindings(), oQ.Elements(), [], 0, oQ.Band())
		ok
		if cFace = cMini
			nAgree++
		ok
		chk(aC[1] + ": the face says '" + cFace + "', the host from the document says '" + cMini + "'", cFace = cMini)
	next
	chk("the two agree on all " + nAll + " cases: margin, declared and derived hidden shapes, ints, vector buffers, atomic counters", nAgree = nAll)
	? "  (scene 3: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pfq()
shutdown($nFail)

# ======================================================================
# THE HOST, written from SOFTANZA_GPU_HOST_CONTRACT.md. It calls only the
# engine's entry points (StzEngineGpu*): no stzGpu, no stzKernelMaker, no
# stzKernelPuzzle. Every number it uses is the engine's.
# ======================================================================

# the names a description declares with a line starting 'in' or 'scalar', in order
func _MiniNames cSpec, cHead
	acN = []
	acLines = StzSplit(StzReplace(cSpec, char(13), ""), char(10))
	nLn = len(acLines)
	for q = 1 to nLn
		acW = StzSplit(trim(acLines[q]), " ")
		if len(acW) >= 2 and acW[1] = cHead
			acN + acW[2]
		ok
	next
	return acN

# rows of a vecN input travel flat
func _MiniFlat aVal
	if len(aVal) = 0
		return aVal
	ok
	if NOT isList(aVal[1])
		return aVal
	ok
	aF = []
	nR = len(aVal)
	for q = 1 to nR
		nC = len(aVal[q])
		for r = 1 to nC
			aF + aVal[q][r]
		next
	next
	return aF

func _MiniBind aB, cName
	nL = len(aB)
	for q = 1 to nL
		if aB[q][1] = cName
			return aB[q][2]
		ok
	next
	return 0

# the hidden shape: the engine's count and the engine's reversed tail, per input
func _MiniHiddenBind cRef, aBind, nA, nB
	acIn = _MiniNames(cRef, "in")
	aH = aBind
	nI = len(acIn)
	for q = 1 to nI
		nW = StzEngineGpuSpecInWidth(cRef, q)
		aHid = StzEngineGpuHostHiddenInput(_MiniFlat(_MiniBind(aBind, acIn[q])), nW, nA, nB)
		nL = len(aH)
		for r = 1 to nL
			if aH[r][1] = acIn[q]
				aH[r] = [ acIn[q], aHid ]
			ok
		next
	next
	return aH

# one shape: size, fill, dispatch, read, scan the margin, compare. "" when it holds.
func _MiniRunShape cRef, nK, aBind, nN, nBand, cSuffix
	acIn = _MiniNames(cRef, "in")
	acSc = _MiniNames(cRef, "scalar")
	aFlat = []
	aLens = []
	aIds = []
	nI = len(acIn)
	for q = 1 to nI
		aV = _MiniFlat(_MiniBind(aBind, acIn[q]))
		nV = len(aV)
		for r = 1 to nV
			aFlat + aV[r]
		next
		aLens + nV
		nId = StzEngineGpuBufferNew(nV * 4)
		StzEngineGpuBufferUploadList(nId, aV)
		aIds + nId
	next
	aScal = []
	nS = len(acSc)
	for q = 1 to nS
		aScal + _MiniBind(aBind, acSc[q])
	next
	nOutLen = StzEngineGpuSpecOutLen(cRef, nN)
	nTotal = nOutLen + StzEngineGpuHostMargin()
	nOut = StzEngineGpuBufferNew(nTotal * 4)
	StzEngineGpuBufferFillI32(nOut, 2143289344, nTotal) # NaN: the f32 bits 0x7FC00000, everywhere
	bAtom = StzEngineGpuSpecOutAtomic(cRef) = 1
	if bAtom
		StzEngineGpuBufferFillI32(nOut, StzEngineGpuSpecOutIdentity(cRef), nOutLen) # the counters, at their identity
	ok
	aIds + nOut
	StzEngineGpuDispatchParams(nK, nN, aScal, aIds, StzEngineGpuHostGroups(nN))
	aGot = StzEngineGpuBufferDownloadList(nOut, nTotal)
	aCnt = []
	if bAtom
		aCnt = StzEngineGpuBufferDownloadI32List(nOut, nOutLen) # the counters are i32s
	ok
	aRef = StzEngineGpuSpecEval(cRef, aFlat, aLens, nN, aScal)
	nIds = len(aIds)
	for q = 1 to nIds
		StzEngineGpuBufferFree(aIds[q])
	next
	nW = StzEngineGpuSpecOutWidth(cRef)
	nEl = nN
	if bAtom
		nW = 1
		nEl = nOutLen
	ok
	for k = nOutLen + 1 to nTotal
		if aGot[k] = aGot[k] # a number where NaN was left: written past the region
			return "write-outside at element " + (nEl + floor((k - 1 - nOutLen) / nW) + 1)
		ok
	next
	for k = 1 to nOutLen
		nG = aGot[k]
		if bAtom
			nG = aCnt[k]
		ok
		nR = aRef[k]
		bRN = NOT (nR = nR)
		bGN = NOT (nG = nG)
		if bRN and bGN
			loop
		ok
		if bRN or bGN or fabs(nR - nG) > nBand
			return "mismatch" + cSuffix + " at element " + ceil(k / nW)
		ok
	next
	return ""

func _MiniVerdict cRef, cLearner, aVis, nA, aHid, nB, nBand
	cW = StzEngineGpuWgslElementwise(cLearner)
	if cW = ""
		return "refused: " + StzEngineGpuWgslError()
	ok
	nK = StzEngineGpuKernelCompile(cW)
	if nK = 0
		return "refused: " + StzEngineGpuLastError()
	ok
	cV = _MiniRunShape(cRef, nK, aVis, nA, nBand, "")
	if cV != ""
		return cV
	ok
	if nB = 0
		nB = StzEngineGpuHostHiddenCount(nA)
		aHid = _MiniHiddenBind(cRef, aVis, nA, nB)
	ok
	cV = _MiniRunShape(cRef, nK, aHid, nB, nBand, "-hidden")
	if cV != ""
		return cV
	ok
	return "verified"

func chk cLabel, bCond
	if bCond
		$nPass++
		? "  [OK] " + cLabel
	else
		$nFail++
		? "  [FAIL] " + cLabel
	ok

func _Same paA, paB
	if len(paA) != len(paB)
		return 0
	ok
	nQ = len(paA)
	for q = 1 to nQ
		if paA[q] != paB[q]
			return 0
		ok
	next
	return 1
