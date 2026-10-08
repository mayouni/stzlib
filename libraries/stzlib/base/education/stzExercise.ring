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

	# Opens an exercise folder and reads what is needed to judge a program against it: the promises, the facts and the optional harness.
	#
	#   pcFolder   the exercise folder, with or without a trailing slash
	#   returns    nothing; the object is built
	#   note       a check.ring turns the exercise into a harness exercise, where the learner hands
	#              in a file that is not a program
	#   warning    raises an error naming the exercise when the folder has no promise.ring, and
	#              another when promise.ring holds no #--> line; exercise.zknw and check.ring are
	#              optional
	#   see        Id, Promises, HasHarness
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

	# Returns the exercise's id, the last segment of its folder path.
	#
	#   returns    a text such as ex-01-01
	#   see        Folder
	def Id()
		return @cId

	# Returns the exercise's folder path, without a trailing slash.
	#
	#   returns    a text
	#   see        Id
	def Folder()
		return @cFolder

	# Returns the values the learner's program must print, the text after each #--> line of promise.ring.
	#
	#   returns    a list of text, in the order they must appear
	#   warning    these are the expected values, the teacher's side: never show them to the
	#              learner, whose Why() never repeats them
	#   see        ForbiddenWords, Check
	def Promises()
		return @acPromises

	# Returns the steps of the mental model the exercise needs, from its needs-step facts.
	#
	#   returns    a list of text such as finds and applies; [ ] when exercise.zknw names none
	#   see        StepWords, GapText
	def NeededSteps()
		return _EduObjects(@aFacts, @cId, "needs-step")

	# Returns the words in a learner's code that show a step of the exercise was attempted.
	#
	# They are the <step> | seen-by | <word> facts of exercise.zknw. The three steps of chapter 1 (asks, finds,
	# applies) keep default words when the exercise declares none; any other step without them is never seen,
	# so the tutor always asks about it.
	#
	#   pcStep     the step's name, as written in a needs-step fact
	#   returns    a list of text; [ ] for a step with no declared words
	#   see        GapText, NeededSteps
	def StepWords(pcStep)
		_acW_ = _EduObjects(@aFacts, pcStep, "seen-by")
		if len(_acW_) > 0
			return _acW_
		ok
		_cS_ = StzLower(pcStep)
		if _cS_ = "asks"
			return [ "contains", "numberof", "count" ]
		but _cS_ = "finds"
			return [ "find" ]
		but _cS_ = "applies"
			return [ "remove", "replace" ]
		ok
		return []

	# Returns the question the tutor asks about a step of the exercise, in a language.
	#
	# It is the <step>: line of the exercise's own gaps.<lang>.md; failing that, the built-in text of the three
	# chapter-1 steps. A step with no question in that language raises, and is never answered in another one.
	#
	#   pcStep     the step's name, as written in a needs-step fact
	#   pcLang     the language code
	#   returns    the question, as text
	#   warning    raises when the exercise has no question for the step in that language
	#   see        StepWords
	def GapText(pcStep, pcLang)
		_cF_ = @cFolder + "/gaps." + StzLower(pcLang) + ".md"
		if fexists(_cF_)
			_acL_ = StzSplit(StzReplace(read(_cF_), char(13), ""), char(10))
			_cKey_ = StzLower(pcStep) + ":"
			_nL_ = len(_acL_)
			for _i_ = 1 to _nL_
				_c_ = ring_trim(_acL_[_i_])
				if StzLeft(StzLower(_c_), StzLen(_cKey_)) = _cKey_
					return ring_trim(StzRight(_c_, StzLen(_c_) - StzLen(_cKey_)))
				ok
			next
		ok
		if StzFindFirst(StzLower(pcStep), [ "asks", "finds", "applies" ]) > 0
			return _EduSay(pcLang, "gap-" + StzLower(pcStep), "")
		ok
		StzRaise("Exercise '" + @cId + "' has no question for step '" + pcStep + "' in '" + pcLang +
			"': add `" + pcStep + ": ...` to gaps." + pcLang + ".md (law 7: never another language instead).")

	# Returns the task text a learner reads, in one language, with carriage returns removed so that a CRLF checkout reads like an LF one.
	#
	#   pcLang     the language code of the task.<lang>.md file
	#   returns    a text
	#   warning    raises an error naming the exercise and the language when there is no task file
	#              in that language; the fr, ar and ha tasks are drafts, 0 of 35 units reviewed by a
	#              person
	#   see        HasTaskIn
	def Task(pcLang)
		_cF_ = @cFolder + "/task." + pcLang + ".md"
		if NOT fexists(_cF_)
			StzRaise("Exercise '" + @cId + "' has no task in '" + pcLang + "'.")
		ok
		# the same text from an LF tree and from a CRLF checkout (autocrlf):
		# found by MATH-FINDING-EDU-INST-01, which failed on a fresh checkout
		return StzReplace(read(_cF_), char(13), "")

	# TRUE if the exercise has a task file in one language.
	#
	#   pcLang     the language code of the task.<lang>.md file
	#   returns    TRUE or FALSE
	#   see        Task
	def HasTaskIn(pcLang)
		return fexists(@cFolder + "/task." + pcLang + ".md")

	# Runs a learner's program in a fresh Ring process with the library loaded and returns the verdict on it as a stzExerciseCheck.
	#
	#   pcCode     the learner's program, as text
	#   returns    a stzExerciseCheck: Passed() says whether every promise was kept, Why() says in
	#              the learner's terms what to look at; the call itself does not raise when the
	#              program fails
	#   note       the program is judged by running it, never by reading it or comparing strings;
	#              the cells and checks run on the desktop only
	#   warning    one process per call, so it takes seconds: the child loads the whole library;
	#              temporary _edu_run_ files are written in the current folder and removed;
	#              CheckMany does the same for a list of programs, at most 4 side by side; a line
	#              number in an error counts two library lines the learner never wrote
	#   see        CheckFile, ProveItself
	#@ aka  -- checking
	def Check(pcCode)
		return This.CheckMany([ pcCode ])[1]

	# TRUE if the exercise has a check.ring, so that it judges a submitted file with the library's own court instead of running it as a program.
	#
	#   returns    TRUE or FALSE
	#   see        SubmissionExtension, Check
	def HasHarness()
		return @cHarness != ""

	# Returns the extension of what a learner hands in for this exercise.
	#
	#   returns    .ring for a program; for a harness exercise the extension its submits fact names,
	#              such as .pia
	#   see        HasHarness, WrongAnswers
	#@ aka  What the learner hands in: ".ring" for a program, or the extension the exercise names with `<id> | submits | pia`.
	def SubmissionExtension()
		return @cExt

	# Reads a file and returns the verdict on its content, as Check does.
	#
	#   pcFile     the path of the file to read
	#   returns    a stzExerciseCheck
	#   warning    raises a file error when pcFile cannot be opened
	#   see        Check
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

	# Returns the paths of the known wrong answers, the files of the wrong subfolder.
	#
	#   returns    a list of text, sorted by name and limited to files with the submission
	#              extension; [ ] when there is no wrong folder
	#   see        RightAnswers, ProveItself
	def WrongAnswers()
		return This._Answers("wrong")

	# Returns the paths of the known right answers, the files of the right subfolder.
	#
	#   returns    a list of text, sorted by name and limited to files with the submission
	#              extension; [ ] when there is no right folder
	#   see        WrongAnswers, ProveItself
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

	# Runs every known wrong and right answer through the checker and counts the ones it judged correctly.
	#
	#   returns    a hash list with wrong, wrongrefused, right, rightaccepted, failures and checks;
	#              failures names each wrong answer that passed and each right answer that failed,
	#              and checks holds a file and its verdict for every answer
	#   warning    one fresh process per answer, at most 4 side by side; an exercise that accepts a
	#              wrong answer or refuses a right one is a red guard
	#   see        IsProven, WrongAnswers, RightAnswers
	#@ aka  [ :wrong, :wrongrefused, :right, :rightaccepted, :failures, :checks ] :checks holds [ file, check ] for every known answer, so a caller reads the verdicts without running the answers a second time.
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

	# TRUE if the exercise has at least one wrong and one right answer and the checker refuses every wrong one and accepts every right one.
	#
	#   returns    TRUE or FALSE; FALSE for an exercise with no wrong answer or no right answer
	#   see        ProveItself
	def IsProven()
		_aP_ = This.ProveItself()
		return _aP_[:wrong] > 0 and _aP_[:right] > 0 and len(_aP_[:failures]) = 0

	# Returns the words a tutor must not say before the learner passes: the names the right answers call and the promised values.
	#
	#   returns    a list of text without repeats; the promised values are normalized, with their
	#              spaces removed
	#   warning    names are the words of four characters or more written right before "(" in the
	#              right answers
	#   see        Promises, Check
	#@ aka  Words a tutor must not say before the learner passes: every method name a right answer calls, and the promised values themselves.
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

	# Sets whether the check judged a program or a declaration that a harness court examined, which changes the wording of Why.
	#
	#   pcKind     decl for a submission a harness judged, an empty text for a program
	#   returns    nothing
	#   warning    the exercise sets it itself for a harness exercise; a kind other than decl reads
	#              as a program
	#   see        WhyIn, Passed
	def SetKind(pcKind)
		@cKind = pcKind

	# Builds the verdict on a learner's program: matches the promises against its run and stamps the code's SHA-256 and the time.
	#
	#   pcId          the exercise's id
	#   pacPromises   the promised values, in order
	#   pcCode        the learner's program, hashed for the evidence
	#   paRun         the list [ stdout, exit code, stderr ] of a run already made, or [ ] to run
	#                 pcCode now in a fresh process
	#   returns       nothing; the object is built
	#   warning       the promises must appear in order; a promise written error: followed by a text
	#                 is kept by an error that contains the text, and then a non-zero exit still
	#                 passes
	#   see           Passed, Evidence
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

	# Returns the id of the exercise this verdict belongs to.
	#
	#   returns    a text such as ex-01-01
	#   see        Evidence
	def Id()
		return @cId

	# TRUE if every promise was kept in order and the program exited cleanly, or the exercise promises an error.
	#
	#   returns    TRUE or FALSE
	#   see        Why, Report, ExitCode
	def Passed()
		return @bPassed

	# Returns everything the program printed, one line per print, each ended by a line break.
	#
	#   returns    a text; an empty text when it printed nothing
	#   warning    for a program that stopped with an error the text also holds the error report,
	#              including the name of the temporary file it ran from: show a learner Why, not
	#              this
	#   see        Error, Report, Why
	def Output()
		return @cOutput

	# Returns the first line of the run that reports an error.
	#
	#   returns    a text such as Line 5 Error (R14) : Calling Method without definition:
	#              withouttwins; an empty text when the exit code was 0; "the program stopped (exit
	#              code not 0)" when the exit was not 0 and no line reports an error
	#   warning    the line number counts the two library lines placed before the learner's code, so
	#              it is 2 more than the line the learner wrote
	#   see        Why, ExitCode
	def Error()
		return @cError

	# Returns the exit code of the run.
	#
	#   returns    a number; 0 for a clean run
	#   see        Error, Passed
	def ExitCode()
		return @nExit

	# Returns, for every promise in order, whether it was kept.
	#
	#   returns    a list of pairs of the promised text and 1 or 0
	#   warning    each pair holds the expected value, the teacher's side: never show it to a
	#              learner
	#   see        Passed, Why
	def Report()
		return @aReport

	# Returns the SHA-256 of the checked code, as 64 hexadecimal characters.
	#
	#   returns    a text
	#   see        Evidence, CheckedAtMs
	def Hash()
		return @cHash

	# Returns the wall-clock time at which the verdict was built.
	#
	#   returns    a number of milliseconds since the epoch
	#   see        Evidence, Hash
	def CheckedAtMs()
		return @nCheckedAtMs

	# Returns the evidence a progress fact carries: what was run, and when.
	#
	#   returns    a hash list with exercise, sha256, checkedatms and passed
	#   see        Hash, CheckedAtMs, Passed
	#@ aka  The evidence a progress fact carries: what was run, and when.
	def Evidence()
		return [ :exercise = @cId, :sha256 = @cHash, :checkedatms = @nCheckedAtMs, :passed = @bPassed ]

	# Returns, in English and in the learner's own terms, what went well or what to look at, never the expected value.
	#
	#   returns    a text a learner reads: a statement that every promise was kept, the error the
	#              program raised, or the first three lines it printed joined with a slash
	#   warning    a program that printed nothing reads as (nothing), in English also in fr, ar and
	#              ha
	#   see        WhyIn, Passed
	#@ aka  In the learner's terms only: never the expected value.
	def Why()
		return This.WhyIn("en")

	# Returns the same message as Why, in one language.
	#
	#   pcLang     en, fr, ar or ha
	#   returns    a text in that language: the passed message, the error line, or the first three
	#              printed lines, normalized with their spaces removed
	#   warning    raises an error, saying a missing translation is red and never English, for any
	#              other language; the fr, ar and ha messages are drafts, 0 of 35 units reviewed by
	#              a person
	#   see        Why, SetKind
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

