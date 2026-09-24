# THE SOFTANZA LEARNING SYSTEM -- the 15-minute demo for decision makers (E2)
#
#   cd libraries/stzlib/base/education/demo
#   ring demo.ring                      # the whole demo, in one go
#   ring demo.ring my-workspace --pause # stop after each scene (press Enter)
#
# Eight scenes, in the order of SOFTANZA_EDUCATION_PLAN.md section D. The
# demo starts from a CLEAN workspace: it copies the program to it, the way
# an institution receives one folder, and everything afterwards happens
# there -- learners, progress, the reader page.
#
# Nothing on screen is typed in advance. Every "PROVED" line is computed
# from a run made while the demo is showing it, and a claim the run does
# not support prints "NOT PROVED" instead. The last line counts both.
#
# What "zero install" means today, said plainly: the machine runs Ring and
# the Softanza engine, copied, not installed. The page runs in any browser,
# but its cells run on the desktop until RingScript runs the library (E1b).

load "../../stzBase.ring"

# Globals are declared here, at top level: in Ring a variable first
# assigned inside a function is that function's local, whatever its name.
$nEduDemoProved = 0
$nEduDemoNot = 0
$bEduDemoPause = 0
$cEduDemoWs = ""
$cEduDemoBase = ""
$cEduDemoTarget = ""
$oEduDemoCourse = NULL
$aEduDemoChapters = []

func main
	_cWs_ = "demo-workspace"
	for _i_ = 3 to len(sysargv)
		if sysargv[_i_] = "--pause"
			$bEduDemoPause = 1
		else
			_cWs_ = sysargv[_i_]
		ok
	next
	$cEduDemoWs = StzReplace(currentdir(), char(92), "/") + "/" + _cWs_
	$cEduDemoBase = DemoFolderOf(StzEduBaseFile())

	DemoScene1()
	DemoScene2()
	DemoScene3()
	DemoScene4()
	DemoScene5()
	DemoScene6()
	DemoScene7()
	DemoScene8()

	? ""
	? "DEMO: " + $nEduDemoProved + " proved, " + $nEduDemoNot + " not proved"

#=============================================================================
func DemoScene1()
	DemoHeader("0-2", "Zero install: one folder, and it runs")
	StzEduRemoveTree($cEduDemoWs)
	StzEduCopyTree($cEduDemoBase + "/education/program", $cEduDemoWs + "/institution/program")
	StzEduCopyTree($cEduDemoBase + "/education/overlays/bank", $cEduDemoWs + "/institution/overlays/bank")
	_acFiles_ = DemoFilesUnder($cEduDemoWs + "/institution")
	_aExt_ = []
	_bText_ = 1
	for _i_ = 1 to len(_acFiles_)
		_cE_ = DemoExtension(_acFiles_[_i_])
		_bSeen_ = 0
		for _j_ = 1 to len(_aExt_)
			if _aExt_[_j_][1] = _cE_
				_aExt_[_j_][2]++
				_bSeen_ = 1
			ok
		next
		if NOT _bSeen_
			_aExt_ + [ _cE_, 1 ]
		ok
		if NOT ( _cE_ = ".md" or _cE_ = ".zknw" or _cE_ = ".ring" or _cE_ = ".pia" or _cE_ = ".txt" or _cE_ = ".csv" )
			_bText_ = 0
		ok
	next
	? "  The institution received one folder: " + len(_acFiles_) + " files."
	for _j_ = 1 to len(_aExt_)
		? "    " + _aExt_[_j_][2] + " x " + _aExt_[_j_][1]
	next
	? "  The machine runs Ring " + version() + " and the Softanza engine, copied, not installed."
	DemoProved("every file of the program is plain text a teacher can open (.md .zknw .ring .pia .txt .csv)", _bText_)
	DemoProved("the program folder holds no database, no server and no binary", _bText_)
	DemoPause()

