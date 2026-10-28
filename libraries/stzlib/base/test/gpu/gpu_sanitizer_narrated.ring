# GZ0 -- THE INTERPRETER AS A SANITIZER (SOFTANZA_GPU_PLAN.md, NEXT; the
# reader's account is base/gpu/SOFTANZA_GPU_KERNELS.md).
#
# The checker compares VALUES: the device's against the interpreter's. Some
# defects of a kernel leave the values alone, or change them only sometimes,
# and the device runs them without a word. The interpreter runs a group a
# stage at a time, so it can watch what the device cannot report.
#
# What the grammar already makes unwritable, held here by its refusals: a
# barrier some threads skip (every barrier stands outside any branch, and a
# tiles count is the same for every thread), and a stage reading the array it
# writes. What remains, and what the sanitizer names with the description's
# line, the threads and the slot:
#   race       two threads of one stage write one slot; the device keeps any
#              one of the writes
#   dropped    a stage writes past its array; the kernel drops the write
#   past       a read past a shared array; it reads 0
#   unwritten  a read of a slot no stage wrote; it reads the zero the kernel
#              filled -- a max or min reduce counts that zero, a sum does not
#
# Measured 2026-10-28 on the RTX 3050 under rnxc, the reason this is a rung:
# 900 generated kernels with a race injected in their first stage; the
# sanitizer named all 900, and comparing the device's values with the
# interpreter's showed only 383 of them -- 517 races came back VERIFIED,
# because the device happened to keep the write the interpreter keeps. The
# quieter three come back verified every time. And 900 kernels the generator
# writes without a race: the sanitizer named none (no false race).
#
# A race is now a VERDICT of a puzzle, before anything runs, in both runners:
# "race at line L". The rest is said under the verdict.
#
# Run with Ring++: rnxc gpu_sanitizer_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

decimals(3)
NLc = char(10)
cHead = "in a" + NLc + "out c" + NLc

? "-- Scene 1: the four defects, named on the CPU, each with its line --"
$t0 = clock()
aA = []
for i = 1 to 1024
	aA + (i - 1)
next
aDefects = [
	[ "race", "shared t 256" + NLc + "stage { @t[@l % 4] = @a }" + NLc + "body { @c = @t[@l % 4] }",
	  "race: line 4, a stage: threads 0 and 4 of group 0 both write slot 0 of @t" ],
	[ "dropped", "shared t 128" + NLc + "stage { @t[@l] = @a }" + NLc + "body { @c = @t[@l % 128] }",
	  "dropped: line 4, a stage: thread 128 of group 0 writes slot 128 of @t, which holds 128" ],
	[ "past", "shared t 256" + NLc + "stage { @t[@l] = @a }" + NLc + "body { @c = @t[@l + 1] }",
	  "past: line 5, the body: thread 255 of group 0 reads slot 256 of @t, which holds 256; it reads 0" ],
	[ "unwritten", "shared t 256" + NLc + "body { @c = @t[255 - @l] }",
	  "unwritten: line 4, the body: thread 0 of group 0 reads slot 255 of @t, which no stage wrote" ],
	[ "unwritten under a max", "shared t 256" + NLc + "stage { @t[@l * 2] = 0 - 1 - @a }" + NLc + "reduce t max" + NLc + "body { @c = @t[0] }",
	  "unwritten: line 5, a reduce: thread 1 of group 0 reads slot 1 of @t, which no stage wrote" ]
]
nD = len(aDefects)
for q = 1 to nD
	aR = StzKernelMakerFromSpec(cHead + aDefects[q][2]).SanitizeOn([ :a = aA ])
	cJoined = ""
	nR = len(aR)
	for r = 1 to nR
		cJoined += aR[r] + NLc
	next
	chk(aDefects[q][1] + ": " + aDefects[q][3], StzFindFirst(aDefects[q][3], cJoined) > 0)
next
aSum = StzKernelMakerFromSpec(cHead + "shared t 256" + NLc + "stage { @t[@l * 2] = 0 - 1 - @a }" + NLc + "reduce t sum" + NLc + "body { @c = @t[0] }").SanitizeOn([ :a = aA ])
chk("...and the same reduce as a SUM is not told off for the unwritten slots (a zero adds nothing), only for the dropped writes",
	len(aSum) = 1 and StzFindFirst("dropped:", aSum[1]) = 1)
