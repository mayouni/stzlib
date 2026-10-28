# GT0 -- THE RANDOM-KERNEL FUZZ (SOFTANZA_GPU_PLAN.md, NEXT; the reader's
# account of the language is base/gpu/SOFTANZA_GPU_KERNELS.md).
#
# One description has two readers that share a parser and nothing else: the
# rewriter that writes WGSL and the compiler that builds the interpreter's
# program are separate code. Every other guard checks them on kernels a
# person wrote. This one has the engine GENERATE kernels from the grammar --
# six kinds, from a plain map to the tiled product -- run each on the device
# and through the interpreter, and count. An exact description (inputs,
# scalars and literals in eighths, operations that round nowhere) must agree
# bit for bit; an inexact one within 1e-5 of the value.
#
# Its first run, 2026-10-28, found four defects in a grammar every other
# guard passed, and they are held here by name:
#   - inverseSqrt: names are folded to lower case and the whitelist holds
#     WGSL's camel case, so the transpiler refused every inversesqrt the
#     interpreter admitted (a match would also have emitted a name WGSL lacks)
#   - a guard's parenthesis: '@i < n and (A or B)' reached WGSL, and the
#     interpreter refused it ("missing ')'") -- it read only arithmetic there
#   - untyped literals: a call made only of literals, ceil(0.5), is abstract
#     outside a constant expression and the device refused the kernel; and
#     '3 / 4' was INTEGER division on the device, 0 where the grammar means
#     0.75 -- a silent wrong answer, -0.475 where the interpreter said -0.042
#   - 'and' beside 'or' without parentheses: naga accepts it, Chrome refuses
#     it ("mixing '&&' and '||' requires parenthesis"), so one guard ran on
#     the desktop and failed in a browser; both readers now refuse it
#
# The control: the same run with one wrong operator put in each kernel's WGSL
# (its first ' + ' in the store made ' - '). Measured 2026-10-28 on the RTX
# 3050: 144 of 158 caught, and each of the 14 that escaped was read and
# cannot change an answer (a guard that writes nothing; a term that is zero
# everywhere, as the fractional part of an integer). The band is 1e-5; the
# worst inexact difference measured is 0.07 of it.
#
# Time, measured 2026-10-28 on the RTX 3050 on mains power: 3.2 s for the
# whole guard when the driver has seen these kernels, 57 s the FIRST time --
# 300 kernels the driver compiles once and then keeps in its shader cache.
# The seed is fixed so the cost is paid once per machine, not once per run.
#
# Run with Ring++: rnxc gpu_fuzz_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(6)
NLc = char(10)
nSeed = 20261028
nAll = 63
nMutate = 64

? "-- Scene 1: the four defects the first run found, held on the device --"
$t0 = clock()
oG = new stzGpu
bDevice = oG.IsAvailable()
aA = []
for i = 1 to 3000
	aA + ((((i * 7) % 33) - 16) / 8)
next

kInv = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "body { @c = inversesqrt(abs(@a) + 0.5) + InverseSqrt(2) }")
cW = kInv.ToWGSL()
chk("inversesqrt, in any case, is admitted by the transpiler and written in WGSL's spelling",
	StzFindFirst("inverseSqrt(abs(v_a[i]) + 0.5f) + inverseSqrt(2f)", cW) > 0 and StzFindFirst("inversesqrt", cW) = 0)
kPar = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "guard { @i < n and (@a > 1 or @i < 2) }" + NLc + "body { @c = @a * 2 }")
aP = kPar.EvaluateOnWith([ :a = [ 0, 0, 0, 3, 0.5 ] ], [ :n = 5 ])
chk("a guard's parenthesis holds a condition in the interpreter: 0 and 1 by the index, 3 by the value, 2 and 4 unwritten",
	aP[1] = 0 and aP[2] = 0 and aP[4] = 6 and aP[3] != aP[3] and aP[5] != aP[5])
kDiv = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "body { @c = @a * 0 + 3 / 4 + ceil(0.5) }")
chk("every literal is an f32 in the WGSL: '3f / 4f', 'ceil(0.5f)'",
	StzFindFirst("3f / 4f", kDiv.ToWGSL()) > 0 and StzFindFirst("ceil(0.5f)", kDiv.ToWGSL()) > 0)
chk("...and the interpreter means 3 / 4 as 0.75", kDiv.EvaluateOn([ :a = [ 1, 2 ] ])[1] = 1.75)
cMix = "in a" + NLc + "out c" + NLc + "guard { @i < n and @a > 0 or @a < -1 }" + NLc + "body { @c = @a }"
bRefT = 0
try
	StzKernelMakerFromSpec(cMix).ToWGSL()
catch
	bRefT = (StzFindFirst("need parentheses", cCatchError) > 0)
done
chk("'and' beside 'or' without parentheses: the transpiler refuses it, naming the parentheses", bRefT)
bRefI = 0
try
	StzKernelMakerFromSpec(cMix).EvaluateOn([ :a = [ 1, 2 ] ])
catch
	bRefI = (StzFindFirst("need parentheses", cCatchError) > 0)
done
chk("...and the interpreter refuses it in the same words", bRefI)