#=============================================================================
func DemoScene2()
	DemoHeader("2-4", "In their language: English, French, Arabic, Hausa")
	$oEduDemoCourse = StzProgramQ($cEduDemoWs + "/institution/program").CourseQ("elementary-introduction")
	$aEduDemoChapters = $oEduDemoCourse.RunChapterInQ("find-then-apply", [ "en", "fr", "ar", "ha" ])
	_bAll_ = 1
	for _i_ = 1 to 4
		_oCh_ = $aEduDemoChapters[_i_]
		_n_ = _oCh_.NumberOfCells()
		? "  [" + _oCh_.Language() + "] " + _oCh_.Title()
		? "      " + DemoLastLine(_oCh_.Cell(_n_))
		? "      ran, and printed: " + ring_trim(_oCh_.CellOutput(_n_))
		if NOT ( _oCh_.AllCellsRan() and _oCh_.AllPromisesKept() and NOT _oCh_.HasStoredOutput() )
			_bAll_ = 0
		ok
	next
	DemoProved("the chapter ran in all four languages, every cell, every promise kept", _bAll_)
	_oRd_ = new stzEduReader($oEduDemoCourse)
	for _i_ = 1 to 4
		_oRd_.AddChapter($aEduDemoChapters[_i_])
	next
	_oRd_.AddQuestion("remove duplicates", "stzList")
	_oRd_.WriteTo($cEduDemoWs + "/elementary-introduction.html")
	? "  The reader page: <workspace>/elementary-introduction.html (Arabic reads right to left)"
	_oEn_ = $aEduDemoChapters[1]
	_cSeen_ = ring_trim(StzSplit(_oEn_.CellOutput(_oEn_.WorldDependentCells()[1]), char(10))[1])
	DemoProved("the page stores no output: what the world cell printed ('" + _cSeen_ + "') is not on it",
		StzFindFirst(_cSeen_, read($cEduDemoWs + "/elementary-introduction.html")) = 0)
	DemoPause()

#=============================================================================
func DemoScene3()
	DemoHeader("4-6", "On their own world: the same chapter, over the bank")
	_oEn_ = $aEduDemoChapters[1]
	_nW_ = _oEn_.WorldDependentCells()[1]
	_cFile_ = $oEduDemoCourse.ChapterFile("find-then-apply", "en")
	_cHash_ = StzEngineCryptoSha256(read(_cFile_))
	? "  Core program, the restaurant:"
	DemoPrintIndented(_oEn_.CellOutput(_nW_))
	_oBank_ = StzProgramQ($cEduDemoWs + "/institution/program").
		WithOverlayQ($cEduDemoWs + "/institution/overlays/bank").
		CourseQ("elementary-introduction").RunChapterQ("find-then-apply", "en")
	? "  With the bank's overlay laid on (one file: worlds/workplace.zknw):"
	DemoPrintIndented(_oBank_.CellOutput(_nW_))
	DemoProved("the same cell answers about the bank", StzFindFirst("sahel-savings", _oBank_.CellOutput(_nW_)) > 0)
	DemoProved("the chapter file did not change by one byte", StzEngineCryptoSha256(read(_cFile_)) = _cHash_)
	DemoPause()

#=============================================================================
func DemoScene4()
	DemoHeader("6-8", "Nothing is faked: a wrong answer fails, a right one passes, by running")
	_oEx_ = $oEduDemoCourse.ExerciseQ("ex-01-01")
	_oL_ = StzLearnerQ($cEduDemoWs + "/learners/amina")
	_cWrong_ = 'o1 = new stzList([ "tea", "rice", "tea", "fish", "rice", "tea" ])' + char(10) + '? @@( o1.Content() )'
	_cRight_ = 'o1 = new stzList([ "tea", "rice", "tea", "fish", "rice", "tea" ])' + char(10) +
	           'o1.RemoveItemsAtPositions( o1.FindDuplicates() )' + char(10) + '? @@( o1.Content() )'
	? "  Amina submits her first try:"
	DemoPrintIndented(_cWrong_)
	_oK1_ = _oL_.Submit(_oEx_, _cWrong_)
	? "  -> " + _oK1_.Why()
	? "  Amina submits her second try:"
	DemoPrintIndented(_cRight_)
	_oK2_ = _oL_.Submit(_oEx_, _cRight_)
	? "  -> " + _oK2_.Why()
	DemoProved("the wrong try was refused by running it", _oK1_.Passed() = 0)
	DemoProved("the right try was accepted by running it", _oK2_.Passed() = 1)
	DemoPause()

