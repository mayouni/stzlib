# GL0 -- THE CONDITIONAL VALUE (SOFTANZA_GPU_PLAN.md, GL0; the reader's
# account of the language is base/gpu/SOFTANZA_GPU_KERNELS.md, 3.1).
#
# The kernel language grows one admission at a time, each with a puzzle, a
# refusal list and both readers agreeing. The first is a choice between two
# values:
#
#     when(condition, value if true, value if false)
#
# The transpiler writes it as WGSL's select, whose FALSE value comes first:
# select(f, t, c). The order is written once, in the rewriter, and the
# random-kernel fuzz's SWAP control proves that a swapped pair would be
# caught: it exchanges the two values in each generated kernel's WGSL and
# counts the kernels the run then judges defective. The interpreter jumps
# over the value it does not choose; neither value has a side effect, so the
# result is the device's.
#
# A condition's SHAPE is read from its source once, by both readers, before
# either compiles it: comparisons between values, joined by and / or, grouped
# by parentheses. That closed four holes the guard line had since KP0 -- a
# bare value as a guard, a comparison used as a number -- which reached the
# device and failed there in naga's words. They are refused here in the
# learner's.
#
# Run with Ring++: rnxc gpu_when_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(6)
NLc = char(10)

? "-- Scene 1: one value in both readers --"
$t0 = clock()
kRelu = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "body { @c = when(@a > 0, @a, 0) }")
cW = kRelu.ToWGSL()
chk("the transpiler writes when as select, the value if FALSE first: select((0f), (v_a[i]), (v_a[i] > 0f))",
	StzFindFirst("select((0f), (v_a[i]), (v_a[i] > 0f))", cW) > 0)
aR = kRelu.EvaluateOn([ :a = [ -2, -0.5, 0, 0.5, 3 ] ])
chk("the interpreter: -2 -0.5 0 0.5 3 give 0 0 0 0.5 3", aR[1] = 0 and aR[2] = 0 and aR[3] = 0 and aR[4] = 0.5 and aR[5] = 3)
kDeep = StzKernelMakerFromSpec("in a" + NLc + "scalar s" + NLc + "out c" + NLc +
	"body { @c = when(@a < s or (@i > 2 and @a > 2), when(@a < -1, -1, @a[@i + 1]), sum(k, 0, 3, @a[k])) }")
aD = kDeep.EvaluateOn([ :a = [ -2, -0.5, 0, 0.5, 3 ], :s = 0 ])
chk("nested, joined by or and and, a neighbour and a sum among its values: -1 0 -2.5 -2.5 0",
	aD[1] = -1 and aD[2] = 0 and aD[3] = -2.5 and aD[4] = -2.5 and aD[5] = 0)
kG = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "guard { @i < n and when(@a > 0, @a, -@a) > 1 }" + NLc + "body { @c = 1 }")
aG = kG.EvaluateOnWith([ :a = [ -2, -0.5, 0, 0.5, 3 ] ], [ :n = 5 ])
chk("inside a guard's comparison: |a| > 1 writes elements 1 and 5 and leaves the others unwritten",
	aG[1] = 1 and aG[5] = 1 and aG[2] != aG[2] and aG[3] != aG[3] and aG[4] != aG[4])
? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

? ""
? "-- Scene 2: what is refused, in the same words by both readers --"
$t0 = clock()
aRef = [
	[ "a number where the condition goes", "body { @c = when(@a, 1, 0) }", "a bare value is not a condition" ],
	[ "two arguments", "body { @c = when(@a > 0, 1) }", "when takes 3 arguments" ],
	[ "a comparison as a value", "body { @c = when(@a > 0, @a > 1, 0) }", "is a comparison" ],
	[ "a comparison used as a number", "body { @c = @a + (@a > 0) * 2 }", "is a comparison" ],
	[ "a chain of comparisons", "body { @c = when(0 < @a < 2, 1, 0) }", "a condition compares values" ],
	[ "and beside or", "body { @c = when(@a > 0 and @a < 1 or @a > 5, 1, 0) }", "need parentheses" ],
	[ "a when as a condition", "body { @c = when(when(@a > 0, 1, 0), 1, 0) }", "a bare value is not a condition" ],
	[ "a guard that is a value (KP0's hole)", "guard { @a }" + NLc + "body { @c = 1 }", "a bare value is not a condition" ],
	[ "a guard joined to a value (KP0's hole)", "guard { @i < n and @a }" + NLc + "body { @c = 1 }", "a bare value is not a condition" ],
	[ "a comparison inside a guard's function (KP0's hole)", "guard { max(@a < 0, 1) > 0 }" + NLc + "body { @c = 1 }", "a comparison is not a value" ],
	[ "a guard multiplying a comparison (KP0's hole)", "guard { (@i < n) * 2 > 0 }" + NLc + "body { @c = 1 }", "a comparison is not a value" ]
]
nRef = len(aRef)
for q = 1 to nRef
	cSpec = "in a" + NLc + "out c" + NLc + aRef[q][2]
	cT = ""
	try
		StzKernelMakerFromSpec(cSpec).ToWGSL()
	catch
		cT = cCatchError
	done
	cI = ""
	try
		StzKernelMakerFromSpec(cSpec).EvaluateOn([ :a = [ 1, 2 ] ])
	catch
		cI = cCatchError
	done
	chk(aRef[q][1] + ": both readers refuse it with '" + aRef[q][3] + "'",
		StzFindFirst(aRef[q][3], cT) > 0 and StzFindFirst(aRef[q][3], cI) > 0)
