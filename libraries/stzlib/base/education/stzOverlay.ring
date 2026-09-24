#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZOVERLAY                  #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : An OVERLAY is an institution's adaptation   #
#                  of the core program, laid over it file by   #
#                  file: its world, its exercises, its         #
#                  languages, its brand, its governance. It    #
#                  ADDS and SHADOWS; it never forks the core.  #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# On disk (charter 4.1), every folder optional but the manifest:
#   overlay.zknw                         who I am, what I extend, what I speak
#   worlds/<role>.zknw                   replaces the core world of that role
#   courses/<slug>/course.zknw           facts MERGED into the core course:
#                                        an added chapter, an attached exercise
#   courses/<slug>/chapters/NN-<id>.<lang>.md    an ADDED chapter, every language
#   courses/<slug>/exercises/<id>/       an ADDED exercise, in the usual shape
#   governance/<name>.zgov               a regime the learners' agents live under
#
# Check(oProgram) is the overlay's COURT: it returns findings in the house
# shape [ :rule, :subject, :where, :severity, :message ], and an overlay is
# valid when none is an error. The rule that matters most is overlay-no-fork:
# an overlay may replace a WORLD, and may add chapters and exercises, but a
# file that would replace a core chapter or a core exercise is a fork, and
# a fork is refused (law 5).

func StzOverlayQ(pcFolder)
	return new stzOverlay(pcFolder)

# The guide's first step made runnable: copy the template folder and fill
# every {{PLACEHOLDER}} in every text file with the value given for it.
func StzOverlayFromTemplate(pcTemplate, pcTarget, paPairs)
	StzEduCopyTree(pcTemplate, pcTarget)
	_acFiles_ = _EduFilesUnder(_EduNoSlash(pcTarget), "")
	_nF_ = len(_acFiles_)
	_nP_ = len(paPairs)
	for _i_ = 1 to _nF_
		_cPath_ = _EduNoSlash(pcTarget) + "/" + _acFiles_[_i_]
		_c_ = read(_cPath_)
		for _j_ = 1 to _nP_
			_c_ = StzReplace(_c_, paPairs[_j_][1], paPairs[_j_][2])
		next
		write(_cPath_, _c_)
	next
	return new stzOverlay(pcTarget)

