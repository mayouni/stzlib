# KP0 -- THE GRAMMAR GROWS, ONE ADMISSION AT A TIME (SOFTANZA_GPU_PLAN.md, KP0).
#
# The elementwise grammar covered map, zip and a scalar. The kernel puzzles
# need, in order: an element index readable in the body; a bounds guard the
# learner writes -- or omits, and sees the checker's margin catch; a stencil
# over neighbours; a two-pass reduction. Each is admitted in the transpiler
# AND in the interpreter from one parser, with a refusal message for the
# forms not admitted, and the emitted kernel always references the params
# uniform (a kernel that does not gets a layout without binding 1 -- GK6).
#
# What this suite asserts, negative siblings beside each:
#   - the interpreter answers each admission with no device: the index, the
#     guard's refused elements, the stencil's zero outside the input, the
#     partial sums and the fold; the operations executed count the loop
#   - the refusals name the offender: a reserved name declared, a comparison
#     in a body, a sum inside a sum, a sum with three arguments, '=' in a guard
#   - on the device: each admission's description verifies its own kernel
#     at the visible and the hidden shape, and a wrong sibling is refused
#     with the first bad element named -- an edge the task leaves unwritten
#     and the learner writes, a guard the learner drops at a size that is not
#     a multiple of 256 (write-outside at n + 1), a partial sum one short
#   - the generated WGSL carries `_ = p.n;` whenever the learner owns the guard
#
# Run with Ring++: rnxc gpu_grammar_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(4)

? "-- Scene 0: the four admissions on the CPU, no device --"
kIdx = StzKernelMakerQ()
kIdx.TakesVector(:a)
kIdx.ReturnsVector(:c)
kIdx.ForEachElement('{ @c = @a + @i }')
aR = kIdx.EvaluateOn([ :a = [1, 2, 3] ])
? "  @a + @i over [1,2,3] -> " + @@(aR)
chk("the INDEX: @i is the element number, from 0", len(aR) = 3 and aR[1] = 1 and aR[2] = 3 and aR[3] = 5)
chk("...and the WGSL says f32(i)", StzFindFirst("v_a[i] + f32(i)", kIdx.ToWGSL()) > 0)

kG = StzKernelMakerQ()
kG.TakesVector(:a)
kG.ReturnsVector(:c)
kG.Guard('{ @i < n - 1 }')
kG.ForEachElement('{ @c = @a * 2 }')
aR = kG.EvaluateOn([ :a = [1, 2, 3] ])
? "  guard @i < n - 1, @a * 2 over [1,2,3] -> " + @@(aR)
chk("the GUARD: the first two elements are written", aR[1] = 2 and aR[2] = 4)
chk("...and the one the guard refuses is left unwritten (not a number)", NOT (aR[3] = aR[3]))
cW = kG.ToWGSL()
chk("...the kernel keeps the params uniform bound (`_ = p.n;`) now that the learner owns the guard", StzFindFirst("_ = p.n;", cW) > 0)
chk("...and the guard is the learner's words, in f32", StzFindFirst("if (f32(i) < f32(p.n) - 1) {", cW) > 0)
kN = StzKernelMakerQ()
kN.TakesVector(:a)
kN.ReturnsVector(:c)
kN.WithoutGuard()
kN.ForEachElement('{ @c = @a }')
cW = kN.ToWGSL()
chk("guard none: no if at all, and p still bound", StzFindFirst("if (", cW) = 0 and StzFindFirst("_ = p.n;", cW) > 0)

kSt = StzKernelMakerQ()
kSt.TakesVector(:a)
kSt.ReturnsVector(:c)
kSt.ForEachElement('{ @c = @a[@i - 1] + @a + @a[@i + 1] }')
aR = kSt.EvaluateOn([ :a = [1, 2, 3, 4] ])
? "  @a[@i-1] + @a + @a[@i+1] over [1,2,3,4] -> " + @@(aR)
chk("the STENCIL: a neighbour read, zero outside the input on both edges", aR[1] = 3 and aR[2] = 6 and aR[3] = 9 and aR[4] = 7)
chk("...the WGSL has a reader per input with the same rule", StzFindFirst("fn rd_a(k : i32) -> f32 {", kSt.ToWGSL()) > 0)

kP = StzKernelMakerQ()
kP.TakesVector(:a)
kP.ReturnsVector(:c)
kP.ForEachElement('{ @c = sum(k, 0, 4, @a[@i * 4 + k]) }')
aR = kP.EvaluateOnWith([ :a = [1, 2, 3, 4, 5, 6, 7, 8] ], [ :n = 2 ])
? "  sum(k, 0, 4, @a[@i*4 + k]) over 8 inputs, n = 2 -> " + @@(aR) + "   operations " + kP.OperationsExecuted()
chk("the SUM, first pass: two partials over an input longer than n", len(aR) = 2 and aR[1] = 10 and aR[2] = 26)
chk("...and the work counted is the loop's, not one operation per element", kP.OperationsExecuted() > 8)
kF = StzKernelMakerQ()
kF.TakesVector(:c)
kF.TakesScalar(:m)
kF.ReturnsVector(:d)
kF.ForEachElement('{ @d = sum(k, 0, m, @c[k]) }')
aR = kF.EvaluateOnWith([ :c = [10, 26], :m = 2 ], [ :n = 1 ])
chk("the SUM, second pass: the fold of the partials into one element", len(aR) = 1 and aR[1] = 36)
chk("...the WGSL carries the loop as a prelude and the body reads the accumulator",
	StzFindFirst("var acc0 : f32 = 0.0;", kF.ToWGSL()) > 0 and StzFindFirst("v_d[i] = acc0;", kF.ToWGSL()) > 0)

