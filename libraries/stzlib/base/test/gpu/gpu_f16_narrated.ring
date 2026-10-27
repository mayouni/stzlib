# GK5 -- F16 WEIGHTS ON THE DEVICE (SOFTANZA_GPU_PLAN.md, GK5).
#
# The device asks for shader-f16 when the adapter offers it (subgroups are
# noted, never requested). The matmul template gains a form that stores B --
# the weights, in the backbone -- as f16 in VRAM and widens each read to f32;
# the accumulation stays f32. The resident backbone keeps its weight
# matrices at f16 on a path BESIDE the f32 one, off unless asked, so the two
# can alternate. f16 accumulation is not in scope: the storage number did
# not earn the question (measured 2026-10-27: 2-6% on the kernels, about 2%
# on the forward).
#
# What this suite asserts, bands set from measurement (about ten times the
# differences measured on 2026-10-27 on the RTX 3050):
#   - the adapter's features are reported, and a granted device runs the
#     f16 form: on MiniLM's three matmul shapes at 130 tokens, register-
#     blocked, the f16 result stays within 2e-3 of an f64 product (measured
#     6.85e-4 at |ref| 3.6) while the f32 one stays within 1e-5 (5.3e-6);
#     neither form is slower than the other by a third
#   - the backbone (MiniLM, when the model is present): f16 binds exactly
#     half the weight bytes; at a hidden shape (68 tokens) its embedding is
#     within 2e-6 of the f32 path's by cosine (1.5e-7), and as close to the
#     CPU forward as the f32 path is (within 1e-5 of the same distance)
#   - the default is f32: asked off, the forward runs on f32 weights
#
# Run with Ring++: rnxc gpu_f16_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(9)

? "-- Scene 1: the device's features, and the f16 matmul against an f64 product --"
$t0 = clock()
oG = new stzGpu
bDevice = oG.IsAvailable()
if bDevice
	? "  adapter: " + oG.DeviceName() + "; shader-f16 offered " + StzEngineGpuFeature(0) + ", granted " + StzEngineGpuFeature(1) +
		"; subgroups offered " + StzEngineGpuFeature(2) + " (noted, never requested)"
	chk("a feature the adapter offers is granted (shader-f16: offered " + StzEngineGpuFeature(0) + ", granted " + StzEngineGpuFeature(1) + ")",
		StzEngineGpuFeature(1) = StzEngineGpuFeature(0))
	if StzEngineGpuFeature(1) = 1
		for aS in [ [ 130, 384, 384 ], [ 130, 384, 1536 ], [ 130, 1536, 384 ] ]
			nSt = StzEngineGpuFoundryMatmulF16(aS[1], aS[2], aS[3], 7, 3)
			cS = "" + aS[1] + " x " + aS[2] + " x " + aS[3]
			nE32 = StzEngineGpuFoundryF16Result(11)
			nE16 = StzEngineGpuFoundryF16Result(12)
			nR = StzEngineGpuFoundryF16Result(7)
			if nR < 0
				nR = StzEngineGpuFoundryF16Result(8)
			ok
			? "  " + cS + " reg4: f32 " + StzEngineGpuFoundryF16Result(3) + " ms, f16 " + StzEngineGpuFoundryF16Result(4) + " ms on the GPU clock, f32/f16 " + nR +
				"; error f32 " + nE32 + ", f16 " + nE16 + " against |ref| up to " + StzEngineGpuFoundryF16Result(14)
			chk(cS + ": both forms ran, alternated four times", nSt = 0 and StzEngineGpuFoundryF16Result(0) = 1 and StzEngineGpuFoundryF16Result(15) = 4)
			chk("...the f32 form within 1e-5 of the f64 product", nE32 < 0.00001)
			chk("...the f16 form within 2e-3 (the weights rounded to f16 once, at upload)", nE16 < 0.002)
			chk("...and it is MORE than the f32 error: the f16 path really ran on f16 weights", nE16 > 10 * nE32)
			chk("...neither form slower than the other by a third", nR > 0.75 and nR < 1.33)
		next
	ok
ok
? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

cModel = "../../../models/all-MiniLM-L6-v2.Q8_0.gguf"
if bDevice and fexists(cModel)
	? ""
	? "-- Scene 2: the resident backbone on MiniLM, f32 and f16 weights --"
	$t0 = clock()
	chk("the model loads (its digest recorded beside it)", StzEngineNeuralModelLoad(cModel) = 1)
	cHid = ""
	for i = 1 to 6
		cHid += "a hidden sentence with other words in it, said again "
	next
	nMin = StzEngineNeuralBackboneMinTokens()
	StzEngineNeuralBackboneSetMinTokens(1000000)
	nDim = StzEngineNeuralEmbed(cHid)
	StzEngineNeuralBackboneSetMinTokens(nMin)
	aCpu = []
	for i = 1 to nDim
		aCpu + StzEngineNeuralEmbedAt(i - 1)
	next
	StzEngineNeuralBackboneSetWeightsF16(0)
	a32 = StzEngineNeuralBackboneEmbed(cHid)
	n32 = StzEngineNeuralBackboneWeightBytes()
	chk("asked off, the forward runs on f32 weights", StzEngineNeuralBackboneWeightsF16() = 0 and len(a32) = nDim)
	chk("...in 62 dispatches (GK4's count: 1 + 10 per layer x 6 + 1; GELU stays a pass of its own)", StzEngineNeuralBackboneDispatches() = 62)
	if StzEngineNeuralBackboneF16Available() = 1
		StzEngineNeuralBackboneSetWeightsF16(1)
		a16 = StzEngineNeuralBackboneEmbed(cHid)
		n16 = StzEngineNeuralBackboneWeightBytes()
		StzEngineNeuralBackboneSetWeightsF16(0)
		chk("asked on, with shader-f16 granted, the forward runs on f16 weights", StzEngineNeuralBackboneWeightsF16() = 1 and len(a16) = nDim)
		? "  weight matrices bound per forward: " + n32 + " bytes in f32, " + n16 + " in f16"
		chk("...binding exactly half the weight bytes", n16 * 2 = n32 and n32 > 0)
		nD = 1 - cosv(a32, a16)
		n32c = 1 - cosv(aCpu, a32)
		n16c = 1 - cosv(aCpu, a16)
		? "  " + StzEngineNeuralTokenize(cHid) + " tokens: 1 - cos(f32, f16) " + nD + "; from the CPU forward: f32 " + n32c + ", f16 " + n16c
		chk("at the hidden shape the f16 embedding is within 2e-6 of the f32 one by cosine (measured 1.5e-7)", nD < 0.000002)
		chk("...and as close to the CPU forward as the f32 path is (within 1e-5 of the same distance)", fabs(n16c - n32c) < 0.00001)
	ok
	StzEngineNeuralModelFree()
	? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"
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

func cosv a, b
	n = 0
	na = 0
	nb = 0
	for i = 1 to len(a)
		n += a[i] * b[i]
		na += a[i] * a[i]
		nb += b[i] * b[i]
	next
	return n / sqrt(na * nb)
