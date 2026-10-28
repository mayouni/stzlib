# GL0 -- WHOLE NUMBERS (SOFTANZA_GPU_PLAN.md, GL0; the reader's account of
# the language is base/gpu/SOFTANZA_GPU_KERNELS.md, 3.1).
#
# The second admission: a value is an f32, an i32 or a truth value. A
# declaration says which ('in a int', 'scalar k int', 'out c int'). A whole
# number with no decimal point, and the counting names (@i, n, @l, @g ...),
# take the type of the value they meet, and are f32 when they meet none,
# which is what every description before GL0 meant. An int and a float never
# meet without int(...) or float(...).
#
# Both readers were rebuilt as typed recursive descents. The transpiler wrote
# the same WGSL, byte for byte, for 18,000 generated kernels before and after.
#
# Two defects the device showed, held here by name:
#   - the RTX 3050's compiler (wgpu-native 29) takes an i32 '%' as UNSIGNED:
#     -7 % 4 was 1 there, -3 in WGSL. So the transpiler writes every int
#     remainder out itself (stz_rem: a - (a / b) * b), never WGSL's '%'
#   - a sum in a GUARD had its loop written inside the guard's own if, after
#     the guard read it: the device refused every such kernel since KP0. The
#     int fuzz found it on its first run
# And one meaning measured rather than assumed: int() of a value past i32
# saturates at 2147483520, the largest f32 below 2^31, and NaN reads as the
# most negative int. The interpreter follows the device.
#
# Run with Ring++: rnxc gpu_int_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(3)
NLc = char(10)

? "-- Scene 1: an int is declared, and a whole number takes its partner's type --"
$t0 = clock()
kAr = StzKernelMakerFromSpec("in a int" + NLc + "scalar k int" + NLc + "out c int" + NLc + "body { @c = (@a * 3 + k) / 2 - @a % 4 }")
cW = kAr.ToWGSL()
chk("the declarations read back as written: Spec() is 'in a int', 'scalar k int', 'out c int'",
	StzFindFirst("in a int", kAr.Spec()) = 1 and StzFindFirst("scalar k int", kAr.Spec()) > 0 and StzFindFirst("out c int", kAr.Spec()) > 0)
chk("the WGSL reads the int input and scalar through i32(), writes 3i and 2i, the int / and % through helpers, and the output through f32()",
	StzFindFirst("v_c[i] = f32(stz_div((i32(v_a[i]) * 3i + i32(p.s_k)), 2i) - stz_rem(i32(v_a[i]), 4i));", cW) > 0)
aR = kAr.EvaluateOn([ :a = [ -7, -1, 0, 5, 9.9 ], :k = 1 ])
chk("the interpreter: (a * 3 + 1) / 2 - a % 4 over -7 -1 0 5 9.9 gives -7 0 0 7 13 (a / truncates; 9.9 reads as 9)",
	aR[1] = -7 and aR[2] = 0 and aR[3] = 0 and aR[4] = 7 and aR[5] = 13)
kUn = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "body { @c = 3 / 4 + @a }")
chk("a whole number that meets no int is a float, as before GL0: 3 / 4 is 0.75", kUn.EvaluateOn([ :a = [ 1 ] ])[1] = 1.75 and StzFindFirst("3f / 4f", kUn.ToWGSL()) > 0)
kIx = StzKernelMakerFromSpec("in a int" + NLc + "out c int" + NLc + "body { @c = @i * @a + n }")
chk("@i and n meet an int and become ints: i32(i) * i32(v_a[i]) + i32(p.n)", StzFindFirst("i32(i) * i32(v_a[i]) + i32(p.n)", kIx.ToWGSL()) > 0)
kCv = StzKernelMakerFromSpec("in a" + NLc + "out c int" + NLc + "body { @c = int(@a) }")
aC = kCv.EvaluateOn([ :a = [ 2.7, -2.7 ] ])
chk("int() goes toward zero: 2.7 and -2.7 give 2 and -2", aC[1] = 2 and aC[2] = -2)
? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

