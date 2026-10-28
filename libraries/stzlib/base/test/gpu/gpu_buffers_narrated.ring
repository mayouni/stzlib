# GL0 -- TYPED BUFFERS (SOFTANZA_GPU_PLAN.md, GL0; the reader's account of
# the language is base/gpu/SOFTANZA_GPU_KERNELS.md, 3.1d).
#
# The fourth admission: an input or the output may hold vectors. 'in p vec2'
# is a buffer of two floats per element, side by side -- element i is floats
# 2i and 2i + 1 -- and 'out q vec3' writes three per element. @p is the
# element's vector and @p[k] another element's, a zero vector outside. The
# value of a vecN output's body must be a vecN.
#
# The width rides on the declaration, and the engine reads it, once: every
# host (the checker, the fuzz, the Ring face, the browser runner) sizes its
# buffers from stz_gpu_spec_in_width / stz_gpu_spec_out_width, never from a
# parse of its own. Each sizes the output n * W floats with the NaN margin
# after it, keeps one mask byte per element, and names a mismatch by element.
#
# Ints stay as they were: an int buffer still crosses as f32, exact to
# 16,777,216, because the values reach the engine from Ring as numbers. A
# real i32 buffer is the atomics rung's, where atomic<i32> needs one.
#
# Run with Ring++: rnxc gpu_buffers_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(4)
NLc = char(10)

? "-- Scene 1: a buffer of vectors in, a buffer of vectors out, in both readers --"
$t0 = clock()
k = new stzKernelMaker
k.TakesVectorOf(:p, :vec2)
k.TakesScalar(:c)
k.TakesScalar(:s)
k.ReturnsVectorOf(:q, :vec2)
k.ForEachElement('{ @q = vec2(c * @p.x - s * @p.y, s * @p.x + c * @p.y) }')
chk("the declarations read back as written: 'in p vec2', 'out q vec2'",
	StzFindFirst("in p vec2", k.Spec()) = 1 and StzFindFirst("out q vec2", k.Spec()) > 0)
chk("...and the engine reads two floats per element in and out", k.InputWidth(:p) = 2 and k.OutputWidth() = 2)
chk("Spec() survives StzKernelMakerFromSpec unchanged", StzKernelMakerFromSpec(k.Spec()).Spec() = k.Spec())
cW = k.ToWGSL()
chk("the WGSL reads element i at floats 2i and 2i + 1: vec2<f32>(v_p[2u * i], v_p[2u * i + 1u])",
	StzFindFirst("vec2<f32>(v_p[2u * i], v_p[2u * i + 1u])", cW) > 0)
chk("...and stores the two components there: v_q[2u * i] = o_.x; v_q[2u * i + 1u] = o_.y;",
	StzFindFirst("v_q[2u * i] = o_.x; v_q[2u * i + 1u] = o_.y;", cW) > 0)
aR = k.EvaluateOn([ :p = [ [ 1, 0 ], [ 0, 1 ], [ 2, 3 ] ], :c = 0, :s = 1 ])
chk("the interpreter turns (1, 0), (0, 1), (2, 3) a quarter: two numbers per element, flat: 0 1 -1 0 -3 2",
	_Same(aR, [ 0, 1, -1, 0, -3, 2 ]))
kL = StzKernelMakerFromSpec("in p vec3" + NLc + "out d" + NLc + "body { @d = length(@p) + @p[@i + 1].x }")
aL = kL.EvaluateOn([ :p = [ [ 3, 4, 0 ], [ 0, 0, 0 ], [ 1, 2, 2 ] ] ])
chk("a vec3 input reduced to a number, and its neighbour, a zero vector past the end: 5 1 3", _Same(aL, [ 5, 1, 3 ]))
kG = StzKernelMakerFromSpec("in p vec2" + NLc + "out q vec2" + NLc + "guard { @i < n and @p.x > 2 }" + NLc + "body { @q = @p * 2 }")
aG = kG.EvaluateOn([ :p = [ [ 1, 2 ], [ 3, 4 ] ] ])
chk("a guard over a vector output leaves both numbers of a refused element unwritten", aG[1] != aG[1] and aG[2] != aG[2] and aG[3] = 6 and aG[4] = 8)
? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

