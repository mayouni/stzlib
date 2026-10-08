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

# Holds a folder of learners following one course under one overlay, and writes their progress as a narration that checks itself.
#
# A cohort is a folder with cohort.zknw, whose facts name the course it follows, the overlay it is
# under and its learners; each learner is a stzLearner folder inside it. Its report is generated
# from the learners' progress files, which only the checker writes, and every figure in it sits as a
# promise beside the cell that computes it, so running the report says whether it is still true. The
# cells run on the desktop only.
#
#   receiver   StzEduRemoveTree("t_edu_doc/espa"); StzEngineDirCreatePath("t_edu_doc/espa");
#              write("t_edu_doc/espa/cohort.zknw", 'knowledge "espa"' + char(10) + char(10) +
#              "facts" + char(10) + "    espa | follows | elementary-introduction" + char(10) + "
#              espa | under | bank" + char(10)); o1 = new stzCohort("t_edu_doc/espa")
#   example    ? o1.CourseSlug()
#              #--> elementary-introduction
#              o1.AddLearner("amina")
#              ? @@( o1.LearnerIds() )
#              #--> [ "amina" ]
#              oP = o1.ProgramQ("../../education/program")
#              ? len( o1.ExerciseIds(oP) )
#              #--> 24
#   see        stzLearner, stzOverlay, stzProgram
class stzCohort from stzObject

	@cFolder = ""
	@cName = ""
	@aFacts = []

	# Opens a cohort from its folder, which must hold cohort.zknw, the facts that name its course, its overlay and its learners.
	#
	#   pcFolder   the cohort's folder: its last segment is the cohort's name
	#   returns    nothing; the object is built
	#   note       a cohort is a folder of learners following one course under one overlay: each
	#              learner is a stzLearner folder inside it, and reports/ holds the generated
	#              narrations
	#   warning    raises an error saying Not a cohort and naming the missing cohort.zknw when the
	#              folder lacks that file
	#   see        AddLearner, CourseSlug, ProgramQ
	def init(pcFolder)
		@cFolder = _EduNoSlash(pcFolder)
		@cName = _EduLastSegment(@cFolder)
		if NOT fexists(@cFolder + "/cohort.zknw")
			StzRaise("Not a cohort: " + @cFolder + "/cohort.zknw is missing.")
		ok
		@aFacts = _EduFactsOf(@cFolder + "/cohort.zknw")

	# Returns the cohort's name, which is the last segment of its folder's path.
	#
	#   returns    a text such as espa-2026
	#   see        Folder, CourseSlug
	def Name()
		return @cName

	# Returns the cohort's folder path, without a trailing slash.
	#
	#   returns    a text
	#   see        Name, LearnerQ
	def Folder()
		return @cFolder

	# Returns the id of the course the cohort follows, as its cohort.zknw says.
	#
	#   returns    a text such as elementary-introduction
	#   warning    raises an error naming the cohort when the file has no follows fact
	#   see        OverlayName, ProgramQ
	def CourseSlug()
		_ac_ = _EduObjects(@aFacts, @cName, "follows")
		if len(_ac_) = 0
			StzRaise("Cohort '" + @cName + "' follows no course.")
		ok
		return _ac_[1]

	# Returns the name of the overlay the cohort is under, or an empty text when it names none.
	#
	#   returns    a text such as bank; an empty text for none
	#   see        CourseSlug, ProgramQ
	def OverlayName()
		_ac_ = _EduObjects(@aFacts, @cName, "under")
		if len(_ac_) = 0
			return ""
		ok
		return _ac_[1]

	# Returns the ids of the learners enrolled in the cohort, in the order they were added.
	#
	#   returns    a list of text; [ ] for a cohort with no learner
	#   see        AddLearner, LearnerQ
	def LearnerIds()
		return _EduObjects(@aFacts, @cName, "has-learner")

	# Opens the stzLearner whose folder is the cohort's folder plus the id, creating the folders on disk when they are absent.
	#
	#   pcId       the learner's id
	#   returns    a stzLearner
	#   note       it does not enroll: an id never added is opened, and its folders are created, but
	#              it stays out of LearnerIds and of the report
	#   see        AddLearner, LearnerIds
	def LearnerQ(pcId)
		return StzLearnerQ(@cFolder + "/" + pcId)

	# Enrolls a learner by id, saving cohort.zknw, and returns that learner; an id already enrolled is not added twice.
	#
	#   pcId       the learner's id, with no space
	#   returns    the learner's stzLearner
	#   note       the learner's folder is created at once
	#   see        LearnerQ, LearnerIds
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

	# Returns the program the cohort is judged against: the core program, with the cohort's overlay laid on when it names one.
	#
	#   pcProgramFolder   the core program's folder, beside which the overlays/<name> folders sit
	#   returns           a stzProgram
	#   note              the overlay is found at overlays/<name> beside the program folder
	#   warning           raises an error naming the cohort and the folder when the overlay it names
	#                     is not a folder with overlay.zknw
	#   see               ExerciseIds, Report, stzProgram
	#@ aka  The program this cohort is judged against: the core, with the cohort's overlay laid on when it names one. Overlays live BESIDE the program folder, in <parent>/overlays/<name> (base/education/overlays/).
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

	# Returns the id of every exercise of every chapter of the cohort's course, those an overlay adds included, in course order.
	#
	#   poProgram   the stzProgram given by ProgramQ, so that the overlay counts
	#   returns     a list of text
	#   note        with the bank reference overlay laid on, the elementary course has 24 exercises,
	#               one more than the core's 23
	#   see         PassedBy, ProgramQ
	#@ aka  Every exercise of every chapter of the cohort's course, under its overlay.
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

	# Returns the exercises of the cohort's course that a learner has passed, with evidence that still matches.
	#
	#   pcLearner   the learner's id
	#   poProgram   the stzProgram given by ProgramQ
	#   returns     a list of exercise ids; [ ] when none
	#   see         LevelsEarnedBy, ExerciseIds, stzLearner
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

	# Returns the levels a learner has earned in the cohort's course, in the program's order.
	#
	#   pcLearner   the learner's id
	#   poProgram   the stzProgram given by ProgramQ
	#   returns     a list of level ids such as s0; [ ] when none
	#   note        no level is earned by one exercise: a level also needs the passes of its
	#               chapters and its project
	#   see         PassedBy, stzLearner
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

	# Returns the cohort's progress report as a narration: a table of its learners, then one cell of promises per learner.
	#
	#   pcProgramFolder   the core program's folder, as for ProgramQ
	#   returns           a text, markdown with ring cells whose figures are #--> promises
	#   note              every figure is a promise beside the cell that computes it, so the report
	#                     can say whether it is still true
	#   warning           the cells hold absolute paths of this machine and run on the desktop only,
	#                     so a report copied elsewhere cannot be run
	#   see               WriteReport, IsReportCurrent
	#@ aka  -- the report, a narration
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

	# Writes the progress report to a file and returns the path written.
	#
	#   pcProgramFolder   the core program's folder, as for ProgramQ
	#   pcFile            the file to write, or an empty text for reports/progress.en.md under the
	#                     cohort's folder
	#   returns           a text, the path
	#   see               Report, IsReportCurrent
	def WriteReport(pcProgramFolder, pcFile)
		_cDir_ = @cFolder + "/reports"
		StzEngineDirCreatePath(_cDir_)
		_cFile_ = pcFile
		if _cFile_ = ""
			_cFile_ = _cDir_ + "/progress.en.md"
		ok
		write(_cFile_, This.Report(pcProgramFolder))
		return _cFile_

	# TRUE if the report, run as the narration it is, still has every cell running and every promise kept.
	#
	#   pcFile     a written report, or any narration file
	#   returns    TRUE or FALSE
	#   note       it runs the report's cells, so it takes seconds and runs on the desktop only; a
	#              report written before a learner passed one more exercise answers FALSE (shown),
	#              and writing it again makes it TRUE
	#   see        WriteReport, Report
	#@ aka  Runs a report as the narration it is: 1 when every figure still holds.
	def IsReportCurrent(pcFile)
		_oCh_ = StzChapterQ(pcFile, "en")
		_oCh_.Run("")
		return _oCh_.AllCellsRan() and _oCh_.AllPromisesKept()
