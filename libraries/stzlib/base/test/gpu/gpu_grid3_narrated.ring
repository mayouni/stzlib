# GL0 -- THE 3-D GRID (SOFTANZA_GPU_PLAN.md, GL0; the reader's account of the
# language is base/gpu/SOFTANZA_GPU_KERNELS.md, 3.1g).
#
# The seventh admission, and the last of GL0's vocabulary: a `depth` line after
# `width`. The output is a STACK of slices, each a `width` grid worked in
# 16 x 16 tiles. A thread knows its slice (@slice) and its row and column
# INSIDE that slice (@row, @col); @i is its place in the whole volume. The
# groups run slice by slice -- a group is a tile of ONE slice, never a tile
# straddling two -- so the dispatch is still ceil(n / 256) groups in x, the
# host contract moves not at all, and the element count must be a whole number
# of slices of whole tiles (n = width * rows * depth, rows a multiple of 16).
#
# Both readers carry it: the transpiler writes the prologue (per, tps, slc,
# gs, row, col, i) and the interpreter keeps the slice in the thread; a depth
# of one is the 2-D grid it always was. width and depth are each a number or
# a declared scalar.
#
# Run with Ring++: rnxc gpu_grid3_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(4)
NLc = char(10)

? "-- Scene 1: slices of width grids, in both readers --"
$t0 = clock()
kLit = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "width 16" + NLc + "depth 3" + NLc + "body { @c = @slice * 1000 + @row * 16 + @col + @a * 0 }")
cW = kLit.ToWGSL()
chk("the transpiler splits the elements into slices of per = n / 3, then tiles",
	StzFindFirst("let per = p.n / 3u;", cW) > 0 and StzFindFirst("let tps = per / 256u;", cW) > 0 and StzFindFirst("let slc = g / tps;", cW) > 0)
chk("...and puts the cell at slice * per + row * width + col, with @slice reading the slice",
	StzFindFirst("let i = slc * per + row * 16u + col;", cW) > 0 and StzFindFirst("f32(slc)", cW) > 0)
aSeq = _Seq(768)
aC = kLit.EvaluateOn([ :a = aSeq ])
bOk = 1
for j = 1 to 768
	i = j - 1
	if aC[j] != floor(i / 256) * 1000 + i % 256
		bOk = 0
	ok
next
chk("the interpreter: three 16 x 16 slices, every cell is slice * 1000 + its place in its own slice (768 cells)", bOk)
kSc = StzKernelMakerFromSpec("in a" + NLc + "scalar w" + NLc + "scalar d" + NLc + "out c" + NLc + "width w" + NLc + "depth d" + NLc + "body { @c = @slice * 10000 + @row * 100 + @col + @a * 0 }")
chk("width and depth as scalars are read from the parameters",
	StzFindFirst("let per = p.n / u32(p.s_d);", kSc.ToWGSL()) > 0 and StzFindFirst("let tpr = u32(p.s_w) / 16u;", kSc.ToWGSL()) > 0)
aS = kSc.EvaluateOn([ :a = _Seq(2048), :w = 32, :d = 2 ])
chk("two 32 x 32 slices: the cell at element 1058 is slice 1, row 1, column 1 (10101), and element 33 is slice 0, row 1, column 0 (100)",
	aS[1058] = 10101 and aS[33] = 100 and aS[2048] = 10000 + 31 * 100 + 31)
aOne = kSc.EvaluateOn([ :a = _Seq(1024), :w = 32, :d = 1 ])
chk("a depth of one is the 2-D grid it always was: @slice is 0 and rows count down the whole grid",
	aOne[33] = 100 and aOne[1024] = 31 * 100 + 31)
cT = ""
try
	kSc.EvaluateOn([ :a = _Seq(1536), :w = 32, :d = 2 ])
catch
	cT = cCatchError
done
chk("elements that are not whole slices of whole tiles are refused by name (" + left(cT, 70) + ")", StzFindFirst("whole slices", cT) > 0)
cT = ""
try
	kSc.EvaluateOn([ :a = _Seq(1024), :w = 32, :d = 0 ])
catch
	cT = cCatchError
done
chk("a depth scalar of zero is refused by name", StzFindFirst("depth scalar", cT) > 0)
? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