if bDevice
	aKs = [ [ "inversesqrt", kInv ], [ "the parenthesised guard", kPar ], [ "3 / 4 and ceil(0.5)", kDiv ] ]
	nKs = len(aKs)
	for q = 1 to nKs
		aV = oG.VerifySpecWith(aKs[q][2], aKs[q][2], [ :a = aA ], [ :n = 2000 ])
		chk("on the device, " + aKs[q][1] + ": the kernel compiles and agrees with the interpreter (" + aV[:verdict] + ", maxdiff " + aV[:maxdiff] + ")",
			aV[:verdict] = "verified")
	next
	kParen = StzKernelMakerFromSpec("in a" + NLc + "out c" + NLc + "guard { (@i < n and @a > 0) or (@i < n and @a < -1) }" + NLc + "body { @c = @a }")
	aV = oG.VerifySpecWith(kParen, kParen, [ :a = aA ], [ :n = 2000 ])
	chk("...and 'and' beside 'or' written with parentheses runs and agrees (" + aV[:verdict] + ")", aV[:verdict] = "verified")
ok
? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

? ""
? "-- Scene 2: three hundred generated kernels, six kinds, both readers --"
$t0 = clock()
nSt = StzEngineGpuFuzzRun(nSeed, 300, nAll, 0.00001)
? "  generated " + StzEngineGpuFuzzResult(0) + "; ran " + StzEngineGpuFuzzResult(4) + " (exact " + StzEngineGpuFuzzResult(9) + ", inexact " + StzEngineGpuFuzzResult(10) +
	"); agreed " + StzEngineGpuFuzzResult(5) + "; elements compared " + StzEngineGpuFuzzResult(16) + ", left unwritten by a guard " + StzEngineGpuFuzzResult(36) +
	"; worst inexact difference " + StzEngineGpuFuzzResult(11) + " of the band; " + StzEngineGpuFuzzResult(14) + " ms"
cLog = StzEngineGpuFuzzLog()
if cLog != ""
	? cLog
	? StzEngineGpuFuzzFirst()
ok
for k = 0 to 5
	? "  kind " + k + ": generated " + StzEngineGpuFuzzResult(20 + k) + ", defective " + StzEngineGpuFuzzResult(30 + k)
next
chk("300 descriptions generated, 50 of each of the six kinds",
	StzEngineGpuFuzzResult(0) = 300 and StzEngineGpuFuzzResult(20) = 50 and StzEngineGpuFuzzResult(25) = 50)
chk("no description refused by both readers (the generator writes the grammar)", StzEngineGpuFuzzResult(1) = 0)
chk("no description admitted by one reader and refused by the other", StzEngineGpuFuzzResult(2) = 0)
if bDevice
	chk("the device compiled every kernel the transpiler wrote", StzEngineGpuFuzzResult(3) = 0 and StzEngineGpuFuzzResult(15) = 0)
	chk("all 300 ran, and agreed with the interpreter", StzEngineGpuFuzzResult(4) = 300 and StzEngineGpuFuzzResult(5) = 300)
	chk("...the exact ones bit for bit, and they are more than half (" + StzEngineGpuFuzzResult(9) + ")",
		StzEngineGpuFuzzResult(17) = 0 and StzEngineGpuFuzzResult(9) > 150)
	chk("no kernel stored past its region or where its guard said not to", StzEngineGpuFuzzResult(7) = 0)
	chk("the guards were exercised: over a thousand elements left unwritten and checked so", StzEngineGpuFuzzResult(36) > 1000)
else
	? "  (no device: the admission checks ran; the device's comparisons were NOT run)"
ok
? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

if bDevice
	? ""
	? "-- Scene 3: the control -- one wrong operator in each kernel must be caught --"
	$t0 = clock()
	StzEngineGpuFuzzRun(nSeed, 300, nAll + nMutate, 0.00001)
	nMut = StzEngineGpuFuzzResult(18)
	nCaught = StzEngineGpuFuzzResult(19)
	? "  mutated " + nMut + ", caught " + nCaught
	chk("over a hundred kernels had an operator to break", nMut > 100)
	chk("...and at least 85% of them were caught (measured 91% on seed 11; every escape read was unable to change an answer)",
		nCaught >= 0.85 * nMut)
	? "  (scene 3: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 4: a case is two numbers -- the run is deterministic --"
$t0 = clock()
c1 = StzEngineGpuFuzzCase(nSeed, 41, nAll)
c2 = StzEngineGpuFuzzCase(nSeed, 41, nAll)
chk("case 41 of the seed is one description, every time it is asked for", c1 = c2 and c1 != "")
chk("...and another seed gives another one", StzEngineGpuFuzzCase(nSeed + 1, 41, nAll) != c1)
if bDevice
	StzEngineGpuFuzzRun(nSeed, 60, nAll, 0.00001)
	n1 = StzEngineGpuFuzzResult(16)
	StzEngineGpuFuzzRun(nSeed, 60, nAll, 0.00001)
	chk("two runs of one seed compare the same number of elements (" + n1 + ")", StzEngineGpuFuzzResult(16) = n1 and n1 > 0)
ok
? "  (scene 4: " + ((clock() - $t0) / clockspersecond()) + " s)"

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
