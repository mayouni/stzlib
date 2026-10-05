# THE COURSE GATE OF THE MATHEMATICS PLANE -- every shipped chapter of the
# mathematics course, by running (the education plane's own contract, held
# to this course).
#
# For each chapter course.zknw ships:
#   - it has text in all four languages, and each edition RUNS every cell in
#     its own fresh process with every promise kept and no stored output
#   - the four editions make the SAME promises, cell for cell
#   - it ends with a recap and references at least one exercise
#   - every exercise it references exists, has a task in four languages, and
#     PROVES ITSELF: every wrong answer refused, every right answer accepted,
#     with at least two of each
#   - no picture file lives under the course folder: a figure is a declaration
#     in a cell (charter law 1, and the demo's whitelist)
# Scoped run: `ring course_math_narrated.ring <chapter-id>` runs one chapter
# and PRINTS the chapters it skipped, by name. Per-chapter wall time is printed.
#
# Run from this folder: ring course_math_narrated.ring [chapter-id]

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
aLangs = [ "en", "fr", "ar", "ha" ]
cProgram = "../../education/program"
oP = StzProgramQ(cProgram)
oC = oP.CourseQ("math")
acAll = oC.ChapterIds()
acRun = acAll
if len(sysargv) >= 3
	acRun = [ sysargv[3] ]
ok
? "  chapters shipped: " + len(acAll) + " -- " + @@(acAll)
? "  chapters planned: " + len(oC.PlannedChapterIds()) + " (shipped + unwritten = planned; never summed as shipped)"
if len(acRun) < len(acAll)
	? "  [skipped, by name]"
	for i = 1 to len(acAll)
		if StzFindFirst(acAll[i], acRun) = 0
			? "      " + acAll[i]
		ok
	next
ok

Scenario("The course folder: plain text, no picture file")
acFiles = MathFilesUnder(cProgram + "/courses/math")
acBad = []
for i = 1 to len(acFiles)
	cE = StzLower(MathExtensionOf(acFiles[i]))
	if NOT ( cE = ".md" or cE = ".zknw" or cE = ".ring" )
		acBad + acFiles[i]
	ok
next
Then("every file under courses/math is .md, .zknw or .ring  [" + len(acFiles) + " files]", @@(acBad), "[ ]")
acOutside = []
acPlan = oC.PlannedChapterIds()
for i = 1 to len(acAll)
	if StzFindFirst(acAll[i], acPlan) = 0
		acOutside + acAll[i]
	ok
next
Then("every shipped chapter is a planned chapter", @@(acOutside), "[ ]")
EndScenario()

for n = 1 to len(acRun)
	cId = acRun[n]
	t1 = clock()
	Scenario("Chapter " + oC.ChapterNumber(cId) + " · " + cId)
	acMissing = []
	for i = 1 to len(aLangs)
		if oC.ChapterFile(cId, aLangs[i]) = ""
			acMissing + aLangs[i]
		ok
	next
	Then("text exists in all four languages", @@(acMissing), "[ ]")
	if len(acMissing) > 0
		EndScenario()
		loop
	ok
	aCh = oC.RunChapterInQ(cId, aLangs)
	for i = 1 to len(aLangs)
		oCh = aCh[i]
		acBroken = []
		for j = 1 to oCh.NumberOfCells()
			if NOT oCh.CellRan(j)
				acBroken + ("cell " + j + " raised: " + StzLeft(oCh.CellError(j), 70))
			but oCh.CellKept(j) = 0
				acBroken + ("cell " + j + " diverged, printed: " + StzLeft(StzReplace(ring_trim(oCh.CellOutput(j)), char(10), " / "), 70))
			ok
		next
		Then(aLangs[i] + ": " + oCh.NumberOfCells() + " cells ran and " + oCh.NumberOfPromises() +
			" promises kept", @@(acBroken), "[ ]")
		Then(aLangs[i] + ": no stored output", oCh.HasStoredOutput(), 0)
	next
	acDrift = []
	for i = 2 to len(aLangs)
		if aCh[i].NumberOfCells() != aCh[1].NumberOfCells()
			acDrift + (aLangs[i] + ": " + aCh[i].NumberOfCells() + " cells against " + aCh[1].NumberOfCells())
		else
			for j = 1 to aCh[1].NumberOfCells()
				if @@(aCh[i].CellPromises(j)) != @@(aCh[1].CellPromises(j))
					acDrift + (aLangs[i] + ": cell " + j + " promises differ from en")
				ok
			next
		ok
	next
	Then("the four editions make the same promises, cell for cell", @@(acDrift), "[ ]")
	nPromised = 0
	for j = 1 to aCh[1].NumberOfCells()
		if len(aCh[1].CellPromises(j)) > 0
			nPromised++
		ok
	next
	Then("every cell but a world cell carries a promise: a claim without its check is refused",
		len(aCh[1].WorldDependentCells()) + nPromised, aCh[1].NumberOfCells())
	Then("it references at least one exercise", len(aCh[1].ExerciseIds()) >= 1, 1)
	Then("it ends with a recap", StzFindFirst("## Recap", read(oC.ChapterFile(cId, "en"))) > 0, 1)
	acEx = aCh[1].ExerciseIds()
	for e = 1 to len(acEx)
		oEx = oC.ExerciseQ(acEx[e])
		acNoTask = []
		for i = 1 to len(aLangs)
			if NOT oEx.HasTaskIn(aLangs[i])
				acNoTask + aLangs[i]
			ok
		next
		Then(acEx[e] + ": task in all four languages", @@(acNoTask), "[ ]")
		Then(acEx[e] + ": declares the steps the tutor's gap question needs", len(oEx.NeededSteps()) >= 1, 1)
		aPr = oEx.ProveItself()
		Then(acEx[e] + ": at least two wrong and two right answers", aPr[:wrong] >= 2 and aPr[:right] >= 2, 1)
		Then(acEx[e] + ": every wrong answer refused, every right one accepted (" + aPr[:wrongrefused] + "/" +
			aPr[:wrong] + ", " + aPr[:rightaccepted] + "/" + aPr[:right] + ")", @@(aPr[:failures]), "[ ]")
	next
	EndScenario()
	? "  [time] " + cId + ": " + ((clock() - t1) / clockspersecond()) + " s"
next

? ""
? "  [time] whole guard: " + ((clock() - t0) / clockspersecond()) + " s"
Summary()

# every file under a folder, recursively, as paths relative to it
func MathFilesUnder pcDir
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
		_acSub_ = MathFilesUnder(pcDir + "/" + _acD_[_i_])
		for _j_ = 1 to len(_acSub_)
			_acRes_ + (_acD_[_i_] + "/" + _acSub_[_j_])
		next
	next
	return _acRes_

func MathExtensionOf pcFile
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
	if _n_ = 0
		return ""
	ok
	return right(pcFile, len(pcFile) - _n_ + 1)