aSame = StzKernelMakerFromSpec(cHead + "shared t 256" + NLc + "stage { @t[@l % 4] = 1 }" + NLc + "body { @c = @t[0] }").SanitizeOn([ :a = aA ])
chk("a race in which every thread writes one value is named, and said not to change the answer",
	len(aSame) = 1 and StzFindFirst("the same value, so the answer does not depend on it", aSame[1]) > 0)

cMm = "in a" + NLc + "in b" + NLc + "scalar k" + NLc + "scalar w" + NLc + "out c" + NLc + "width w" + NLc + "shared ta 256" + NLc + "shared tb 256" + NLc +
	"tiles t { k / 16 }" + NLc + "stage { @ta[@ly * 16 + @lx] = @a[@row * k + t * 16 + @lx] }" + NLc + "stage { @tb[@ly * 16 + @lx] = @b[(t * 16 + @ly) * w + @col] }" + NLc +
	"accumulate { @acc = @acc + sum(j, 0, 16, @ta[@ly * 16 + j] * @tb[j * 16 + @lx]) }" + NLc + "body { @c = @acc }"
aMa = []
for i = 1 to 3072
	aMa + ((i % 13) - 6)
next
chk("the references are clean: puzzle 9's reversal, puzzle 10's tiled product, a group sum",
	len(StzKernelMakerFromSpec(cHead + "shared t 256" + NLc + "stage { @t[@l] = @a }" + NLc + "body { @c = @t[255 - @l] }").SanitizeOn([ :a = aA ])) = 0 and
	len(StzKernelMakerFromSpec(cMm).SanitizeOnWith([ :a = aMa, :b = aMa, :k = 64, :w = 48 ], [ :n = 1536 ])) = 0 and
	len(StzKernelMakerFromSpec(cHead + "shared t 256" + NLc + "stage { @t[@l] = @a }" + NLc + "reduce t sum" + NLc + "body { @c = @t[0] }").SanitizeOn([ :a = aA ])) = 0)
chk("a description with no shared memory is clean by construction", len(StzKernelMakerFromSpec(cHead + "body { @c = @a * 2 }").SanitizeOn([ :a = aA ])) = 0)
k1 = StzKernelMakerFromSpec(cHead + "shared t 256" + NLc + "stage { @t[@l] = @a }" + NLc + "body { @c = @t[255 - @l] }")
a1 = k1.EvaluateOn([ :a = aA ])
k1.SanitizeOn([ :a = aA ])
chk("...and watching changes no value: the evaluation after a sanitized run is the same", @@(k1.EvaluateOn([ :a = aA ])) = @@(a1))
? "  (scene 1: " + ((clock() - $t0) / clockspersecond()) + " s)"

? ""
? "-- Scene 2: what the grammar makes unwritable, held by its refusals --"
$t0 = clock()
bC = 0
try
	StzKernelMakerFromSpec(cHead + "shared t 256" + NLc + "tiles u { @i }" + NLc + "stage { @t[@l] = @a }" + NLc + "accumulate { @acc = @acc + @t[@l] }" + NLc + "body { @c = @acc }").ToWGSL()
catch
	bC = (StzFindFirst("the same for every thread", cCatchError) > 0)
done
chk("a tiles count that could differ between threads is refused: every thread reaches every barrier", bC)
bR = 0
try
	StzKernelMakerFromSpec(cHead + "shared t 256" + NLc + "stage { @t[@l] = @t[@l + 1] }" + NLc + "body { @c = @t[0] }").ToWGSL()
catch
	bR = (StzFindFirst("would race", cCatchError) > 0)
done
chk("a stage reading the array it writes is refused: the threads would race", bR)
cW = StzKernelMakerFromSpec(cMm).ToWGSL()
aParts = StzSplit(cW, "if (i < p.n)")
chk("in the tiled product's kernel every barrier comes before the guard's branch, none inside it",
	len(aParts) = 2 and StzFindFirst("workgroupBarrier", aParts[1]) > 0 and StzFindFirst("workgroupBarrier", aParts[2]) = 0)
