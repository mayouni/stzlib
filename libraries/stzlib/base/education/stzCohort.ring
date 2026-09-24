#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZCOHORT                   #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : A COHORT is a folder of learners following  #
#                  one course under one overlay. Its progress  #
#                  report is a NARRATION: every number in it   #
#                  is a promise, so running the report says    #
#                  whether it is still true.                   #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
#   cohorts/<name>/cohort.zknw     `<name> | follows | <course>`, `| under | <overlay>`, `| has-learner | <id>`
#   cohorts/<name>/<learner>/      a stzLearner folder: work/, projects/, progress.zknw
#   cohorts/<name>/reports/        generated narrations
#
# The report is generated from progress.zknw files that only the checker
# writes. It is a plain text file the institution keeps; and because each
# figure is written as a promise beside the cell that computes it, a report
# run through StzChapterQ after the learners moved on REPORTS ITS OWN
# STALENESS instead of quietly lying (law 9).

func StzCohortQ(pcFolder)
	return new stzCohort(pcFolder)

# The folder above a folder: "a/b/c" -> "a/b"; "c" -> "."
func _EduParentOf(pcPath)
	_c_ = _EduNoSlash(pcPath)
	_nSlash_ = 0
	_nL_ = len(_c_)
	for _i_ = 1 to _nL_
		if _c_[_i_] = "/"
			_nSlash_ = _i_
		ok
	next
	if _nSlash_ = 0
		return "."
	ok
	return StzLeft(_c_, _nSlash_ - 1)

func _EduAbsolute(pcPath)
	_c_ = _EduNoSlash(pcPath)
	if StzLeft(_c_, 1) = "/" or (StzLen(_c_) > 1 and StzMid(_c_, 2, 1) = ":")
		return _c_
	ok
	return StzReplace(currentdir(), char(92), "/") + "/" + _c_

