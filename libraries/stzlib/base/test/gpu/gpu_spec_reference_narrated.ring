# GK6 -- THE USER KERNEL'S OWN REFERENCE (SOFTANZA_GPU_PLAN.md, GK6).
#
# GK0 compares a candidate with a REFERENCE KERNEL on the device. A kernel a
# user writes through stzKernelMaker had no reference of its own, so the
# checker could not check it without a Zig twin. GK6 gives it one: the
# engine INTERPRETS the same description the transpiler turns into WGSL --
# one grammar, one whitelist, two readers held to agree -- and evaluates it
# on the CPU as the reference, element by element, in f32 with WGSL's
# meanings. The candidate's output buffer carries a NaN MARGIN after its
# region; a store past the region lands there and is named by index. A
# declared shape that disagrees with its buffers is refused before dispatch.
#
# What this suite asserts, negative siblings beside each:
#   - the interpreter answers on the CPU with no device: values, WGSL's
#     round-to-even and truncated %, a refusal naming the offender
#   - the CONTROL: a description against its own transpiled kernel verifies,
#     exactly, at both shapes; the description's operation count is the
#     FLOPs the compute ceiling reads
#   - an equivalent kernel verifies; a WRONG OPERATOR is refused with the
#     first bad element named; the CHEAT is caught on the hidden shape
#   - a description whose function returns NaN is refused (NaN agrees with
#     nothing, the band's rule)
#   - a kernel WITHOUT ITS BOUNDS GUARD writes past the region: the margin
#     names the first index; the guarded sibling passes (the fixture that
#     had nothing to catch it before GK6)
#   - a shape that disagrees with its buffers is refused BEFORE dispatch,
#     with both numbers
#   - without a device, VerifySpec refuses by name
#
# Run with Ring++: rnxc gpu_spec_reference_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(6)

? "-- Scene 0: the interpreter, no device needed --"
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesScalar(:s)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = @a * 2 + s }')
aOut = k.EvaluateOn([ :a = [1, 2, 3], :s = 1 ])
? "  @c = @a * 2 + s over [1,2,3], s = 1 -> " + @@(aOut)
chk("the interpreter evaluates the description element by element", len(aOut) = 3 and aOut[1] = 3 and aOut[2] = 5 and aOut[3] = 7)
chk("...and counts its operations per element (2: * and +)", k.OperationsPerElement() = 2)
kR = StzKernelMakerQ()
kR.TakesVector(:x)
kR.ReturnsVector(:y)
kR.ForEachElement('{ @y = round(@x) + (@x % 3) }')
aR = kR.EvaluateOn([ :x = [2.5, 3.5, -7] ])
? "  round(@x) + (@x % 3) over [2.5, 3.5, -7] -> " + @@(aR)
chk("round goes to EVEN as in WGSL (2.5 -> 2, 3.5 -> 4) and % truncates (-7 % 3 = -1)",
	aR[1] = 4.5 and aR[2] = 4.5 and aR[3] = -8)
bRaised = FALSE
cMsg = ""
try
	kBad = StzKernelMakerQ()
	kBad.TakesVector(:a)
	kBad.ReturnsVector(:c)
	kBad.ForEachElement('{ @c = foo(@a) }')
	kBad.EvaluateOn([ :a = [1] ])
catch
	bRaised = TRUE
	cMsg = cCatchError
done
chk("an unknown function is refused, naming it", bRaised and StzFindFirst("foo", cMsg) > 0)
bRaised = FALSE
try
	kVec = StzKernelMakerQ()
	kVec.TakesVector(:a)
	kVec.TakesVector(:b)
	kVec.ReturnsVector(:c)
	kVec.ForEachElement('{ @c = dot(@a, @b) }')
	kVec.EvaluateOn([ :a = [1], :b = [2] ])
catch
	bRaised = TRUE
	cMsg = cCatchError
done
chk("a vector-only name is refused as not elementwise (the transpiler would let WGSL fail later)",
	bRaised and StzFindFirst("vectors", cMsg) > 0)

nN = 4096
aData = []
for i = 0 to nN - 1
	aData + i
next

kDouble = StzKernelMakerQ()
kDouble.TakesVector(:a)
kDouble.ReturnsVector(:c)
kDouble.ForEachElement('{ @c = @a * 2 }')

oG = new stzGpu
if NOT oG.IsAvailable()
	? "  NO GPU ON THIS MACHINE -- the device scenes need one; Scene 0 and the refusal are the coverage"