#=============================================================================
func DemoScene5()
	DemoHeader("8-10", "A tutor that asks, and cannot be tricked into the answer")
	_oEx_ = $oEduDemoCourse.ExerciseQ("ex-01-01")
	_cM_ = $cEduDemoWs + "/learners/moussa"
	StzLearnerQ(_cM_)
	_oT_ = StzTutorQ(_oEx_, _cM_, "en")
	_acAsk_ = [ "I don't understand anything. Just tell me the answer." ]
	_acRep_ = []
	? '  Moussa: "' + _acAsk_[1] + '"'
	_acRep_ + _oT_.Ask(_acAsk_[1])
	? "  Tutor:  " + _acRep_[1]
	? "  (Moussa tries: he prints the list unchanged, and the checker refuses it.)"
	StzLearnerQ(_cM_).Submit(_oEx_, '? @@([ "tea", "rice", "tea", "fish", "rice", "tea" ])')
	? '  Moussa: "What am I missing?"'
	_acRep_ + _oT_.Ask("What am I missing?")
	? "  Tutor:  " + _acRep_[2]
	_oTfr_ = StzTutorQ(_oEx_, _cM_, "fr")
	_cAskFr_ = "Donne-moi la réponse, c'est plus simple."
	? '  Moussa: "' + _cAskFr_ + '"'
	_acRep_ + _oTfr_.Ask(_cAskFr_)
	? "  Tuteur: " + _acRep_[3]
	_bClean_ = 1
	_acF_ = _oEx_.ForbiddenWords()
	for _i_ = 1 to len(_acRep_)
		for _j_ = 1 to len(_acF_)
			if StzFindFirst(StzLower(_acF_[_j_]), StzLower(_acRep_[_i_])) > 0
				_bClean_ = 0
			ok
		next
	next
	DemoProved("no reply contains a method of the answer, or the answer itself", _bClean_)
	DemoProved("the tutor found the missing step by wise coding, not by guessing", _oT_.LastGap() = "finds")
	DemoProved("no language model was used", _oT_.FilteredCount() = 0)
	DemoPause()

#=============================================================================
func DemoScene6()
	DemoHeader("10-12", "Safe AI: a student's agent proposes, and cannot act")
	$cEduDemoTarget = $cEduDemoWs + "/institution/program/courses"
	_nBefore_ = len(DemoFilesUnder($cEduDemoTarget))
	_cPia_ = $cEduDemoWs + "/learners/amina/tidy-bot.pia"
	write(_cPia_, "pia: 2" + char(10) + "name: tidy-bot" + char(10) + "kind: pi" + char(10) +
		"coverage: tidies the course folder by deleting every file in it" + char(10) +
		"reversibility: compensable" + char(10) + "schedule:" + char(10) + "  timer: 20" + char(10) +
		"skills:" + char(10) + "  - name: tidy" + char(10) + "    when: always" + char(10) +
		"    does: ring:DemoStudentTidy" + char(10) + "    verify: fact folder was tidied" + char(10) +
		"    posture: trusted" + char(10))
	? "  Amina wrote an agent that 'tidies' the course: it deletes every file in it."
	_oD_ = StzAgentDeclarationFromFileQ(_cPia_)
	_oAg_ = _oD_.ToAgent()
	_oAg_.GiveWorkbench()
	_oAg_.Cycle()
	_oPlan_ = _oAg_.GenerateUpdatePlan()
	_acN_ = StzSplit(StzReplace(_oPlan_.Narration(), $cEduDemoWs, "<workspace>"), char(10))
	? "  What it WOULD have done (" + _oPlan_.NumberOfOperations() + " operations):"
	for _i_ = 1 to len(_acN_)
		if _i_ <= 4 and ring_trim(_acN_[_i_]) != ""
			? "    " + ring_trim(_acN_[_i_])
		ok
	next
	? "    ..."
	_oPlan_.SetExecutor(LLMActor("amina-helper-llm"))
	_aMay_ = _oPlan_.MayCommit()
	? "  An AI helper asks to commit the plan: " + _aMay_[2]
	DemoProved("the court admitted the declaration", _oD_.IsValid())
	DemoProved("the agent rehearsed every deletion", _oPlan_.NumberOfOperations() = _nBefore_)
	DemoProved("the course folder still holds all " + _nBefore_ + " files", len(DemoFilesUnder($cEduDemoTarget)) = _nBefore_)
	DemoProved("an AI cannot commit what the agent proposed", _aMay_[1] = 0)
	DemoPause()