class stzCohort from stzObject

	@cFolder = ""
	@cName = ""
	@aFacts = []

	def init(pcFolder)
		@cFolder = _EduNoSlash(pcFolder)
		@cName = _EduLastSegment(@cFolder)
		if NOT fexists(@cFolder + "/cohort.zknw")
			StzRaise("Not a cohort: " + @cFolder + "/cohort.zknw is missing.")
		ok
		@aFacts = _EduFactsOf(@cFolder + "/cohort.zknw")

	def Name()
		return @cName

	def Folder()
		return @cFolder

	def CourseSlug()
		_ac_ = _EduObjects(@aFacts, @cName, "follows")
		if len(_ac_) = 0
			StzRaise("Cohort '" + @cName + "' follows no course.")
		ok
		return _ac_[1]

	def OverlayName()
		_ac_ = _EduObjects(@aFacts, @cName, "under")
		if len(_ac_) = 0
			return ""
		ok
		return _ac_[1]

	def LearnerIds()
		return _EduObjects(@aFacts, @cName, "has-learner")

	def LearnerQ(pcId)
		return StzLearnerQ(@cFolder + "/" + pcId)

	def AddLearner(pcId)
		if StzFindFirst(pcId, This.LearnerIds()) > 0
			return This.LearnerQ(pcId)
		ok
		@aFacts + [ @cName, "has-learner", pcId ]
		This._Save()
		return This.LearnerQ(pcId)

	def _Save()
		_c_ = 'knowledge "' + @cName + '"' + char(10) + char(10) + "facts" + char(10)
		_nL_ = len(@aFacts)
		for _i_ = 1 to _nL_
			_c_ += "    " + @aFacts[_i_][1] + " | " + @aFacts[_i_][2] + " | " + @aFacts[_i_][3] + char(10)
		next
		write(@cFolder + "/cohort.zknw", _c_)

	# The program this cohort is judged against: the core, with the
	# cohort's overlay laid on when it names one. Overlays live BESIDE the
	# program folder, in <parent>/overlays/<name> (base/education/overlays/).
	def ProgramQ(pcProgramFolder)
		_oP_ = StzProgramQ(pcProgramFolder)
		_cOv_ = This.OverlayName()
		if _cOv_ != ""
			_cDir_ = _EduParentOf(_EduNoSlash(pcProgramFolder)) + "/overlays/" + _cOv_
			if NOT fexists(_cDir_ + "/overlay.zknw")
				StzRaise("Cohort '" + @cName + "' is under overlay '" + _cOv_ + "', and " + _cDir_ + " is not one.")
			ok
			_oP_.WithOverlay(_cDir_)
		ok
		return _oP_

	# Every exercise of every chapter of the cohort's course, under its overlay.
	def ExerciseIds(poProgram)
		_oC_ = poProgram.CourseQ(This.CourseSlug())
		_acCh_ = _oC_.ChapterIds()
		_acRes_ = []
		_nL_ = len(_acCh_)
		for _i_ = 1 to _nL_
			_acEx_ = _oC_.ExercisesOf(_acCh_[_i_])
			_nE_ = len(_acEx_)
			for _e_ = 1 to _nE_
				_acRes_ + _acEx_[_e_]
			next
		next
		return _acRes_

	def PassedBy(pcLearner, poProgram)
		_oL_ = This.LearnerQ(pcLearner)
		_acAll_ = This.ExerciseIds(poProgram)
		_acRes_ = []
		_nL_ = len(_acAll_)
		for _i_ = 1 to _nL_
			if _oL_.HasPassed(_acAll_[_i_])
				_acRes_ + _acAll_[_i_]
			ok
		next
		return _acRes_

	def LevelsEarnedBy(pcLearner, poProgram)
		_oL_ = This.LearnerQ(pcLearner)
		_oC_ = poProgram.CourseQ(This.CourseSlug())
		_acLv_ = poProgram.LevelIds()
		_acRes_ = []
		_nL_ = len(_acLv_)
		for _i_ = 1 to _nL_
			if _oL_.HasEarned(poProgram, _oC_, _acLv_[_i_])
				_acRes_ + _acLv_[_i_]
			ok
		next
		return _acRes_

	#-- the report, a narration

	def Report(pcProgramFolder)
		_oP_ = This.ProgramQ(pcProgramFolder)
		_cAbsCo_ = _EduAbsolute(@cFolder)
		_cAbsPr_ = _EduAbsolute(pcProgramFolder)
		_acIds_ = This.LearnerIds()
		_nAll_ = len(This.ExerciseIds(_oP_))
		_cOv_ = This.OverlayName()
		if _cOv_ = ""
			_cOv_ = "(none)"
		ok
		_c_ = "# Progress of cohort " + @cName + char(10) + char(10)
		_c_ += "*Course " + This.CourseSlug() + ", overlay " + _cOv_ + ", " + len(_acIds_) + " learners, " + _nAll_ +
		       " exercises. Every figure below is a promise beside the cell that computes it: run this file" +
		       " through StzChapterQ, and it says whether it is still true.*" + char(10) + char(10)
		_c_ += "| Learner | Exercises passed | Levels earned |" + char(10) + "|---|---|---|" + char(10)
		_aRows_ = []
		_nL_ = len(_acIds_)
		for _i_ = 1 to _nL_
			_acP_ = This.PassedBy(_acIds_[_i_], _oP_)
			_acLv_ = This.LevelsEarnedBy(_acIds_[_i_], _oP_)
			_cLv_ = "none"
			if len(_acLv_) > 0
				_cLv_ = Q(_acLv_).Joined(", ")
			ok
			_c_ += "| " + _acIds_[_i_] + " | " + len(_acP_) + " of " + _nAll_ + " | " + _cLv_ + " |" + char(10)
			_aRows_ + [ _acIds_[_i_], len(_acP_), _acLv_ ]
		next
		_c_ += char(10)
		for _i_ = 1 to _nL_
			_c_ += "## " + _aRows_[_i_][1] + char(10) + char(10) + "```ring" + char(10)
			_c_ += 'oCohort = StzCohortQ("' + _cAbsCo_ + '")' + char(10)
			_c_ += 'oProgram = oCohort.ProgramQ("' + _cAbsPr_ + '")' + char(10)
			_c_ += '? len( oCohort.PassedBy("' + _aRows_[_i_][1] + '", oProgram) )' + char(10)
			_c_ += "#--> " + _aRows_[_i_][2] + char(10)
			_c_ += '? @@( oCohort.LevelsEarnedBy("' + _aRows_[_i_][1] + '", oProgram) )' + char(10)
			_c_ += "#--> " + @@(_aRows_[_i_][3]) + char(10)
			_c_ += "```" + char(10) + char(10)
		next
		return _c_

	def WriteReport(pcProgramFolder, pcFile)
		_cDir_ = @cFolder + "/reports"
		StzEngineDirCreatePath(_cDir_)
		_cFile_ = pcFile
		if _cFile_ = ""
			_cFile_ = _cDir_ + "/progress.en.md"
		ok
		write(_cFile_, This.Report(pcProgramFolder))
		return _cFile_

	# Runs a report as the narration it is: 1 when every figure still holds.
	def IsReportCurrent(pcFile)
		_oCh_ = StzChapterQ(pcFile, "en")
		_oCh_.Run("")
		return _oCh_.AllCellsRan() and _oCh_.AllPromisesKept()
