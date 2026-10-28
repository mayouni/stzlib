# GL0 -- VECTORS (SOFTANZA_GPU_PLAN.md, GL0; the reader's account of the
# language is base/gpu/SOFTANZA_GPU_KERNELS.md, 3.1c).
#
# The third admission: vec2, vec3 and vec4 of floats, as values inside a
# kernel. They are built from numbers (vec3(@x, @y, @z), vec4(v2, 1, 0),
# vec3(1)), read by component (.x, .zyx), combined component by component (a
# number meeting a vector is spread across it), passed to every float function
# component by component, and reduced by dot, length and distance;
# normalize, cross and reflect give vectors back. An input or an output is
# still a number, so a vector is built and reduced inside one expression.
# Vector inputs and outputs need interleaved buffers, which belong with the
# real i32 buffers atomics need: the next rung.
#
# One decision is shared by both readers: what a call means once its
# arguments' types are known (planCall). Each reader parses, writes and
# computes the call its own way; the interpreter computes every component
# through the same function that computes a number (applyF), so a vector's
# meaning and a number's cannot drift. The transpiler wrote the same WGSL,
# byte for byte, for 18,000 generated kernels before and after.
#
# Run with Ring++: rnxc gpu_vec_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(4)
NLc = char(10)

? "-- Scene 1: vectors built, read, combined and reduced, in both readers --"
$t0 = clock()
kLen = StzKernelMakerFromSpec("in x" + NLc + "in y" + NLc + "in z" + NLc + "out d" + NLc + "body { @d = length(vec3(@x, @y, @z)) }")
chk("the transpiler writes WGSL's own vector: length(vec3<f32>(v_x[i], v_y[i], v_z[i]))",
	StzFindFirst("length(vec3<f32>(v_x[i], v_y[i], v_z[i]))", kLen.ToWGSL()) > 0)
aL = kLen.EvaluateOn([ :x = [ 3, 0, 1 ], :y = [ 4, 0, 2 ], :z = [ 0, 0, 2 ] ])
chk("the interpreter: the lengths of (3, 4, 0), (0, 0, 0), (1, 2, 2) are 5, 0, 3", aL[1] = 5 and aL[2] = 0 and aL[3] = 3)
kSw = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "body { @c = (vec3(@a, 1, 2) * 2 + 1).zyx.x + dot(vec2(@a, 1), vec2(3, 4)) }")
aS = kSw.EvaluateOn([ :a = [ 0, 1, 2 ] ])
chk("a number spread across a vector, a swizzle of a swizzle, a dot: 3a + 9 gives 9 12 15", aS[1] = 9 and aS[2] = 12 and aS[3] = 15)
kFx = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "body { @c = cross(vec3(1, 0, 0), vec3(0, @a, 0)).z + normalize(vec2(@a, 0)).x + reflect(vec2(1, -1), vec2(0, 1)).y + mix(vec2(0, 2), vec2(4, 6), 0.5).y + when(@a > 1, vec2(10, 20), vec2(30, 40)).y + floor(vec2(@a * 1.5, 0)).x }")
aF = kFx.EvaluateOn([ :a = [ 1, 2, 3 ] ])
chk("cross, normalize, reflect, mix with one weight, when of vectors, floor by component: 48 31 33", aF[1] = 48 and aF[2] = 31 and aF[3] = 33)
chk("...and when of two vectors is WGSL's select of two vectors", StzFindFirst("select((vec2<f32>(30f, 40f)), (vec2<f32>(10f, 20f)), (v_a[i] > 1f)).y", kFx.ToWGSL()) > 0)
kCt = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "body { @c = vec4(vec2(@a, 1), 2, 3).w + vec3(@a).y - (-vec2(@a, 5)).y }")
aC = kCt.EvaluateOn([ :a = [ 0, 1, 2 ] ])
chk("a constructor of a vector and numbers, one number spread, a vector negated: a + 8", aC[1] = 8 and aC[2] = 9 and aC[3] = 10)
? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

