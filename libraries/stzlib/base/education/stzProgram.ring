#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZPROGRAM                  #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : A learning PROGRAM is a folder; a COURSE is #
#                  a path through its chapters; an OVERLAY is  #
#                  an institution's folder laid over the core. #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# In plain words: a program HAS courses, skills and worlds. A course IS A
# PATH THROUGH chapters. An overlay SHADOWS core files one by one and can
# never write into the core (law 5). Resolution is overlay first, then
# core, file by file -- so a bank's overlay that ships worlds/workplace.zknw
# makes the SAME chapter reason over the bank.
#
# Manifests are .zknw facts (charter 5.2): the course's own data is a
# knowledge world, readable by the same Query a learner uses.
#
#   oProgram = StzProgramQ("education/program")
#   oProgram.WithOverlay("education/overlays/bank")
#   oCourse = oProgram.CourseQ("elementary-introduction")
#   oChapter = oCourse.RunChapterQ("find-then-apply", "fr")
#
# Set the overlay BEFORE taking a course: Ring copies the program into
# the course, so a later WithOverlay() on the program does not reach it.

func StzProgramQ(pcFolder)
	return new stzProgram(pcFolder)

func _EduNoSlash(pcPath)
	_c_ = StzReplace("" + pcPath, char(92), "/")
	while StzLen(_c_) > 1 and StzRight(_c_, 1) = "/"
		_c_ = StzLeft(_c_, StzLen(_c_) - 1)
	end
	return _c_

func _EduLastSegment(pcPath)
	_c_ = _EduNoSlash(pcPath)
	_acParts_ = StzSplit(_c_, "/")
	return _acParts_[len(_acParts_)]

# Facts of a .zknw file, as [ subject, relation, object ] triples.
func _EduFactsOf(pcFile)
	_oKg_ = new stzKnowledgeGraph("manifest")
	_oKg_.ImportKnow(pcFile)
	return _oKg_.Facts()

# Objects of (subject, relation) in written order, case-insensitive.
func _EduObjects(paFacts, pcSubject, pcRelation)
	_acRes_ = []
	_cS_ = StzLower(pcSubject)
	_cR_ = StzLower(pcRelation)
	_nL_ = len(paFacts)
	for _i_ = 1 to _nL_
		if StzLower(paFacts[_i_][1]) = _cS_ and StzLower(paFacts[_i_][2]) = _cR_
			_acRes_ + paFacts[_i_][3]
		ok
	next
	return _acRes_