? ""
? "-- Scene 2: what is refused, in the same words by both readers --"
$t0 = clock()
aRef = [
	[ "a number into a vector output", "in p vec2" + NLc + "out q vec2" + NLc + "body { @q = 1 }", "the output '@q' holds vec2s: its value must be a vec2" ],
	[ "a vector of another width", "in p vec2" + NLc + "out q vec3" + NLc + "body { @q = @p }", "the output '@q' holds vec3s: its value must be a vec3" ],
	[ "a vector into a number output", "in p vec2" + NLc + "out c" + NLc + "body { @c = @p }", "a vector stands where a number is needed" ],
	[ "a scalar declared a vector", "in p vec2" + NLc + "scalar s vec2" + NLc + "out c" + NLc + "body { @c = 1 }", "a scalar is one number" ],
	[ "a width that is not one", "in p vec5" + NLc + "out c" + NLc + "body { @c = 1 }", "'vec5' is not a type" ]
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
		StzKernelMakerFromSpec(aQ[2]).EvaluateOn([ :p = [ [ 1, 2 ] ] ])
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
	? "-- Scene 3: on the device, every path that makes a buffer --"
	$t0 = clock()
	aP = [] aN = []
	for i = 1 to 3000
		aP + [ (((i * 7) % 33) - 16) / 8, (((i * 5) % 29) - 14) / 4 ]
		aN + [ (((i * 3) % 17) - 8) / 2, 1, (i % 5) / 4 ]
	next
	aV = oG.VerifySpecWith(k, k, [ :p = aP, :c = 0.6, :s = 0.8 ], [ :n = 3000, :band = 0.00001 ])
	chk("the checker verifies the rotation, vec2 in and out, at both shapes (" + aV[:verdict] + ", maxdiff " + aV[:maxdiff] + ")", aV[:verdict] = "verified")
	kN = StzKernelMakerFromSpec("in p vec2" + NLc + "in nrm vec3" + NLc + "out c vec4" + NLc + "guard { @i < n and @p.x > -1 }" + NLc +
		"body { @c = vec4(normalize(@nrm), dot(@p, @p[@i + 1])) }")
	aV = oG.VerifySpecWith(kN, kN, [ :p = aP, :nrm = aN ], [ :n = 3000, :band = 0.00001 ])
	chk("two vector inputs of two widths, a neighbour, a guard and a vec4 output (" + aV[:verdict] + ", maxdiff " + aV[:maxdiff] + ")", aV[:verdict] = "verified")
	kS = StzKernelMakerFromSpec("in p vec2" + NLc + "out c" + NLc + "shared t 256" + NLc + "stage { @t[@l] = @p.x + @p.y }" + NLc + "body { @c = @t[255 - @l] }")
	aV = oG.VerifySpecWith(kS, kS, [ :p = aP ], [ :n = 3000 ])
	chk("a stage reads a vector input through the group's bounded read (" + aV[:verdict] + ")", aV[:verdict] = "verified")
	aRun = oG.RunQWith(k, [ :p = [ [ 1, 0 ], [ 0, 1 ], [ 2, 3 ] ], :c = 0, :s = 1 ], []).Download()
	chk("RunQWith sizes its output by the width: " + @@(aRun), _Same(aRun, [ 0, 1, -1, 0, -3, 2 ]))
	kLen = StzKernelMakerFromSpec("in p vec2" + NLc + "out d" + NLc + "body { @d = length(@p) }")
	kDbl = StzKernelMakerFromSpec("in p vec2" + NLc + "out d vec2" + NLc + "body { @d = @p * 2 }")
	aCh = oG.UploadQ([ [ 3, 4 ], [ 6, 8 ] ]).ApplyQ(kDbl).ApplyQ(kLen).Download()
	chk("a chain of buffers: rows uploaded flat, vec2 -> vec2 -> number: " + @@(aCh), _Same(aCh, [ 10, 20 ]))
	? "  (scene 3: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 4: the fuzz's typed-buffer kind, and its control --"
	$t0 = clock()
	nSeed = 20261028
	StzEngineGpuFuzzRun(nSeed, 300, 2048, 0.00001)
	? "  generated " + StzEngineGpuFuzzResult(44) + " kernels with vector buffers; ran " + StzEngineGpuFuzzResult(4) + ", agreed " + StzEngineGpuFuzzResult(5) +
		" (exact " + StzEngineGpuFuzzResult(9) + "); " + StzEngineGpuFuzzResult(36) + " elements left unwritten by a guard, checked so"
	chk("300 kernels: none refused by both readers, no split, no compile failure",
		StzEngineGpuFuzzResult(44) = 300 and StzEngineGpuFuzzResult(1) = 0 and StzEngineGpuFuzzResult(2) = 0 and StzEngineGpuFuzzResult(3) = 0)
	chk("...all 300 agree with the interpreter, nothing stored past the region or where a guard said not to",
		StzEngineGpuFuzzResult(5) = 300 and StzEngineGpuFuzzResult(17) = 0 and StzEngineGpuFuzzResult(7) = 0)
	StzEngineGpuFuzzRun(nSeed, 300, 2048 + 64, 0.00001)
	nMut = StzEngineGpuFuzzResult(18)
	nCaught = StzEngineGpuFuzzResult(19)
	? "  mutated " + nMut + ", caught " + nCaught
	chk("the control: over a hundred kernels had a '+' to break", nMut > 100)
	chk("...and at least 75% were caught (measured 170 of 211 on 2026-10-28; eight escapes read, seven cannot change an answer)", nCaught >= 0.75 * nMut)
	StzEngineGpuFuzzRun(nSeed, 300, 63, 0.00001)
	chk("the six float kinds still agree as before (300, 219 exactly)", StzEngineGpuFuzzResult(5) = 300 and StzEngineGpuFuzzResult(9) = 219)
	? "  (scene 4: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 5: puzzle 16, turn the points --"
$t0 = clock()
oQ = StzKernelPuzzleQ("kp-16")
chk("the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
chk("the task reads in four languages and ends with what the GPU did differently from a loop",
	oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "" and StzFindFirst("differently from a loop", oQ.Task("en")) > 0)
cHead = "in p vec2" + NLc + "scalar c" + NLc + "scalar s" + NLc + "out q vec2" + NLc
aCases = [
	[ "vec2(c * @p.x - s * @p.y, s * @p.x + c * @p.y)", "verified" ],
	[ "vec2(dot(@p, vec2(c, -s)), dot(@p, vec2(s, c)))", "verified" ],
	[ "c * @p + s * vec2(-@p.y, @p.x)", "verified" ],
	[ "vec2(c * @p.x + s * @p.y, -s * @p.x + c * @p.y)", "mismatch at element 1" ],
	[ "vec2(c * @p.x, s * @p.x)", "mismatch at element 1" ]
]
nAgree = 0
for aQ in aCases
	cSpec = cHead + "body { @q = " + aQ[1] + " }"
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
cV = oQ.Grade(cHead + "body { @q = length(@p) }")
chk("a number for a point is refused by name (" + cV + ")", StzFindFirst("refused", cV) = 1 and StzFindFirst("holds vec2s", cV) > 0)
if bDevice
	oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/kp-16")
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
