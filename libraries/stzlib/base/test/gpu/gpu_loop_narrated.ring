# GL0 -- THE BOUNDED LOOP (SOFTANZA_GPU_PLAN.md, GL0; the reader's account of
# the language is base/gpu/SOFTANZA_GPU_KERNELS.md, 3.1f).
#
# The sixth admission: iterate(k, from, to, s, init, step) and, to stop early,
# iterate(k, from, to, s, init, step, stop). A STATE s starts at init; on each
# pass k counts up from `from` and s becomes step; the value is the state at
# the end, or at the pass whose stop held. The state is a float, an int
# (written int(1)) or a vector. sum(k, a, b, e) is the special case
# iterate(k, a, b, s, 0, s + e). A loop runs at most 4096 times -- the trip
# count is to - from, wrapping as an i32, clamped to 0 .. 4096 -- so a kernel
# always ends, and a literal span past the cap is refused by name. One level:
# no loop inside a loop.
#
# Both readers read it as typed recursive descents with the same checks run
# first by shared code (iterCheck), so they refuse in the same order and the
# same words; the transpiler writes a prelude (var, for, break) and the
# interpreter five ops (it_begin, it_upd, it_end, it_k, it_s) over a frame
# that keeps the counter, the passes left and up to four state words.
#
# Run with Ring++: rnxc gpu_loop_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(4)
NLc = char(10)

? "-- Scene 1: a state, a stop, and sum as a special case, in both readers --"
$t0 = clock()
kCol = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "body { @c = iterate(k, 0, 200, s, vec2(@a, 0), vec2(when(s.x % 2 == 0, s.x / 2, 3 * s.x + 1), s.y + 1), s.x == 1).y }")
cW = kCol.ToWGSL()
chk("the transpiler declares the state, runs at most 4096 passes, and breaks when the stop holds",
	StzFindFirst("var it0 : vec2<f32> = vec2<f32>(v_a[i], 0f);", cW) > 0 and StzFindFirst("clamp(i32(200i) - f_, 0i, 4096i)", cW) > 0 and StzFindFirst("if (it0.x == 1f) { break; }", cW) > 0)
aC = kCol.EvaluateOn([ :a = [ 6, 1, 27 ] ])
chk("Collatz with a vec2 state (the value, the passes): 6 takes 8 passes, 1 takes 3, 27 takes 111", aC[1] = 8 and aC[2] = 3 and aC[3] = 111)
kS1 = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "body { @c = iterate(k, 0, 5, s, 0, s + k * 2) + @a * 0 }")
kS2 = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "body { @c = sum(k, 0, 5, k * 2) + @a * 0 }")
chk("sum is the special case: iterate(k, 0, 5, s, 0, s + k * 2) and sum(k, 0, 5, k * 2) both give 20",
	kS1.EvaluateOn([ :a = [ 1 ] ])[1] = 20 and kS2.EvaluateOn([ :a = [ 1 ] ])[1] = 20)
kE = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "body { @c = iterate(k, 5, 5, s, 7, s + 1) + iterate(k, 5, 2, t, 100, t + 1) + @a * 0 }")
chk("an empty range and a backwards one leave the init: 7 + 100", kE.EvaluateOn([ :a = [ 1 ] ])[1] = 107)
kF = StzKernelMakerFromSpec("in a" + NLc + "out c int" + NLc + "body { @c = iterate(k, 1, 6, s, int(1), s * k) + int(@a) * 0 }")
chk("an int state, written int(1): a factorial, whole, 5! = 120", kF.EvaluateOn([ :a = [ 0 ] ])[1] = 120)
kKf = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "body { @c = iterate(k, 0, 4, s, 0, s + k / 2) + @a * 0 }")
kKi = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "body { @c = float(iterate(k, 0, 4, s, int(0), s + k / 2)) + @a * 0 }")
chk("the variable takes the state's type: float k / 2 adds 0 .5 1 1.5 = 3, int k / 2 adds 0 0 1 1 = 2",
	kKf.EvaluateOn([ :a = [ 0 ] ])[1] = 3 and kKi.EvaluateOn([ :a = [ 0 ] ])[1] = 2)