class stzProgram from stzObject

	@cCore = ""
	@cOverlay = ""
	@aFacts = []

	def init(pcFolder)
		@cCore = _EduNoSlash(pcFolder)
		if NOT fexists(@cCore + "/program.zknw")
			StzRaise("Not a learning program: " + @cCore + "/program.zknw is missing.")
		ok
		@aFacts = _EduFactsOf(@cCore + "/program.zknw")

	def Core()
		return @cCore

	def Name()
		return _EduLastSegment(@cCore)

	def Languages()
		return _EduObjects(@aFacts, "softanza-education", "speaks")

	def Courses()
		return _EduObjects(@aFacts, "softanza-education", "has-course")

	#-- overlays

	def WithOverlay(pcFolder)
		_c_ = _EduNoSlash(pcFolder)
		if NOT fexists(_c_ + "/overlay.zknw")
			StzRaise("Not an overlay: " + _c_ + "/overlay.zknw is missing.")
		ok
		@cOverlay = _c_

		def WithOverlayQ(pcFolder)
			This.WithOverlay(pcFolder)
			return This

	def WithoutOverlay()
		@cOverlay = ""

		def WithoutOverlayQ()
			This.WithoutOverlay()
			return This

	def Overlay()
		return @cOverlay

	def HasOverlay()
		return @cOverlay != ""

	# Every file the overlay brings, and whether it SHADOWS a core file or
	# ADDS a new one -- so an institution always sees what differs.
	def OverlayReport()
		_aRes_ = []
		if @cOverlay = ""
			return _aRes_
		ok
		_acFiles_ = This._FilesUnder(@cOverlay, "")
		_nL_ = len(_acFiles_)
		for _i_ = 1 to _nL_
			if _acFiles_[_i_] = "overlay.zknw"
				loop
			ok
			if fexists(@cCore + "/" + _acFiles_[_i_])
				_aRes_ + [ _acFiles_[_i_], "shadows" ]
			else
				_aRes_ + [ _acFiles_[_i_], "adds" ]
			ok
		next
		return _aRes_

	def _FilesUnder(pcRoot, pcRel)
		_acRes_ = []
		_cDir_ = pcRoot
		if pcRel != ""
			_cDir_ = pcRoot + "/" + pcRel
		ok
		_acF_ = StzEngineDirListFiles(_cDir_)
		_nF_ = len(_acF_)
		for _i_ = 1 to _nF_
			if pcRel = ""
				_acRes_ + _acF_[_i_]
			else
				_acRes_ + (pcRel + "/" + _acF_[_i_])
			ok
		next
		_acD_ = StzEngineDirListDirs(_cDir_)
		_nD_ = len(_acD_)
		for _i_ = 1 to _nD_
			_cSub_ = _acD_[_i_]
			if pcRel != ""
				_cSub_ = pcRel + "/" + _acD_[_i_]
			ok
			_acMore_ = This._FilesUnder(pcRoot, _cSub_)
			_nM_ = len(_acMore_)
			for _j_ = 1 to _nM_
				_acRes_ + _acMore_[_j_]
			next
		next
		return _acRes_

	#-- resolution: overlay first, then core, one file at a time

	def FileFor(pcRel)
		if @cOverlay != "" and fexists(@cOverlay + "/" + pcRel)
			return @cOverlay + "/" + pcRel
		ok
		if fexists(@cCore + "/" + pcRel)
			return @cCore + "/" + pcRel
		ok
		return ""

	def FolderFor(pcRel)
		if @cOverlay != "" and StzEngineDirExists(@cOverlay + "/" + pcRel)
			return @cOverlay + "/" + pcRel
		ok
		if StzEngineDirExists(@cCore + "/" + pcRel)
			return @cCore + "/" + pcRel
		ok
		return ""

	def WorldFile(pcRole)
		return This.FileFor("worlds/" + pcRole + ".zknw")

	def CourseQ(pcSlug)
		return new stzCourse(This, pcSlug)

	#-- skills and levels

	# Every skill the core AND the overlay bring, by id, sorted.
	def SkillIds()
		_acRes_ = []
		_acDirs_ = [ @cCore + "/skills" ]
		if @cOverlay != ""
			_acDirs_ + (@cOverlay + "/skills")
		ok
		_nD_ = len(_acDirs_)
		for _d_ = 1 to _nD_
			if NOT StzEngineDirExists(_acDirs_[_d_])
				loop
			ok
			_acF_ = StzEngineDirListFiles(_acDirs_[_d_])
			_nF_ = len(_acF_)
			for _i_ = 1 to _nF_
				if StzRight(_acF_[_i_], 5) = ".zknw"
					_cId_ = StzLeft(_acF_[_i_], StzLen(_acF_[_i_]) - 5)
					if StzFindFirst(_cId_, _acRes_) = 0
						_acRes_ + _cId_
					ok
				ok
			next
		next
		return sort(_acRes_)

	def SkillQ(pcId)
		_cDir_ = This.FolderFor("skills")
		if @cOverlay != "" and fexists(@cOverlay + "/skills/" + StzLower(pcId) + ".zknw")
			_cDir_ = @cOverlay + "/skills"
		else
			_cDir_ = @cCore + "/skills"
		ok
		return new stzSkill(_cDir_, pcId)

	def LevelFacts()
		_cF_ = This.FileFor("levels.zknw")
		if _cF_ = ""
			return []
		ok
		return _EduFactsOf(_cF_)

	# Level ids in rank order.
	def LevelIds()
		_aF_ = This.LevelFacts()
		_aPairs_ = []
		_nL_ = len(_aF_)
		for _i_ = 1 to _nL_
			if StzLower(_aF_[_i_][2]) = "is-a" and StzLower(_aF_[_i_][3]) = "level"
				_acR_ = _EduObjects(_aF_, _aF_[_i_][1], "rank")
				_nR_ = 0
				if len(_acR_) > 0
					_nR_ = 0 + _acR_[1]
				ok
				_aPairs_ + [ _nR_, _aF_[_i_][1] ]
			ok
		next
		_aPairs_ = sort(_aPairs_, 1)
		_acRes_ = []
		_nP_ = len(_aPairs_)
		for _i_ = 1 to _nP_
			_acRes_ + _aPairs_[_i_][2]
		next
		return _acRes_

	# One value of a level's fact, "" if absent.
	def LevelFact(pcLevel, pcRelation)
		_ac_ = _EduObjects(This.LevelFacts(), pcLevel, pcRelation)
		if len(_ac_) = 0
			return ""
		ok
		return _ac_[1]

	def ProjectQ(pcId)
		_cF_ = This.FolderFor("projects/" + StzLower(pcId))
		if _cF_ = ""
			StzRaise("No project '" + pcId + "' in the program.")
		ok
		return new stzProject(_cF_)

	# The chapter ids a level requires: the course's first N shipped chapters.
	def ChaptersForLevel(poCourse, pcLevel)
		_nThrough_ = 0 + This.LevelFact(pcLevel, "needs-chapters-through")
		_acAll_ = poCourse.ChapterIds()
		_acRes_ = []
		_nL_ = len(_acAll_)
		for _i_ = 1 to _nL_
			if _i_ <= _nThrough_
				_acRes_ + _acAll_[_i_]
			ok
		next
		return _acRes_

	def ProjectIds()
		_aF_ = This.LevelFacts()
		_acRes_ = []
		_nL_ = len(_aF_)
		for _i_ = 1 to _nL_
			if StzLower(_aF_[_i_][2]) = "is-a" and StzLower(_aF_[_i_][3]) = "project"
				_acRes_ + _aF_[_i_][1]
			ok
		next
		return _acRes_