? ""
? "-- Scene 2: what is refused, in the same words by both readers --"
$t0 = clock()
# (two depth lines are refused by the engine's own test: the face keeps one depth, as it keeps one width)
aRef = [
	[ "@slice without a depth line", "in a" + NLc + "out c" + NLc + "width 16" + NLc + "body { @c = @a + @slice }", "'@slice' needs a depth line" ],
	[ "a depth line without a width line", "in a" + NLc + "out c" + NLc + "depth 2" + NLc + "body { @c = @a }", "a depth line needs a width line" ],
	[ "a depth of zero", "in a" + NLc + "out c" + NLc + "width 16" + NLc + "depth 0" + NLc + "body { @c = @a }", "depth 0 holds no slice" ],
	[ "a depth that is not a declared scalar", "in a" + NLc + "out c" + NLc + "width 16" + NLc + "depth d" + NLc + "body { @c = @a }", "depth must be a declared scalar or a number" ],
	[ "a scalar named slice", "in a" + NLc + "scalar slice" + NLc + "out c" + NLc + "width 16" + NLc + "body { @c = @a }", "'slice' is the slice of a 3-D grid" ]
]
for aQ in aRef
	cT = ""
	try
		StzKernelMakerFromSpec(aQ[2]).ToWGSL()
	catch
		cT = cCatchError
	done
	cI = ""
	try
		StzKernelMakerFromSpec(aQ[2]).EvaluateOn([ :a = _Seq(256) ])
	catch
		cI = cCatchError
	done
	chk(aQ[1] + ": both readers refuse it with '" + aQ[3] + "'", StzFindFirst(aQ[3], cT) > 0 and cT = cI)
next
? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

oG = new stzGpu
bDevice = oG.IsAvailable()
if bDevice
	? ""
	? "-- Scene 3: on the device --"
	$t0 = clock()
	cHead = "in a" + NLc + "scalar w" + NLc + "scalar d" + NLc + "scalar p" + NLc + "out c" + NLc + "width w" + NLc + "depth d" + NLc
	aA = []
	for i = 1 to 1536
		aA + (i % 13)
	next
	aB = [ [ "a", aA ], [ "w", 16 ], [ "d", 3 ], [ "p", 512 ] ]
	aOpt = [ [ "n", 1536 ], [ "hidden", [ [ "n", 1536 ], [ "bindings", aB ] ] ] ]
	aBodies = [
		"@slice * 1000 + @row * 16 + @col + @a * 0",
		"@a * (@slice + 1) + @row * 0.5",
		"when(@slice > 0, @a - @a[@i - p], @a)",
		"@a[@i + p] + @a",
		"sum(j, 0, d, @a[j * p + @row * w + @col])",
		"sum(j, 0, d, @a[j * p + @row * w + @col] * (j + 1))"
	]
	for cB in aBodies
		k = StzKernelMakerFromSpec(cHead + "body { @c = " + cB + " }")
		aV = oG.VerifySpecWith(k, k, aB, aOpt)
		chk(cB + ": three 16 x 32 slices, the device agrees with the interpreter (" + aV[:verdict] + ")", aV[:verdict] = "verified")
	next
	# a literal width and depth, a different shape: two slices of 48 x 16
	aA2 = []
	for i = 1 to 1536
		aA2 + ((i * 7) % 11)
	next
	aB2 = [ [ "a", aA2 ] ]
	k = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "width 48" + NLc + "depth 2" + NLc + "body { @c = @a * (@slice + 1) + @col - @row }")
	aV = oG.VerifySpecWith(k, k, aB2, [ [ "n", 1536 ], [ "hidden", [ [ "n", 1536 ], [ "bindings", aB2 ] ] ] ])
	chk("literal width 48 and depth 2: the device agrees with the interpreter (" + aV[:verdict] + ")", aV[:verdict] = "verified")
	? "  (scene 3: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 4: the fuzz's grid kind, and its control --"
	$t0 = clock()
	nSeed = 20261028
	StzEngineGpuFuzzRun(nSeed, 300, 16384, 0.00001)
	? "  generated " + StzEngineGpuFuzzResult(50) + " grid kernels; ran " + StzEngineGpuFuzzResult(4) + ", agreed " + StzEngineGpuFuzzResult(5) + " (exact " + StzEngineGpuFuzzResult(9) + ")"
	chk("300 kernels: none refused by both readers, no split, no compile failure",
		StzEngineGpuFuzzResult(50) = 300 and StzEngineGpuFuzzResult(1) = 0 and StzEngineGpuFuzzResult(2) = 0 and StzEngineGpuFuzzResult(3) = 0)
	chk("...all 300 agree with the interpreter bit for bit, literal and scalar width and depth, one to four slices",
		StzEngineGpuFuzzResult(5) = 300 and StzEngineGpuFuzzResult(9) = 300 and StzEngineGpuFuzzResult(17) = 0)
	StzEngineGpuFuzzRun(nSeed, 300, 16384 + 64, 0.00001)
	nMut = StzEngineGpuFuzzResult(18)
	nCaught = StzEngineGpuFuzzResult(19)
	? "  slice stride read as the tiles per slice in " + nMut + ", caught " + nCaught
	chk("the control reads each grid's slice stride as the tiles per slice, and all 300 had one", nMut = 300)
	chk("...at least 80% were caught (measured 256 of 300; the 44 escapes are exactly the 44 volumes of ONE slice, where a stride has nothing to separate)", nCaught >= 0.8 * nMut)
	StzEngineGpuFuzzRun(nSeed, 300, 63, 0.00001)
	chk("the six float kinds still agree as before (300, 219 exactly)", StzEngineGpuFuzzResult(5) = 300 and StzEngineGpuFuzzResult(9) = 219)
	? "  (scene 4: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 5: puzzle 19, what changed since the slice before --"
