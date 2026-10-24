# KP1 -- THE PUZZLE FORM AND ITS RUNNERS (SOFTANZA_GPU_PLAN.md, KP1).
#
# A kernel puzzle is an exercise of the Learning System in the System's own
# shape -- exercise.zknw, task.<lang>.md, promise.ring, right/, wrong/ --
# plus two texts the grammar reads, reference.txt and starter.txt, and data
# facts the two runners build the same vectors from. The promise is ONE
# WORD, the checker's verdict; the learner's program builds a description
# and prints what the grader says of it. The desktop runner is
# stzKernelPuzzle over the face; the browser runner is a page over stz.wasm
# and WebGPU, in the edge proof's shape; the same text gets the same words.
#
# What this suite asserts, negative siblings beside each:
#   - the course is declared and opens through the program; the puzzle
#     folder is an exercise the System reads (its promise, its right/ and
#     wrong/ counts, its task in four languages)
#   - the puzzle opens: its facts give n and the data, its reference and its
#     starter read; a description text round-trips through FromSpec
#   - the starter grades "waiting for your implementation" (a puzzle starts
#     red); a refused description grades "refused: ..." naming the offender;
#     the task's inputs must be declared in the task's order
#   - on the CPU alone, with no device: the right answers grade verified,
#     the wrong operator is named at its element, the cheat at the hidden shape
#   - on the device: the same four verdicts, word for word -- the two paths
#     agree -- and the dropped guard is write-outside at n + 1 (the mistake
#     only a device shows)
#   - the exercise PROVES ITSELF through the System's own checker: every
#     wrong answer refused, every right answer accepted, by running them
#
# Run with Ring++: rnxc gpu_puzzle_narrated.ring

load "../../stzBase.ring"

$nPass = 0
$nFail = 0

pr()

? "-- Scene 0: the course and the puzzle, as the Learning System reads them --"
oP = StzProgramQ("../../education/program")
chk("the program declares the course kernel-puzzles", StzFindFirst("kernel-puzzles", oP.Courses()) > 0)
oCk = oP.CourseQ("kernel-puzzles")
chk("...and the course names its eight puzzles in four chapters", len(oCk.ChapterIds()) = 4)
bOpens = TRUE
try
	oC = oP.CourseQ("kernel-puzzles")
catch
	bOpens = FALSE
done
chk("...and the course opens through the program", bOpens)
oEx = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/kp-01")
chk("kp-01 is an exercise the System reads: its promise is the one word 'verified'", len(oEx.Promises()) = 1 and ring_trim(oEx.Promises()[1]) = "verified")
chk("...with two right answers and three wrong ones shipped", len(oEx.RightAnswers()) = 2 and len(oEx.WrongAnswers()) = 3)
chk("...and a task in the four languages (fr, ar, ha marked as provisional translations)",
	oEx.HasTaskIn("en") and oEx.HasTaskIn("fr") and oEx.HasTaskIn("ar") and oEx.HasTaskIn("ha"))

oPz = StzKernelPuzzleQ("kp-01")
? "  reference: " + StzReplace(oPz.Reference(), char(10), " / ") + "   n = " + oPz.Elements()
chk("the puzzle opens with n from its facts", oPz.Elements() = 4000)
chk("...its reference is the task's description", StzFindFirst("@c = @a * 2", oPz.Reference()) > 0)
chk("...its starter has no body (red until the learner writes one)", StzFindFirst("body", oPz.Starter()) = 0)
aB = oPz.Bindings()
chk("...and its data is built from its facts: one input a, a ramp of 4000", len(aB) = 1 and aB[1][1] = "a" and len(aB[1][2]) = 4000 and aB[1][2][1] = 0 and aB[1][2][4000] = 3999)
chk("the task reads in English and in French", StzFindFirst("Puzzle 1", oPz.Task("en")) > 0 and StzFindFirst("1", oPz.Task("fr")) > 0)
oK = StzKernelMakerFromSpec(oPz.Reference())
chk("a description text round-trips through FromSpec", ring_trim(oK.Spec()) = ring_trim(oPz.Reference()))