? ""
? "-- Scene 2: what is refused, in the same words by both readers --"
$t0 = clock()
aRef = [
	[ "an int meeting a float", "in a int" + NLc + "out c int" + NLc + "body { @c = @a + 0.5 }", "an int and a float meet at '+'" ],
	[ "a float function on an int", "in a int" + NLc + "out c int" + NLc + "body { @c = sqrt(@a) }", "'sqrt' works on floats: write sqrt(float(...))" ],
	[ "a float into an int output", "in a" + NLc + "out c int" + NLc + "body { @c = @a }", "holds ints; its value is a float" ],
	[ "an int into a float output", "in a int" + NLc + "out c" + NLc + "body { @c = @a }", "holds floats; its value is an int" ],
	[ "a literal past i32", "in a int" + NLc + "out c int" + NLc + "body { @c = @a + 2147483648 }", "too large for an int" ],
	[ "an int compared with a float", "in a int" + NLc + "out c" + NLc + "guard { @a > 0.5 }" + NLc + "body { @c = 1 }", "meet at '>'" ],
	[ "two types in one when", "in a int" + NLc + "out c int" + NLc + "body { @c = when(@a > 0, @a, 0.5) }", "meet at 'when'" ],
	[ "an unknown type word", "in a word" + NLc + "out c" + NLc + "body { @c = 1 }", "'word' is not a type" ],
	[ "an int staged into a shared array", "in a int" + NLc + "out c" + NLc + "shared t 256" + NLc + "stage { @t[@l] = @a }" + NLc + "body { @c = @t[0] }", "a shared array holds floats" ]
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
		StzKernelMakerFromSpec(aQ[2]).EvaluateOnWith([ :a = [ 1, 2 ] ], [ :n = 2 ])
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
	? "-- Scene 3: on the device, the edges where an int is decided --"
	$t0 = clock()
	aCases = [
		[ "a negative remainder: -7 % 4 is -3, the device's own '%' said 1", "in a int" + NLc + "out c int" + NLc + "body { @c = @a % 4 }", [ -7, -1, 7 ] ],
		[ "a wrapped product into a remainder: (2 * 2147483647) % 100000 is -2", "in a int" + NLc + "out c int" + NLc + "body { @c = (@a * 2147483647) % 100000 }", [ 2, 3 ] ],
		[ "division and remainder by zero: the dividend, and 0", "in a int" + NLc + "out c int" + NLc + "body { @c = @a / (@a - @a) * 1000 + @a % (@a - @a) }", [ -7, 0, 5 ] ],
		[ "the most negative int over -1: itself, remainder 0", "in a int" + NLc + "out c int" + NLc + "body { @c = (0 - 2147483647 - 1) / (@a - @a - 1) + (0 - 2147483647 - 1) % (@a - @a - 1) }", [ 1, 2 ] ],
		[ "int() past the range: 2147483520 and the most negative int", "in a" + NLc + "out c int" + NLc + "body { @c = int(@a * 1000000000) }", [ 3, -3 ] ],
		[ "int() of infinity and of NaN", "in a" + NLc + "out c int" + NLc + "body { @c = int(1 / (@a - @a)) + int((@a - @a) / (@a - @a)) * 0 }", [ 3 ] ],
		[ "a sum in a guard: its loop now comes before the guard's if", "in a int" + NLc + "out c int" + NLc + "guard { @i < n and sum(k, 0, 3, @a[@i + k]) > 0 }" + NLc + "body { @c = @a }", [ 1, 5, 2, 2, 3 ] ]
	]
	for aQ in aCases
		k = StzKernelMakerFromSpec(aQ[2])
		aD = oG.UploadQ(aQ[3]).ApplyQ(k).Download()
		aI = k.EvaluateOnWith([ :a = aQ[3] ], [ :n = len(aQ[3]) ])
		chk(aQ[1] + ": device " + @@(aD) + ", interpreter " + @@(aI), _SameNumbers(aD, aI))
	next
	aV = oG.VerifySpecWith(kAr, kAr, [ :a = [ -7, -1, 0, 5, 9, 300, -300 ], :k = 1 ], [ :n = 7 ])
	chk("the arithmetic of scene 1 is verified on the device (" + aV[:verdict] + ")", aV[:verdict] = "verified")
	? "  (scene 3: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 4: the fuzz's int kind, and its control --"
	$t0 = clock()
	nSeed = 20261028
	StzEngineGpuFuzzRun(nSeed, 300, 512, 0.00001)
	? "  generated " + StzEngineGpuFuzzResult(40) + " int kernels; ran " + StzEngineGpuFuzzResult(4) + ", agreed " + StzEngineGpuFuzzResult(5) + " (exact " + StzEngineGpuFuzzResult(9) + ")"
	chk("300 int kernels: no split, no compile failure", StzEngineGpuFuzzResult(40) = 300 and StzEngineGpuFuzzResult(2) = 0 and StzEngineGpuFuzzResult(3) = 0)
	chk("...and all 300 agree with the interpreter bit for bit: wrapping, division by zero and conversions included",
		StzEngineGpuFuzzResult(5) = 300 and StzEngineGpuFuzzResult(9) = 300 and StzEngineGpuFuzzResult(17) = 0)
	StzEngineGpuFuzzRun(nSeed, 300, 512 + 64, 0.00001)
	nMut = StzEngineGpuFuzzResult(18)
	nCaught = StzEngineGpuFuzzResult(19)
	? "  mutated " + nMut + ", caught " + nCaught
	chk("the control: over a hundred int kernels had a '+' to break", nMut > 100)
	chk("...and at least 75% were caught (measured 100 of 124 on 2026-10-28; ten escapes read, nine cannot change an answer)", nCaught >= 0.75 * nMut)
	StzEngineGpuFuzzRun(nSeed, 300, 63, 0.00001)
	chk("the six float kinds, rewritten by the typed readers, still all agree (219 exactly)", StzEngineGpuFuzzResult(5) = 300 and StzEngineGpuFuzzResult(9) = 219)
	? "  (scene 4: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 5: puzzle 14, roll the dice --"
$t0 = clock()
oQ = StzKernelPuzzleQ("kp-14")
chk("the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
chk("the task reads in four languages and ends with what the GPU did differently from a loop",
	oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "" and StzFindFirst("differently from a loop", oQ.Task("en")) > 0)
aCases = [
	[ "in a int" + NLc + "out c int" + NLc + "body { @c = (@a * 1664525 + 1013904223) % 1000 }", "verified" ],
	[ "in a int" + NLc + "out c int" + NLc + "body { @c = (@a * 525 + 223) % 1000 }", "verified" ],
	[ "in a" + NLc + "out c" + NLc + "body { @c = (@a * 1664525 + 1013904223) % 1000 }", "mismatch at element 1" ],
	[ "in a int" + NLc + "out c int" + NLc + "body { @c = @a * 1664525 + 1013904223 % 1000 }", "mismatch at element 2" ]
]
nAgree = 0
for aQ in aCases
	if bDevice
		cV = oQ.Grade(aQ[1])
	else
		cV = oQ.GradeOnCpu(aQ[1])
	ok
	acL = StzSplit(aQ[1], NLc)
	chk(acL[1] + " / " + acL[len(acL)] + " -> " + aQ[2] + " (" + cV + ")", cV = aQ[2])
	if oQ.GradeOnCpu(aQ[1]) = aQ[2]
		nAgree++
	ok
next
chk("GradeOnCpu says the same words for all " + len(aCases) + " cases", nAgree = len(aCases))
cV = oQ.Grade("in a int" + NLc + "out c int" + NLc + "body { @c = (@a * 1664525 + 1013904223) % 1000.0 }")
chk("a float in the int kernel is refused by name (" + cV + ")", StzFindFirst("refused", cV) = 1 and StzFindFirst("meet at '%'", cV) > 0)
if bDevice
	oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/kp-14")
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

func _SameNumbers paA, paB
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