kCap = StzKernelMakerFromSpec("in a int" + NLc + "out c" + NLc + "body { @c = iterate(k, 0, @a, s, 0, s + 1) }")
chk("a data-dependent bound is clamped to the cap, and a negative one runs nothing: 5 5000 -3 give 5 4096 0",
	_Same(kCap.EvaluateOn([ :a = [ 5, 5000, -3 ] ]), [ 5, 4096, 0 ]))
? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

? ""
? "-- Scene 2: what is refused, in the same words by both readers --"
$t0 = clock()
aRef = [
	[ "too few arguments", "body { @c = iterate(k, 0, 5, s, 0) }", "iterate takes 6 or 7 arguments" ],
	[ "one name twice", "body { @c = iterate(k, 0, 5, k, 0, k) }", "need two names, and 'k' is both" ],
	[ "a variable that is an input", "body { @c = iterate(a, 0, 5, s, 0, s) }", "iterate's variable 'a' is already a name here" ],
	[ "a state that is the element index", "body { @c = iterate(k, 0, 5, i, 0, i) }", "iterate's state 'i' is already a name here" ],
	[ "a literal span past the cap", "body { @c = iterate(k, 0, 5000, s, 0, s + 1) }", "a loop runs at most 4096 times; from 0 to 5000 asks for 5000" ],
	[ "a sum inside a loop", "body { @c = iterate(k, 0, 3, s, 0, s + sum(j, 0, 2, j)) }", "a loop inside a loop is not admitted" ],
	[ "a loop inside a sum", "body { @c = sum(j, 0, 3, iterate(k, 0, 2, s, 0, s + 1)) }", "a loop inside a loop is not admitted" ],
	[ "a step of another type", "body { @c = iterate(k, 0, 3, s, 0, vec2(1, 2)) }", "the loop's state is a float, and its step gives a vec2" ],
	[ "a stop that is a number", "body { @c = iterate(k, 0, 3, s, 0, s + 1, s) }", "a bare value is not a condition" ],
	[ "a vector as a bound", "body { @c = iterate(k, vec2(0, 1), 3, s, 0, s + 1) }", "a vector stands where a number is needed" ],
	[ "a comparison as a step", "body { @c = iterate(k, 0, 3, s, 0, s > 1) }", "is a comparison" ],
	[ "the variable after the loop", "body { @c = iterate(k, 0, 3, s, 0, s + 1) + k }", "unknown name 'k'" ],
	[ "the state after the loop", "body { @c = iterate(k, 0, 3, s, 0, s + 1) + s }", "unknown name 's'" ]
]
for aQ in aRef
	cSpec = "in a" + NLc + "out c" + NLc + aQ[2]
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
	chk(aQ[1] + ": both readers refuse it with '" + aQ[3] + "'", StzFindFirst(aQ[3], cT) > 0 and cT = cI)
next
? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

