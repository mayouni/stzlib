# THE COURSE GATE -- every shipped chapter of the Elementary Introduction, by running.
#
# For each chapter course.zknw ships:
#   - it has text in all four languages, and each edition RUNS every cell in
#     its own fresh process with every promise kept and no stored output
#   - it ends with a recap and references at least one exercise
#   - every exercise it references exists, has a task in four languages, and
#     PROVES ITSELF: every wrong answer refused, every right answer accepted,
#     with at least two of each
# Scoped run: `ring course_narrated.ring <chapter-id>` runs one chapter and
# PRINTS the chapters it skipped, by name. Per-chapter wall time is printed.
#
# Run from this folder: ring course_narrated.ring [chapter-id]

load "../../stzBase.ring"
load "../_narrated.ring"

t0 = clock()
aLangs = [ "en", "fr", "ar", "ha" ]
oP = StzProgramQ("../../education/program")
oC = oP.CourseQ("elementary-introduction")
acAll = oC.ChapterIds()
acRun = acAll
if len(sysargv) >= 3
	acRun = [ sysargv[3] ]
ok
? "  chapters shipped: " + len(acAll) + " -- " + @@(acAll)
if len(acRun) < len(acAll)
	? "  [skipped, by name]"
	for i = 1 to len(acAll)
		if StzFindFirst(acAll[i], acRun) = 0
			? "      " + acAll[i]
		ok
	next
ok

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
	# an edition may word a cell in its own language (chapter 1's natural
	# cell does), but every edition must make the SAME PROMISES, cell for cell
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