? ""
? "-- Scene 1: the verdicts no device is needed for --"
chk("the starter grades 'waiting for your implementation'", oPz.Grade(oPz.Starter()) = "waiting for your implementation")
kEmpty = StzKernelMakerQ()
kEmpty.TakesVector(:a)
kEmpty.ReturnsVector(:c)
chk("...and so does a maker with no body", oPz.Grade(kEmpty) = "waiting for your implementation")
cV = oPz.Grade("in a" + char(10) + "out c" + char(10) + "body { @c = foo(@a) }")
? "  " + cV
chk("a refused description grades 'refused: ...' naming the offender", StzLeft(cV, 8) = "refused:" and StzFindFirst("foo", cV) > 0)
cV = oPz.GradeOnCpu("in a" + char(10) + "out c" + char(10) + "body { @c = @a * 2 }")
chk("on the CPU alone, the right answer grades 'verified'", cV = "verified")
chk("...and so does the other right answer", oPz.GradeOnCpu("in a" + char(10) + "out c" + char(10) + "body { @c = @a + @a }") = "verified")
cV = oPz.GradeOnCpu("in a" + char(10) + "out c" + char(10) + "body { @c = @a * 3 }")
? "  " + cV
chk("...the wrong operator is a mismatch at element 2 (the first is 0 either way)", cV = "mismatch at element 2")
cV = oPz.GradeOnCpu("in a" + char(10) + "out c" + char(10) + "body { @c = @i * 2 }")
? "  " + cV
chk("...the cheat (twice the INDEX, right where a[i] = i) is caught at the hidden shape, element 1", cV = "mismatch-hidden at element 1")
cV = oPz.GradeOnCpu("in b" + char(10) + "out c" + char(10) + "body { @c = @b * 2 }")
chk("...an input not the task's is refused, naming yours and the task's", StzLeft(cV, 8) = "refused:" and StzFindFirst('"b"', cV) > 0 and StzFindFirst('"a"', cV) > 0)

if StzEngineGpuInit($cStzGpuRuntime) = 0 or StzEngineGpuIsAvailable() = 0
	? "  NO GPU ON THIS MACHINE -- the device scenes need one; Scenes 0 and 1 are the coverage"
else
	? ""
	? "-- Scene 2: the same text on the device, the same words --"
	chk("the right answer grades 'verified' on the device", oPz.Grade("in a" + char(10) + "out c" + char(10) + "body { @c = @a * 2 }") = "verified")
	chk("...the other right answer too", oPz.Grade("in a" + char(10) + "out c" + char(10) + "body { @c = @a + @a }") = "verified")
	chk("...the wrong operator: the SAME words as the CPU path", oPz.Grade("in a" + char(10) + "out c" + char(10) + "body { @c = @a * 3 }") = "mismatch at element 2")
	chk("...the cheat: the SAME words as the CPU path", oPz.Grade("in a" + char(10) + "out c" + char(10) + "body { @c = @i * 2 }") = "mismatch-hidden at element 1")
	cV = oPz.Grade("in a" + char(10) + "out c" + char(10) + "guard none" + char(10) + "body { @c = @a * 2 }")
	? "  guard none at n = 4000: " + cV
	chk("the dropped guard is write-outside at element 4001 -- the mistake only a device shows", cV = "write-outside at element 4001")
	chk("...which the CPU path cannot see (it answers verified, values only)", oPz.GradeOnCpu("in a" + char(10) + "out c" + char(10) + "guard none" + char(10) + "body { @c = @a * 2 }") = "verified")

	? ""
	? "-- Scene 3: the exercise proves itself through the System's own checker, by running --"
	aPr = oEx.ProveItself()
	? "  wrong refused " + aPr[:wrong] + "   right accepted " + aPr[:right] + "   failures " + @@(aPr[:failures])
	chk("every wrong answer is refused and every right answer accepted (3 and 2)", aPr[:wrong] = 3 and aPr[:right] = 2 and len(aPr[:failures]) = 0)
ok