class stzCourse from stzObject

	@oProgram
	@cSlug = ""
	@aFacts = []

	def init(poProgram, pcSlug)
		@oProgram = poProgram
		@cSlug = pcSlug
		_cF_ = poProgram.FileFor("courses/" + pcSlug + "/course.zknw")
		if _cF_ = ""
			StzRaise("No course '" + pcSlug + "' in the program.")
		ok
		@aFacts = _EduFactsOf(_cF_)

	def Slug()
		return @cSlug

	def Program()
		return @oProgram

	#-- the curriculum: the PLAN of the course, against which what SHIPS
	#   (course.zknw) is measured. It carries plans-chapter-NN, trains
	#   and requires; course.zknw carries only what exists.

	def CurriculumFacts()
		_cF_ = @oProgram.FileFor("courses/" + @cSlug + "/curriculum.zknw")
		if _cF_ = ""
			return []
		ok
		return _EduFactsOf(_cF_)

	def HasCurriculum()
		return len(This.CurriculumFacts()) > 0

	def PlannedChapterIds()
		_aF_ = This.CurriculumFacts()
		_aPairs_ = []
		_cS_ = StzLower(@cSlug)
		_nL_ = len(_aF_)
		for _i_ = 1 to _nL_
			if StzLower(_aF_[_i_][1]) = _cS_ and StzLeft(StzLower(_aF_[_i_][2]), 14) = "plans-chapter-"
				_aPairs_ + [ _aF_[_i_][2], _aF_[_i_][3] ]
			ok
		next
		_aPairs_ = sort(_aPairs_, 1)
		_acRes_ = []
		_nP_ = len(_aPairs_)
		for _i_ = 1 to _nP_
			_acRes_ + _aPairs_[_i_][2]
		next
		return _acRes_

	# Planned chapters with no text yet -- printed by name, never summed
	# into the shipped count.
	def UnwrittenChapterIds()
		_acPlan_ = This.PlannedChapterIds()
		_acHave_ = This.ChapterIds()
		_acRes_ = []
		_nL_ = len(_acPlan_)
		for _i_ = 1 to _nL_
			if StzFindFirst(_acPlan_[_i_], _acHave_) = 0
				_acRes_ + _acPlan_[_i_]
			ok
		next
		return _acRes_

	def Trains(pcChapterId)
		return _EduObjects(This.CurriculumFacts(), pcChapterId, "trains")

	def Requires(pcChapterId)
		return _EduObjects(This.CurriculumFacts(), pcChapterId, "requires")

	def TrainedBy(pcSkillId)
		_aF_ = This.CurriculumFacts()
		_acRes_ = []
		_nL_ = len(_aF_)
		for _i_ = 1 to _nL_
			if StzLower(_aF_[_i_][2]) = "trains" and StzLower(_aF_[_i_][3]) = StzLower(pcSkillId)
				_acRes_ + _aF_[_i_][1]
			ok
		next
		return _acRes_

	# Everything a chapter needs first, walked to the root; a cycle raises.
	def Prerequisites(pcChapterId)
		_acRes_ = []
		This._Walk(pcChapterId, _acRes_, [ pcChapterId ])
		return _acRes_

	def _Walk(pcId, pacInto, pacPath)
		_acReq_ = This.Requires(pcId)
		_nL_ = len(_acReq_)
		for _i_ = 1 to _nL_
			_c_ = _acReq_[_i_]
			if StzFindFirst(_c_, pacPath) > 0
				StzRaise("The curriculum has a cycle: " + _c_ + " requires itself through " + pcId + ".")
			ok
			if StzFindFirst(_c_, pacInto) = 0
				pacInto + _c_
				_acDeeper_ = pacPath
				_acDeeper_ + _c_
				This._Walk(_c_, pacInto, _acDeeper_)
			ok
		next

	def HasCycle()
		_acPlan_ = This.PlannedChapterIds()
		_nL_ = len(_acPlan_)
		for _i_ = 1 to _nL_
			try
				This.Prerequisites(_acPlan_[_i_])
			catch
				return 1
			done
		next
		return 0

	# Chapter ids in course order (the order lives in the relation name,
	# has-chapter-NN, because .zknw has no ordered list -- charter 5.2).
	def ChapterIds()
		_aPairs_ = []
		_cS_ = StzLower(@cSlug)
		_nL_ = len(@aFacts)
		for _i_ = 1 to _nL_
			if StzLower(@aFacts[_i_][1]) = _cS_ and StzLeft(StzLower(@aFacts[_i_][2]), 12) = "has-chapter-"
				_aPairs_ + [ @aFacts[_i_][2], @aFacts[_i_][3] ]
			ok
		next
		_aPairs_ = sort(_aPairs_, 1)
		_acRes_ = []
		_nP_ = len(_aPairs_)
		for _i_ = 1 to _nP_
			_acRes_ + _aPairs_[_i_][2]
		next
		return _acRes_

	def ChapterNumber(pcId)
		_cS_ = StzLower(@cSlug)
		_nL_ = len(@aFacts)
		for _i_ = 1 to _nL_
			if StzLower(@aFacts[_i_][1]) = _cS_ and StzLower(@aFacts[_i_][3]) = StzLower(pcId) and
			   StzLeft(StzLower(@aFacts[_i_][2]), 12) = "has-chapter-"
				return StzRight(@aFacts[_i_][2], 2)
			ok
		next
		StzRaise("No chapter '" + pcId + "' in course '" + @cSlug + "'.")

	def ChapterFile(pcId, pcLang)
		return @oProgram.FileFor("courses/" + @cSlug + "/chapters/" +
			This.ChapterNumber(pcId) + "-" + pcId + "." + pcLang + ".md")

	# A chapter with no text in a language is a RED fact, never a quiet
	# fallback to English (law 7).
	def ChapterQ(pcId, pcLang)
		_cF_ = This.ChapterFile(pcId, pcLang)
		if _cF_ = ""
			StzRaise("Chapter '" + pcId + "' has no text in '" + pcLang + "'.")
		ok
		return new stzChapter(_cF_, pcLang)

	def WorldRoleOf(pcId)
		_acR_ = _EduObjects(@aFacts, pcId, "uses-world")
		if len(_acR_) = 0
			return ""
		ok
		return _acR_[1]

	def WorldFileOf(pcId)
		_cRole_ = This.WorldRoleOf(pcId)
		if _cRole_ = ""
			return ""
		ok
		return @oProgram.WorldFile(_cRole_)

	def ExercisesOf(pcId)
		return _EduObjects(@aFacts, pcId, "has-exercise")

	def ExerciseQ(pcExerciseId)
		_cF_ = @oProgram.FolderFor("courses/" + @cSlug + "/exercises/" + pcExerciseId)
		if _cF_ = ""
			StzRaise("No exercise '" + pcExerciseId + "' in course '" + @cSlug + "'.")
		ok
		return new stzExercise(_cF_)

	# Runs every cell of a chapter in one fresh process, over the world the
	# program (or its overlay) supplies, then observes where each cell can
	# run. The chapter object comes back holding both.
	def RunChapterQ(pcId, pcLang)
		_oCh_ = This.ChapterQ(pcId, pcLang)
		_oCh_.Run(This.WorldFileOf(pcId))
		_oCh_.ObserveWhere()
		return _oCh_

	# The chapter in several languages: each language in its OWN fresh
	# process (no cell can lean on another language's variables), the
	# processes side by side. Returns the chapters, run and observed.
	def RunChapterInQ(pcId, pacLangs)
		_aCh_ = []
		_acProgs_ = []
		_cWorld_ = This.WorldFileOf(pcId)
		_nL_ = len(pacLangs)
		# the library runs first, side by side; the plain-Ring runs after
		for _i_ = 1 to _nL_
			_oCh_ = This.ChapterQ(pcId, pacLangs[_i_])
			_acProgs_ + _oCh_.RunProgram(_cWorld_)
			_aCh_ + _oCh_
		next
		for _i_ = 1 to _nL_
			_acProgs_ + _aCh_[_i_].WhereProgram()
		next
		_aRuns_ = StzEduRunPrograms(_acProgs_)
		for _i_ = 1 to _nL_
			_aCh_[_i_].AcceptRun(_aRuns_[_i_])
			_aCh_[_i_].AcceptWhere(_aRuns_[_nL_ + _i_])
		next
		return _aCh_
