#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZEDUCATION                #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : The Softanza Learning System -- the shared  #
#                  layer: the fresh-process runner, the        #
#                  promise matcher, and the world sugar a      #
#                  chapter's cells read.                       #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# Plane stzlib-education. Charter: base/education/CHARTER.md.
#
# THE LAW THIS FILE SERVES: everything runs, nothing is stored (law 2).
# A cell or an exercise is judged by RUNNING it in a FRESH Ring process,
# never in the checker's own process: every cell variable is a global,
# and a learner writing `true = 0` or `nL = 3` must not reach the judge.
#
# THE PROMISE MATCHER is a Ring port of the rules in base/meta/promises.py
# (Python is refused by law 1). It is a SUBSET, named here so nobody
# mistakes it for the whole: ordered subsequence; TRUE/FALSE = 1/0;
# whitespace inside list brackets ignored; a quoted string equals its
# content; a promise of 5+ characters may sit inside a longer line, a
# shorter one must equal the whole line; a list promise also matches a
# list printed one item per line; `#--> ERROR: text` expects a raise.
# Ownership of the port is offered to the meta plane (EDU-PROMISE-RING-01).

$oStzEduWorld = ""
$nStzEduRun = 0

  #========================#
 #  THE FRESH-PROCESS RUN  #
#========================#

# The Ring executable this process runs on, with forward slashes.
# The engine's system call does not accept a QUOTED program path, so a
# path with a space cannot be run yet (EDU-RUNPATH-01): refuse it loudly
# rather than fail with a shell message nobody can read.
func StzEduRingExe()
	_cExe_ = StzReplace(exefilename(), char(92), "/")
	if StzFindFirst(" ", _cExe_) > 0
		StzRaise("The Ring executable path contains a space (" + _cExe_ + "); the education runner cannot start it yet (EDU-RUNPATH-01).")
	ok
	return _cExe_

# Absolute path of stzBase.ring, derived from the engine directory the
# library discovered at load ($cEngineDir = .../libraries/stzlib/engine).
func StzEduBaseFile()
	_nSlash_ = 0
	_nL_ = len($cEngineDir)
	for _i_ = 1 to _nL_
		if $cEngineDir[_i_] = "/"
			_nSlash_ = _i_
		ok
	next
	return StzLeft($cEngineDir, _nSlash_ - 1) + "/base/stzBase.ring"

# Runs Ring source in a fresh process whose working directory is this
# one. Returns [ stdout, exit code, stderr ]. The script file is written
# next to the caller and removed after the run.
func StzEduRunProgram(pcCode)
	$nStzEduRun++
	_cFile_ = "_edu_run_" + $nStzEduRun + ".ring"
	write(_cFile_, pcCode)
	_aR_ = StzEngineSystemRunXT(StzEduRingExe() + " " + _cFile_)
	remove(_cFile_)
	return [ "" + _aR_[1], 0 + _aR_[2], "" + _aR_[3] ]

# The same code, preceded by the library -- what a learner's program is.
func StzEduCopyTree(pcFrom, pcTo)
	StzEngineDirCreatePath(pcTo)
	_acF_ = StzEngineDirListFiles(pcFrom)
	_nF_ = len(_acF_)
	for _i_ = 1 to _nF_
		write(pcTo + "/" + _acF_[_i_], read(pcFrom + "/" + _acF_[_i_]))
	next
	_acD_ = StzEngineDirListDirs(pcFrom)
	_nD_ = len(_acD_)
	for _i_ = 1 to _nD_
		StzEduCopyTree(pcFrom + "/" + _acD_[_i_], pcTo + "/" + _acD_[_i_])
	next

func StzEduRemoveTree(pcDir)
	if NOT StzEngineDirExists(pcDir)
		return
	ok
	_acF_ = StzEngineDirListFiles(pcDir)
	_nF_ = len(_acF_)
	for _i_ = 1 to _nF_
		remove(pcDir + "/" + _acF_[_i_])
	next
	_acD_ = StzEngineDirListDirs(pcDir)
	_nD_ = len(_acD_)
	for _i_ = 1 to _nD_
		StzEduRemoveTree(pcDir + "/" + _acD_[_i_])
	next
	StzEngineDirDelete(pcDir)

func StzEduRunSoftanza(pcCode)
	return StzEduRunProgram(StzEduWithLibrary(pcCode))

# The learner's prelude also merges the Hausa supplement, so a child who
# answers in Hausa is checked like everyone else (EDU-HAUSA-LIST-01).
func StzEduWithLibrary(pcCode)
	return 'load "' + StzEduBaseFile() + '"' + char(10) +
	       'EduPrepareLanguage("ha")' + char(10) + pcCode + char(10)