? ""
? "-- Scene 2: what is refused, in the same words by both readers --"
$t0 = clock()
aRef = [
	[ "a vector as the output's value", "body { @c = vec3(@a, 1, 2) }", "a vector stands where a number is needed" ],
	[ "a vector compared whole", "body { @c = when(vec2(@a, 1) > 0, 1, 0) }", "a vector is not compared whole" ],
	[ "two widths in one sum", "body { @c = (vec2(1, 2) + vec3(1, 2, 3)).x }", "vectors of two widths meet at '+'" ],
	[ "a number where a function takes a vector", "body { @c = min(vec2(@a, 1), 0).x }", "'min' takes values of one type: write vec2(x)" ],
	[ "a constructor short of numbers", "body { @c = vec3(1, 2).x }", "vec3 takes 3 numbers" ],
	[ "a vector function given numbers", "body { @c = dot(@a, 2) }", "'dot' works on vectors" ],
	[ "cross of two vec2s", "body { @c = cross(vec2(1, 2), vec2(3, 4)).x }", "cross takes two vec3s" ],
	[ "a component of a number", "body { @c = @a.x }", "'.x' reads a vector's components, and this value is a number" ],
	[ "a component past the width", "body { @c = vec2(@a, 1).z }", "a vec2's letters are xy" ],
	[ "a vector as an index", "body { @c = @a[vec2(1, 2)] }", "a vector stands where a number is needed" ],
	[ "a vector and a number in one when", "body { @c = when(@a > 0, vec2(1, 2), 3).x }", "'when' takes values of one type" ]
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
cSpec = "in k int" + NLc + "out c" + NLc + "body { @c = vec2(@k, 1).x }"
cT = ""
try
	StzKernelMakerFromSpec(cSpec).ToWGSL()
catch
	cT = cCatchError
done
chk("an int in a vector: 'a vector holds floats'", StzFindFirst("a vector holds floats", cT) > 0)
? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

oG = new stzGpu
bDevice = oG.IsAvailable()
if bDevice
	? ""
	? "-- Scene 3: on the device --"
	$t0 = clock()
	aX = [] aY = [] aZ = []
	for i = 1 to 3000
		aX + ((((i * 7) % 33) - 16) / 8)
		aY + ((((i * 5) % 29) - 14) / 4)
		aZ + ((((i * 3) % 17) - 8) / 2)
	next
	aCases = [
		[ "a length", "body { @c = length(vec3(@x, @y, @z)) }" ],
		[ "swizzles and spreading", "body { @c = (vec3(@x, 1, 2) * 2 + @y).zyx.x + dot(vec2(@x, @z), vec2(3, 4)) }" ],
		[ "cross, reflect, mix, when, floor", "body { @c = cross(vec3(@x, @y, @z), vec3(@z, @x, @y)).y + reflect(vec2(@x, @y), vec2(0, 1)).y + mix(vec2(@x, 2), vec2(4, @z), 0.25).x + when(@x > 1, vec2(@y, 20), vec2(30, @z)).x + floor(vec2(@x * 1.5, 0)).x }" ],
		[ "normalize and distance", "body { @c = normalize(vec3(@x, @y, @z) + 0.5).x + distance(vec2(@x, @y), vec2(@z, 1)) }" ],
		[ "max, clamp, smoothstep by component", "body { @c = max(vec2(@x, @y), vec2(@z, 0)).y + clamp(vec2(@x, @y), vec2(-1, -1), vec2(1, 1)).x + smoothstep(vec2(-2, -2), vec2(2, 2), vec2(@x, @y)).y }" ]
	]
	for aQ in aCases
		k = StzKernelMakerFromSpec("in x" + NLc + "in y" + NLc + "in z" + NLc + "out c" + NLc + aQ[2])
		aV = oG.VerifySpecWith(k, k, [ :x = aX, :y = aY, :z = aZ ], [ :n = 3000 ])
		chk(aQ[1] + ": the kernel compiles and agrees with the interpreter (" + aV[:verdict] + ", maxdiff " + aV[:maxdiff] + ")", aV[:verdict] = "verified")
	next
	? "  (scene 3: " + ((clock() - $t0) / clockspersecond()) + " s)"

	? ""
	? "-- Scene 4: the fuzz's vector kind, and its control --"
	$t0 = clock()
	nSeed = 20261028
	StzEngineGpuFuzzRun(nSeed, 300, 1024, 0.00001)
	? "  generated " + StzEngineGpuFuzzResult(42) + " vector kernels; ran " + StzEngineGpuFuzzResult(4) + ", agreed " + StzEngineGpuFuzzResult(5) + " (exact " + StzEngineGpuFuzzResult(9) + ", the worst inexact one at " + StzEngineGpuFuzzResult(11) + " of the band)"
	chk("300 vector kernels: none refused by both readers, no split, no compile failure",
		StzEngineGpuFuzzResult(42) = 300 and StzEngineGpuFuzzResult(1) = 0 and StzEngineGpuFuzzResult(2) = 0 and StzEngineGpuFuzzResult(3) = 0)
	chk("...all 300 agree with the interpreter, the exact ones bit for bit, and they are more than half",
		StzEngineGpuFuzzResult(5) = 300 and StzEngineGpuFuzzResult(17) = 0 and StzEngineGpuFuzzResult(9) > 150)
	StzEngineGpuFuzzRun(nSeed, 300, 1024 + 64, 0.00001)
	nMut = StzEngineGpuFuzzResult(18)
	nCaught = StzEngineGpuFuzzResult(19)
	? "  mutated " + nMut + ", caught " + nCaught
	chk("the control: over a hundred vector kernels had a '+' to break", nMut > 100)
	chk("...and at least 85% were caught (measured 157 of 173 on 2026-10-28)", nCaught >= 0.85 * nMut)
	? "  (scene 4: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 5: puzzle 15, light on a surface --"
$t0 = clock()
oQ = StzKernelPuzzleQ("kp-15")
chk("the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
chk("the task reads in four languages and ends with what the GPU did differently from a loop",
	oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "" and StzFindFirst("differently from a loop", oQ.Task("en")) > 0)
cHead = "in nx" + NLc + "in ny" + NLc + "in nz" + NLc + "scalar sx" + NLc + "scalar sy" + NLc + "scalar sz" + NLc + "out c" + NLc
aCases = [
	[ "max(dot(normalize(vec3(@nx, @ny, @nz)), normalize(vec3(sx, sy, sz))), 0)", "verified" ],
	[ "max(dot(normalize(vec3(@nx, @ny, @nz)), vec3(sx, sy, sz) / 3), 0)", "verified" ],
	[ "max(dot(vec3(@nx, @ny, @nz), normalize(vec3(sx, sy, sz))), 0)", "mismatch at element 8" ],
	[ "dot(normalize(vec3(@nx, @ny, @nz)), normalize(vec3(sx, sy, sz)))", "mismatch at element 1" ]
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
cV = oQ.Grade(cHead + "body { @c = normalize(vec3(@nx, @ny, @nz)) }")
chk("a vector for the output is refused by name (" + cV + ")", StzFindFirst("refused", cV) = 1 and StzFindFirst("a vector stands where a number is needed", cV) > 0)
if bDevice
	oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/kp-15")
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