next
aOk = [
	"guard { (@i < n) }" + NLc + "body { @c = 1 }",
	"guard { (@a + 1) * 2 > 0 and @i < n }" + NLc + "body { @c = 1 }",
	"body { @c = when((@a > 0), 1, 0) + when(@a <= 0, 2, 3) }"
]
nOk = 0
for cBody in aOk
	cSpec = "in a" + NLc + "out c" + NLc + cBody
	try
		StzKernelMakerFromSpec(cSpec).ToWGSL()
		StzKernelMakerFromSpec(cSpec).EvaluateOnWith([ :a = [ 1, 2 ] ], [ :n = 2 ])
		nOk++
	catch
		? "  refused: " + cBody + " -- " + cCatchError
	done
next
chk("the shapes a condition may take are admitted by both: a parenthesised guard, arithmetic in a comparison, two whens added", nOk = 3)
? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

oG = new stzGpu
bDevice = oG.IsAvailable()
if bDevice
	? ""
	? "-- Scene 3: on the device --"
	$t0 = clock()
	aA = []
	for i = 1 to 3000
		aA + ((((i * 7) % 33) - 16) / 8)
	next
	aKs = [ [ "the ReLU", kRelu ], [ "the nested when", kDeep ], [ "a when inside a guard", kG ] ]
	nKs = len(aKs)
	for q = 1 to nKs
		aV = oG.VerifySpecWith(aKs[q][2], aKs[q][2], [ :a = aA, :s = 0.5 ], [ :n = 2000 ])
		chk(aKs[q][1] + ": the kernel compiles and agrees with the interpreter (" + aV[:verdict] + ", maxdiff " + aV[:maxdiff] + ")",
			aV[:verdict] = "verified")
	next
	? "  (scene 3: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 4: the fuzz writes when, and the SWAP control --"
	$t0 = clock()
	nSeed = 20261028
	StzEngineGpuFuzzRun(nSeed, 300, 63, 0.00001)
	? "  generated " + StzEngineGpuFuzzResult(0) + ", " + StzEngineGpuFuzzResult(26) + " holding a when; agreed " + StzEngineGpuFuzzResult(5) + " (exact " + StzEngineGpuFuzzResult(9) + ")"
	chk("over thirty of 300 generated kernels hold a when", StzEngineGpuFuzzResult(26) > 30)
	chk("no admission split, no compile failure, and all 300 agree", StzEngineGpuFuzzResult(2) = 0 and StzEngineGpuFuzzResult(3) = 0 and StzEngineGpuFuzzResult(5) = 300 and StzEngineGpuFuzzResult(17) = 0)
	StzEngineGpuFuzzRun(nSeed, 300, 63 + 256, 0.00001)
	nMut = StzEngineGpuFuzzResult(18)
	nCaught = StzEngineGpuFuzzResult(19)
	? "  swapped " + nMut + ", caught " + nCaught
	chk("SWAP: over twenty kernels had a select in their store to swap", nMut > 20)
	chk("...and at least 85% were caught (measured 28 of 32 on 2026-10-28; the four escapes were read: a guard that writes nothing, a when times tanh(0), and two whose values are one text)",
		nCaught >= 0.85 * nMut)
	? "  (scene 4: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 5: puzzle 13, two prices --"
$t0 = clock()
oQ = StzKernelPuzzleQ("kp-13")
chk("the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
chk("the task reads in four languages and ends with what the GPU did differently from a loop",
	oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "" and StzFindFirst("differently from a loop", oQ.Task("en")) > 0)
cHead = "in a" + NLc + "scalar t" + NLc + "out c" + NLc
aCases = [
	[ "when(@a <= t, @a, t + 2 * (@a - t))", "verified" ],
	[ "@a + max(@a - t, 0)", "verified" ],
	[ "when(@a < t, @a, t + 2 * (@a - t))", "verified" ],
	[ "when(@a <= t, t + 2 * (@a - t), @a)", "mismatch at element 1" ],
	[ "when(@a <= t, @a, 2 * (@a - t))", "mismatch at element 2" ]
]
nAgree = 0
for aCase in aCases
	cSpec = cHead + "body { @c = " + aCase[1] + " }"
	if bDevice
		cV = oQ.Grade(cSpec)
	else
		cV = oQ.GradeOnCpu(cSpec)
	ok
	chk(aCase[1] + " -> " + aCase[2] + " (" + cV + ")", cV = aCase[2])
	if oQ.GradeOnCpu(cSpec) = aCase[2]
		nAgree++
	ok
next
chk("GradeOnCpu says the same words for all " + len(aCases) + " cases", nAgree = len(aCases))
cV = oQ.Grade(cHead + "body { @c = when(@a - t, @a, t + 2 * (@a - t)) }")
chk("a number where the condition goes is refused by name (" + cV + ")", StzFindFirst("refused", cV) = 1 and StzFindFirst("not a condition", cV) > 0)
cV = oQ.Grade(cHead + "body { @c = @a + (@a > t) * (@a - t) }")
chk("a comparison used as 0 or 1 is refused by name (" + cV + ")", StzFindFirst("refused", cV) = 1 and StzFindFirst("is a comparison", cV) > 0)
if bDevice
	oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/kp-13")
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