oG = new stzGpu
bDevice = oG.IsAvailable()
if bDevice
	? ""
	? "-- Scene 3: on the device --"
	$t0 = clock()
	aA = [] aB = []
	for i = 1 to 3000
		aA + ((((i * 7) % 33) - 16) / 8)
		aB + ((i * 37) % 201 - 100)
	next
	aCases = [
		[ "Collatz with a vec2 state and a stop", kCol, [ :a = _Ramp(3000, 1) ] ],
		[ "an int state through a wrapping recurrence", StzKernelMakerFromSpec("in b int" + NLc + "out c int" + NLc + "body { @c = iterate(k, 0, (abs(@b) % 9 + 4), s, int(@b), s * 1103515245 + 12345, s % 7 == 0) }"), [ :b = aB ] ],
		[ "a data-dependent bound, some empty", StzKernelMakerFromSpec("in a" + NLc + "in b int" + NLc + "out c" + NLc + "body { @c = iterate(k, 0, @b % 25, s, @a, max(s, k - @a), s > 12) }"), [ :a = aA, :b = aB ] ],
		[ "a vec2 state, fibonacci with a stop", StzKernelMakerFromSpec("in b int" + NLc + "out c" + NLc + "body { @c = iterate(k, 0, (@b % 12 + 14), s, vec2(0, 1), vec2(s.y, s.x + s.y), s.x > 50).y }"), [ :b = aB ] ],
		[ "a loop in a guard", StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "guard { @i < n and iterate(k, 0, 3, s, 0, s + @a) > 0 }" + NLc + "body { @c = @a }"), [ :a = aA ] ],
		[ "a stopping loop in a stage, before the barrier", StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "stage { @t[@l] = iterate(k, 0, 8, s, @a, s * 0.5 + 1, s < 1.5) }" + NLc + "reduce t sum" + NLc + "body { @c = @t[0] }"), [ :a = aA ] ]
	]
	for aQ in aCases
		aV = oG.VerifySpecWith(aQ[2], aQ[2], aQ[3], [ :n = 2000 ])
		chk(aQ[1] + ": the kernel compiles and agrees with the interpreter (" + aV[:verdict] + ", maxdiff " + aV[:maxdiff] + ")", aV[:verdict] = "verified")
	next
	? "  (scene 3: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 4: the fuzz's loop kind, and its control --"
	$t0 = clock()
	nSeed = 20261028
	StzEngineGpuFuzzRun(nSeed, 300, 8192, 0.00001)
	? "  generated " + StzEngineGpuFuzzResult(48) + " loop kernels; ran " + StzEngineGpuFuzzResult(4) + ", agreed " + StzEngineGpuFuzzResult(5) + " (exact " + StzEngineGpuFuzzResult(9) + ")"
	chk("300 kernels: none refused by both readers, no split, no compile failure",
		StzEngineGpuFuzzResult(48) = 300 and StzEngineGpuFuzzResult(1) = 0 and StzEngineGpuFuzzResult(2) = 0 and StzEngineGpuFuzzResult(3) = 0)
	chk("...all 300 agree with the interpreter bit for bit, float, int and vector states, with and without a stop",
		StzEngineGpuFuzzResult(5) = 300 and StzEngineGpuFuzzResult(9) = 300 and StzEngineGpuFuzzResult(17) = 0)
	StzEngineGpuFuzzRun(nSeed, 300, 8192 + 64, 0.00001)
	nMut = StzEngineGpuFuzzResult(18)
	nCaught = StzEngineGpuFuzzResult(19)
	? "  step operator flipped in " + nMut + ", caught " + nCaught
	chk("the control flips each loop's step operator, and all 300 had one", nMut = 300)
	chk("...at least 80% were caught (measured 254 of 300; twelve of the 46 escapes read: loops that run no pass, a component the flip never reaches, a fibonacci whose signs alternate back)", nCaught >= 0.8 * nMut)
	StzEngineGpuFuzzRun(nSeed, 300, 63, 0.00001)
	chk("the six float kinds still agree as before (300, 219 exactly)", StzEngineGpuFuzzResult(5) = 300 and StzEngineGpuFuzzResult(9) = 219)
	? "  (scene 4: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 5: puzzle 18, round up to a power of two --"
$t0 = clock()
oQ = StzKernelPuzzleQ("kp-18")
chk("the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
chk("the task reads in four languages and ends with what the GPU did differently from a loop",
	oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "" and StzFindFirst("differently from a loop", oQ.Task("en")) > 0)
cHead = "in a" + NLc + "out c" + NLc
# the verdicts were worked out from the data (a runs 0, 1, 2 ... 3999) before the first run:
#   s > a:      element 2 (a = 1) gets 2, not 1
#   start at 1: element 1 (a = 0) gets 2, not 1
#   8 passes:   the largest state is 128, so a = 129 (element 130) is the first wrong one
aCases = [
	[ "iterate(k, 0, 40, s, 0.5, s * 2, s >= @a)", "verified" ],
	[ "iterate(k, 0, 13, s, 1, when(s >= @a, s, s * 2))", "verified" ],
	[ "float(iterate(k, 0, 13, s, int(1), when(s < int(@a), s * 2, s)))", "verified" ],
	[ "iterate(k, 0, 40, s, 0.5, s * 2, s > @a)", "mismatch at element 2" ],
	[ "iterate(k, 0, 40, s, 1, s * 2, s >= @a)", "mismatch at element 1" ],
	[ "iterate(k, 0, 8, s, 0.5, s * 2, s >= @a)", "mismatch at element 130" ]
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
cV = oQ.Grade(cHead + "body { @c = iterate(k, 0, 40, s, 0.5, s * 2, s) }")
chk("a stop that is a number is refused by name (" + cV + ")", StzFindFirst("refused", cV) = 1 and StzFindFirst("not a condition", cV) > 0)
if bDevice
	oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/kp-18")
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

func _Ramp nN, nFrom
	aR = []
	for q = 0 to nN - 1
		aR + (nFrom + q % 40)
	next
	return aR
