load "../../stzBase.ring"
load "../_narrated.ring"
load "../../../atelier/atelierClient.ring"

# THE ATELIER, B3 -- the lessons. The Learning System's chapters (base/education/, read
# through its public calls and never written) open as notebooks: every cell runs as the
# education runner runs a chapter -- one program over the chapter's world, each cell in its
# own try -- and each cell is judged by the course's own court on what its ? lines printed.
# An exercise is checked and recorded only by the learner's own Submit. Three defects B3
# found are guarded here too: a ? line indented with a tab was never seen, a cell naming a
# variable n was refused admission (Rule A), and a chain held by ref() ended the VM when a
# method copied This (ATELIER-REFTHIS-16).
#
# Run from this folder, on rnxc:
#     rnxc atelier_lessons_narrated.ring
# About a minute warm: the child Atelier's compile of the library, a dozen requests, and the
# education runner's own run of two chapters (a fresh process each).

? "ATELIER B3 -- the lessons"
cAtHere = substr(currentdir(), "\", "/")
cAtAtelier = cAtHere + "/../../../atelier"
cAtLibrary = cAtHere + "/../../.."
nAtPort = 8667
cAtSettings = cAtHere + "/_planted_settings_lessons.ring"
cAtLearner = "guard-lessons-" + ProcessId()
_nl_ = char(10)

oAt = AtelierBoot(cAtAtelier, nAtPort, cAtLibrary, cAtSettings)
aAtState = AtelierWaitReady(nAtPort, 600000, oAt)
if aAtState[:library][:state] != "admitted"  ? "    the child said: " + aAtState[:library][:why]  ok
oAtProg = StzProgramQ(cAtLibrary + "/base/education/program")

#============================================================================
Scenario("The courses that have written chapters, with their titles in every language")
	Then("the library is admitted", aAtState[:library][:state], "admitted")
	aC = _AtGet(nAtPort, "/atelier/courses")
	acSlugs = []
	for i = 1 to len(aC[:courses])  acSlugs + aC[:courses][i][:slug]  next
	Then("the elementary introduction is offered", find(acSlugs, "elementary-introduction") > 0, TRUE)
	Then("and mathematics", find(acSlugs, "math") > 0, TRUE)
	Then("a course whose chapters are planned but unwritten is not", find(acSlugs, "kernel-puzzles"), 0)
	aCh = aC[:courses][find(acSlugs, "elementary-introduction")][:chapters]
	Then("fifteen chapters, as the course lists them", len(aCh), len(oAtProg.CourseQ("elementary-introduction").ChapterIds()))
	Then("chapter 1 in four languages", len(aCh[1][:titles]), 4)
	Then("its French title is the French edition's", aCh[1][:titles][:fr], oAtProg.CourseQ("elementary-introduction").TitleOf("find-then-apply", "fr"))
EndScenario()

Scenario("A chapter opens as blocks: prose, cells and exercises, in the file's order")
	aL = _AtPost(nAtPort, "/atelier/lesson", '{"course":"elementary-introduction","chapter":"find-then-apply","lang":"en","learner":"' + cAtLearner + '"}')
	oChap = oAtProg.CourseQ("elementary-introduction").ChapterQ("find-then-apply", "en")
	Then("its title", aL[:title], oChap.Title())
	nCells = 0  nEx = 0
	for i = 1 to len(aL[:blocks])
		if aL[:blocks][i][:kind] = "cell"  nCells++  ok
		if aL[:blocks][i][:kind] = "exercise"  nEx++  aEx = aL[:blocks][i]  ok
	next
	Then("every cell of the chapter", nCells, oChap.NumberOfCells())
	Then("and its exercise", nEx, 1)
	Then("the exercise brings its task", StzFindFirst("Exercise 1.1", aEx[:task]) > 0, TRUE)
	Then("and the learner has not tried it yet", aEx[:verdict], "")
	Then("the world is named by its file, never by a path", aL[:world], "workplace.zknw")
	Then("English is the source: no draft notice", aL[:draft], 0)
	aF = _AtPost(nAtPort, "/atelier/lesson", '{"course":"elementary-introduction","chapter":"find-then-apply","lang":"fr","learner":"' + cAtLearner + '"}')
	Then("the French edition is a draft until a person reviews it", aF[:draft], 1)
	Then("a course that is not in the program is refused", _AtCode(nAtPort, "/atelier/lesson", '{"course":"../../base","chapter":"x","lang":"en"}'), 422)
	Then("so is a chapter the course does not list", _AtCode(nAtPort, "/atelier/lesson", '{"course":"math","chapter":"find-then-apply","lang":"en"}'), 422)
EndScenario()

Scenario("A chapter runs as the education runner runs it, and the course's court judges each cell")
	acCells = oAtProg.CourseQ("elementary-introduction").ChapterQ("find-then-apply", "en").Cells()
	aR = _AtLesson(nAtPort, "elementary-introduction", "find-then-apply", acCells, 0)
	Then("the chapter ran to its end", aR[:end], "finished")
	Then("every cell has a verdict", len(aR[:verdicts]), len(acCells))
	nKept = 0  nNone = 0
	for i = 1 to len(aR[:verdicts])
		if aR[:verdicts][i][:kept] = 1  nKept++  ok
		if aR[:verdicts][i][:kept] = -1  nNone++  ok
	next
	Then("seven cells keep their promises", nKept, 7)
	Then("one promises nothing", nNone, 1)
	Then("the world was read: cell 7 printed the restaurant's name", _AtValueOfCell(aR, 7, 1), "bella-cucina (restaurant)")
	aR = _AtLesson(nAtPort, "elementary-introduction", "find-then-apply", acCells, 2)
	Then("running up to cell 2 runs two cells", len(aR[:verdicts]), 2)
	acBad = acCells
	acBad[3] = "? o1.NoSuchMethodHere()" + _nl_ + "#--> 3" + _nl_
	aR = _AtLesson(nAtPort, "elementary-introduction", "find-then-apply", acBad, 0)
	Then("a cell that raises does not hide the cells after it", aR[:verdicts][4][:kept], 1)
	Then("and it carries its own error", StzFindFirst("nosuchmethodhere", lower(aR[:verdicts][3][:error])) > 0, TRUE)
EndScenario()

Scenario("Three defects B3 found stay fixed")
	aC = _AtCell(nAtPort, "for i = 1 to 2" + _nl_ + char(9) + "? i" + _nl_ + "next" + _nl_)
	Then("a ? line indented with a TAB is seen", len(aC[:sees]), 1)
	Then("on each pass", len(aC[:sees][1][:values]), 2)
	aC = _AtCell(nAtPort, 'o1 = new stzList([ "tea", "rice", "tea" ])' + _nl_ + "? o1.ContainsDuplicates()" + _nl_ + "#--> TRUE" + _nl_)
	Then("a method that copies This, at the end of an unfolded chain, answers (it ended the VM under ref())", aC[:sees][1][:state], "kept")
	Then("and the Atelier is still there", AtelierState(nAtPort)[:library][:state], "admitted")
	aR = _AtLesson(nAtPort, "elementary-introduction", "find-then-apply", [ "n = 3" + _nl_ + "? n" + _nl_ + "#--> 3" + _nl_ ], 0)
	Then("a lesson cell may name a variable n: its statements run inside one function (Rule A)", aR[:verdicts][1][:kept], 1)
EndScenario()

Scenario("A cell that prints by itself is unperceived, never diverged")
	acCells = oAtProg.CourseQ("elementary-introduction").ChapterQ("draw-the-answer", "en").Cells()
	aR = _AtLesson(nAtPort, "elementary-introduction", "draw-the-answer", acCells, 0)
	Then("cell 3 draws with Show(): unperceived", aR[:verdicts][3][:kept], 2)
	Then("its two ? lines before the drawing are kept", "" + aR[:verdicts][3][:report][1][2] + aR[:verdicts][3][:report][2][2], "11")
	Then("the lines of the drawing are unperceived", aR[:verdicts][3][:report][3][2], 2)
EndScenario()

Scenario("The court: the education runner and the Atelier agree, cell by cell")
	acCh = [ [ "elementary-introduction", "find-then-apply" ], [ "math", "money-to-the-centime" ] ]
	nAgree = 0  nAll = 0
	for c = 1 to len(acCh)
		oCourse = oAtProg.CourseQ(acCh[c][1])
		oChap = oCourse.ChapterQ(acCh[c][2], "en")
		nT = clock()
		oChap.Run(oCourse.WorldFileOf(acCh[c][2]))
		nEduS = (clock() - nT) / clockspersecond()
		aR = _AtLesson(nAtPort, acCh[c][1], acCh[c][2], oChap.Cells(), 0)
		for k = 1 to oChap.NumberOfCells()
			nAll++
			if oChap.CellKept(k) = aR[:verdicts][k][:kept]  nAgree++  ok
		next
		? "    " + acCh[c][2] + ": the education runner " + _AtelierNum(nEduS) + " s in a fresh process, the Atelier " + aR[:ms] + " ms"
	next
	Then("two chapters, every cell judged twice", nAll, 17)
	Then("the two courts agree on every one (the second chapter names a variable n)", nAgree, nAll)
EndScenario()

Scenario("An exercise is checked by the learner's own Submit, which records the verdict")
	cWrong = 'o1 = new stzList([ "tea", "rice", "tea", "fish", "rice", "tea" ])' + _nl_ + "? @@( o1.Content() )" + _nl_
	aW = _AtPost(nAtPort, "/atelier/exercise", '{"course":"elementary-introduction","exercise":"ex-01-01","lang":"en","learner":"' + cAtLearner + '","code":' + _AtelierJsonStr(cWrong) + '}')
	Then("a wrong answer diverges", aW[:verdict], "diverged")
	Then("and does not pass", aW[:passed], 0)
	Then("the learner is told what it printed", StzFindFirst("printed", aW[:why]) > 0, TRUE)
	cRight = '? @@( StzListQ([ "tea", "rice", "tea", "fish", "rice", "tea" ]).DuplicatesRemoved() )' + _nl_
	aP = _AtPost(nAtPort, "/atelier/exercise", '{"course":"elementary-introduction","exercise":"ex-01-01","lang":"en","learner":"' + cAtLearner + '","code":' + _AtelierJsonStr(cRight) + '}')
	Then("a right answer passes", aP[:verdict], "passed")
	Then("and counts: the work file is the one the court ran", aP[:counts], 1)
	? "    checked in " + aW[:seconds] + " s and " + aP[:seconds] + " s"
	cFolder = cAtAtelier + "/_work/learners/" + cAtLearner
	oLearner = StzLearnerQ(cFolder)
	Then("the learner's own progress says passed", oLearner.LastVerdict("ex-01-01"), "passed")
	Then("and the education plane's own reading of it agrees", oLearner.HasPassed("ex-01-01"), TRUE)
	aL = _AtPost(nAtPort, "/atelier/lesson", '{"course":"elementary-introduction","chapter":"find-then-apply","lang":"en","learner":"' + cAtLearner + '"}')
	for i = 1 to len(aL[:blocks])
		if aL[:blocks][i][:kind] = "exercise"  aEx = aL[:blocks][i]  ok
	next
	Then("the chapter opens again with the pass", aEx[:passed], 1)
	Then("and the learner's work", aEx[:work], cRight)
	Then("an exercise id that is a path is refused", _AtCode(nAtPort, "/atelier/exercise", '{"course":"elementary-introduction","exercise":"../ex-01-01","code":"? 1"}'), 422)
	StzEduRemoveTree(cFolder)
EndScenario()

Scenario("The Atelier stops when asked")
	Then("it answered", AtelierStop(nAtPort), TRUE)
	Then("and the child ended", oAt.WaitFor(10000) != -2, TRUE)
	remove(cAtSettings)
EndScenario()

Summary()
shutdown($_zst_fail)

func _AtHttp(pnPort, pcPath, pcBody)
	_oH_ = new stzHttpClient()
	_oH_.SetTimeout(300)
	if pcBody = NULL
		_oH_.Get_("http://127.0.0.1:" + pnPort + pcPath)
	else
		_oH_.Post("http://127.0.0.1:" + pnPort + pcPath, pcBody)
	ok
	return _oH_

func _AtGet(pnPort, pcPath)
	return StzJsonToList(_AtHttp(pnPort, pcPath, NULL).ResponseBody())

func _AtPost(pnPort, pcPath, pcBody)
	_oH_ = _AtHttp(pnPort, pcPath, pcBody)
	if _oH_.ResponseCode() != 200
		? "    " + pcPath + " answered " + _oH_.ResponseCode() + ": " + left(_oH_.ResponseBody(), 200)
		return [ :end = "http " + _oH_.ResponseCode(), :verdicts = [], :blocks = [], :sees = [], :verdict = "", :passed = -1, :counts = -1, :why = "", :seconds = 0, :title = "", :draft = -1, :world = "" ]
	ok
	return StzJsonToList(_oH_.ResponseBody())

func _AtCode(pnPort, pcPath, pcBody)
	return _AtHttp(pnPort, pcPath, pcBody).ResponseCode()

func _AtCell(pnPort, pcCode)
	_oH_ = _AtHttp(pnPort, "/atelier/cell", pcCode)
	return StzJsonToList(_oH_.ResponseBody())

func _AtLesson(pnPort, pcCourse, pcChapter, pacCells, pnRun)
	_c_ = '{"course":' + _AtelierJsonStr(pcCourse) + ',"chapter":' + _AtelierJsonStr(pcChapter) + ',"lang":"en"'
	if pnRun > 0  _c_ += ',"run":' + pnRun  ok
	_c_ += ',"cells":['
	for _i_ = 1 to len(pacCells)
		if _i_ > 1  _c_ += ","  ok
		_c_ += _AtelierJsonStr(pacCells[_i_])
	next
	return _AtPost(pnPort, "/atelier/lesson/run", _c_ + "]}")

# the k-th value a cell's ? lines showed, in the order the lines come
func _AtValueOfCell(paR, pnCell, pnK)
	_n_ = 0
	for _i_ = 1 to len(paR[:sees])
		_s_ = paR[:sees][_i_]
		if paR[:map][_s_[:line]][1] = pnCell
			for _j_ = 1 to len(_s_[:values])
				_n_++
				if _n_ = pnK  return _s_[:values][_j_][:payload]  ok
			next
		ok
	next
	return ""