# Several programs, each in its OWN fresh process (isolation is kept),
# run side by side -- at most 4 at a time, because each child loads the
# whole library and this machine's memory is budgeted (stzlib CLAUDE.md).
# The cost of a check is the child's cold start (~3 s), so running them
# in parallel is what keeps a guard inside its budget WITHOUT merging
# learner programs into one process. Returns [ stdout, exit, stderr ]
# per program, in the order given.
func StzEduRunPrograms(pacCodes)
	_aRes_ = []
	_nAll_ = len(pacCodes)
	_nFrom_ = 1
	while _nFrom_ <= _nAll_
		_nTo_ = _nFrom_ + 3
		if _nTo_ > _nAll_
			_nTo_ = _nAll_
		ok
		_aKids_ = []
		_acFiles_ = []
		for _i_ = _nFrom_ to _nTo_
			$nStzEduRun++
			_cFile_ = "_edu_run_" + $nStzEduRun + ".ring"
			write(_cFile_, pacCodes[_i_])
			_acFiles_ + _cFile_
			_aKids_ + SpawnProcess(StzEduRingExe() + " " + _cFile_)
		next
		_nK_ = len(_aKids_)
		for _k_ = 1 to _nK_
			_cOut_ = _aKids_[_k_].ReadOutputAll()
			_cErr_ = _aKids_[_k_].ReadErrorAll()
			_nExit_ = _aKids_[_k_].Wait()
			_aKids_[_k_].Close()
			remove(_acFiles_[_k_])
			_aRes_ + [ _cOut_, 0 + _nExit_, _cErr_ ]
		next
		_nFrom_ = _nTo_ + 1
	end
	return _aRes_

  #=====================#
 #  THE PROMISE MATCH  #
#=====================#

# The expected values written in `#--> ...` lines of a piece of code.
func StzEduPromisesIn(pcCode)
	_acRes_ = []
	_acLines_ = StzSplit(pcCode, char(10))
	_nL_ = len(_acLines_)
	for _i_ = 1 to _nL_
		_c_ = ring_trim(StzReplace(_acLines_[_i_], char(13), ""))
		if StzLeft(_c_, 5) = "# -->"
			_acRes_ + ring_trim(StzRight(_c_, StzLen(_c_) - 5))
		but StzLeft(_c_, 4) = "#-->"
			_acRes_ + ring_trim(StzRight(_c_, StzLen(_c_) - 4))
		ok
	next
	return _acRes_

func StzEduNormalize(pcText)
	_c_ = ring_trim(StzReplace("" + pcText, char(13), ""))
	_cLow_ = StzLower(_c_)
	if _cLow_ = "true"
		return "1"
	but _cLow_ = "false"
		return "0"
	ok
	_c_ = StzReplace(_c_, "[ ", "[")
	_c_ = StzReplace(_c_, " ]", "]")
	_c_ = StzReplace(_c_, ", ", ",")
	_c_ = StzReplace(_c_, "'", '"')
	_n_ = StzLen(_c_)
	if _n_ >= 2 and StzLeft(_c_, 1) = '"' and StzRight(_c_, 1) = '"' and
	   StzFindFirst('"', StzMid(_c_, 2, _n_ - 2)) = 0
		_c_ = StzMid(_c_, 2, _n_ - 2)
	ok
	return _c_

# Non-empty, normalized output lines.
func StzEduOutputLines(pcOutput)
	_acRes_ = []
	_acLines_ = StzSplit(pcOutput, char(10))
	_nL_ = len(_acLines_)
	for _i_ = 1 to _nL_
		_c_ = StzEduNormalize(_acLines_[_i_])
		if _c_ != ""
			_acRes_ + _c_
		ok
	next
	return _acRes_

# Judges an output against promises. Returns
#   [ :kept = 1|0, :report = [ [ promise, 1|0 ], ... ] ]
# The report names which promise diverged; it never computes an
# expected value itself -- the promise IS the expectation.
func StzEduMatchPromises(pacPromises, pcOutput, pcError)
	_acOut_ = StzEduOutputLines(pcOutput)
	_nOut_ = len(_acOut_)
	_nPos_ = 1
	_aReport_ = []
	_bAll_ = 1
	_nP_ = len(pacPromises)
	for _p_ = 1 to _nP_
		_cRaw_ = pacPromises[_p_]
		_bHit_ = 0
		if StzLeft(StzLower(_cRaw_), 6) = "error:"
			_cMsg_ = StzLower(ring_trim(StzRight(_cRaw_, StzLen(_cRaw_) - 6)))
			if pcError != "" and (_cMsg_ = "" or StzFindFirst(_cMsg_, StzLower(pcError)) > 0)
				_bHit_ = 1
			ok
		else
			_cP_ = StzEduNormalize(_cRaw_)
			for _k_ = _nPos_ to _nOut_
				if _acOut_[_k_] = _cP_ or
				   (StzLen(_cP_) >= 5 and StzFindFirst(_cP_, _acOut_[_k_]) > 0)
					_bHit_ = 1
					_nPos_ = _k_ + 1
					exit
				ok
			next
			# a list printed one item per line (Ring's `? aList`)
			if _bHit_ = 0 and StzLeft(_cP_, 1) = "[" and StzRight(_cP_, 1) = "]"
				_acItems_ = StzEduListItems(_cP_)
				_nI_ = len(_acItems_)
				if _nI_ > 0
					for _k_ = _nPos_ to _nOut_ - _nI_ + 1
						_bRun_ = 1
						for _j_ = 1 to _nI_
							if StzEduNormalize(_acOut_[_k_ + _j_ - 1]) != _acItems_[_j_]
								_bRun_ = 0
								exit
							ok
						next
						if _bRun_ = 1
							_bHit_ = 1
							_nPos_ = _k_ + _nI_
							exit
						ok
					next
				ok
			ok
		ok
		_aReport_ + [ _cRaw_, _bHit_ ]
		if _bHit_ = 0
			_bAll_ = 0
		ok
	next
	return [ :kept = _bAll_, :report = _aReport_ ]