class stzOverlay from stzObject

	@cFolder = ""
	@cId = ""
	@cName = ""
	@aFacts = []

	def init(pcFolder)
		@cFolder = _EduNoSlash(pcFolder)
		@cId = _EduLastSegment(@cFolder)
		if fexists(@cFolder + "/overlay.zknw")
			@aFacts = _EduFactsOf(@cFolder + "/overlay.zknw")
			_nL_ = len(@aFacts)
			for _i_ = 1 to _nL_
				if StzLower(@aFacts[_i_][2]) = "is-a" and StzLower(@aFacts[_i_][3]) = "overlay"
					@cName = @aFacts[_i_][1]
				ok
			next
		ok

	def Folder()
		return @cFolder

	def Id()
		return @cId

	def Name()
		return @cName

	def HasManifest()
		return @cName != ""

	def Extends()
		return _EduObjects(@aFacts, @cName, "extends")

	def Languages()
		return _EduObjects(@aFacts, @cName, "speaks")

	def Brand()
		_ac_ = _EduObjects(@aFacts, @cName, "branded")
		if len(_ac_) = 0
			return ""
		ok
		return _ac_[1]

	def ReplacedWorlds()
		return _EduObjects(@aFacts, @cName, "replaces-world")

	def Files()
		return _EduFilesUnder(@cFolder, "")

	#-- the court

	def Check(poProgram)
		_aF_ = []
		if NOT This.HasManifest()
			_aF_ + This._Finding("overlay-manifest", @cId, "overlay.zknw", "error",
				"an overlay must carry overlay.zknw with one `<name> | is-a | overlay` fact; without it nothing can be laid over the core")
			return _aF_
		ok
		# what it extends is the program it is laid over
		_acExt_ = This.Extends()
		if len(_acExt_) = 0 or StzLower(_acExt_[1]) != StzLower(poProgram.Id())
			_aF_ + This._Finding("overlay-extends", @cName, "overlay.zknw", "error",
				"the overlay must say `" + @cName + " | extends | " + poProgram.Id() + "`, the id of the program it is laid over")
		ok
		# every language it speaks is one the core teaches in
		_acCoreLangs_ = poProgram.Languages()
		_acL_ = This.Languages()
		_nL_ = len(_acL_)
		for _i_ = 1 to _nL_
			if StzFindFirst(_acL_[_i_], _acCoreLangs_) = 0
				_aF_ + This._Finding("overlay-language", @cName, "overlay.zknw", "error",
					"'" + _acL_[_i_] + "' is not a language of the core program (" + @@(_acCoreLangs_) + "); a new language is added to the natural pack, not declared here")
			ok
		next
		# worlds: every world file loads and keeps the teaching world's
		# contract (StzEduWorldFindings); every replaced world is shipped
		_cW_ = @cFolder + "/worlds"
		if StzEngineDirExists(_cW_)
			_acWf_ = StzEngineDirListFiles(_cW_)
			_nW_ = len(_acWf_)
			for _i_ = 1 to _nW_
				_acMsg_ = StzEduWorldFindings(_cW_ + "/" + _acWf_[_i_])
				_nM_ = len(_acMsg_)
				for _j_ = 1 to _nM_
					_aF_ + This._Finding("overlay-world", @cName, "worlds/" + _acWf_[_i_], "error", _acMsg_[_j_])
				next
			next
		ok
		_acRw_ = This.ReplacedWorlds()
		_nR_ = len(_acRw_)
		for _i_ = 1 to _nR_
			if NOT fexists(_cW_ + "/" + _acRw_[_i_] + ".zknw")
				_aF_ + This._Finding("overlay-world", @cName, "worlds/" + _acRw_[_i_] + ".zknw", "error",
					"the overlay says it replaces world '" + _acRw_[_i_] + "' but ships no worlds/" + _acRw_[_i_] + ".zknw")
			ok
		next
		# courses: added chapters and exercises, never replaced ones
		_cC_ = @cFolder + "/courses"
		if StzEngineDirExists(_cC_)
			_acSlugs_ = StzEngineDirListDirs(_cC_)
			_nS_ = len(_acSlugs_)
			for _s_ = 1 to _nS_
				This._CheckCourse(poProgram, _acSlugs_[_s_], _aF_, _acCoreLangs_)
			next
		ok
		# governance: every regime loads
		_cG_ = @cFolder + "/governance"
		if StzEngineDirExists(_cG_)
			_acGf_ = StzEngineDirListFiles(_cG_)
			_nG_ = len(_acGf_)
			for _i_ = 1 to _nG_
				try
					_oGov_ = new stzGovernance("check")
					_oGov_.LoadFrom(_cG_ + "/" + _acGf_[_i_])
				catch
					_aF_ + This._Finding("overlay-governance", @cName, "governance/" + _acGf_[_i_], "error",
						"the regime does not load: " + StzLeft(cCatchError, 120))
				done
			next
		ok
		return _aF_

	def _CheckCourse(poProgram, pcSlug, paFindings, pacCoreLangs)
		_cCoreCourse_ = poProgram.Core() + "/courses/" + pcSlug
		if NOT StzEngineDirExists(_cCoreCourse_)
			paFindings + This._Finding("overlay-course", @cName, "courses/" + pcSlug, "error",
				"the core has no course '" + pcSlug + "'; an overlay adds to a course, it does not create one")
			return
		ok
		# chapters
		_cCh_ = @cFolder + "/courses/" + pcSlug + "/chapters"
		_acAddedIds_ = []
		if StzEngineDirExists(_cCh_)
			_acF_ = StzEngineDirListFiles(_cCh_)
			_nF_ = len(_acF_)
			for _i_ = 1 to _nF_
				if fexists(_cCoreCourse_ + "/chapters/" + _acF_[_i_])
					paFindings + This._Finding("overlay-no-fork", @cName, "courses/" + pcSlug + "/chapters/" + _acF_[_i_], "error",
						"this file would replace a core chapter; an overlay adds chapters and replaces worlds, it never rewrites the core (law 5)")
				else
					_cBase_ = _acF_[_i_]
					_nDot_ = StzFindFirst(".", _cBase_)
					if _nDot_ > 0
						_cBase_ = StzLeft(_cBase_, _nDot_ - 1)
					ok
					if StzFindFirst(_cBase_, _acAddedIds_) = 0
						_acAddedIds_ + _cBase_
					ok
				ok
			next
			_nA_ = len(_acAddedIds_)
			for _i_ = 1 to _nA_
				_nLg_ = len(pacCoreLangs)
				for _j_ = 1 to _nLg_
					if NOT fexists(_cCh_ + "/" + _acAddedIds_[_i_] + "." + pacCoreLangs[_j_] + ".md")
						paFindings + This._Finding("overlay-chapter", @cName, "courses/" + pcSlug + "/chapters/" + _acAddedIds_[_i_], "error",
							"an added chapter must exist in every language of the program; '" + pacCoreLangs[_j_] + "' is missing (law 7)")
					ok
				next
			next
		ok
		# exercises
		_cEx_ = @cFolder + "/courses/" + pcSlug + "/exercises"
		if StzEngineDirExists(_cEx_)
			_acD_ = StzEngineDirListDirs(_cEx_)
			_nD_ = len(_acD_)
			for _i_ = 1 to _nD_
				if StzEngineDirExists(_cCoreCourse_ + "/exercises/" + _acD_[_i_])
					paFindings + This._Finding("overlay-no-fork", @cName, "courses/" + pcSlug + "/exercises/" + _acD_[_i_], "error",
						"this folder would replace the core exercise '" + _acD_[_i_] + "'; give yours another id")
					loop
				ok
				try
					_oE_ = new stzExercise(_cEx_ + "/" + _acD_[_i_])
					_nLg_ = len(pacCoreLangs)
					for _j_ = 1 to _nLg_
						if NOT _oE_.HasTaskIn(pacCoreLangs[_j_])
							paFindings + This._Finding("overlay-exercise", @cName, "courses/" + pcSlug + "/exercises/" + _acD_[_i_], "error",
								"the task is missing in '" + pacCoreLangs[_j_] + "' (law 7)")
						ok
					next
					_aP_ = _oE_.ProveItself()
					if _aP_[:wrong] < 1 or _aP_[:right] < 1
						paFindings + This._Finding("overlay-exercise", @cName, "courses/" + pcSlug + "/exercises/" + _acD_[_i_], "error",
							"an exercise ships at least one answer that must fail (wrong/) and one that must pass (right/)")
					but len(_aP_[:failures]) > 0
						paFindings + This._Finding("overlay-exercise", @cName, "courses/" + pcSlug + "/exercises/" + _acD_[_i_], "error",
							"the exercise does not prove itself: " + @@(_aP_[:failures]))
					ok
				catch
					paFindings + This._Finding("overlay-exercise", @cName, "courses/" + pcSlug + "/exercises/" + _acD_[_i_], "error",
						"the exercise folder is not usable: " + StzLeft(cCatchError, 120))
				done
			next
		ok

	def _Finding(pcRule, pcSubject, pcWhere, pcSeverity, pcMessage)
		return [ :rule = pcRule, :subject = pcSubject, :where = pcWhere, :severity = pcSeverity, :message = pcMessage ]

	def IsValid(poProgram)
		_aF_ = This.Check(poProgram)
		_nL_ = len(_aF_)
		for _i_ = 1 to _nL_
			if _aF_[_i_][:severity] = "error"
				return 0
			ok
		next
		return 1

	def CiteFindings(poProgram)
		_aF_ = This.Check(poProgram)
		_c_ = ""
		_nL_ = len(_aF_)
		for _i_ = 1 to _nL_
			_c_ += "[" + _aF_[_i_][:rule] + " @ " + _aF_[_i_][:where] + "] " + _aF_[_i_][:message] + char(10)
		next
		return _c_
