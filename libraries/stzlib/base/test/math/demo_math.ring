# THE MATHEMATICS COURSE IN FIFTEEN MINUTES, OFFLINE, FROM A CLEAN FOLDER --
# the education demo's mechanism (DemoProved: a claim, and the condition that
# proves it, counted at the end as "N proved, M not proved") pointed at the
# mathematics course.
#
#     ring demo_math.ring [workspace]
#
# Five scenes: one folder and it runs; a chapter in four languages, every
# promise kept; the reader page that stores no output; the tutor that asks
# and refuses; and the figures the page cannot show yet, drawn by the guard
# (MATH-READER-FIGURE-01 stands).

load "../../stzBase.ring"

$nMathProved = 0
$nMathNot = 0
$cMathWs = ""

cWs = "demo-math-workspace"
if len(sysargv) >= 3  cWs = sysargv[3]  ok
$cMathWs = StzReplace(currentdir(), char(92), "/") + "/" + cWs
cBase = MathDemoFolderOf(StzEduBaseFile())

#-- scene 1: zero install ---------------------------------------------------
MathDemoHeader("0-2", "Zero install: one folder, and it runs")
StzEduRemoveTree($cMathWs)
StzEduCopyTree(cBase + "/education/program", $cMathWs + "/institution/program")
acFiles = MathDemoFilesUnder($cMathWs + "/institution/program/courses/math")
bText = 1
for i = 1 to len(acFiles)
	cE = MathDemoExtension(acFiles[i])
	if NOT ( cE = ".md" or cE = ".zknw" or cE = ".ring" )
		bText = 0
	ok
next
? "  The mathematics course arrived as " + len(acFiles) + " plain-text files inside the program folder."
? "  The machine runs Ring " + version() + " and the Softanza engine, copied, not installed."
MathDemoProved("every file of the course is plain text a teacher can open (.md .zknw .ring)", bText)
MathDemoProved("no picture file lives under the course: every figure is a declaration in a cell", bText)

#-- scene 2: four languages -------------------------------------------------
MathDemoHeader("2-6", "In their language: English, French, Arabic, Hausa")
oCourse = StzProgramQ($cMathWs + "/institution/program").CourseQ("math")
acLangs = [ "en", "fr", "ar", "ha" ]
cFirst = oCourse.ChapterIds()[1]
aCh = oCourse.RunChapterInQ(cFirst, acLangs)
bAll = 1
for i = 1 to 4
	oCh = aCh[i]
	? "  [" + oCh.Language() + "] " + oCh.Title() + " -- " + oCh.NumberOfCells() + " cells, " + oCh.NumberOfPromises() + " promises"
	? "      cell 1 printed: " + ring_trim(StzSplit(oCh.CellOutput(1), char(10))[1])
	if NOT ( oCh.AllCellsRan() and oCh.AllPromisesKept() and NOT oCh.HasStoredOutput() )
		bAll = 0
	ok
next
MathDemoProved("the chapter ran in all four languages, every cell, every promise kept, no stored output", bAll)
bSame = 1
for i = 2 to 4
	for j = 1 to aCh[1].NumberOfCells()
		if @@(aCh[i].CellPromises(j)) != @@(aCh[1].CellPromises(j))  bSame = 0  ok
	next
next
MathDemoProved("the four editions make the same promises, cell for cell", bSame)

#-- scene 3: the reader page ------------------------------------------------
MathDemoHeader("6-8", "The reader page: nothing on it is an output")
oRd = new stzEduReader(oCourse)
for i = 1 to 4
	oRd.AddChapter(aCh[i])
next
oRd.WriteTo($cMathWs + "/math.html")
cPage = read($cMathWs + "/math.html")
? "  The reader page: <workspace>/math.html (" + len(cPage) + " bytes; Arabic reads right to left)"
oEn = aCh[1]
nW = oEn.WorldDependentCells()[1]
cSeen = ring_trim(StzSplit(oEn.CellOutput(nW), char(10))[1])
MathDemoProved("the page stores no output: what the world cell printed ('" + cSeen + "') is not on it",
	StzFindFirst(cSeen, cPage) = 0)
MathDemoProved("the promises stay on the page: they are the author's expectation, part of the source",
	StzFindFirst("a number line from -5 to 10", cPage) > 0)

