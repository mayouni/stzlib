# KP3 -- THE GROUP'S MEMORY (SOFTANZA_GPU_PLAN.md, KP3).
#
# KP0 stopped the grammar at the reduction a single thread can do. KP3
# admits what a tiled matrix product needs: arrays in the workgroup's
# shared memory, a SCHEDULE of stages (one write per thread, then a
# barrier), reduces (the halving tree, a barrier at each step) and a tiles
# loop with a per-thread accumulator; a width line makes the output a
# matrix worked in 16 x 16 tiles. The transpiler and the interpreter read
# them through one parser and refuse the same things with the same words;
# the interpreter runs a GROUP at a time, every item over all 256 threads
# before the next, which is what the barrier promises the kernel.
#
# What this suite asserts, negative siblings beside each:
#   - on the CPU: each group reversed through a stage; a reduce over a
#     partial last group; the tiled product equal to the plain loop and to
#     a product computed here; six refusals, the same words from both readers
#   - on the device: each form verifies itself at a visible and a hidden
#     shape; a kernel that reads shared memory no stage wrote is a mismatch
#     at element 1 -- it PASSED the visible shape before 2026-10-27, reading
#     the previous kernel's values, until the kernel zeroed its own memory;
#     one tile only is caught; a hidden shape given whole is honoured and a
#     short hidden vector refused
#   - puzzles 9 to 12: every right answer verified, every wrong one named,
#     on the device and the CPU in the same words; each exercise proves
#     itself through the System's checker
#   - the roofline: SAXPY sits under the bandwidth roof and a right answer
#     that rereads memory shows a smaller share of it (measured A B A)
#
# Run with Ring++: rnxc gpu_shared_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0
$t0 = clock()

pr()

decimals(6)
NLc = char(10)

? "-- Scene 0: the group's memory on the CPU, no device --"
$t0 = clock()
kRev = StzKernelMakerQ()
kRev.TakesVector(:a)
kRev.ReturnsVector(:c)
kRev.Shared(:t, 256)
kRev.Stage('{ @t[@l] = @a }')
kRev.ForEachElement('{ @c = @t[255 - @l] }')
aRamp = []
for i = 0 to 511
	aRamp + i
next
aR = kRev.EvaluateOn([ :a = aRamp ])
chk("a stage then a read across the group: element 1 is 255, element 256 is 0, element 257 is 511",
	aR[1] = 255 and aR[256] = 0 and aR[257] = 511)
cW = kRev.ToWGSL()
chk("...the WGSL declares the array in the group's memory", StzFindFirst("var<workgroup> w_t : array<f32, 256>;", cW) > 0)
chk("...zeroes it itself before any stage (WGSL promises it; this machine's runtime did not keep the promise)",
	StzFindFirst("for (var z_ : u32 = l; z_ < 256u; z_ = z_ + 256u) { w_t[z_] = 0.0; }", cW) > 0)
chk("...and waits at a barrier after the stage", StzFindFirst("workgroupBarrier();", cW) > 0)

kSum = StzKernelMakerQ()
kSum.TakesVector(:a)
kSum.ReturnsVector(:c)
kSum.Shared(:t, 256)
kSum.Stage('{ @t[@l] = @a }')
kSum.Reduce(:t, :sum)
kSum.ForEachElement('{ @c = @t[0] }')
aOnes = []
for i = 1 to 300
	aOnes + 1
next
aR = kSum.EvaluateOn([ :a = aOnes ])
chk("a reduce over 300 ones: the first group sums 256, the partial last one 44 (zero past the input)", aR[1] = 256 and aR[300] = 44)

cMm = "in a" + NLc + "in b" + NLc + "scalar k" + NLc + "scalar w" + NLc + "out c" + NLc + "width w" + NLc +
	"shared ta 256" + NLc + "shared tb 256" + NLc + "tiles t { k / 16 }" + NLc +
	"stage { @ta[@ly * 16 + @lx] = @a[@row * k + t * 16 + @lx] }" + NLc +
	"stage { @tb[@ly * 16 + @lx] = @b[(t * 16 + @ly) * w + @col] }" + NLc +
	"accumulate { @acc = @acc + sum(j, 0, 16, @ta[@ly * 16 + j] * @tb[j * 16 + @lx]) }" + NLc + "body { @c = @acc }"
cPl = "in a" + NLc + "in b" + NLc + "scalar k" + NLc + "scalar w" + NLc + "out c" + NLc + "width w" + NLc +
	"body { @c = sum(j, 0, k, @a[@row * k + j] * @b[j * w + @col]) }"
aMa = []
for i = 0 to 2047
	aMa + ((i * 7) % 13)
