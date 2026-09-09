# GK0 -- THE CHECKER as an engine primitive (SOFTANZA_GPU_PLAN.md, GK).
#
# Proteus's lesson: generation is the cheap step; the checker is the
# product, and a number that beats the bus is a measurement defect. So
# stzGpu.Verify() hands a REFERENCE and a CANDIDATE kernel to the engine,
# which compares them at the visible shape AND at a hidden one (different
# size, DIFFERENT data -- the checker's, never the caller's), times both
# the same way (warm on both sides, alternating, warm-min, two clocks
# where the adapter has them), and refuses by name any time faster than
# the floors it MEASURED on this device.
#
# What this suite asserts, negative siblings first:
#   - the CONTROL: a kernel verified against itself is equal, and its
#     "speedup" sits inside the measured jitter -- the arm that must not move
#   - an equivalent formulation verifies (no false refusal)
#   - a WRONG candidate is refused, with the first bad element NAMED
#   - THE CHEAT: a candidate that answers the visible fixture without
#     reading its input (out[i] = 2i, when a[i] = i) passes the visible
#     shape and is CAUGHT on the hidden one -- the mechanism Proteus built
#     its checker around, and the one this plane did not have
#   - the ROOFLINE: the judge refuses a physically impossible time and
#     accepts a plausible one, over floors it measured (>0)
#   - the second clock, when present, reads GPU time INSIDE the wall time;
#     absent, ONE clock is recorded, never a failure
#   - without a device, Verify refuses by name

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

decimals(6)

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
	? "  NO GPU ON THIS MACHINE -- the checker needs a device; the refusal scene is the CI coverage"