? ""
? "-- Scene 0b: the refusals name the offender --"
aBad = [
	[ "a vector named i", "in i" + char(10) + "out c" + char(10) + "body { @c = @i }", "element index" ],
	[ "a scalar named n", "in a" + char(10) + "scalar n" + char(10) + "out c" + char(10) + "body { @c = @a }", "element count" ],
	[ "a comparison in a body", "in a" + char(10) + "out c" + char(10) + "body { @c = @a < 2 }", "guard" ],
	[ "a sum inside a sum", "in a" + char(10) + "out c" + char(10) + "body { @c = sum(k, 0, 4, sum(j, 0, 2, @a[k + j])) }", "sum inside a sum" ],
	[ "a sum with three arguments", "in a" + char(10) + "out c" + char(10) + "body { @c = sum(k, 0, @a[k]) }", "4 arguments" ],
	[ "a single = in a guard", "in a" + char(10) + "out c" + char(10) + "guard { @i = 2 }" + char(10) + "body { @c = @a }", "==" ],
	[ "and in a body", "in a" + char(10) + "out c" + char(10) + "body { @c = @a and 1 }", "guard" ]
]
for aCase in aBad
	cW = StzEngineGpuWgslElementwise(aCase[2])
	cWhy = StzEngineGpuWgslError()
	chk(aCase[1] + " is refused by the transpiler, naming it: " + cWhy, cW = "" and StzFindFirst(aCase[3], cWhy) > 0)
	aOut = StzEngineGpuSpecEval(aCase[2], [1], [1], 1, [])
	chk("...and by the interpreter (the two readers agree)", len(aOut) = 0)
next

nN = 4096
aData = []
for i = 0 to nN - 1
	aData + i
next

oG = new stzGpu
if NOT oG.IsAvailable()
	? "  NO GPU ON THIS MACHINE -- the device scenes need one; Scene 0 is the coverage"
