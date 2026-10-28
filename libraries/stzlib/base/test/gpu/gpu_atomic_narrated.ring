# GL0 -- ATOMICS (SOFTANZA_GPU_PLAN.md, GL0; the reader's account of the
# language is base/gpu/SOFTANZA_GPU_KERNELS.md, 3.1e).
#
# The fifth admission: an output may be counters that many threads write at
# once. 'out h atomic 16' is 16 i32 counters, and the body is
# '@h[index] += value' (or max=, min=). The transpiler writes WGSL's
# atomicAdd / atomicMax / atomicMin into an engine-made array<atomic<i32>>, the
# real i32 buffer the typed-buffer rung left for this one. An index outside
# the counters is dropped. += counters start at 0, max= at the most negative
# int, min= at the most positive; every host fills them so.
#
# Add, max and min on ints give one answer in any order, so the
# interpreter's count is the device's, bit for bit, however the threads
# arrive.
#
# Two defects this rung's own fuzz found, held here by name:
#   - an untyped index was f32, as every index before it, and the device's
#     float '%' gave 55 for some multiples of 55: @h[@i % 55] dropped threads.
#     A counter index that meets no type is an int now
#   - 1i / 0i between two literals is folded by WGSL at compile time and the
#     kernel refused; an int '/' goes through stz_div, as '%' through stz_rem
#
# Run with Ring++: rnxc gpu_atomic_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(3)
NLc = char(10)

? "-- Scene 1: counters many threads add to, in both readers --"
$t0 = clock()
k = new stzKernelMaker
k.TakesVector(:a)
k.ReturnsAtomic(:h, 4)
k.ForEachElement('{ @h[@a] += 1 }')
chk("the declaration reads back as written: 'out h atomic 4'", StzFindFirst("out h atomic 4", k.Spec()) > 0 and StzKernelMakerFromSpec(k.Spec()).Spec() = k.Spec())
chk("...and the output is 4 counters, whatever n is", k.OutputIsAtomic() = 1 and k.OutputLength(1000) = 4)
cW = k.ToWGSL()
chk("the WGSL binds array<atomic<i32>> and adds through atomicAdd, dropping an index outside",
	StzFindFirst("v_h : array<atomic<i32>>;", cW) > 0 and StzFindFirst("if (k_ >= 0 && k_ < 4) { atomicAdd(&v_h[u32(k_)], 1i); }", cW) > 0)
aH = k.EvaluateOn([ :a = [ 0, 1, 1, 3, 5, -1 ] ])
chk("the interpreter counts 0 1 1 3 into 1 2 0 1, and drops 5 and -1", _Same(aH, [ 1, 2, 0, 1 ]))
kM = StzKernelMakerFromSpec("in a int" + NLc + "out m atomic 3" + NLc + "body { @m[@i % 2] max= @a }")
chk("max= keeps the largest; a counter nobody touched holds the most negative int",
	_Same(kM.EvaluateOn([ :a = [ 3, -7, 9, 2 ] ]), [ 9, 2, -2147483648 ]))
kN = StzKernelMakerFromSpec("in a int" + NLc + "out m atomic 2" + NLc + "body { @m[0] min= @a * 2 }")
chk("min= keeps the smallest; an untouched one holds the most positive", _Same(kN.EvaluateOn([ :a = [ 3, -7, 9 ] ]), [ -14, 2147483648 ]))
kW = StzKernelMakerFromSpec("in a int" + NLc + "out h atomic 1" + NLc + "body { @h[0] += 2147483647 }")
chk("the adds wrap, as on every GPU: two threads adding 2147483647 leave -2", _Same(kW.EvaluateOn([ :a = [ 0, 0 ] ]), [ -2 ]))
kI = StzKernelMakerFromSpec("in a" + NLc + "out h atomic 55" + NLc + "body { @h[@i % 55] += 1 }")
chk("an untyped counter index is an int: @i % 55 is written stz_rem(i32(i), 55i), not a float '%'",
	StzFindFirst("i32(stz_rem(i32(i), 55i))", kI.ToWGSL()) > 0)
? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

