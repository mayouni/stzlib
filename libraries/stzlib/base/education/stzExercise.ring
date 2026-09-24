#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZEXERCISE                 #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : An EXERCISE is a promise, checked by        #
#                  RUNNING the learner's program -- never by   #
#                  reading it, never by comparing strings.     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# An exercise is a folder:
#   exercise.zknw     its facts (chapter, skill, the steps it needs)
#   task.<lang>.md    the task, in every language of the program
#   promise.ring      the `#-->` lines the learner's program must print
#   wrong/*.ring      answers that MUST fail
#   right/*.ring      answers that MUST pass
#
# ProveItself() runs every known answer through the checker: an exercise
# that accepts one wrong answer, or refuses one right answer, is a red
# guard. Every positive has a negative sibling.
#
# The check's Why() says what went wrong in the learner's OWN terms --
# the error it raised, or what it printed -- and never the expected
# value: the promise is the teacher's, not the learner's to be shown.

func StzExerciseQ(pcFolder)
	return new stzExercise(pcFolder)

# Names written right before "(" -- the calls a piece of code makes.
func _EduCalledNames(pcCode)
	_acRes_ = []
	_cWord_ = ""
	_nL_ = len(pcCode)
	for _i_ = 1 to _nL_
		_ch_ = pcCode[_i_]
		if isalnum(_ch_) or _ch_ = "_" or _ch_ = "@"
			_cWord_ += _ch_
		else
			if _ch_ = "(" and len(_cWord_) >= 4 and _cWord_ != "sort"
				if StzFindFirst(_cWord_, _acRes_) = 0
					_acRes_ + _cWord_
				ok
			ok
			_cWord_ = ""
		ok
	next
	return _acRes_

func _EduFirstErrorLine(pcText)
	_acL_ = StzSplit(StzReplace(pcText, char(13), ""), char(10))
	_nL_ = len(_acL_)
	for _i_ = 1 to _nL_
		if StzFindFirst("Error (", _acL_[_i_]) > 0
			return ring_trim(_acL_[_i_])
		ok
	next
	return "the program stopped (exit code not 0)"