next
aMb = []
for i = 0 to 3071
	aMb + ((i * 3) % 7)
next
aBm = [ [ "a", aMa ], [ "b", aMb ], [ "k", 64 ], [ "w", 48 ] ]
kT = StzKernelMakerFromSpec(cMm)
aT = kT.EvaluateOnWith(aBm, [ :n = 1536 ])
aP = StzKernelMakerFromSpec(cPl).EvaluateOnWith(aBm, [ :n = 1536 ])
nSame = 0
for i = 1 to 1536
	if aT[i] = aP[i]
		nSame++
	ok
next
chk("the tiled product (32 x 64 times 64 x 48) equals the plain loop in all 1536 cells", nSame = 1536)
nHere = 0
for aCell in [ [ 0, 0 ], [ 17, 33 ], [ 31, 47 ] ]
	nS = 0
	for j = 0 to 63
		nS += aMa[aCell[1] * 64 + j + 1] * aMb[j * 48 + aCell[2] + 1]
	next
	if aT[aCell[1] * 48 + aCell[2] + 1] = nS
		nHere++
	ok
next
chk("...and three cells equal the product computed here, by hand", nHere = 3)

aRef = [
	[ "in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "stage { @t[@l] = @t[@l + 1] }" + NLc + "body { @c = @t[0] }", "cannot read the array it writes" ],
	[ "in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "tiles q { @i }" + NLc + "stage { @t[@l] = @a }" + NLc + "body { @c = @t[0] }", "same for every thread" ],
	[ "in a" + NLc + "out c" + NLc + "body { @c = @a + @row }", "needs a width line" ],
	[ "in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "stage { @t[@l] = @a }" + NLc + "body { @c = @t }", "read one slot" ],
	[ "in a" + NLc + "out c" + NLc + "shared t 300" + NLc + "stage { @t[@l] = @a }" + NLc + "reduce t sum" + NLc + "body { @c = @t[0] }", "power of two" ],
	[ "in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "accumulate { @acc = @a }" + NLc + "body { @c = @acc }", "inside a tiles loop" ]
]
for aCase in aRef
	cT = ""
	try
		StzKernelMakerFromSpec(aCase[1]).ToWGSL()
	catch
		cT = cCatchError
	done
	cE = ""
	try
		StzKernelMakerFromSpec(aCase[1]).EvaluateOn([ :a = [ 1, 2, 3 ] ])
	catch
		cE = cCatchError
	done
	chk("refused by both readers, naming the offender: '" + aCase[2] + "'",
		StzFindFirst(aCase[2], cT) > 0 and StzFindFirst(aCase[2], cE) > 0)
next
? "  (scene 0: " + ((clock() - $t0) / clockspersecond()) + " s)"

bDevice = (StzEngineGpuInit($cStzGpuRuntime) != 0 and StzEngineGpuIsAvailable() != 0)
if bDevice
	? ""
	? "-- Scene 1: the same forms on the device, at a visible and a hidden shape --"
	$t0 = clock()
	oG = new stzGpu
	aRamp = []
	for i = 0 to 4095
		aRamp + i
	next
	aV = oG.VerifySpecWith(kRev, kRev, [ [ "a", aRamp ] ], [ :n = 4096 ])
	chk("each group reversed verifies itself (hidden shape " + aV[:hiddensize] + ", its last group partial)", aV[:verdict] = "verified")
	kNo = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "body { @c = @t[255 - @l] }")
	aV = oG.VerifySpecWith(kRev, kRev, [ [ "a", aRamp ] ], [ :n = 4096 ])
	aV = oG.VerifySpecWith(kRev, kNo, [ [ "a", aRamp ] ], [ :n = 4096 ])
	chk("a kernel reading memory no stage wrote is a mismatch at element 1, right after a kernel that filled it (it passed before the zeroing)",
		aV[:verdict] = "mismatch" and aV[:firstbad] = 1)
	aTen = []
	for i = 0 to 4095
		aTen + ((i % 10) / 10.0)
	next
	aV = oG.VerifySpecWith(kSum, kSum, [ [ "a", aTen ] ], [ :n = 4096 ])
	chk("a reduce verifies itself", aV[:verdict] = "verified")
	cSm = "in a" + NLc + "out c" + NLc + "shared m 256" + NLc + "shared s 256" + NLc + "stage { @m[@l] = @a }" + NLc + "reduce m max" + NLc +
		"stage { @s[@l] = exp(@a - @m[0]) }" + NLc + "reduce s sum" + NLc + "body { @c = exp(@a - @m[0]) / @s[0] }"
	kSm = StzKernelMakerFromSpec(cSm)
	aV = oG.VerifySpecWith(kSm, kSm, [ [ "a", aTen ] ], [ :n = 4096 ])
	chk("softmax verifies itself, the device's exp within " + (aV[:maxdiff] * 1000000000) + " billionths of the CPU's (measured 0.47 on 2026-10-27)",
		aV[:verdict] = "verified" and aV[:maxdiff] < 0.00000001)
	aMa16 = []
	for i = 1279 to 0 step -1
		aMa16 + ((i * 7) % 13)
	next
	aMb16 = []
	for i = 2559 to 0 step -1
		aMb16 + ((i * 3) % 7)
	next
	aHm = [ [ "a", aMa16 ], [ "b", aMb16 ], [ "k", 80 ], [ "w", 32 ] ]
	aV = oG.VerifySpecWith(kT, kT, aBm, [ :n = 1536, :hidden = [ :n = 512, :bindings = aHm ] ])
	chk("the tiled product verifies itself, its hidden shape another matrix (16 x 80 times 80 x 32)", aV[:verdict] = "verified" and aV[:hiddensize] = 512)
	aV = oG.VerifySpecWith(kT, StzKernelMakerFromSpec(cPl), aBm, [ :n = 1536, :hidden = [ :n = 512, :bindings = aHm ] ])
	chk("...the plain loop is right too", aV[:verdict] = "verified")
	aV = oG.VerifySpecWith(kT, StzKernelMakerFromSpec(StzReplace(cMm, "tiles t { k / 16 }", "tiles t { 1 }")), aBm, [ :n = 1536, :hidden = [ :n = 512, :bindings = aHm ] ])
	chk("...one tile only is a mismatch at element 1", aV[:verdict] = "mismatch" and aV[:firstbad] = 1)
	cWhy = ""
	try
		oG.VerifySpecWith(kT, kT, aBm, [ :n = 1536, :hidden = [ :n = 512, :bindings = [ [ "a", [ 1, 2, 3 ] ], [ "b", aMb16 ], [ "k", 80 ], [ "w", 32 ] ] ] ])
	catch
		cWhy = cCatchError
	done
	chk("...a hidden vector shorter than the hidden n is refused, saying so", StzFindFirst("fewer than the hidden n = 512", cWhy) > 0)
	? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 2: puzzles 9 to 12 -- each right answer verified, each wrong answer named, each exercise proving itself --"
$t0 = clock()
cMmHead = "in a" + NLc + "in b" + NLc + "scalar k" + NLc + "scalar w" + NLc + "out c" + NLc + "width w" + NLc
aCases = [
	[ "kp-09", "in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "stage { @t[@l] = @a }" + NLc + "body { @c = @t[255 - @l] }", "verified" ],
	[ "kp-09", "in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "stage { @t[255 - @l] = @a }" + NLc + "body { @c = @t[@l] }", "verified" ],
	[ "kp-09", "in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "body { @c = @t[255 - @l] }", "mismatch at element 1" ],
	[ "kp-09", "in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "body { @c = @a[n - 1 - @i] }", "mismatch at element 1" ],
	[ "kp-10", cMm, "verified" ],
	[ "kp-10", cPl, "verified" ],
	[ "kp-10", StzReplace(cMm, "tiles t { k / 16 }", "tiles t { 1 }"), "mismatch at element 1" ],
	[ "kp-10", StzReplace(cMm, "@b[(t * 16 + @ly) * w + @col]", "@b[(t * 16 + @lx) * w + @col]"), "mismatch at element 1" ],
	[ "kp-11", cSm, "verified" ],
	[ "kp-11", "in a" + NLc + "out c" + NLc + "shared m 256" + NLc + "shared s 256" + NLc + "stage { @s[@l] = exp(@a) }" + NLc + "reduce s sum" + NLc + "body { @c = exp(@a) / @s[0] }", "verified" ],
	[ "kp-11", StzReplace(cSm, "body { @c = exp(@a - @m[0]) / @s[0] }", "body { @c = exp(@a - @m[0]) }"), "mismatch at element 1" ],
	[ "kp-11", StzReplace(cSm, "/ @s[0] }", "/ @s[@l] }"), "mismatch at element 2" ],
	[ "kp-12", "in a" + NLc + "in b" + NLc + "scalar alpha" + NLc + "out c" + NLc + "body { @c = alpha * @a + @b }", "verified" ],
	[ "kp-12", "in a" + NLc + "in b" + NLc + "scalar alpha" + NLc + "out c" + NLc + "body { @c = alpha * @a + @b + 0 * sum(k, 0, 64, @a[k]) }", "verified" ],
	[ "kp-12", "in a" + NLc + "in b" + NLc + "scalar alpha" + NLc + "out c" + NLc + "body { @c = @a + @b }", "mismatch at element 2" ],
	[ "kp-12", "in a" + NLc + "in b" + NLc + "scalar alpha" + NLc + "out c" + NLc + "body { @c = alpha * (@a + @b) }", "mismatch at element 2" ]
]
acPuzzles = [ "kp-09", "kp-10", "kp-11", "kp-12" ]
for cId in acPuzzles
	oQ = StzKernelPuzzleQ(cId)
	chk(cId + ": the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
	chk(cId + ": the task reads in four languages and ends with what the GPU did differently from a loop",
		oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "" and StzFindFirst("differently from a loop", oQ.Task("en")) > 0)
next
nAgree = 0
for aCase in aCases
	oQ = StzKernelPuzzleQ(aCase[1])
	if bDevice
		cV = oQ.Grade(aCase[2])
	else
		cV = oQ.GradeOnCpu(aCase[2])
	ok
	acL = StzSplit(aCase[2], NLc)
	chk(aCase[1] + " " + acL[len(acL)] + " -> " + aCase[3], cV = aCase[3])
	if oQ.GradeOnCpu(aCase[2]) = aCase[3]
		nAgree++
	ok
next
chk("GradeOnCpu says the same words for all " + len(aCases) + " cases", nAgree = len(aCases))
if bDevice
	? "  each exercise proves itself through the System's checker, by running its programs:"
	for cId in acPuzzles
		oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/" + cId)
		aPr = oE.ProveItself()
		chk(cId + ": wrong refused " + aPr[:wrong] + ", right accepted " + aPr[:right] + ", failures " + @@(aPr[:failures]),
			aPr[:wrong] = 3 and aPr[:right] = 2 and len(aPr[:failures]) = 0)
	next
ok
? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

if bDevice
	? ""
	? "-- Scene 3: the roofline -- a kernel under this device's two roofs, A B A --"
	$t0 = clock()
	oQ = StzKernelPuzzleQ("kp-12")
	cSax = oQ.Reference()
	cExtra = "in a" + NLc + "in b" + NLc + "scalar alpha" + NLc + "out c" + NLc + "body { @c = alpha * @a + @b + 0 * sum(k, 0, 64, @a[k]) }"
	aA1 = oQ.Roofline(cSax)
	aB1 = oQ.Roofline(cExtra)
	aA2 = oQ.Roofline(cSax)
	? "  SAXPY " + aA1[:ms] + " ms (" + aA1[:bandwidthfraction] + " of the copy roof), with the extra reads " + aB1[:ms] + " ms (" + aB1[:bandwidthfraction] + "), SAXPY again " + aA2[:ms] + " ms (" + aA2[:bandwidthfraction] + ")"
	chk("SAXPY is under the bandwidth roof: 0.17 operations per byte", aA1[:bound] = "memory")
	chk("...it moves its 48 MB at a sane share of the copy roof (0.3 to 8: a cache may beat DRAM, nothing beats it eightfold)",
		aA1[:bandwidthfraction] > 0.3 and aA1[:bandwidthfraction] < 8)
	chk("...and uses a vanishing share of the compute roof (under 5%)", aA1[:peakfraction] < 0.05)
	nFast = aA1[:ms]
	if aA2[:ms] < nFast
		nFast = aA2[:ms]
	ok
	chk("a right answer that rereads memory is slower than both SAXPY runs around it, by over 1.3x (measured 1.9x on 2026-10-27)",
		aB1[:ms] > 1.3 * aA1[:ms] and aB1[:ms] > 1.3 * aA2[:ms])
	chk("...the roofline of a wrong description is its refusal, not a number", isString(oQ.Roofline("in a" + NLc + "out c" + NLc + "body { @c = @z }")))
	? "  (scene 3: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 4: the browser runner speaks the same schedule --"
cPage = read("../../education/program/courses/kernel-puzzles/runner/puzzle.html")
chk("the page reads a declared hidden shape and the band from the facts",
	StzFindFirst("hidden-elements", cPage) > 0 and StzFindFirst("hidden-scalar-", cPage) > 0 and StzFindFirst(char(34) + "band" + char(34), cPage) > 0)
chk("...measures its roofs with the engine's own kernels (stz.wasm carries them), timed in batches",
	StzFindFirst("stz_gpu_roof_wgsl", cPage) > 0 and StzFindFirst("BATCH", cPage) > 0)
chk("...and checks every allocation in the engine's memory (0 is no room; it wrote at address 0 until 2026-10-27)",
	StzFindFirst("the engine's memory refused", cPage) > 0)

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