? ""
? "-- Scene 2: what is refused, in the same words by both readers --"
$t0 = clock()
aRef = [
	[ "a float added to a counter", "in a" + NLc + "out h atomic 4" + NLc + "body { @h[@a] += 0.5 }", "an atomic output holds ints" ],
	[ "a counter assigned whole", "in a" + NLc + "out h atomic 4" + NLc + "body { @h = 1 }", "an atomic output is written '@h[index] += value'" ],
	[ "a counter stored, not added", "in a" + NLc + "out h atomic 4" + NLc + "body { @h[@a] = 1 }", "an atomic output is written" ],
	[ "an index into a plain output", "in a" + NLc + "out c" + NLc + "body { @c[@i] += 1 }", "declare it 'out c atomic SIZE'" ],
	[ "no counters", "in a" + NLc + "out h atomic 0" + NLc + "body { @h[0] += 1 }", "SIZE a whole number from 1 to 65536" ]
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
		StzKernelMakerFromSpec(aQ[2]).EvaluateOn([ :a = [ 1, 2 ] ])
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
	? "-- Scene 3: on the device, every path that makes the counters --"
	$t0 = clock()
	aA = [] aB = []
	for i = 1 to 3000
		aA + ((i * 7) % 5)
		aB + ((i * 37) % 201 - 100)
	next
	aV = oG.VerifySpecWith(k, k, [ :a = aA ], [ :n = 3000 ])
	chk("the checker verifies the histogram at both shapes (" + aV[:verdict] + ")", aV[:verdict] = "verified")
	kS = StzKernelMakerFromSpec("in b int" + NLc + "out h atomic 55" + NLc + "guard { @i < n and @b != 0 }" + NLc + "body { @h[@i % 55] += clamp(@b, -50, 50) }")
	aV = oG.VerifySpecWith(kS, kS, [ :b = aB ], [ :n = 3000 ])
	chk("sums of ints into 55 counters, with a guard: the case the float index lost (" + aV[:verdict] + ")", aV[:verdict] = "verified")
	kX = StzKernelMakerFromSpec("in b int" + NLc + "out m atomic 7" + NLc + "body { @m[@b % 7] max= @b * @b - @i }")
	aV = oG.VerifySpecWith(kX, kX, [ :b = aB ], [ :n = 3000 ])
	chk("max= from 3000 threads, negative indices dropped (" + aV[:verdict] + ")", aV[:verdict] = "verified")
	kD = StzKernelMakerFromSpec("in b int" + NLc + "out h atomic 2" + NLc + "body { @h[0] += 1 / 0 + @b / (@b - @b) }")
	aV = oG.VerifySpecWith(kD, kD, [ :b = aB ], [ :n = 3000 ])
	chk("1 / 0 between literals compiles and gives the dividend, as a runtime zero does (" + aV[:verdict] + ")", aV[:verdict] = "verified")
	aRun = oG.RunQWith(k, [ :a = [ 0, 1, 1, 3, 5, -1 ] ], []).Download()
	chk("RunQWith fills the counters and reads them as ints: " + @@(aRun), _Same(aRun, [ 1, 2, 0, 1 ]))
	aCh = oG.UploadQ([ 3, -7, 9, 2 ]).ApplyQ(kM).Download()
	chk("ApplyQ starts max= counters at the most negative int: " + @@(aCh), _Same(aCh, [ 9, 2, -2147483648 ]))
	bRef = 0
	try
		oG.UploadQ([ 1, 2 ]).ApplyQ(kM).ApplyQ(k)
	catch
		bRef = StzFindFirst("whole-number counters", cCatchError) > 0
	done
	chk("...and refuses to hand counters to the next kernel as floats", bRef)
	? "  (scene 3: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 4: the fuzz's atomic kind, and its control --"
	$t0 = clock()
	nSeed = 20261028
	StzEngineGpuFuzzRun(nSeed, 300, 4096, 0.00001)
	? "  generated " + StzEngineGpuFuzzResult(46) + " atomic kernels; ran " + StzEngineGpuFuzzResult(4) + ", agreed " + StzEngineGpuFuzzResult(5) + " (exact " + StzEngineGpuFuzzResult(9) + ")"
	chk("300 kernels: no split, no compile failure, nothing past the counters",
		StzEngineGpuFuzzResult(46) = 300 and StzEngineGpuFuzzResult(2) = 0 and StzEngineGpuFuzzResult(3) = 0 and StzEngineGpuFuzzResult(7) = 0)
	chk("...and all 300 agree with the interpreter bit for bit, in whatever order the threads arrived",
		StzEngineGpuFuzzResult(5) = 300 and StzEngineGpuFuzzResult(9) = 300 and StzEngineGpuFuzzResult(17) = 0)
	StzEngineGpuFuzzRun(nSeed, 300, 4096 + 64, 0.00001)
	nMut = StzEngineGpuFuzzResult(18)
	nCaught = StzEngineGpuFuzzResult(19)
	? "  operation rotated in " + nMut + ", caught " + nCaught
	chk("the control rotates each kernel's operation (add to max to min to add), and all 300 had one", nMut = 300)
	chk("...at least 80% caught (measured 257 of 300; seven escapes read: every index dropped, or one contribution where the operations agree)", nCaught >= 0.8 * nMut)
	StzEngineGpuFuzzRun(nSeed, 300, 512, 0.00001)
	chk("the int kind, its '/' now through stz_div, still agrees bit for bit (300)", StzEngineGpuFuzzResult(5) = 300 and StzEngineGpuFuzzResult(17) = 0)
	? "  (scene 4: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 5: puzzle 17, count the votes --"
$t0 = clock()
oQ = StzKernelPuzzleQ("kp-17")
chk("the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
chk("the task reads in four languages and ends with what the GPU did differently from a loop",
	oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "" and StzFindFirst("differently from a loop", oQ.Task("en")) > 0)
cHead = "in a" + NLc + "out h atomic 13" + NLc
aCases = [
	[ "@h[@a] += 1", "verified" ],
	[ "@h[int(@a)] += 1", "verified" ],
	[ "@h[@a % 13] += 1", "verified" ],
	[ "@h[@a] += int(@a)", "mismatch at element 1" ],
	[ "@h[@a - 1] += 1", "mismatch at element 5" ],
	[ "@h[@a] max= 1", "mismatch at element 1" ]
]
nAgree = 0
for aQ in aCases
	cSpec = cHead + "body { " + aQ[1] + " }"
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
cV = oQ.Grade(cHead + "body { @h[@a] += 0.5 }")
chk("half a vote is refused by name (" + cV + ")", StzFindFirst("refused", cV) = 1 and StzFindFirst("holds ints", cV) > 0)
if bDevice
	oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/kp-17")
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
