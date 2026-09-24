#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZPROJECT                  #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : A level PROJECT: a brief, and a guard that  #
#                  judges a learner's FOLDER by running it. A   #
#                  level is earned by a project that passes,   #
#                  never by a score.                           #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# A project is a folder:
#   brief.<lang>.md    what is asked, in every language of the program
#   guard.ring         the court: it reads %PROJECT% (the learner's folder)
#                      and prints its findings
#   promise.ring       the `#-->` lines the guard must print for a pass
#   wrong/<sample>/    learner folders that MUST fail
#   right/<sample>/    learner folders that MUST pass
#
# The guard is run in a fresh process, with the library loaded, exactly
# like an exercise's harness; a project that accepts a wrong sample or
# refuses a right one is a red guard. A learner's evidence is the hash
# of every file in their project folder, so a folder changed after the
# pass no longer counts as passed (law 9).

func StzProjectQ(pcFolder)
	return new stzProject(pcFolder)

# The sha256 of a folder: every file's relative path and content, in
# sorted order, so two folders with the same files hash the same.
func _EduFolderHash(pcFolder)
	_acFiles_ = sort(_EduFilesUnder(pcFolder, ""))
	_c_ = ""
	_nL_ = len(_acFiles_)
	for _i_ = 1 to _nL_
		_c_ += _acFiles_[_i_] + char(10) + read(pcFolder + "/" + _acFiles_[_i_]) + char(10)
	next
	return StzEngineCryptoSha256(_c_)

func _EduFilesUnder(pcRoot, pcRel)
	_acRes_ = []
	_cDir_ = pcRoot
	if pcRel != ""
		_cDir_ = pcRoot + "/" + pcRel
	ok
	if NOT StzEngineDirExists(_cDir_)
		return _acRes_
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
		_acMore_ = _EduFilesUnder(pcRoot, _cSub_)
		_nM_ = len(_acMore_)
		for _j_ = 1 to _nM_
			_acRes_ + _acMore_[_j_]
		next
	next
	return _acRes_

class stzProject from stzObject

	@cFolder = ""
	@cId = ""
	@cGuard = ""
	@acPromises = []

	def init(pcFolder)
		@cFolder = _EduNoSlash(pcFolder)
		@cId = _EduLastSegment(@cFolder)
		if fexists(@cFolder + "/guard.ring")
			@cGuard = read(@cFolder + "/guard.ring")
		ok
		if fexists(@cFolder + "/promise.ring")
			@acPromises = StzEduPromisesIn(read(@cFolder + "/promise.ring"))
		ok

	def Id()
		return @cId

	def Folder()
		return @cFolder

	def HasGuard()
		return @cGuard != "" and len(@acPromises) > 0

	def Brief(pcLang)
		_cF_ = @cFolder + "/brief." + pcLang + ".md"
		if NOT fexists(_cF_)
			StzRaise("Project '" + @cId + "' has no brief in '" + pcLang + "'.")
		ok
		return read(_cF_)

	def HasBriefIn(pcLang)
		return fexists(@cFolder + "/brief." + pcLang + ".md")

	def Promises()
		return @acPromises

	# Judges a learner's project folder by running the guard on it.
	def Check(pcLearnerFolder)
		return This.CheckMany([ pcLearnerFolder ])[1]

	def CheckMany(pacFolders)
		if NOT This.HasGuard()
			StzRaise("Project '" + @cId + "' has no guard yet: nothing can be earned by it.")
		ok
		_acProgs_ = []
		_nL_ = len(pacFolders)
		for _i_ = 1 to _nL_
			_cAbs_ = _EduNoSlash(pacFolders[_i_])
			_acProgs_ + StzEduWithLibrary(StzReplace(@cGuard, "%PROJECT%", _cAbs_))
		next
		_aRuns_ = StzEduRunPrograms(_acProgs_)
		_aRes_ = []
		for _i_ = 1 to _nL_
			_oK_ = new stzExerciseCheck(@cId, @acPromises, _EduFolderHash(pacFolders[_i_]), _aRuns_[_i_])
			_oK_.SetKind("decl")
			_aRes_ + _oK_
		next
		return _aRes_

	def _Samples(pcKind)
		_acRes_ = []
		_cDir_ = @cFolder + "/" + pcKind
		if NOT StzEngineDirExists(_cDir_)
			return _acRes_
		ok
		_acD_ = sort(StzEngineDirListDirs(_cDir_))
		_nL_ = len(_acD_)
		for _i_ = 1 to _nL_
			_acRes_ + (_cDir_ + "/" + _acD_[_i_])
		next
		return _acRes_

	def WrongSamples()
		return This._Samples("wrong")

	def RightSamples()
		return This._Samples("right")

	# [ :wrong, :wrongrefused, :right, :rightaccepted, :failures, :checks ]
	def ProveItself()
		_acW_ = This.WrongSamples()
		_acR_ = This.RightSamples()
		_acAll_ = []
		_nW_ = len(_acW_)
		for _i_ = 1 to _nW_
			_acAll_ + _acW_[_i_]
		next
		_nR_ = len(_acR_)
		for _i_ = 1 to _nR_
			_acAll_ + _acR_[_i_]
		next
		_aChecks_ = This.CheckMany(_acAll_)
		_nWR_ = 0
		_nRA_ = 0
		_acFail_ = []
		_aPairs_ = []
		_nL_ = len(_acAll_)
		for _i_ = 1 to _nL_
			_aPairs_ + [ _acAll_[_i_], _aChecks_[_i_] ]
			if _i_ <= _nW_
				if _aChecks_[_i_].Passed()
					_acFail_ + ("accepted a wrong sample: " + _EduLastSegment(_acAll_[_i_]))
				else
					_nWR_++
				ok
			else
				if _aChecks_[_i_].Passed()
					_nRA_++
				else
					_acFail_ + ("refused a right sample: " + _EduLastSegment(_acAll_[_i_]))
				ok
			ok
		next
		return [ :wrong = _nW_, :wrongrefused = _nWR_,
		         :right = _nR_, :rightaccepted = _nRA_, :failures = _acFail_, :checks = _aPairs_ ]