class stzExercise from stzObject

	@cFolder = ""
	@cId = ""
	@acPromises = []
	@aFacts = []
	@cHarness = ""
	@cExt = ".ring"

	def init(pcFolder)
		@cFolder = _EduNoSlash(pcFolder)
		@cId = _EduLastSegment(@cFolder)
		if NOT fexists(@cFolder + "/promise.ring")
			StzRaise("Exercise '" + @cId + "' has no promise.ring: nothing could check it.")
		ok
		@acPromises = StzEduPromisesIn(read(@cFolder + "/promise.ring"))
		if len(@acPromises) = 0
			StzRaise("Exercise '" + @cId + "': promise.ring holds no #--> line.")
		ok
		if fexists(@cFolder + "/exercise.zknw")
			@aFacts = _EduFactsOf(@cFolder + "/exercise.zknw")
		ok
		# A HARNESS exercise: the learner submits a file that is not a
		# program (a .pia declaration, a .zknw world), and check.ring runs
		# the library's own court on it. %SUBMISSION% names the file.
		if fexists(@cFolder + "/check.ring")
			@cHarness = read(@cFolder + "/check.ring")
			_acX_ = _EduObjects(@aFacts, @cId, "submits")
			if len(_acX_) > 0
				@cExt = "." + _acX_[1]
			ok
		ok

	def Id()
		return @cId

	def Folder()
		return @cFolder

	def Promises()
		return @acPromises

	def NeededSteps()
		return _EduObjects(@aFacts, @cId, "needs-step")

	def Task(pcLang)
		_cF_ = @cFolder + "/task." + pcLang + ".md"
		if NOT fexists(_cF_)
			StzRaise("Exercise '" + @cId + "' has no task in '" + pcLang + "'.")
		ok
		return read(_cF_)

	def HasTaskIn(pcLang)
		return fexists(@cFolder + "/task." + pcLang + ".md")

	#-- checking

	def Check(pcCode)
		return This.CheckMany([ pcCode ])[1]

	def HasHarness()
		return @cHarness != ""

	# What the learner hands in: ".ring" for a program, or the extension
	# the exercise names with `<id> | submits | pia`.
	def SubmissionExtension()
		return @cExt

	def CheckFile(pcFile)
		return This.Check(read(pcFile))

	def _Answers(pcKind)
		_acRes_ = []
		_cDir_ = @cFolder + "/" + pcKind
		if NOT StzEngineDirExists(_cDir_)
			return _acRes_
		ok
		_acF_ = sort(StzEngineDirListFiles(_cDir_))
		_nL_ = len(_acF_)
		for _i_ = 1 to _nL_
			if StzRight(_acF_[_i_], StzLen(@cExt)) = @cExt
				_acRes_ + (_cDir_ + "/" + _acF_[_i_])
			ok
		next
		return _acRes_

	def WrongAnswers()
		return This._Answers("wrong")

	def RightAnswers()
		return This._Answers("right")

	# Checks several programs, each in its own fresh process, side by side.
	def CheckMany(pacCodes)
		_acProgs_ = []
		_acTemp_ = []
		_nL_ = len(pacCodes)
		for _i_ = 1 to _nL_
			if @cHarness = ""
				_acProgs_ + StzEduWithLibrary(pacCodes[_i_])
			else
				$nStzEduRun++
				_cSub_ = _EduTempName("_edu_sub_", @cExt)
				write(_cSub_, pacCodes[_i_])
				_acTemp_ + _cSub_
				_acProgs_ + StzEduWithLibrary(StzReplace(@cHarness, "%SUBMISSION%", _cSub_))
			ok
		next
		_aRuns_ = StzEduRunPrograms(_acProgs_)
		_nT_ = len(_acTemp_)
		for _i_ = 1 to _nT_
			remove(_acTemp_[_i_])
		next
		_aRes_ = []
		for _i_ = 1 to _nL_
			_oK_ = new stzExerciseCheck(@cId, @acPromises, pacCodes[_i_], _aRuns_[_i_])
			if @cHarness != ""
				_oK_.SetKind("decl")
			ok
			_aRes_ + _oK_
		next
		return _aRes_

	# [ :wrong, :wrongrefused, :right, :rightaccepted, :failures, :checks ]
	# :checks holds [ file, check ] for every known answer, so a caller
	# reads the verdicts without running the answers a second time.
	def ProveItself()
		_acW_ = This.WrongAnswers()
		_acR_ = This.RightAnswers()
		_acFiles_ = []
		_acCodes_ = []
		_nW_ = len(_acW_)
		for _i_ = 1 to _nW_
			_acFiles_ + _acW_[_i_]
			_acCodes_ + read(_acW_[_i_])
		next
		_nR_ = len(_acR_)
		for _i_ = 1 to _nR_
			_acFiles_ + _acR_[_i_]
			_acCodes_ + read(_acR_[_i_])
		next
		_aChecks_ = This.CheckMany(_acCodes_)
		_nWR_ = 0
		_nRA_ = 0
		_acFail_ = []
		_aPairs_ = []
		_nL_ = len(_acFiles_)
		for _i_ = 1 to _nL_
			_aPairs_ + [ _acFiles_[_i_], _aChecks_[_i_] ]
			if _i_ <= _nW_
				if _aChecks_[_i_].Passed()
					_acFail_ + ("accepted a wrong answer: " + _EduLastSegment(_acFiles_[_i_]))
				else
					_nWR_++
				ok
			else
				if _aChecks_[_i_].Passed()
					_nRA_++
				else
					_acFail_ + ("refused a right answer: " + _EduLastSegment(_acFiles_[_i_]))
				ok
			ok
		next
		return [ :wrong = _nW_, :wrongrefused = _nWR_,
		         :right = _nR_, :rightaccepted = _nRA_, :failures = _acFail_, :checks = _aPairs_ ]

	def IsProven()
		_aP_ = This.ProveItself()
		return _aP_[:wrong] > 0 and _aP_[:right] > 0 and len(_aP_[:failures]) = 0

	# Words a tutor must not say before the learner passes: every method
	# name a right answer calls, and the promised values themselves.
	def ForbiddenWords()
		_acRes_ = []
		_acR_ = This.RightAnswers()
		_nL_ = len(_acR_)
		for _i_ = 1 to _nL_
			_acW_ = _EduCalledNames(read(_acR_[_i_]))
			_nW_ = len(_acW_)
			for _j_ = 1 to _nW_
				if StzFindFirst(_acW_[_j_], _acRes_) = 0
					_acRes_ + _acW_[_j_]
				ok
			next
		next
		_nP_ = len(@acPromises)
		for _i_ = 1 to _nP_
			_acRes_ + StzEduNormalize(@acPromises[_i_])
		next
		return _acRes_