$t0 = clock()
oQ = StzKernelPuzzleQ("kp-19")
chk("the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
chk("the task reads in four languages and ends with what the GPU did differently from a triple loop",
	oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "" and StzFindFirst("differently from a triple loop", oQ.Task("en")) > 0)
cHead = "in a" + NLc + "scalar w" + NLc + "scalar d" + NLc + "scalar p" + NLc + "out c" + NLc + "width w" + NLc + "depth d" + NLc
# the verdicts were worked out from the data (a is i % 13, so a[0] = 0, and the hidden volume is
# 3 slices of 16 x 32, its first cell also 0) before the first run:
#   the row above:    element 33 (row 1, column 0) coincides, a[0] being 0; element 34 is the first wrong one
#   a stride of 1024: right at the shape shown; in the hidden volume (512 a slice) element 513 coincides, 514 does not
#   from slice 2:     element 1025 (slice 1, column 0) coincides; 1026 is the first wrong one
aCases = [
	[ "when(@slice > 0, @a - @a[@i - p], @a)", "verified" ],
	[ "@a - @a[@i - p]", "verified" ],
	[ "@a - when(@slice > 0, @a[@i - p], 0)", "verified" ],
	[ "when(@row > 0, @a - @a[@i - w], @a)", "mismatch at element 34" ],
	[ "when(@slice > 0, @a - @a[@i - 1024], @a)", "mismatch-hidden at element 514" ],
	[ "when(@slice > 1, @a - @a[@i - p], @a)", "mismatch at element 1026" ]
]
nAgree = 0
for aQ in aCases
	cSpec = cHead + "body { @c = " + aQ[1] + " }"
	if bDevice
		cV = oQ.Grade(cSpec)
	else
		cV = oQ.GradeOnCpu(cSpec)
	ok
	chk(aQ[1] + " -> " + aQ[2] + " (" + cV + ")", cV = aQ[2])
	if oQ.GradeOnCpu(cSpec) = aQ[2]
		nAgree++
	ok
next
chk("GradeOnCpu says the same words for all " + len(aCases) + " cases", nAgree = len(aCases))
cV = oQ.Grade("in a" + NLc + "scalar w" + NLc + "scalar d" + NLc + "scalar p" + NLc + "out c" + NLc + "width w" + NLc + "body { @c = when(@slice > 0, @a - @a[@i - p], @a) }")
chk("@slice with no depth line is refused by name (" + cV + ")", StzFindFirst("refused", cV) = 1 and StzFindFirst("needs a depth line", cV) > 0)
if bDevice
	cV = oQ.Grade(cHead + "body { @c = when(@slice > 0, @a - @a[@i - n / d], @a) }")
	cC = oQ.GradeOnCpu(cHead + "body { @c = when(@slice > 0, @a - @a[@i - n / d], @a) }")
	# A DEVICE FACT, kept out of the puzzle's mistakes because it is not the same on every device:
	# the RTX 3050 compiles a float division to a multiplication by a reciprocal and fuses it with the
	# subtraction, so for 1536 / 3 the index @i - n / d lands a hair under the element and reads the one
	# before (mismatch-hidden at element 514); the Intel iGPU divides exactly and verifies. The
	# interpreter divides exactly, so it can never see it -- which is the checker's whole reason to run the device
	? "  (n / d for three slices: device says '" + cV + "', interpreter says '" + cC + "')"
	chk("n / d, the quotient given as a division: the interpreter verifies it, and the device either agrees or the checker names the element where the division was not exact (" + cV + ")",
		cC = "verified" and (cV = "verified" or cV = "mismatch-hidden at element 514"))
	oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/kp-19")
	aPr = oE.ProveItself()
	chk("the exercise proves itself through the System's checker: wrong refused " + aPr[:wrong] + ", right accepted " + aPr[:right] + ", failures " + @@(aPr[:failures]),
		aPr[:wrong] = 5 and aPr[:right] = 3 and len(aPr[:failures]) = 0)
ok
? "  (scene 5: " + ((clock() - $t0) / clockspersecond()) + " s)"

? ""
? "=========================================="
? "TOTAL: " + ($nPass + $nFail) + " assertions, " + $nPass + " pass, " + $nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		$nPass++
		? "  [OK] " + cLabel
	else
		$nFail++
		? "  [FAIL] " + cLabel
	ok

func _Seq nN
	aR = []
	for q = 0 to nN - 1
		aR + q
	next
	return aR