? "  (scene 2: " + ((clock() - $t0) / clockspersecond()) + " s)"

oG = new stzGpu
bDevice = oG.IsAvailable()
if bDevice
	? ""
	? "-- Scene 3: on the device -- the checker's verdict beside the sanitizer's --"
	$t0 = clock()
	for q = 2 to 5
		k = StzKernelMakerFromSpec(cHead + aDefects[q][2])
		aV = oG.VerifySpecWith(k, k, [ :a = aA ], [ :n = 1024 ])
		chk(aDefects[q][1] + ": the device agrees with the interpreter -- the checker says " + aV[:verdict] + " -- and only the sanitizer names it",
			aV[:verdict] = "verified" and len(k.SanitizeOn([ :a = aA ])) > 0)
	next
	? "  (scene 3: " + ((clock() - $t0) / clockspersecond()) + " s)"
ok

? ""
? "-- Scene 4: a race is a verdict of the puzzles, in both runners --"
$t0 = clock()
oQ = StzKernelPuzzleQ("kp-09")
cRace = "in a" + NLc + "out c" + NLc + "shared t 256" + NLc + "stage { @t[@l % 128] = @a }" + NLc + "body { @c = @t[255 - @l] }"
cShort = "in a" + NLc + "out c" + NLc + "shared t 128" + NLc + "stage { @t[@l] = @a }" + NLc + "body { @c = @t[255 - @l] }"
chk("puzzle 9, two threads per slot: 'race at line 4' (" + oQ.Grade(cRace) + ")", oQ.Grade(cRace) = "race at line 4")
chk("...the same words without a device", oQ.GradeOnCpu(cRace) = "race at line 4")
aS = oQ.Sanitize(cShort)
chk("puzzle 9, an array too short: the verdict stays the values' own, and Sanitize names the dropped writes and the reads past",
	oQ.GradeOnCpu(cShort) = "mismatch at element 1" and len(aS) = 2 and StzFindFirst("dropped:", aS[1]) = 1 and StzFindFirst("past:", aS[2]) = 1)
chk("...and the right answer is clean", len(oQ.Sanitize(oQ.Reference())) = 0 and oQ.GradeOnCpu(oQ.Reference()) = "verified")
cPage = read("../../education/program/courses/kernel-puzzles/runner/puzzle.html")
chk("the browser runner sanitizes the learner's kernel and gives the same race verdict",
	StzFindFirst("stz_gpu_spec_sanitize", cPage) > 0 and StzFindFirst("race at line ${san.raceLine}", cPage) > 0)
? "  (scene 4: " + ((clock() - $t0) / clockspersecond()) + " s)"

if bDevice
	? ""
	? "-- Scene 5: the control -- a race injected in every shared-memory kernel --"
	$t0 = clock()
	StzEngineGpuFuzzRun(20261028, 300, 63, 0.00001)
	chk("300 generated kernels, none with a race: the sanitizer names none (" + StzEngineGpuFuzzResult(37) + "), and the device agrees on all",
		StzEngineGpuFuzzResult(37) = 0 and StzEngineGpuFuzzResult(5) = 300)
	? "  quieter defects named in " + StzEngineGpuFuzzResult(38) + " of them, every one VERIFIED by the checker"
	StzEngineGpuFuzzRun(20261028, 300, 16 + 128, 0.00001)
	nRaces = StzEngineGpuFuzzResult(37)
	nShown = StzEngineGpuFuzzResult(6)
	? "  300 shared-memory kernels with a race: the sanitizer named " + nRaces + "; comparing values showed " + nShown
	chk("every injected race is named (the kill line: a missed race is the sanitizer's defect)", StzEngineGpuFuzzResult(24) = 300 and nRaces = 300)
	chk("...and comparing values alone misses many of them (measured 130 shown of 300 on this seed)", nShown > 0 and nShown < 300)
	? "  (scene 5: " + ((clock() - $t0) / clockspersecond()) + " s)"
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