class stzExerciseCheck from stzObject

	@cId = ""
	@cOutput = ""
	@cError = ""
	@nExit = 0
	@aReport = []
	@bPassed = 0
	@cHash = ""
	@nCheckedAtMs = 0
	@cKind = ""     # "" for a program, "decl" for a submission a harness judged

	def SetKind(pcKind)
		@cKind = pcKind

	def init(pcId, pacPromises, pcCode, paRun)
		@cId = pcId
		_aR_ = paRun
		if len(_aR_) = 0
			_aR_ = StzEduRunSoftanza(pcCode)
		ok
		@nExit = _aR_[2]
		_cAll_ = _aR_[1] + _aR_[3]
		@cOutput = _aR_[1]
		if @nExit != 0
			@cError = _EduFirstErrorLine(_cAll_)
		ok
		_aM_ = StzEduMatchPromises(pacPromises, @cOutput, @cError)
		@aReport = _aM_[:report]
		_bExpectsError_ = 0
		_nP_ = len(pacPromises)
		for _i_ = 1 to _nP_
			if StzLeft(StzLower(pacPromises[_i_]), 6) = "error:"
				_bExpectsError_ = 1
			ok
		next
		if _aM_[:kept] = 1 and (@nExit = 0 or _bExpectsError_ = 1)
			@bPassed = 1
		ok
		@cHash = StzEngineCryptoSha256(pcCode)
		@nCheckedAtMs = StzEngineTimeNowMs()

	def Id()
		return @cId

	def Passed()
		return @bPassed

	def Output()
		return @cOutput

	def Error()
		return @cError

	def ExitCode()
		return @nExit

	def Report()
		return @aReport

	def Hash()
		return @cHash

	def CheckedAtMs()
		return @nCheckedAtMs

	# The evidence a progress fact carries: what was run, and when.
	def Evidence()
		return [ :exercise = @cId, :sha256 = @cHash, :checkedatms = @nCheckedAtMs, :passed = @bPassed ]

	# In the learner's terms only: never the expected value.
	def Why()
		return This.WhyIn("en")

	def WhyIn(pcLang)
		if @bPassed
			return _EduSay(pcLang, "why-passed" + This._Suffix(), "")
		ok
		if @cError != ""
			return _EduSay(pcLang, "why-error", @cError)
		ok
		_acL_ = StzEduOutputLines(@cOutput)
		_c_ = ""
		_nL_ = len(_acL_)
		if _nL_ > 3
			_nL_ = 3
		ok
		for _i_ = 1 to _nL_
			if _c_ != ""
				_c_ += " / "
			ok
			_c_ += _acL_[_i_]
		next
		if _c_ = ""
			_c_ = "(nothing)"
		ok
		return _EduSay(pcLang, "why-diverged" + This._Suffix(), _c_)

	def _Suffix()
		if @cKind = "decl"
			return "-decl"
		ok
		return ""