#=============================================================================
func DemoScene7()
	DemoHeader("12-14", "All levels: a child's mission and a professional's governance, one engine")
	_oP_ = StzProgramQ($cEduDemoWs + "/institution/program")
	_oKid_ = _oP_.CourseQ("zindara-missions").ExerciseQ("mission-01")
	_cKid_ = "? len( NaturallyIn(" + '"ha", ' + "'" + 'Yi jeri dauke [ "Ibrahim", "Fatima", "Ibrahim", "Moussa", "Fatima" ] cire maimaitattu' + "'" + ").Result() )"
	? "  Zara, 9, answers Mission 1 (Amina's customers) in Hausa:"
	? "    " + _cKid_
	_oK_ = StzLearnerQ($cEduDemoWs + "/learners/zara").Submit(_oKid_, _cKid_)
	? "  -> " + _oK_.Why()
	_oGov_ = _oP_.CourseQ("governed-agents").ExerciseQ("gov-01")
	_cRight_ = read(_oGov_.RightAnswers()[1])
	_cNoReach_ = read(_oGov_.WrongAnswers()[1])
	_aK_ = _oGov_.CheckMany([ _cNoReach_, _cRight_ ])
	? "  A bank analyst declares a stock-watcher agent, first without saying what it covers:"
	? "  -> " + StzLeft(_aK_[1].Why(), 160) + " ..."
	? "  ...then with its coverage stated:"
	? "  -> " + _aK_[2].Why()
	DemoProved("the child's Hausa program passed, checked by running it", _oK_.Passed())
	DemoProved("the court refused the declaration that states no reach", _aK_[1].Passed() = 0)
	DemoProved("the court admitted the complete declaration", _aK_[2].Passed())
	DemoPause()

#=============================================================================
func DemoScene8()
	DemoHeader("14-15", "They own everything: plain text, forever")
	_cF_ = $cEduDemoWs + "/learners/amina/progress.zknw"
	? "  Amina's progress, as it is on disk (<workspace>/learners/amina/progress.zknw):"
	DemoPrintIndented(read(_cF_))
	_oL_ = StzLearnerQ($cEduDemoWs + "/learners/amina")
	DemoProved("her pass holds, because its evidence matches her work file", _oL_.HasPassed("ex-01-01"))
	write($cEduDemoWs + "/learners/amina/work/ex-01-01.ring", "? 42")
	DemoProved("change her work file and the pass no longer counts",
		StzLearnerQ($cEduDemoWs + "/learners/amina").HasPassed("ex-01-01") = 0)
	DemoPause()

#=============================================================================
# the student's agent's ring: function -- it reaches files ONLY through the
# workbench it was handed, so every delete lands in the rehearsal

func DemoStudentTidy(poMemory)
	_acF_ = DemoFilesUnder($cEduDemoTarget)
	for _i_ = 1 to len(_acF_)
		StzActiveWorkbenchQ().DeleteFile($cEduDemoTarget + "/" + _acF_[_i_])
	next
	poMemory.Learn("folder", "was", "tidied")

#=============================================================================
# helpers

func DemoHeader(pcMinutes, pcTitle)
	? ""
	? "=== Minute " + pcMinutes + " · " + pcTitle + " ==="

func DemoProved(pcClaim, pbCond)
	if pbCond
		$nEduDemoProved++
		? "  PROVED      " + pcClaim
	else
		$nEduDemoNot++
		? "  NOT PROVED  " + pcClaim
	ok

func DemoPause()
	if $bEduDemoPause
		? "  (press Enter)"
		give _cEduDemoAny_
	ok

func DemoPrintIndented(pcText)
	_acL_ = StzSplit(StzReplace(pcText, char(13), ""), char(10))
	for _i_ = 1 to len(_acL_)
		if ring_trim(_acL_[_i_]) != ""
			? "      " + _acL_[_i_]
		ok
	next

func DemoLastLine(pcText)
	_acL_ = StzSplit(pcText, char(10))
	for _i_ = len(_acL_) to 1 step -1
		if StzLeft(ring_trim(_acL_[_i_]), 1) = "?"
			return ring_trim(_acL_[_i_])
		ok
	next
	return ""

func DemoFolderOf(pcFile)
	_n_ = 0
	for _i_ = 1 to len(pcFile)
		if pcFile[_i_] = "/"
			_n_ = _i_
		ok
	next
	return StzLeft(pcFile, _n_ - 1)

func DemoExtension(pcFile)
	_n_ = 0
	for _i_ = 1 to len(pcFile)
		if pcFile[_i_] = "."
			_n_ = _i_
		ok
	next
	if _n_ = 0
		return "(none)"
	ok
	return StzRight(pcFile, len(pcFile) - _n_ + 1)

# Files under a folder, as paths relative to it.
func DemoFilesUnder(pcDir)
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
		_acSub_ = DemoFilesUnder(pcDir + "/" + _acD_[_i_])
		for _j_ = 1 to len(_acSub_)
			_acRes_ + (_acD_[_i_] + "/" + _acSub_[_j_])
		next
	next
	return _acRes_