else
	? "  device: " + oG.DeviceName()
	? ""
	? "-- Scene 1: the CONTROL -- a kernel against itself --"
	aR = oG.Verify(kDouble, kDouble, [ :a = aData ])
	? "  verdict " + aR[:verdict] + "   ref " + aR[:refms] + " ms   cand " + aR[:candms] +
		" ms   speedup " + aR[:speedup] + "   jitter " + aR[:jitterms] + " ms   clocks " + aR[:clocks]
	? "  floors: " + aR[:floorgbs] + " GB/s copy, " + aR[:submitfloorms] + " ms smallest dispatch" +
		"   min possible for this candidate " + aR[:minms] + " ms"
	chk("a kernel verifies against itself", aR[:verdict] = "verified")
	chk("...with ZERO difference at the visible shape", aR[:maxdiff] = 0)
	chk("...and ZERO at the hidden one", aR[:maxdiffhidden] = 0)
	chk("the hidden shape is a different, ODD size (" + aR[:hiddensize] + ")",
		aR[:hiddensize] < nN and aR[:hiddensize] % 2 = 1)
	chk("the floors were MEASURED, not quoted (both > 0)",
		aR[:floorgbs] > 0 and aR[:submitfloorms] > 0)
	chk("the reference itself clears the floor (the measurement is sane)",
		aR[:refms] >= aR[:minms])
	chk("same kernel, same cost: the speedup is inside [0.5, 2] -- the arm that must not move",
		aR[:speedup] >= 0.5 and aR[:speedup] <= 2)
	chk("reps as asked (7 by default)", aR[:reps] = 7)
	if aR[:clocks] = 2
		? "  second clock: ref " + aR[:refgpums] + " ms GPU vs " + aR[:refms] + " ms wall"
		chk("TWO clocks: GPU time is positive", aR[:refgpums] > 0)
		chk("...and sits INSIDE the wall time (a dispatch cannot run longer than its submit+sync)",
			aR[:refgpums] <= aR[:refms])
	else
		? "  ONE clock on this adapter (no timestamp queries) -- a recorded limit, not a failure"
		chk("one clock is reported as one", aR[:clocks] = 1)
		chk("...and the GPU-side readings say so (-1)", aR[:refgpums] = -1)
	ok

	? ""
	? "-- Scene 2: an equivalent formulation is NOT refused --"
	kPlus = StzKernelMakerQ()
	kPlus.TakesVector(:a)
	kPlus.ReturnsVector(:c)
	kPlus.ForEachElement('{ @c = @a + @a }')
	aR = oG.Verify(kDouble, kPlus, [ :a = aData ])
	chk("a + a verifies against a * 2", aR[:verdict] = "verified")
	chk("...exactly, on both shapes", aR[:maxdiff] = 0 and aR[:maxdiffhidden] = 0)

	? ""
	? "-- Scene 3: a WRONG candidate is refused, and the first bad element is NAMED --"
	kOff = StzKernelMakerQ()
	kOff.TakesVector(:a)
	kOff.ReturnsVector(:c)
	kOff.ForEachElement('{ @c = @a * 2 + 0.5 }')
	aR = oG.Verify(kDouble, kOff, [ :a = aData ])
	? "  verdict " + aR[:verdict] + "   max |diff| " + aR[:maxdiff] + "   first bad element " + aR[:firstbad]
	chk("the constant offset is a MISMATCH", aR[:verdict] = "mismatch")
	chk("...by exactly 0.5", aR[:maxdiff] = 0.5)
	chk("...from the FIRST element (1-based at the face)", aR[:firstbad] = 1)
	chk("...and a mismatch is not timed (no speedup claimed for a wrong answer)", aR[:speedup] = 0)

	? ""
	? "-- Scene 4: THE CHEAT -- right on everything it was shown, and caught --"
	# A hand-written kernel on the house binding contract that never uses
	# its input: out[i] = 2i. On the visible fixture a[i] = i, so it is
	# EXACTLY right. The hidden set holds different data at the same
	# indices, and there it is wrong -- which is the whole point of a
	# hidden set the proposer cannot see.
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
	aR = oG.Verify(kDouble, cCheat, [ :a = aData ])
	? "  verdict " + aR[:verdict] + "   visible max |diff| " + aR[:maxdiff] +
		"   hidden max |diff| " + aR[:maxdiffhidden] + "   first bad " + aR[:firstbad]
	chk("the cheat is EXACT on the visible shape (it would have passed a one-shape check)",
		aR[:maxdiff] = 0)
	chk("...and is CAUGHT on the hidden one", aR[:verdict] = "mismatch-hidden")
	chk("...wrong from its first element there", aR[:firstbad] = 1)
	chk("...by a difference that names the trick (2i vs 2a[i], reversed tail)", aR[:maxdiffhidden] > 0)

	? ""
	? "-- Scene 5: the ROOFLINE -- the judge refuses what the bus cannot have done --"
	aF = oG.VerifyFloors()
	? "  measured: " + aF[:floorgbs] + " GB/s, " + aF[:submitfloorms] + " ms per smallest dispatch"
	chk("1 GB in 0.01 ms (100 TB/s) is IMPOSSIBLE", oG.VerifyJudge(1000000000, 0.01) = "impossible")
	chk("a time below half the smallest dispatch is IMPOSSIBLE whatever the bytes",
		oG.VerifyJudge(16, aF[:submitfloorms] / 4) = "impossible")
	chk("32 KB in 5 ms is possible", oG.VerifyJudge(32768, 5) = "verified")
	chk("the reference's own measured time is possible (the negative sibling of the refusal)",
		oG.VerifyJudge(nN * 4 * 2, aR[:refms] + 1) = "verified")

	? ""
	? "-- Scene 6: the device goes away; the checker refuses by name --"
	StzEngineGpuShutdown()
	bRaised = FALSE
	try
		oG.Verify(kDouble, kPlus, [ :a = aData ])
	catch
		bRaised = StzFindFirst("no GPU device", cCatchError) > 0
	done
	chk("Verify without a device raises, naming the device", bRaised)
ok

if NOT oG.IsAvailable()
	bRaised = FALSE
	try
		oG.Verify(kDouble, kDouble, [ :a = aData ])
	catch
		bRaised = StzFindFirst("device", lower(cCatchError)) > 0
	done
	chk("without a device, Verify refuses by name (CI coverage)", bRaised)
ok

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