else
	? "  device: " + oG.DeviceName()
	? ""
	? "-- Scene 1: the CONTROL -- a description against its own kernel --"
	aV = oG.VerifySpec(kDouble, kDouble, [ :a = aData ])
	? "  verdict " + aV[:verdict] + "   cand " + aV[:candms] + " ms   cpu " + aV[:cpums] + " ms   cpu/gpu " + aV[:speedup] +
		"   flops " + aV[:flops] + "   margin " + aV[:margin] + "   clocks " + aV[:clocks]
	chk("the description verifies its own transpiled kernel", aV[:verdict] = "verified")
	chk("...exactly, at the visible shape", aV[:maxdiff] = 0)
	chk("...and at the hidden one (" + aV[:hiddensize] + ")", aV[:maxdiffhidden] = 0 and aV[:hiddensize] < nN)
	chk("the FLOPs the ceiling reads are the description's: 1 operation x n", aV[:flops] = nN)
	chk("the interpreter's own time is reported, and is positive", aV[:cpums] > 0)
	chk("the margin is 256 floats", aV[:margin] = 256)
	chk("nothing was written past the region", aV[:outsideat] = 0)

	? ""
	? "-- Scene 2: an equivalent kernel is NOT refused --"
	kPlus = StzKernelMakerQ()
	kPlus.TakesVector(:a)
	kPlus.ReturnsVector(:c)
	kPlus.ForEachElement('{ @c = @a + @a }')
	aV = oG.VerifySpec(kDouble, kPlus, [ :a = aData ])
	chk("@a + @a verifies against the description @a * 2", aV[:verdict] = "verified")

	? ""
	? "-- Scene 3: a WRONG OPERATOR is refused, the first bad element NAMED --"
	kWrong = StzKernelMakerQ()
	kWrong.TakesVector(:a)
	kWrong.ReturnsVector(:c)
	kWrong.ForEachElement('{ @c = @a * 3 }')
	aV = oG.VerifySpec(kDouble, kWrong, [ :a = aData ])
	? "  verdict " + aV[:verdict] + "   max |diff| " + aV[:maxdiff] + "   first bad " + aV[:firstbad]
	chk("@a * 3 against @a * 2 is a MISMATCH", aV[:verdict] = "mismatch")
	chk("...from the second element (the first is 0 either way)", aV[:firstbad] = 2)
	chk("...by at most 4095 (the last element: 3 x 4095 - 2 x 4095)", aV[:maxdiff] = 4095)
	chk("...and a mismatch is not timed", aV[:candms] = 0)

	? ""
	? "-- Scene 4: THE CHEAT -- right on everything it was shown, and caught --"
	cCheat = "struct StzTile { xoff: u32, p0: u32, p1: u32, p2: u32 };" + char(10) +
		"struct P { n: u32, pad: u32 };" + char(10) +
		"@group(0) @binding(0) var<uniform> tile : StzTile;" + char(10) +
		"@group(0) @binding(1) var<uniform> p : P;" + char(10) +
		"@group(0) @binding(2) var<storage, read> a : array<f32>;" + char(10) +
		"@group(0) @binding(3) var<storage, read_write> c : array<f32>;" + char(10) +
		"@compute @workgroup_size(256)" + char(10) +
		"fn main(@builtin(global_invocation_id) gid : vec3<u32>) {" + char(10) +
		"  let i = gid.x + tile.xoff * 256u;" + char(10) +
		"  if (i < p.n) { c[i] = f32(i) * 2.0 + 0.0 * a[i]; }" + char(10) +
		"}" + char(10)
	aV = oG.VerifySpec(kDouble, cCheat, [ :a = aData ])
	? "  verdict " + aV[:verdict] + "   visible max |diff| " + aV[:maxdiff] + "   hidden max |diff| " + aV[:maxdiffhidden]
	chk("the cheat is EXACT at the visible shape", aV[:maxdiff] = 0)
	chk("...and CAUGHT at the hidden one", aV[:verdict] = "mismatch-hidden")

	? ""
	? "-- Scene 5: a description that returns NaN is refused -- NaN agrees with nothing --"
	aNeg = []
	for i = 0 to nN - 1
		aNeg + (i - 1)
	next
	kSqrt = StzKernelMakerQ()
	kSqrt.TakesVector(:a)
	kSqrt.ReturnsVector(:c)
	kSqrt.ForEachElement('{ @c = sqrt(@a) }')
	aV = oG.VerifySpec(kSqrt, kSqrt, [ :a = aNeg ])
	? "  sqrt(@a) with a[1] = -1: verdict " + aV[:verdict] + "   first bad " + aV[:firstbad]
	chk("sqrt of a negative is NaN on both sides and still a MISMATCH (the band's NaN rule)", aV[:verdict] = "mismatch")
	chk("...at the first element, the only negative one", aV[:firstbad] = 1)

	? ""
	? "-- Scene 6: THE MARGIN -- a kernel without its bounds guard writes past the region --"
	# n = 4000 is not a multiple of 256: the last workgroup's tail (96 threads) has
	# nothing to write and, unguarded, writes indices 4000..4095 into the margin
	nM = 4000
	aM = []
	for i = 0 to nM - 1
		aM + (i * 0.5)
	next
	cHead = "struct StzTile { xoff: u32, p0: u32, p1: u32, p2: u32 };" + char(10) +
		"struct P { n: u32, pad: u32 };" + char(10) +
		"@group(0) @binding(0) var<uniform> tile : StzTile;" + char(10) +
		"@group(0) @binding(1) var<uniform> p : P;" + char(10) +
		"@group(0) @binding(2) var<storage, read> v_a : array<f32>;" + char(10) +
		"@group(0) @binding(3) var<storage, read_write> v_c : array<f32>;" + char(10) +
		"@compute @workgroup_size(256)" + char(10) +
		"fn main(@builtin(global_invocation_id) gid : vec3<u32>) {" + char(10) +
		"  let i = gid.x + tile.xoff * 256u;" + char(10)
	# the unguarded kernel still READS p (the term is zero): a kernel that never
	# touches p gets a layout without binding 1 and is refused outright -- Scene 6b
	cUnguarded = cHead + "  v_c[i] = v_a[i] * 2.0 + 0.0 * f32(p.n);" + char(10) + "}" + char(10)
	cGuarded = cHead + "  if (i < p.n) { v_c[i] = v_a[i] * 2.0; }" + char(10) + "}" + char(10)
	aV = oG.VerifySpec(kDouble, cUnguarded, [ :a = aM ])
	? "  unguarded: verdict " + aV[:verdict] + "   first store outside the region at " + aV[:outsideat]
	chk("the unguarded kernel is refused as WRITE-OUTSIDE", aV[:verdict] = "write-outside")
	chk("...and the first index past the region is named (4001, 1-based: element n)", aV[:outsideat] = nM + 1)
	chk("...with no value verdict claimed", aV[:firstbad] = 0)
	aV = oG.VerifySpec(kDouble, cGuarded, [ :a = aM ])
	chk("the GUARDED sibling at the same n verifies (the negative sibling)", aV[:verdict] = "verified")
	chk("...and wrote nothing past the region", aV[:outsideat] = 0)

	? ""
	? "-- Scene 6b: a kernel that never reads the params uniform is REFUSED by name, not a crash --"
	# the auto layout drops binding 1 when nothing reads p; the layer's bind group then
	# carries an entry the layout lacks. Before GK6 this PANICKED the process at submit.
	cNoParams = cHead + "  v_c[i] = v_a[i] * 2.0;" + char(10) + "}" + char(10)
	bRaised = FALSE
	cMsg = ""
	try
		oG.VerifySpec(kDouble, cNoParams, [ :a = aM ])
	catch
		bRaised = TRUE
		cMsg = cCatchError
	done
	? "  " + cMsg
	chk("a kernel ignoring the params binding is refused (status 5), the process lives", bRaised and StzFindFirst("status 5", cMsg) > 0)
	chk("...and the refusal names the binding", StzFindFirst("ind", cMsg) > 0)

	? ""
	? "-- Scene 7: THE SHAPE ASSERT -- a declared shape that disagrees with its buffers is refused before dispatch --"
	nK = StzEngineGpuKernelCompile(kDouble.ToWGSL())
	nSmall = StzEngineGpuBufferNew(100 * 4)
	nOut = StzEngineGpuBufferNew((nN + 256) * 4)
	nSt = StzEngineGpuVerifySpec(kDouble.Spec(), nK, nN, [], [ nSmall, nOut ], 16, 7, [ nSmall, nOut ], 1, 7, 0.000001)
	cWhy = StzEngineGpuVerifyError()
	? "  status " + nSt + ": " + cWhy
	chk("an input of 100 floats under a declared n of 4096 is refused (bad argument)", nSt = 3)
	chk("...naming both numbers", StzFindFirst("4096", cWhy) > 0 and StzFindFirst("100", cWhy) > 0)
	nNoMargin = StzEngineGpuBufferNew(nN * 4)
	nIn = StzEngineGpuBufferNew(nN * 4)
	nSt = StzEngineGpuVerifySpec(kDouble.Spec(), nK, nN, [], [ nIn, nNoMargin ], 16, 7, [ nIn, nNoMargin ], 1, 7, 0.000001)
	cWhy = StzEngineGpuVerifyError()
	chk("an output without room for the margin is refused too, saying so", nSt = 3 and StzFindFirst("margin", cWhy) > 0)
	StzEngineGpuBufferFree(nSmall)
	StzEngineGpuBufferFree(nOut)
	StzEngineGpuBufferFree(nNoMargin)
	StzEngineGpuBufferFree(nIn)
	nSt = StzEngineGpuVerifySpec("in a" + char(10) + "out c" + char(10) + "body { @c = nope(@a) }", nK, nN, [], [ 1, 2 ], 16, 7, [ 1, 2 ], 1, 7, 0.000001)
	cWhy = StzEngineGpuVerifyError()
	chk("a refused description refuses the check, with the transpiler's own message", nSt = 3 and StzFindFirst("nope", cWhy) > 0)

	? ""
	? "-- Scene 8: the device goes away; VerifySpec refuses by name --"
	StzEngineGpuShutdown()
	bRaised = FALSE
	try
		oG.VerifySpec(kDouble, kDouble, [ :a = aData ])
	catch
		bRaised = StzFindFirst("no GPU device", cCatchError) > 0
	done
	chk("VerifySpec without a device raises, naming the device", bRaised)
ok

if NOT oG.IsAvailable()
	bRaised = FALSE
	try
		oG.VerifySpec(kDouble, kDouble, [ :a = aData ])
	catch
		bRaised = StzFindFirst("device", lower(cCatchError)) > 0
	done
	chk("without a device, VerifySpec refuses by name (CI coverage)", bRaised)
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
