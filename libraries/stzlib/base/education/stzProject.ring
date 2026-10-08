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

# Holds a level project: a brief, and a guard that judges a learner's folder by running it.
#
# A level is earned by a project that passes, never by a score. The project is a folder with a brief
# in each language, guard.ring (the court, run in a fresh process with the library loaded, exactly
# like an exercise's harness), promise.ring (the lines the guard must print for a pass) and wrong/
# and right/ sample folders that must be refused and accepted. The guard runs on the desktop only.
# The fr, ar and ha briefs are drafts, 0 of 35 units reviewed by a person.
#
#   receiver   o1 = new stzProject("../../education/program/projects/project-s0")
#   example    ? o1.Id()
#              #--> project-s0
#              ? o1.HasGuard()
#              #--> 1
#              ? @@( o1.Promises() )
#              #--> [ "cells five or more: yes", "every cell has a promise: yes", "every promise kept: yes", "stored output: no" ]
#              ? o1.Check(o1.RightSamples()[1]).Passed()
#              #--> 1
#   see        stzLearner, stzProgram, stzExercise
class stzProject from stzObject

	@cFolder = ""
	@cId = ""
	@cGuard = ""
	@acPromises = []

	# Opens a level project's folder, reading its guard and the promises the guard must keep when they are there.
	#
	#   pcFolder   the project's folder: its last segment is the project's id
	#   returns    nothing; the object is built
	#   note       a project is a folder: brief.<lang>.md, guard.ring (the court, which reads the
	#              learner's folder and prints its findings), promise.ring (the #--> lines to print
	#              for a pass), and wrong/ and right/ sample folders
	#   see        HasGuard, Check, ProveItself
	def init(pcFolder)
		@cFolder = _EduNoSlash(pcFolder)
		@cId = _EduLastSegment(@cFolder)
		if fexists(@cFolder + "/guard.ring")
			@cGuard = read(@cFolder + "/guard.ring")
		ok
		if fexists(@cFolder + "/promise.ring")
			@acPromises = StzEduPromisesIn(read(@cFolder + "/promise.ring"))
		ok

	# Returns the project's identifier, which is the last segment of its folder's path.
	#
	#   returns    a text such as project-s0
	#   see        Folder
	def Id()
		return @cId

	# Returns the project's folder path, without a trailing slash.
	#
	#   returns    a text
	#   see        Id, WrongSamples
	def Folder()
		return @cFolder

	# TRUE if the project has a guard and at least one promise, so that a level can be earned by it.
	#
	#   returns    TRUE or FALSE
	#   note       Check raises an error when it is FALSE
	#   see        Check, Promises
	def HasGuard()
		return @cGuard != "" and len(@acPromises) > 0

	# Returns what the project asks of the learner, from brief.<lang>.md, with line ends made LF.
	#
	#   pcLang     the language of the brief: en, fr, ar or ha
	#   returns    a text, markdown
	#   note       the fr, ar and ha briefs are drafts, not yet reviewed by a native speaker (0 of
	#              35 units reviewed in each language), and carry a draft notice at their head
	#   warning    raises an error naming the project and the language when that brief does not
	#              exist
	#   see        HasBriefIn
	def Brief(pcLang)
		_cF_ = @cFolder + "/brief." + pcLang + ".md"
		if NOT fexists(_cF_)
			StzRaise("Project '" + @cId + "' has no brief in '" + pcLang + "'.")
		ok
		# the same text from an LF tree and from a CRLF checkout (autocrlf)
		return StzReplace(read(_cF_), char(13), "")

	# TRUE if the project has a brief file for the language.
	#
	#   pcLang     the language code, such as fr
	#   returns    TRUE or FALSE
	#   see        Brief
	def HasBriefIn(pcLang)
		return fexists(@cFolder + "/brief." + pcLang + ".md")

	# Returns the lines the guard must print for a pass, read from the #--> lines of promise.ring.
	#
	#   returns    a list of text; [ ] when the project has no promise file
	#   see        HasGuard, Check
	def Promises()
		return @acPromises

	# Judges a learner's project folder by running the project's guard on it in a fresh process with Softanza loaded.
	#
	#   pcLearnerFolder   the learner's project folder to judge
	#   returns           the stzExerciseCheck of the run: Passed(), Output() (what the guard
	#                     printed) and Why() (a sentence for the learner)
	#   note              the evidence it carries is the hash of every file in the folder, so a
	#                     folder changed after a pass no longer counts; CheckMany(pacFolders) judges
	#                     several folders in one run and returns the list of checks (it is not a
	#                     root of its own in the record, ProveItself uses it)
	#   warning           raises an error when the project has no guard; a folder that does not
	#                     exist is not refused: the guard runs and prints its own missing line, so
	#                     the check does not pass; the guard runs on the desktop only
	#   see               ProveItself, HasGuard, stzLearner
	#@ aka  Judges a learner's project folder by running the guard on it.
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

	# Returns the paths of the learner folders under wrong/ that the guard must refuse, sorted by name.
	#
	#   returns    a list of text; [ ] when there is no wrong folder
	#   see        RightSamples, ProveItself
	def WrongSamples()
		return This._Samples("wrong")

	# Returns the paths of the learner folders under right/ that the guard must accept, sorted by name.
	#
	#   returns    a list of text; [ ] when there is no right folder
	#   see        WrongSamples, ProveItself
	def RightSamples()
		return This._Samples("right")

	# Runs the guard on every wrong and right sample and reports whether it refused each wrong one and accepted each right one.
	#
	#   returns    a hash list [ :wrong, :wrongrefused, :right, :rightaccepted, :failures, :checks
	#              ]: counts, then sentences naming each sample misjudged, then [ path, check ]
	#              pairs
	#   note       a project that accepts a wrong sample or refuses a right one is a red guard, and
	#              failures says which
	#   see        Check, WrongSamples, RightSamples
	#@ aka  [ :wrong, :wrongrefused, :right, :rightaccepted, :failures, :checks ]
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