? ""
? "-- Scene 5 (KP2): puzzles 2 to 8 -- each right answer verified, each wrong answer named, each exercise proving itself --"
# [ puzzle, description, the words the grader must say ]; a description is written out
# because the words are the thing under test, not the sibling file that prints them
aCases = [
	[ "kp-02", "in a" + char(10) + "in b" + char(10) + "out c" + char(10) + "body { @c = @a + @b }", "verified" ],
	[ "kp-02", "in a" + char(10) + "in b" + char(10) + "out c" + char(10) + "body { @c = @b + @a }", "verified" ],
	[ "kp-02", "in a" + char(10) + "in b" + char(10) + "out c" + char(10) + "body { @c = @a - @b }", "mismatch at element 2" ],
	[ "kp-02", "in a" + char(10) + "in b" + char(10) + "out c" + char(10) + "body { @c = @a + @a }", "mismatch at element 2" ],
	[ "kp-03", "in a" + char(10) + "scalar alpha" + char(10) + "out c" + char(10) + "body { @c = alpha * @a }", "verified" ],
	[ "kp-03", "in a" + char(10) + "scalar alpha" + char(10) + "out c" + char(10) + "body { @c = @a * alpha }", "verified" ],
	[ "kp-03", "in a" + char(10) + "scalar alpha" + char(10) + "out c" + char(10) + "body { @c = @a * 2 }", "mismatch at element 2" ],
	[ "kp-03", "in a" + char(10) + "scalar alpha" + char(10) + "out c" + char(10) + "body { @c = alpha + @a }", "mismatch at element 1" ],
	[ "kp-04", "in a" + char(10) + "out c" + char(10) + "body { @c = @a + @i }", "verified" ],
	[ "kp-04", "in a" + char(10) + "out c" + char(10) + "body { @c = @i + @a }", "verified" ],
	[ "kp-04", "in a" + char(10) + "out c" + char(10) + "body { @c = @a + @i + 1 }", "mismatch at element 1" ],
	[ "kp-04", "in a" + char(10) + "out c" + char(10) + "body { @c = @i }", "mismatch at element 2" ],
	[ "kp-05", "in a" + char(10) + "out c" + char(10) + "guard { @i < n }" + char(10) + "body { @c = @a * 2 }", "verified" ],
	[ "kp-05", "in a" + char(10) + "out c" + char(10) + "body { @c = @a * 2 }", "verified" ],
	[ "kp-05", "in a" + char(10) + "out c" + char(10) + "guard none" + char(10) + "body { @c = @a * 2 }", "write-outside at element 4001" ],
	[ "kp-05", "in a" + char(10) + "out c" + char(10) + "guard { @i < n - 1 }" + char(10) + "body { @c = @a * 2 }", "mismatch at element 4000" ],
	[ "kp-06", "in a" + char(10) + "out c" + char(10) + "guard { @i > 0 and @i < n - 1 }" + char(10) + "body { @c = (@a[@i - 1] + @a + @a[@i + 1]) / 3 }", "verified" ],
	[ "kp-06", "in a" + char(10) + "out c" + char(10) + "guard { @i > 0 and @i < n - 1 }" + char(10) + "body { @c = (@a[@i + 1] + @a + @a[@i - 1]) / 3 }", "verified" ],
	[ "kp-06", "in a" + char(10) + "out c" + char(10) + "body { @c = (@a[@i - 1] + @a + @a[@i + 1]) / 3 }", "mismatch at element 1" ],
	[ "kp-06", "in a" + char(10) + "out c" + char(10) + "guard { @i > 0 and @i < n - 1 }" + char(10) + "body { @c = (@a[@i - 1] + @a[@i + 1]) / 2 }", "mismatch at element 2" ],
	[ "kp-07", "in a" + char(10) + "out c" + char(10) + "body { @c = sum(k, 0, 16, @a[@i * 16 + k]) }", "verified" ],
	[ "kp-07", "in a" + char(10) + "out c" + char(10) + "body { @c = sum(k, 0, 16, @a[k + @i * 16]) }", "verified" ],
	[ "kp-07", "in a" + char(10) + "out c" + char(10) + "body { @c = sum(k, 0, 15, @a[@i * 16 + k]) }", "mismatch at element 1" ],
	[ "kp-07", "in a" + char(10) + "out c" + char(10) + "body { @c = sum(k, 0, 16, @a[@i + k]) }", "mismatch at element 2" ],
	[ "kp-08", "in c" + char(10) + "scalar m" + char(10) + "out d" + char(10) + "body { @d = sum(k, 0, m, @c[k]) }", "verified" ],
	[ "kp-08", "in c" + char(10) + "scalar m" + char(10) + "out d" + char(10) + "body { @d = sum(k, 0, 1024, @c[k]) }", "verified" ],
	[ "kp-08", "in c" + char(10) + "scalar m" + char(10) + "out d" + char(10) + "body { @d = sum(k, 0, m - 1, @c[k]) }", "mismatch at element 1" ],
	[ "kp-08", "in c" + char(10) + "scalar m" + char(10) + "out d" + char(10) + "body { @d = @c }", "mismatch at element 1" ]
]
acPuzzles = [ "kp-02", "kp-03", "kp-04", "kp-05", "kp-06", "kp-07", "kp-08" ]
for cId in acPuzzles
	oQ = StzKernelPuzzleQ(cId)
	chk(cId + ": the starter grades 'waiting for your implementation'", oQ.Grade(oQ.Starter()) = "waiting for your implementation")
	chk(cId + ": the reference grades itself verified on the CPU", oQ.GradeOnCpu(oQ.Reference()) = "verified")
	chk(cId + ": the task reads in four languages", oQ.Task("en") != "" and oQ.Task("fr") != "" and oQ.Task("ar") != "" and oQ.Task("ha") != "")
	chk(cId + ": the task ends with what the GPU did differently from a loop", StzFindFirst("differently from a loop", oQ.Task("en")) > 0)