else
	? ""
	? "  device: " + oG.DeviceName()
	? "-- Scene 1: the INDEX on the device --"
	aV = oG.VerifySpec(kIdx, kIdx, [ :a = aData ])
	chk("@a + @i verifies its own kernel at both shapes", aV[:verdict] = "verified" and aV[:maxdiff] = 0 and aV[:maxdiffhidden] = 0)
	kIdxWrong = StzKernelMakerQ()
	kIdxWrong.TakesVector(:a)
	kIdxWrong.ReturnsVector(:c)
	kIdxWrong.ForEachElement('{ @c = @a + @i + 1 }')
	aV = oG.VerifySpec(kIdx, kIdxWrong, [ :a = aData ])
	chk("an index off by one is a MISMATCH from the first element", aV[:verdict] = "mismatch" and aV[:firstbad] = 1)

	? ""
	? "-- Scene 2: the learner's GUARD on the device --"
	kG4 = StzKernelMakerQ()
	kG4.TakesVector(:a)
	kG4.ReturnsVector(:c)
	kG4.Guard('{ @i < n - 2 }')
	kG4.ForEachElement('{ @c = @a * 2 }')
	aV = oG.VerifySpec(kG4, kG4, [ :a = aData ])
	? "  guard @i < n - 2: verdict " + aV[:verdict]
	chk("a description with its own guard verifies itself: the two refused elements are unwritten on both sides", aV[:verdict] = "verified")
	kAll = StzKernelMakerQ()
	kAll.TakesVector(:a)
	kAll.ReturnsVector(:c)
	kAll.ForEachElement('{ @c = @a * 2 }')
	aV = oG.VerifySpec(kG4, kAll, [ :a = aData ])
	? "  the same body without the task's guard: verdict " + aV[:verdict] + "   first bad " + aV[:firstbad]
	chk("a kernel that writes an element the task's guard leaves is a MISMATCH there", aV[:verdict] = "mismatch")
	chk("...named: the first element the task refuses (n - 1, 1-based n - 1)", aV[:firstbad] = nN - 1)
	# the puzzle-5 story: the learner drops the guard at a size that is not a multiple of 256
	nM = 4000
	aM = []
	for i = 0 to nM - 1
		aM + (i * 0.5)
	next
	kDrop = StzKernelMakerQ()
	kDrop.TakesVector(:a)
	kDrop.ReturnsVector(:c)
	kDrop.WithoutGuard()
	kDrop.ForEachElement('{ @c = @a * 2 }')
	kTask = StzKernelMakerQ()
	kTask.TakesVector(:a)
	kTask.ReturnsVector(:c)
	kTask.ForEachElement('{ @c = @a * 2 }')
	aV = oG.VerifySpec(kTask, kDrop, [ :a = aM ])
	? "  guard none at n = 4000: verdict " + aV[:verdict] + "   outside at " + aV[:outsideat]
	chk("the dropped guard is WRITE-OUTSIDE, caught by the margin", aV[:verdict] = "write-outside")
	chk("...at element n + 1: the last workgroup's first thread past the region", aV[:outsideat] = nM + 1)
	aV = oG.VerifySpec(kTask, kG4, [ :a = aM ])
	chk("...while a guard that is merely too TIGHT is a mismatch, not a write-outside (the two mistakes are told apart)", aV[:verdict] = "mismatch")

	? ""
	? "-- Scene 3: the STENCIL on the device --"
	aS = []
	for i = 0 to nN - 1
		aS + ((i * 7) % 13)
	next
	kBlur = StzKernelMakerQ()
	kBlur.TakesVector(:a)
	kBlur.ReturnsVector(:c)
	kBlur.Guard('{ @i > 0 and @i < n - 1 }')
	kBlur.ForEachElement('{ @c = (@a[@i - 1] + @a + @a[@i + 1]) / 3 }')
	aV = oG.VerifySpec(kBlur, kBlur, [ :a = aS ])
	? "  the 3-point blur with its edge guard: verdict " + aV[:verdict] + "   cand " + aV[:candms] + " ms   cpu " + aV[:cpums] + " ms   flops " + aV[:flops]
	chk("the blur with the edge guard verifies itself at both shapes", aV[:verdict] = "verified")
	chk("...and declares its work: 4 operations and 2 reads per written element", aV[:flops] > 4 * (nN - 2))
	kEdge = StzKernelMakerQ()
	kEdge.TakesVector(:a)
	kEdge.ReturnsVector(:c)
	kEdge.ForEachElement('{ @c = (@a[@i - 1] + @a + @a[@i + 1]) / 3 }')
	aV = oG.VerifySpec(kBlur, kEdge, [ :a = aS ])
	? "  the blur without the edge guard: verdict " + aV[:verdict] + "   first bad " + aV[:firstbad]
	chk("the blur WITHOUT the edge guard writes the edge the task leaves: a MISMATCH at element 1", aV[:verdict] = "mismatch" and aV[:firstbad] = 1)

	? ""
	? "-- Scene 4: the REDUCTION on the device, two passes --"
	nBig = 16384
	aBig = []
	for i = 0 to nBig - 1
		aBig + ((i % 10) / 10.0)
	next
	nParts = nBig / 16
	kPass1 = StzKernelMakerQ()
	kPass1.TakesVector(:a)
	kPass1.ReturnsVector(:c)
	kPass1.ForEachElement('{ @c = sum(k, 0, 16, @a[@i * 16 + k]) }')
	aV = oG.VerifySpecWith(kPass1, kPass1, [ :a = aBig ], [ :n = nParts ])
	? "  pass 1, " + nParts + " partials of 16 over " + nBig + ": verdict " + aV[:verdict] + "   cand " + aV[:candms] + " ms   cpu " + aV[:cpums] + " ms   flops " + aV[:flops]
	chk("the first pass verifies itself at n = " + nParts + " over a longer input, visible and hidden", aV[:verdict] = "verified")
	chk("...and the work counted is the loop's (at least 16 reads and 16 adds per partial)", aV[:flops] >= nParts * 32)
	kShort = StzKernelMakerQ()
	kShort.TakesVector(:a)
	kShort.ReturnsVector(:c)
	kShort.ForEachElement('{ @c = sum(k, 0, 15, @a[@i * 16 + k]) }')
	aV = oG.VerifySpecWith(kPass1, kShort, [ :a = aBig ], [ :n = nParts ])
	chk("a partial one term short is a MISMATCH", aV[:verdict] = "mismatch")
	aParts = oG.RunWith(kPass1, [ :a = aBig ], [ :n = nParts ])
	kPass2 = StzKernelMakerQ()
	kPass2.TakesVector(:c)
	kPass2.TakesScalar(:m)
	kPass2.ReturnsVector(:d)
	kPass2.ForEachElement('{ @d = sum(k, 0, m, @c[k]) }')
	aTotal = oG.RunWith(kPass2, [ :c = aParts, :m = nParts ], [ :n = 1 ])
	nCpu = 0
	for x in aBig
		nCpu += x
	next
	? "  pass 2: the fold of " + nParts + " partials -> " + aTotal[1] + "   (the CPU's sum " + nCpu + ")"
	chk("the second pass folds the partials into the total, within f32 of the CPU's sum", fabs(aTotal[1] - nCpu) < 0.5)
	aV = oG.VerifySpecWith(kPass2, kPass2, [ :c = aParts, :m = nParts ], [ :n = 1 ])
	chk("...and the fold verifies itself (one element, the hidden shape one element too)", aV[:verdict] = "verified")
ok

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
