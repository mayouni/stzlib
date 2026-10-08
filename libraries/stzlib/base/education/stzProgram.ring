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

# Opens a learning program, a folder of courses, skills, levels and teaching worlds, and lets an institution lay its own overlay over it.
#
# A learner or a teacher starts here: CourseQ takes a course by its slug, WithWorld chooses the
# world the chapters reason over, and the Review methods say how far each translation has been
# checked by a person. The program is a folder read through its .zknw manifests; every file is
# looked up in the overlay first and the core after, so an institution replaces a world or adds an
# exercise and never writes into the core. Set the overlay and the world BEFORE CourseQ: Ring copies
# the program into the course, so a later WithOverlay does not reach it. WithOverlay, WithoutOverlay
# and WithWorld change the program and have a Q twin that returns it for chaining. LIMITS, stated
# where you meet them: the translations (fr, ar, ha) are drafts, 0 of 35 units of each reviewed by a
# person when this was written, and only ReviewCoverage gives the live figure; the cells of the
# chapters run on the desktop only, not in a browser, and the Run methods start Ring processes whose
# executable path must not contain a space; no institution has adopted the system, and the two
# overlays shipped, bank and university, are references.
#
#   receiver   o1 = new stzProgram("../../education/program")
#   example    ? o1.Id()
#              #--> softanza-education
#              ? @@( o1.Languages() )
#              #--> [ "en", "fr", "ar", "ha" ]
#              ? @@( o1.LevelIds() )
#              #--> [ "s0", "s1", "s2", "s3", "s4" ]
#              ? @@( o1.ChaptersForLevel(o1.CourseQ("elementary-introduction"), "s0") )
#              #--> [ "find-then-apply", "a-first-sentence", "read-the-name-as-a-sentence", "say-it-in-your-language" ]
#   see        stzCourse, stzChapter, stzTutor, stzEduReader
class stzProgram from stzObject

	@cCore = ""
	@cOverlay = ""
	@aFacts = []
	@cWorld = ""     # the teaching world a learner chose ("" = the role's own file)

	# Opens the learning program stored in a folder, reading its program.zknw manifest.
	#
	#   pcFolder   the program's folder, with or without a trailing slash
	#   returns    nothing; the object is built
	#   note       a program is a folder: its courses, skills, levels, worlds and projects are read
	#              from it on demand
	#   warning    raises an error, Not a learning program, when the folder holds no program.zknw
	#   see        CourseQ, WithOverlay
	def init(pcFolder)
		@cCore = _EduNoSlash(pcFolder)
		if NOT fexists(@cCore + "/program.zknw")
			StzRaise("Not a learning program: " + @cCore + "/program.zknw is missing.")
		ok
		@aFacts = _EduFactsOf(@cCore + "/program.zknw")

	# Returns the program's own folder, with slashes forward and none at the end.
	#
	#   returns    a text, such as education/program
	#   see        Name, Overlay
	def Core()
		return @cCore

	# Returns the last segment of the program's folder, the short name it is called by.
	#
	#   returns    a text, such as program
	#   see        Id, Core
	def Name()
		return _EduLastSegment(@cCore)

	# Returns the identifier the manifest gives the program, the subject of its `is-a program` fact.
	#
	#   returns    a text, such as softanza-education; an empty text when the manifest has no such
	#              fact
	#   see        Name, Courses
	#@ aka  The program's own id: the subject of its `is-a program` fact.
	def Id()
		_nL_ = len(@aFacts)
		for _i_ = 1 to _nL_
			if StzLower(@aFacts[_i_][2]) = "is-a" and StzLower(@aFacts[_i_][3]) = "program"
				return @aFacts[_i_][1]
			ok
		next
		return ""

	# Returns the codes of the languages the program speaks, in the order its manifest lists them.
	#
	#   returns    a list of text, such as [ "en", "fr", "ar", "ha" ]
	#   note       en is the source edition; fr, ar and ha are draft translations, 0 of 35 units of
	#              each reviewed by a person when this was written (ReviewCoverage gives the live
	#              figure)
	#   see        ReviewCoverage, SourceLanguage
	def Languages()
		return _EduObjects(@aFacts, "softanza-education", "speaks")

	# Returns the slugs of the courses the manifest declares, in the order it lists them.
	#
	#   returns    a list of text, such as [ "elementary-introduction", "zindara-missions",
	#              "governed-agents", "math" ]
	#   note       a slug is the name of the course's folder under courses/; CourseQ takes it
	#   see        CourseQ, Languages
	def Courses()
		return _EduObjects(@aFacts, "softanza-education", "has-course")

	# Lays an institution's overlay folder over the program, so each of its files is read before the core's.
	#
	#   pcFolder   the overlay's folder, which must hold an overlay.zknw
	#   returns    nothing; use WithOverlayQ to chain
	#   note       an overlay shadows core files one by one and never writes into the core; the two
	#              overlays shipped, bank and university, are references: no institution has adopted
	#              the system
	#   warning    raises an error, Not an overlay, when the folder holds no overlay.zknw; an
	#              overlay set after CourseQ does not reach that course, because the course holds a
	#              copy of the program
	#   see        WithoutOverlay, OverlayReport, FileFor
	#@ aka  -- overlays
	def WithOverlay(pcFolder)
		_c_ = _EduNoSlash(pcFolder)
		if NOT fexists(_c_ + "/overlay.zknw")
			StzRaise("Not an overlay: " + _c_ + "/overlay.zknw is missing.")
		ok
		@cOverlay = _c_

		def WithOverlayQ(pcFolder)
			This.WithOverlay(pcFolder)
			return This

	# Takes the overlay off, so every file is read from the core again.
	#
	#   returns    nothing; use WithoutOverlayQ to chain
	#   note       a course opened while the overlay was on keeps its own copy of the program,
	#              overlay included
	#   see        WithOverlay, HasOverlay
	def WithoutOverlay()
		@cOverlay = ""

		def WithoutOverlayQ()
			This.WithoutOverlay()
			return This

	# Returns the folder of the overlay laid over the program.
	#
	#   returns    a text; an empty text when no overlay is laid on
	#   see        HasOverlay, WithOverlay
	def Overlay()
		return @cOverlay

	# TRUE if an overlay is laid over the program.
	#
	#   returns    TRUE or FALSE
	#   see        Overlay, WithOverlay
	def HasOverlay()
		return @cOverlay != ""

	# Returns every file an institution's folder brings, each paired with whether it adds, shadows or merges into a core file.
	#
	#   returns    a list of [ path, "adds" ], [ path, "shadows" ] or [ path, "merges" ] pairs; [ ]
	#              when no overlay is laid on
	#   note       merges is for a course.zknw or a reviews/ file that the core has too, so an
	#              institution never hides a core course or who signed a core page off; the bank
	#              overlay shadows only worlds/workplace.zknw
	#   see        WithOverlay, FileFor
	#@ aka  Every file the overlay brings, and whether it SHADOWS a core file or ADDS a new one -- so an institution always sees what differs.
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
			if NOT fexists(@cCore + "/" + _acFiles_[_i_])
				_aRes_ + [ _acFiles_[_i_], "adds" ]
			but StzRight(_acFiles_[_i_], 12) = "/course.zknw" or StzLeft(_acFiles_[_i_], 8) = "reviews/"
				# a course manifest and a language's reviews are MERGED into the
				# core's, never shadowing it (an institution never hides who
				# signed a core page off)
				_aRes_ + [ _acFiles_[_i_], "merges" ]
			else
				_aRes_ + [ _acFiles_[_i_], "shadows" ]
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

	# Returns the path of a file of the program, the overlay's copy first and the core's after.
	#
	#   pcRel      the file's path inside the program, such as worlds/school.zknw
	#   returns    a text; an empty text when neither has the file
	#   note       the lookup is file by file, so an overlay can replace one world and leave the
	#              rest
	#   see        FolderFor, WorldFile, WithOverlay
	#@ aka  -- resolution: overlay first, then core, one file at a time
	def FileFor(pcRel)
		if @cOverlay != "" and fexists(@cOverlay + "/" + pcRel)
			return @cOverlay + "/" + pcRel
		ok
		if fexists(@cCore + "/" + pcRel)
			return @cCore + "/" + pcRel
		ok
		return ""

	# Returns the path of a folder of the program, the overlay's first and the core's after.
	#
	#   pcRel      the folder's path inside the program, such as skills
	#   returns    a text; an empty text when neither has it
	#   see        FileFor, WithOverlay
	def FolderFor(pcRel)
		if @cOverlay != "" and StzEngineDirExists(@cOverlay + "/" + pcRel)
			return @cOverlay + "/" + pcRel
		ok
		if StzEngineDirExists(@cCore + "/" + pcRel)
			return @cCore + "/" + pcRel
		ok
		return ""

	# Returns the path of the world file that chapters of a role reason over.
	#
	#   pcRole     the role a chapter names with uses-world, such as workplace
	#   returns    a text; an empty text when no world of that role exists
	#   note       the order is fixed: an overlay that ships worlds/<role>.zknw wins, whatever the
	#              learner chose, then the world chosen with WithWorld, then the core's file of that
	#              role
	#   see        WithWorld, WorldIds, FileFor
	#@ aka  The world a chapter reasons over, by ROLE ("workplace"). An overlay that ships worlds/<role>.zknw wins -- the institution's world IS the workplace, whatever a learner chose; then the learner's chosen world (WithWorld); then the core's file of that role.
	def WorldFile(pcRole)
		if @cOverlay != "" and fexists(@cOverlay + "/worlds/" + pcRole + ".zknw")
			return @cOverlay + "/worlds/" + pcRole + ".zknw"
		ok
		if @cWorld != ""
			return This.FileFor("worlds/" + @cWorld + ".zknw")
		ok
		return This.FileFor("worlds/" + pcRole + ".zknw")

	# Returns the names of the worlds the program and its overlay ship, sorted.
	#
	#   returns    a list of text, such as [ "cooperative", "school", "workplace" ]
	#   see        WithWorld, WorldsWithPages
	#@ aka  -- the teaching worlds a learner may choose without any overlay
	def WorldIds()
		_acRes_ = []
		_acRoots_ = [ @cCore ]
		if @cOverlay != ""
			_acRoots_ + @cOverlay
		ok
		_nR_ = len(_acRoots_)
		for _r_ = 1 to _nR_
			_cDir_ = _acRoots_[_r_] + "/worlds"
			if NOT StzEngineDirExists(_cDir_)
				loop
			ok
			_acF_ = StzEngineDirListFiles(_cDir_)
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

	# Chooses the teaching world a learner's chapters reason over, and refuses a world the program does not ship.
	#
	#   pcName     the world's name, one of WorldIds
	#   returns    nothing; use WithWorldQ to chain
	#   note       set it before CourseQ: a course holds a copy of the program
	#   warning    raises an error naming the worlds the program ships, never quietly the default;
	#              an overlay that ships the role's own world file still wins over the chosen one
	#   see        World, WorldIds, WorldFile
	#@ aka  A world that is not shipped is refused, never quietly the default.
	def WithWorld(pcName)
		if This.FileFor("worlds/" + pcName + ".zknw") = ""
			StzRaise("No world '" + pcName + "' in the program; it ships " + @@(This.WorldIds()) + ".")
		ok
		@cWorld = pcName

		def WithWorldQ(pcName)
			This.WithWorld(pcName)
			return This

	# Returns the world a learner chose.
	#
	#   returns    a text; an empty text when none was chosen
	#   see        WithWorld, HasWorld
	def World()
		return @cWorld

	# TRUE if a learner has chosen a world with WithWorld.
	#
	#   returns    TRUE or FALSE
	#   see        World, WithWorld
	def HasWorld()
		return @cWorld != ""

	# Returns the language the course is written in, the one that is never reviewed as a translation.
	#
	#   returns    a text, en
	#   note       English is the source edition: only the translations are drafts until a native
	#              speaker has signed them off
	#   see        ReviewUnits, ReviewCoverage
	def SourceLanguage()
		return "en"

	# Returns the names of every unit a native reviewer can sign off in a language, in course order.
	#
	#   pcLang     the language code, such as fr, ar or ha
	#   returns    a list of text; [ ] for the source language
	#   note       a unit is a chapter with its exercises (chapter:<course>.<id>), a world page
	#              (world:<name>), the skills (skills) or the tutor's texts (tutor); fr, ar and ha
	#              each have 35 today, all drafts: 0 of 35 reviewed by a person
	#   see        ReviewCoverage, ReviewersOf, UnknownReviews
	def ReviewUnits(pcLang)
		_acRes_ = []
		if StzLower(pcLang) = This.SourceLanguage()
			return _acRes_
		ok
		_acC_ = This.Courses()
		_nC_ = len(_acC_)
		for _i_ = 1 to _nC_
			_oC_ = This.CourseQ(_acC_[_i_])
			_acCh_ = _oC_.ChapterIds()
			_nCh_ = len(_acCh_)
			for _j_ = 1 to _nCh_
				if _oC_.ChapterFile(_acCh_[_j_], pcLang) != ""
					_acRes_ + ("chapter:" + _acC_[_i_] + "." + _acCh_[_j_])
				ok
			next
		next
		_acW_ = This.WorldIds()
		_nW_ = len(_acW_)
		for _i_ = 1 to _nW_
			if This.WorldPageFile(_acW_[_i_], pcLang) != ""
				_acRes_ + ("world:" + _acW_[_i_])
			ok
		next
		_acRes_ + "skills"
		_acRes_ + "tutor"
		return _acRes_

	# Returns the recorded sign-offs of a language, as [ reviewer, "reviewed", unit ] facts.
	#
	#   pcLang     the language code
	#   returns    a list of three-word facts; [ ] when no file exists
	#   note       they are read from reviews/<lang>.zknw in the core and in the overlay, merged, so
	#              an institution that reviews its own pages never hides who signed a core page off
	#   see        ReviewersOf, ReviewUnits
	def ReviewFacts(pcLang)
		_aRes_ = []
		_cRel_ = "reviews/" + StzLower(pcLang) + ".zknw"
		_acRoots_ = [ @cCore ]
		if @cOverlay != ""
			_acRoots_ + @cOverlay
		ok
		_nR_ = len(_acRoots_)
		for _r_ = 1 to _nR_
			if fexists(_acRoots_[_r_] + "/" + _cRel_)
				_aF_ = _EduFactsOf(_acRoots_[_r_] + "/" + _cRel_)
				_nF_ = len(_aF_)
				for _i_ = 1 to _nF_
					if StzLower(_aF_[_i_][2]) = "reviewed"
						_aRes_ + _aF_[_i_]
					ok
				next
			ok
		next
		return _aRes_

	# Returns the names of the people who have signed a unit off in a language.
	#
	#   pcLang     the language code
	#   pcUnit     the unit name, such as chapter:elementary-introduction.find-then-apply, compared
	#              without regard to case
	#   returns    a list of text; [ ] when nobody has signed it
	#   note       no sign-off is recorded in the shipped program: the translations are drafts
	#   see        IsReviewed, ReviewUnits
	def ReviewersOf(pcLang, pcUnit)
		_acRes_ = []
		_aF_ = This.ReviewFacts(pcLang)
		_nF_ = len(_aF_)
		_cU_ = StzLower(pcUnit)
		for _i_ = 1 to _nF_
			if StzLower(_aF_[_i_][3]) = _cU_ and StzFindFirst(_aF_[_i_][1], _acRes_) = 0
				_acRes_ + _aF_[_i_][1]
			ok
		next
		return _acRes_

	# TRUE if at least one person has signed a unit off in a language.
	#
	#   pcLang     the language code
	#   pcUnit     the unit name, as ReviewUnits names it
	#   returns    TRUE or FALSE
	#   see        ReviewersOf, ReviewCoverage
	def IsReviewed(pcLang, pcUnit)
		return len(This.ReviewersOf(pcLang, pcUnit)) > 0

	# Returns how many units of a language a native speaker has signed off, and how many it has in all.
	#
	#   pcLang     the language code
	#   returns    a list of two numbers, [ reviewed, total ]
	#   note       fr, ar and ha read [ 0, 35 ] today: the translations are drafts; the source
	#              language reads [ 0, 0 ]
	#   see        ReviewUnits, IsReviewed
	def ReviewCoverage(pcLang)
		_acU_ = This.ReviewUnits(pcLang)
		_nU_ = len(_acU_)
		_n_ = 0
		for _i_ = 1 to _nU_
			if This.IsReviewed(pcLang, _acU_[_i_])
				_n_++
			ok
		next
		return [ _n_, _nU_ ]

	# Returns the units a sign-off names that are not units of the language, so a typo is reported, not ignored.
	#
	#   pcLang     the language code
	#   returns    a list of text; [ ] when every sign-off names a real unit
	#   see        ReviewFacts, ReviewUnits
	def UnknownReviews(pcLang)
		_acRes_ = []
		_acU_ = This.ReviewUnits(pcLang)
		_aF_ = This.ReviewFacts(pcLang)
		_nF_ = len(_aF_)
		_acLow_ = []
		for _i_ = 1 to len(_acU_)
			_acLow_ + StzLower(_acU_[_i_])
		next
		for _i_ = 1 to _nF_
			if StzFindFirst(StzLower(_aF_[_i_][3]), _acLow_) = 0 and StzFindFirst(_aF_[_i_][3], _acRes_) = 0
				_acRes_ + _aF_[_i_][3]
			ok
		next
		return _acRes_

	# Returns the path of a teaching world's page in a language, the overlay's edition first.
	#
	#   pcWorld    the world's name
	#   pcLang     the language code
	#   returns    a text; an empty text when that edition does not exist
	#   see        WorldPageQ, WorldsWithPages
	#@ aka  -- a page per world: the world itself, questioned, in the chapter format
	def WorldPageFile(pcWorld, pcLang)
		return This.FileFor("worlds/" + pcWorld + "." + pcLang + ".md")

	# Opens a world's page in a language as a chapter, and refuses a missing edition instead of falling back to English.
	#
	#   pcWorld    the world's name
	#   pcLang     the language code
	#   returns    a stzChapter
	#   note       the page is the world itself, questioned, in the chapter format; the fr, ar and
	#              ha pages are draft translations
	#   warning    raises an error, World has no page in that language, for a missing edition
	#   see        WorldPageFile, RunWorldPageQ
	#@ aka  A world with no page in a language is a RED fact, never a quiet fallback to English (law 7).
	def WorldPageQ(pcWorld, pcLang)
		_cF_ = This.WorldPageFile(pcWorld, pcLang)
		if _cF_ = ""
			StzRaise("World '" + pcWorld + "' has no page in '" + pcLang + "'.")
		ok
		return new stzChapter(_cF_, pcLang)

	# Returns the worlds that have a page in at least one of the program's languages.
	#
	#   returns    a list of text, such as [ "cooperative", "school", "workplace" ]
	#   see        WorldIds, WorldPageFile
	#@ aka  The worlds that have a page in at least one language.
	def WorldsWithPages()
		_acRes_ = []
		_acW_ = This.WorldIds()
		_acL_ = This.Languages()
		_nW_ = len(_acW_)
		_nL_ = len(_acL_)
		for _i_ = 1 to _nW_
			for _j_ = 1 to _nL_
				if This.WorldPageFile(_acW_[_i_], _acL_[_j_]) != ""
					_acRes_ + _acW_[_i_]
					exit
				ok
			next
		next
		return _acRes_

	# Runs every cell of a world's page in one fresh process over that world, then observes where each cell can run.
	#
	#   pcWorld    the world's name
	#   pcLang     the language code
	#   returns    a stzChapter, run and observed
	#   note       the cells run on the desktop only, not in a browser; the school page in en took
	#              4.5 s here
	#   warning    raises an error when the Ring executable path contains a space (EDU-RUNPATH-01);
	#              raises for a missing edition
	#   see        RunWorldPageInQ, WorldPageQ
	#@ aka  Runs every cell of a world's page in one fresh process over THAT world (never the chosen one), then observes where each cell can run.
	def RunWorldPageQ(pcWorld, pcLang)
		_oCh_ = This.WorldPageQ(pcWorld, pcLang)
		_oCh_.Run(This.FileFor("worlds/" + pcWorld + ".zknw"))
		_oCh_.ObserveWhere()
		return _oCh_

	# Runs a world's page in several languages, each in its own fresh process, and observes where each cell can run.
	#
	#   pcWorld    the world's name
	#   pacLangs   the language codes, such as [ "en", "fr" ]
	#   returns    a list of stzChapter, one per language, in the order asked
	#   note       the cells run on the desktop only, not in a browser; the processes run side by
	#              side, up to four at a time
	#   warning    raises for a language with no page; raises when the Ring executable path contains
	#              a space
	#   see        RunWorldPageQ, WorldPageQ
	#@ aka  The page in several languages, each edition in its own fresh process, side by side (the shape of stzCourse.RunChapterInQ).
	def RunWorldPageInQ(pcWorld, pacLangs)
		_aCh_ = []
		_acProgs_ = []
		_cWorld_ = This.FileFor("worlds/" + pcWorld + ".zknw")
		_nL_ = len(pacLangs)
		for _i_ = 1 to _nL_
			_oCh_ = This.WorldPageQ(pcWorld, pacLangs[_i_])
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

	# Opens a course of the program by its slug.
	#
	#   pcSlug     the course's slug, one of Courses
	#   returns    a stzCourse
	#   note       the course holds a COPY of the program as it is now: lay the overlay and choose
	#              the world before taking the course
	#   warning    raises an error, No course in the program, for a slug whose folder has no
	#              course.zknw
	#   see        Courses, WithOverlay
	def CourseQ(pcSlug)
		return new stzCourse(This, pcSlug)

	# Returns the ids of the skills the core and the overlay bring, sorted.
	#
	#   returns    a list of text, such as [ "cr-01", "cr-02" ]
	#   see        SkillQ, LevelIds
	#@ aka  -- skills and levels
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

	# Opens a skill by its id, taking the overlay's file over the core's when both exist.
	#
	#   pcId       the skill's id, one of SkillIds
	#   returns    a stzSkill
	#   warning    raises an error, No skill under the skills folder, for an id with no file
	#   see        SkillIds
	def SkillQ(pcId)
		_cDir_ = This.FolderFor("skills")
		if @cOverlay != "" and fexists(@cOverlay + "/skills/" + StzLower(pcId) + ".zknw")
			_cDir_ = @cOverlay + "/skills"
		else
			_cDir_ = @cCore + "/skills"
		ok
		return new stzSkill(_cDir_, pcId)

	# Returns the facts of levels.zknw as [ subject, relation, object ] triples.
	#
	#   returns    a list of three-word facts; [ ] when the program has no levels file
	#   see        LevelIds, LevelFact
	def LevelFacts()
		_cF_ = This.FileFor("levels.zknw")
		if _cF_ = ""
			return []
		ok
		return _EduFactsOf(_cF_)

	# Returns the ids of the levels, lowest rank first.
	#
	#   returns    a list of text, such as [ "s0", "s1", "s2", "s3", "s4" ]
	#   see        LevelFact, ChaptersForLevel
	#@ aka  Level ids in rank order.
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

	# Returns the first object a level has for a relation, such as its name or the chapters it needs.
	#
	#   pcLevel      the level's id, such as s1
	#   pcRelation   the relation to read, such as named, rank or needs-chapters-through
	#   returns      a text; an empty text when the level has none
	#   see          LevelIds, LevelFacts
	#@ aka  One value of a level's fact, "" if absent.
	def LevelFact(pcLevel, pcRelation)
		_ac_ = _EduObjects(This.LevelFacts(), pcLevel, pcRelation)
		if len(_ac_) = 0
			return ""
		ok
		return _ac_[1]

	# Opens the project folder that earns a level, by its id.
	#
	#   pcId       the project's id, such as project-s0, compared in lower case
	#   returns    a stzProject
	#   warning    raises an error, No project in the program, for an id with no folder
	#   see        ProjectIds
	def ProjectQ(pcId)
		_cF_ = This.FolderFor("projects/" + StzLower(pcId))
		if _cF_ = ""
			StzRaise("No project '" + pcId + "' in the program.")
		ok
		return new stzProject(_cF_)

	# Returns the first chapters of a course that a level requires, as many as its needs-chapters-through fact says.
	#
	#   poCourse   the stzCourse whose chapters are counted
	#   pcLevel    the level's id, such as s0
	#   returns    a list of text; [ ] when the level is unknown
	#   see        LevelFact, ProjectIds
	#@ aka  The chapter ids a level requires: the course's first N shipped chapters.
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

	# Returns the ids of the projects that the levels are earned by, in the order levels.zknw lists them.
	#
	#   returns    a list of text, such as [ "project-s0", "project-s1" ]
	#   see        ProjectQ, LevelIds
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