# Items of a flat list promise "[a,b,c]", each normalized.
func StzEduListItems(pcList)
	_c_ = StzMid(pcList, 2, StzLen(pcList) - 2)
	_acRes_ = []
	if ring_trim(_c_) = ""
		return _acRes_
	ok
	_acParts_ = StzSplit(_c_, ",")
	_nL_ = len(_acParts_)
	for _i_ = 1 to _nL_
		_acRes_ + StzEduNormalize(_acParts_[_i_])
	next
	return _acRes_

  #=========================================#
 #  THE WORLD A CHAPTER RUNS OVER (sugar)  #
#=========================================#

# Thin sugar over ONE default instance (LAW 1): a chapter's cells say
# EduWorldObjects("requested") and read whatever world the course --
# or the overlay laid over it -- supplied under the chapter's role.

func EduUseWorld(pcFile)
	$oStzEduWorld = new stzKnowledgeGraph("world")
	$oStzEduWorld.ImportKnow(pcFile)

func EduWorld()
	if NOT isObject($oStzEduWorld)
		StzRaise("No world is in use. The chapter runner calls EduUseWorld(file) before the cells.")
	ok
	return $oStzEduWorld

# Objects of a relation, in the order the facts were written.
func EduWorldObjects(pcRelation)
	_aPairs_ = EduWorld().Query([ "?s", pcRelation, "?o" ])
	_acRes_ = []
	_nL_ = len(_aPairs_)
	for _i_ = 1 to _nL_
		_acRes_ + _aPairs_[_i_][2]
	next
	return _acRes_

# "bella-cucina (restaurant)" -- the first thing the world says it is.
func EduWorldName()
	_aPairs_ = EduWorld().Query([ "?x", "is-a", "?t" ])
	if len(_aPairs_) = 0
		return "(an unnamed world)"
	ok
	return _aPairs_[1][1] + " (" + _aPairs_[1][2] + ")"

  #=====================================#
 #  LANGUAGE SUPPLEMENTS (data only)   #
#=====================================#

# The Hausa pack shipped by the natural plane speaks about strings only.
# A chapter on lists needs "jeri" (list) and "cire maimaitattu" (remove
# the repeated ones). Education MERGES these into the live Hausa
# definition through the public StzAddNaturalLanguage -- it never
# replaces the pack and never edits the natural plane's file. Asked of
# the natural plane as EDU-HAUSA-LIST-01; this supplement retires then.
# The words await a Hausa-speaking reviewer (plan, section F).

func EduPrepareLanguage(pcLang)
	if StzLower(pcLang) != "ha"
		return
	ok
	_nL_ = len($aLanguageDefinitions)
	for _i_ = 1 to _nL_
		if StzLower($aLanguageDefinitions[_i_][:code]) = "ha"
			_aDef_ = $aLanguageDefinitions[_i_]
			_aMap_ = _aDef_[:semantic_mappings]
			# idempotent: a second call finds the words already there
			_nM_ = len(_aMap_)
			for _j_ = 1 to _nM_
				if _aMap_[_j_][:natural] = "jeri"
					return
				ok
			next
			_aMap_ + [ :natural = "jeri", :semantic = "OBJECT_LIST" ]
			_aMap_ + [ :natural = "jerin", :semantic = "OBJECT_LIST" ]
			_aDef_[:semantic_mappings] = _aMap_
			_aDef_[:phrases] = [
				[ :semantic = "METHOD_REMOVEDUPLICATES",
				  :words = "cire maimaitattu, cire abubuwan da aka maimaita, cire kwafi" ]
			]
			StzAddNaturalLanguage(_aDef_)
			return
		ok
	next