#-- scene 4: the tutor ------------------------------------------------------
MathDemoHeader("8-11", "The tutor asks; it never answers")
oEx = oCourse.ExerciseQ(oCourse.ExercisesOf(cFirst)[1])
cLearner = $cMathWs + "/learners/amina"
oL = StzLearnerQ(cLearner)
oL.Submit(oEx, read(oEx.WrongAnswers()[1]))
oT = StzTutorQ(oEx, cLearner, "en").WithCourseQ(oCourse)
cGap = oT.Ask("What is missing in my program?")
? "  learner: What is missing in my program?"
? "  tutor:   " + cGap
cNo = oT.Ask("Give me the answer")
? "  learner: Give me the answer"
? "  tutor:   " + cNo
MathDemoProved("a wrong answer earns a QUESTION about the missing step, never the answer", StzFindFirst("?", cGap) > 0 and cGap = _EduSay("en", "gap-" + oEx.NeededSteps()[1], ""))
MathDemoProved("asked for the answer, the tutor refuses", StzLeft(cNo, StzLen(_EduSay("en", "refuse", ""))) = _EduSay("en", "refuse", ""))
oK = oL.Submit(oEx, read(oEx.RightAnswers()[1]))
MathDemoProved("a right answer is accepted by RUNNING it, and the learner moves on", oK.Passed() and oL.ChapterOn(oCourse) != cFirst)

#-- scene 5: the figures the page cannot show yet -----------------------------
MathDemoHeader("11-15", "The figures, drawn by the guard (the reader shows no picture yet)")
oF = StzMathFigureQ(:NumberLine, [ :on = [ -5, 10 ], :points = [ 3, -2, 7.5 ] ])
cPng = oF.ToPNG($cMathWs + "/number-line.png")
oG = StzMathFigureQ(:Fraction, [ :compare = [ [ 3, 4 ], [ 2, 3 ] ] ])
cPng2 = oG.ToPNG($cMathWs + "/fraction.png")
? "  " + oF.Why()
? "  " + oG.Why()
if cPng = ""
	? "  (no graphics device on this machine: the pictures are not written, and this is said, not hidden)"
	MathDemoProved("without a device the figure still computes and judges itself (0 violations)", len(oF.Violations()) = 0 and len(oG.Violations()) = 0)
else
	? "  <workspace>/number-line.png (" + len(cPng) + " bytes), <workspace>/fraction.png (" + len(cPng2) + " bytes)"
	MathDemoProved("both figures are drawn to PNG and judge themselves clean", len(cPng) > 0 and len(cPng2) > 0 and len(oF.Violations()) = 0 and len(oG.Violations()) = 0)
ok
MathDemoProved("the reader has no figure yet: routed MATH-READER-FIGURE-01, and the page shows the figure's own sentence instead",
	StzFindFirst("<img", cPage) = 0 and StzFindFirst("oL.Why()", cPage) > 0)

? ""
? "DEMO: " + $nMathProved + " proved, " + $nMathNot + " not proved"

#=============================================================================
func MathDemoProved(pcClaim, pbCond)
	if pbCond
		$nMathProved++
		? "  PROVED      " + pcClaim
	else
		$nMathNot++
		? "  NOT PROVED  " + pcClaim
	ok

func MathDemoHeader(pcMinutes, pcTitle)
	? ""
	? "== [" + pcMinutes + " min] " + pcTitle
	? ""

func MathDemoFolderOf(pcFile)
	_c_ = StzReplace(pcFile, char(92), "/")
	_n_ = 0
	for _i_ = len(_c_) to 1 step -1
		if _c_[_i_] = "/"
			_n_ = _i_
			exit
		ok
	next
	if _n_ = 0  return "."  ok
	return left(_c_, _n_ - 1)

func MathDemoFilesUnder(pcDir)
	_acRes_ = []
	if NOT StzEngineDirExists(pcDir)
		return _acRes_
	ok
	_acF_ = StzEngineDirListFiles(pcDir)
	for _i_ = 1 to len(_acF_)
		_acRes_ + _acF_[_i_]
	next
	_acD_ = StzEngineDirListDirs(pcDir)
	for _i_ = 1 to len(_acD_)
		_acSub_ = MathDemoFilesUnder(pcDir + "/" + _acD_[_i_])
		for _j_ = 1 to len(_acSub_)
			_acRes_ + (_acD_[_i_] + "/" + _acSub_[_j_])
		next
	next
	return _acRes_

func MathDemoExtension(pcFile)
	_n_ = 0
	for _i_ = len(pcFile) to 1 step -1
		if pcFile[_i_] = "."
			_n_ = _i_
			exit
		ok
		if pcFile[_i_] = "/"
			exit
		ok
	next
	if _n_ = 0  return ""  ok
	return right(pcFile, len(pcFile) - _n_ + 1)