# Holds one course of a program as a path through its chapters, and answers what a learner or a teacher asks of it.
#
# A learner opens a chapter in a language (ChapterQ) or runs it (RunChapterQ); a teacher asks what a
# chapter needs first (Prerequisites), what it trains (Trains), where a name is first taught
# (TeachesWhere) and which planned chapters have no text yet (UnwrittenChapterIds). The course is
# made of two manifests: course.zknw says what ships, in order, and curriculum.zknw says what is
# planned, with its trains and requires facts; an overlay's course.zknw is merged into the core's,
# never shadowing it. A course is taken from a program with CourseQ and holds a COPY of that
# program, so the overlay and the world must be set before. A chapter with no text in a language
# raises an error, never a quiet fallback to English. LIMITS, stated where you meet them: the
# translations (fr, ar, ha) are drafts, 0 of 35 units of each reviewed by a person when this was
# written; the cells of a chapter run on the desktop only, not in a browser, and the Run methods
# start Ring processes whose executable path must not contain a space; no institution has adopted
# the system.
#
#   receiver   o1 = new stzCourse(new stzProgram("../../education/program"), "elementary-
#              introduction")
#   example    ? o1.TitleOf("find-then-apply", "fr")
#              #--> Trouver, puis agir
#              ? @@( o1.Prerequisites("say-it-in-your-language") )
#              #--> [ "read-the-name-as-a-sentence", "a-first-sentence", "find-then-apply" ]
#              ? o1.TeachesWhere("FindDuplicates")
#              #--> find-then-apply
#              ? @@( o1.Trains("find-then-apply") )
#              #--> [ "ex-01", "ex-02", "ex-03" ]
#   see        stzProgram, stzChapter, stzExercise, stzTutor
class stzCourse from stzObject

	@oProgram
	@cSlug = ""
	@aFacts = []
	@aTeachIndex = []     # [ chapter id, names its cells call, the same lowercased ]
	@aTitleIndex = []     # [ language, chapter id, title ]

	# Opens one course of a program, merging the overlay's course facts into the core's.
	#
	#   poProgram   the stzProgram the course belongs to
	#   pcSlug      the course's slug, as Courses gives it
	#   returns     nothing; the object is built
	#   note        the overlay's course.zknw is merged, never shadowing the core's, so an
	#               institution adds a chapter or an exercise without copying the manifest; CourseQ
	#               is the usual way in
	#   warning     raises an error, No course in the program, when the core has no
	#               courses/<slug>/course.zknw
	#   see         CourseQ, Slug
	#@ aka  The course's facts are the CORE's course.zknw plus, when an overlay is laid on, the overlay's own courses/<slug>/course.zknw -- MERGED, never shadowed: an overlay adds a chapter or attaches an exercise to a chapter without copying the core manifest (charter 4.1).
	def init(poProgram, pcSlug)
		@oProgram = poProgram
		@cSlug = pcSlug
		_cCore_ = poProgram.Core() + "/courses/" + pcSlug + "/course.zknw"
		if NOT fexists(_cCore_)
			StzRaise("No course '" + pcSlug + "' in the program.")
		ok
		@aFacts = _EduFactsOf(_cCore_)
		if poProgram.HasOverlay()
			_cOv_ = poProgram.Overlay() + "/courses/" + pcSlug + "/course.zknw"
			if fexists(_cOv_)
				_aMore_ = _EduFactsOf(_cOv_)
				_nM_ = len(_aMore_)
				for _i_ = 1 to _nM_
					@aFacts + _aMore_[_i_]
				next
			ok
		ok

	# Returns the course's slug, the name of its folder.
	#
	#   returns    a text, such as elementary-introduction
	#   see        Program, ChapterIds
	def Slug()
		return @cSlug

	# Returns the program the course reads its files from.
	#
	#   returns    a stzProgram, the copy taken when the course was opened
	#   note       an overlay laid on the original program afterwards is not seen here
	#   see        Slug
	def Program()
		return @oProgram

	# Returns the facts of the course's curriculum.zknw, the plan the shipped chapters are measured against.
	#
	#   returns    a list of three-word facts; [ ] when the course has no curriculum
	#   note       the curriculum holds plans-chapter-NN, trains and requires; course.zknw holds
	#              only what exists
	#   see        HasCurriculum, PlannedChapterIds
	#@ aka  -- the curriculum: the PLAN of the course, against which what SHIPS (course.zknw) is measured. It carries plans-chapter-NN, trains and requires; course.zknw carries only what exists.
	def CurriculumFacts()
		_cF_ = @oProgram.FileFor("courses/" + @cSlug + "/curriculum.zknw")
		if _cF_ = ""
			return []
		ok
		return _EduFactsOf(_cF_)

	# TRUE if the course has a curriculum file with at least one fact.
	#
	#   returns    TRUE or FALSE
	#   note       zindara-missions has none
	#   see        CurriculumFacts
	def HasCurriculum()
		return len(This.CurriculumFacts()) > 0

	# Returns the ids of the chapters the curriculum plans, in plan order.
	#
	#   returns    a list of text; [ ] when the course has no curriculum
	#   see        UnwrittenChapterIds, ChapterIds
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

	# Returns the planned chapters that have no text yet, so the gap is named and not counted as shipped.
	#
	#   returns    a list of text; [ ] when every planned chapter exists
	#   see        PlannedChapterIds, ChapterIds
	#@ aka  Planned chapters with no text yet -- printed by name, never summed into the shipped count.
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

	# Returns the skills the curriculum says a chapter trains.
	#
	#   pcChapterId   the chapter's id, such as find-then-apply
	#   returns       a list of skill ids; [ ] for an unknown chapter
	#   see           TrainedBy, Requires
	def Trains(pcChapterId)
		return _EduObjects(This.CurriculumFacts(), pcChapterId, "trains")

	# Returns the chapters the curriculum says a chapter needs directly, before it.
	#
	#   pcChapterId   the chapter's id
	#   returns       a list of chapter ids; [ ] when it needs none
	#   see           Prerequisites, Trains
	def Requires(pcChapterId)
		return _EduObjects(This.CurriculumFacts(), pcChapterId, "requires")

	# Returns the chapters the curriculum says train a skill.
	#
	#   pcSkillId   the skill's id, such as ex-01, compared without regard to case
	#   returns     a list of chapter ids; [ ] when none does
	#   see         Trains
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

	# Returns everything a chapter needs first, walked back to the root, nearest chapter first.
	#
	#   pcChapterId   the chapter's id
	#   returns       a list of chapter ids; [ ] for a chapter that needs nothing
	#   note          each chapter is listed once, even when several paths reach it
	#   warning       raises an error, The curriculum has a cycle, when the requirements go round
	#   see           Requires, HasCycle
	#@ aka  Everything a chapter needs first, walked to the root; a cycle raises.
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

	# TRUE if the curriculum's requirements go round in a circle.
	#
	#   returns    TRUE or FALSE
	#   note       only the planned chapters are examined
	#   see        Prerequisites
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

	# Returns the ids of the shipped chapters in course order.
	#
	#   returns    a list of text
	#   note       the order lives in the relation name has-chapter-NN of course.zknw
	#   see        ChapterNumber, PlannedChapterIds
	#@ aka  Chapter ids in course order (the order lives in the relation name, has-chapter-NN, because .zknw has no ordered list -- charter 5.2).
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

	# Returns a chapter's two-digit place in the course.
	#
	#   pcId       the chapter's id
	#   returns    a text, such as 02
	#   warning    raises an error, No chapter in the course, for an unknown id
	#   see        ChapterIds, ChapterFile
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

	# Returns the path of a chapter's edition in a language, the overlay's file first.
	#
	#   pcId       the chapter's id
	#   pcLang     the language code, such as en
	#   returns    a text; an empty text when that edition does not exist
	#   note       fr, ar and ha editions are draft translations, none yet reviewed by a person
	#   warning    raises an error for a chapter id the course does not have
	#   see        ChapterQ, ChapterNumber
	def ChapterFile(pcId, pcLang)
		return @oProgram.FileFor("courses/" + @cSlug + "/chapters/" +
			This.ChapterNumber(pcId) + "-" + pcId + "." + pcLang + ".md")

	# Opens a chapter's edition in a language, and refuses a missing one instead of falling back to English.
	#
	#   pcId       the chapter's id
	#   pcLang     the language code
	#   returns    a stzChapter
	#   note       the fr, ar and ha editions are drafts: 0 of 35 units of each reviewed by a person
	#   warning    raises an error, Chapter has no text in that language, when the edition is
	#              missing
	#   see        ChapterFile, RunChapterQ, TitleOf
	#@ aka  A chapter with no text in a language is a RED fact, never a quiet fallback to English (law 7).
	def ChapterQ(pcId, pcLang)
		_cF_ = This.ChapterFile(pcId, pcLang)
		if _cF_ = ""
			StzRaise("Chapter '" + pcId + "' has no text in '" + pcLang + "'.")
		ok
		return new stzChapter(_cF_, pcLang)

	# Returns the names a chapter's cells call, read from its English edition.
	#
	#   pcId       the chapter's id
	#   returns    a list of text, in the order the cells call them; [ ] for an unknown chapter
	#   note       the cells are identical in every edition, only the prose moves; the first call
	#              reads the English edition of every chapter
	#   see        TeachesWhere
	#@ aka  -- what each chapter teaches, read from its own cells (the tutor's rule 2)
	def NamesTaughtBy(pcId)
		This._IndexTeaching()
		_nL_ = len(@aTeachIndex)
		for _i_ = 1 to _nL_
			if @aTeachIndex[_i_][1] = pcId
				return @aTeachIndex[_i_][2]
			ok
		next
		return []

	# Returns the first chapter, in course order, whose cells call a name.
	#
	#   pcName     the whole name to look for, such as FindDuplicates, compared without regard to
	#              case
	#   returns    a chapter id; an empty text when no chapter calls it
	#   note       a partial name finds nothing: Find does not match FindDuplicates
	#   see        NamesTaughtBy
	#@ aka  The first chapter, in course order, whose cells call a name; "" when no chapter does. Case does not matter.
	def TeachesWhere(pcName)
		This._IndexTeaching()
		_cN_ = StzLower(pcName)
		_nL_ = len(@aTeachIndex)
		for _i_ = 1 to _nL_
			if StzFindFirst(_cN_, @aTeachIndex[_i_][3]) > 0
				return @aTeachIndex[_i_][1]
			ok
		next
		return ""

	# Returns a chapter's title in a language, read from the first line of that edition.
	#
	#   pcId       the chapter's id
	#   pcLang     the language code
	#   returns    a text, such as Find, then apply
	#   note       a title is read once and kept
	#   warning    raises for an edition that does not exist
	#   see        ChapterQ, ChapterIds
	#@ aka  The title of a chapter in a language, from that edition's first line.
	def TitleOf(pcId, pcLang)
		_cLang_ = StzLower(pcLang)
		_nL_ = len(@aTitleIndex)
		for _i_ = 1 to _nL_
			if @aTitleIndex[_i_][1] = _cLang_ and @aTitleIndex[_i_][2] = pcId
				return @aTitleIndex[_i_][3]
			ok
		next
		_cT_ = This.ChapterQ(pcId, pcLang).Title()
		@aTitleIndex + [ _cLang_, pcId, _cT_ ]
		return _cT_

	def _IndexTeaching()
		if len(@aTeachIndex) > 0
			return
		ok
		_acCh_ = This.ChapterIds()
		_nL_ = len(_acCh_)
		for _i_ = 1 to _nL_
			_acN_ = This.ChapterQ(_acCh_[_i_], "en").CalledNames()
			_acLow_ = []
			_nN_ = len(_acN_)
			for _j_ = 1 to _nN_
				_acLow_ + StzLower(_acN_[_j_])
			next
			@aTeachIndex + [ _acCh_[_i_], _acN_, _acLow_ ]
		next

	# Returns the role of the world a chapter reasons over, such as workplace.
	#
	#   pcId       the chapter's id
	#   returns    a text; an empty text for a chapter that uses no world
	#   see        WorldFileOf
	def WorldRoleOf(pcId)
		_acR_ = _EduObjects(@aFacts, pcId, "uses-world")
		if len(_acR_) = 0
			return ""
		ok
		return _acR_[1]

	# Returns the path of the world file a chapter reasons over, as the program or its overlay supplies it.
	#
	#   pcId       the chapter's id
	#   returns    a text; an empty text for a chapter that uses no world
	#   see        WorldRoleOf, RunChapterQ
	def WorldFileOf(pcId)
		_cRole_ = This.WorldRoleOf(pcId)
		if _cRole_ = ""
			return ""
		ok
		return @oProgram.WorldFile(_cRole_)

	# Returns the ids of the exercises attached to a chapter, the overlay's after the core's.
	#
	#   pcId       the chapter's id
	#   returns    a list of text; [ ] when it has none
	#   see        ExerciseQ
	def ExercisesOf(pcId)
		return _EduObjects(@aFacts, pcId, "has-exercise")

	# Opens an exercise of the course by its id.
	#
	#   pcExerciseId   the exercise's id, such as ex-01-01
	#   returns        a stzExercise
	#   warning        raises an error, No exercise in the course, for an id with no folder
	#   see            ExercisesOf
	def ExerciseQ(pcExerciseId)
		_cF_ = @oProgram.FolderFor("courses/" + @cSlug + "/exercises/" + pcExerciseId)
		if _cF_ = ""
			StzRaise("No exercise '" + pcExerciseId + "' in course '" + @cSlug + "'.")
		ok
		return new stzExercise(_cF_)

	# Runs every cell of a chapter in one fresh process over its world, then observes where each cell can run.
	#
	#   pcId       the chapter's id
	#   pcLang     the language code
	#   returns    a stzChapter, run and observed
	#   note       the cells run on the desktop only, not in a browser; find-then-apply in en took
	#              22 s here, 7 promises, all kept
	#   warning    raises an error when the Ring executable path contains a space (EDU-RUNPATH-01);
	#              raises for a missing edition
	#   see        RunChapterInQ, ChapterQ
	#@ aka  Runs every cell of a chapter in one fresh process, over the world the program (or its overlay) supplies, then observes where each cell can run. The chapter object comes back holding both.
	def RunChapterQ(pcId, pcLang)
		_oCh_ = This.ChapterQ(pcId, pcLang)
		_oCh_.Run(This.WorldFileOf(pcId))
		_oCh_.ObserveWhere()
		return _oCh_

	# Runs a chapter in several languages, each in its own fresh process, and observes where each cell can run.
	#
	#   pcId       the chapter's id
	#   pacLangs   the language codes, such as [ "en", "fr" ]
	#   returns    a list of stzChapter, one per language, in the order asked
	#   note       the cells run on the desktop only; no cell can lean on another language's
	#              variables, and the processes run side by side, up to four at a time; en and fr
	#              together took 18 s here
	#   warning    raises for a language with no edition; raises when the Ring executable path
	#              contains a space
	#   see        RunChapterQ, ChapterQ
	#@ aka  The chapter in several languages: each language in its OWN fresh process (no cell can lean on another language's variables), the processes side by side. Returns the chapters, run and observed.
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