next
bDevice = (StzEngineGpuInit($cStzGpuRuntime) != 0 and StzEngineGpuIsAvailable() != 0)
for aCase in aCases
	oQ = StzKernelPuzzleQ(aCase[1])
	if bDevice
		cV = oQ.Grade(aCase[2])
	else
		cV = oQ.GradeOnCpu(aCase[2])
	ok
	cBody = StzSplit(aCase[2], char(10))[len(StzSplit(aCase[2], char(10)))]
	if NOT bDevice and aCase[3] = "write-outside at element 4001"
		chk(aCase[1] + " " + cBody + " -> (no device: the margin cannot be seen) " + cV, cV = "verified")
	else
		chk(aCase[1] + " " + cBody + " -> " + aCase[3], cV = aCase[3])
	ok
next
if bDevice
	? "  the two paths agree on every VALUE verdict (the margin is the device's alone):"
	nAgree = 0
	nValue = 0
	for aCase in aCases
		if aCase[3] != "write-outside at element 4001"
			nValue++
			if StzKernelPuzzleQ(aCase[1]).GradeOnCpu(aCase[2]) = aCase[3]
				nAgree++
			ok
		ok
	next
	chk("...GradeOnCpu says the same words as Grade for all " + nValue + " value cases", nAgree = nValue)
	? "  each exercise proves itself through the System's checker, by running its programs:"
	for cId in acPuzzles
		oE = StzExerciseQ("../../education/program/courses/kernel-puzzles/exercises/" + cId)
		aPr = oE.ProveItself()
		chk(cId + ": wrong refused " + aPr[:wrong] + ", right accepted " + aPr[:right] + ", failures " + @@(aPr[:failures]),
			aPr[:wrong] = 3 and aPr[:right] = 2 and len(aPr[:failures]) = 0)
	next
ok

? ""
? "-- Scene 4: the browser runner exists beside the course --"
cRunner = "../../education/program/courses/kernel-puzzles/runner/puzzle.html"
chk("the page is there", fexists(cRunner))
cPage = read(cRunner)
chk("...it fetches the puzzle's reference, starter and facts (one source for both runners)",
	StzFindFirst("reference.txt", cPage) > 0 and StzFindFirst("starter.txt", cPage) > 0 and StzFindFirst("exercise.zknw", cPage) > 0)
chk("...it grades with the wasm interpreter and a NaN margin, in the face's words",
	StzFindFirst("stz_gpu_spec_eval_masked", cPage) > 0 and StzFindFirst("write-outside at element", cPage) > 0 and StzFindFirst("mismatch${suffix} at element", cPage) > 0)
chk("...and its data recipes are the face's five", StzFindFirst("mod13", cPage) > 0 and StzFindFirst("tenths", cPage) > 0)

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
