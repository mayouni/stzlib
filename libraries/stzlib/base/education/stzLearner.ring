#--------------------------------------------------------------#
#        SOFTANZA LIBRARY (V0.9) - STZLEARNER                  #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : A LEARNER is a folder of their own work and #
#                  their progress, and the progress is written #
#                  ONLY by the checker, with its evidence.     #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
#   <learner>/work/<exercise>.ring    what they submitted, as they wrote it
#   <learner>/progress.zknw           facts, plain text, git-diffable
#
# Law 9 in one sentence: a `passed` fact counts only while the sha256 of
# the work file still equals the evidence the checker recorded when it
# RAN that file. A passed line typed by hand, or a work file changed
# after passing, reads as NOT passed -- the claim is refused, not trusted.

func StzLearnerQ(pcFolder)
	return new stzLearner(pcFolder)

class stzLearner from stzObject

	@cFolder = ""
	@cId = ""
	@aFacts = []

	def init(pcFolder)
		@cFolder = _EduNoSlash(pcFolder)
		@cId = _EduLastSegment(@cFolder)
		StzEngineDirCreatePath(@cFolder + "/work")
		if fexists(This.ProgressFile())
			@aFacts = _EduFactsOf(This.ProgressFile())
		ok

	def Id()
		return @cId

	def Folder()
		return @cFolder

	def ProgressFile()
		return @cFolder + "/progress.zknw"

	def WorkFile(pcExerciseId)
		return @cFolder + "/work/" + pcExerciseId + ".ring"

	def Facts()
		return @aFacts

	#-- the one writer of progress: a check that RAN

	# THE FACT SHAPE. The knowledge graph keeps ONE edge per pair of nodes,
	# so `ali | tried | ex` and `ali | passed | ex` cannot both exist --
	# found by this plane's guard, 2026-09-23. Every fact about an attempt
	# therefore hangs off its own subject, and each carries a distinct
	# object (the prefixes keep two equal hashes from being one node):
	#     ali | worked-on | ex-01-01
	#     ex-01-01-by-ali | verdict | passed          (passed | diverged | error)
	#     ex-01-01-by-ali | last-attempt | attempt:<sha256>
	#     ex-01-01-by-ali | evidence | sha256:<sha256>        (only when passed)
	#     ex-01-01-by-ali | checked-at-ms | <epoch ms, UTC>   (only when passed)
	def Submit(poExercise, pcCode)
		_cEx_ = poExercise.Id()
		write(This.WorkFile(_cEx_), pcCode)
		_oCheck_ = poExercise.Check(pcCode)
		_cKey_ = This._Key(_cEx_)
		This._Add(@cId, "worked-on", _cEx_)
		This._Set(_cKey_, "last-attempt", "attempt:" + _oCheck_.Hash())
		if _oCheck_.Passed()
			This._Set(_cKey_, "verdict", "passed")
			This._Set(_cKey_, "evidence", "sha256:" + _oCheck_.Hash())
			This._Set(_cKey_, "checked-at-ms", "" + _oCheck_.CheckedAtMs())
		but _oCheck_.Error() != ""
			This._Set(_cKey_, "verdict", "error")
		else
			This._Set(_cKey_, "verdict", "diverged")
		ok
		This._Save()
		return _oCheck_

		def SubmitFile(poExercise, pcFile)
			return This.Submit(poExercise, read(pcFile))

	def _Key(pcExerciseId)
		return pcExerciseId + "-by-" + @cId

	def HasTried(pcExerciseId)
		return This._Has(@cId, "worked-on", pcExerciseId) and fexists(This.WorkFile(pcExerciseId))

	def LastVerdict(pcExerciseId)
		_acV_ = _EduObjects(@aFacts, This._Key(pcExerciseId), "verdict")
		if len(_acV_) = 0
			return ""
		ok
		return _acV_[1]

	# Passed means: the checker said so AND its evidence still matches the
	# work file. A verdict typed by hand carries no evidence and is refused.
	def HasPassed(pcExerciseId)
		if This.LastVerdict(pcExerciseId) != "passed"
			return 0
		ok
		_acE_ = _EduObjects(@aFacts, This._Key(pcExerciseId), "evidence")
		if len(_acE_) = 0 or NOT fexists(This.WorkFile(pcExerciseId))
			return 0
		ok
		return StzLower(_acE_[1]) = "sha256:" + StzLower(StzEngineCryptoSha256(read(This.WorkFile(pcExerciseId))))

	# Reloads the facts from disk -- what another object, or a person, wrote.
	def Reload()
		@aFacts = []
		if fexists(This.ProgressFile())
			@aFacts = _EduFactsOf(This.ProgressFile())
		ok

	#-- facts

	def _Has(pcS, pcP, pcO)
		_nL_ = len(@aFacts)
		for _i_ = 1 to _nL_
			if StzLower(@aFacts[_i_][1]) = StzLower(pcS) and StzLower(@aFacts[_i_][2]) = StzLower(pcP) and
			   StzLower(@aFacts[_i_][3]) = StzLower(pcO)
				return 1
			ok
		next
		return 0

	def _Add(pcS, pcP, pcO)
		if NOT This._Has(pcS, pcP, pcO)
			@aFacts + [ pcS, pcP, pcO ]
		ok

	def _Set(pcS, pcP, pcO)
		_aKeep_ = []
		_nL_ = len(@aFacts)
		for _i_ = 1 to _nL_
			if NOT ( StzLower(@aFacts[_i_][1]) = StzLower(pcS) and StzLower(@aFacts[_i_][2]) = StzLower(pcP) )
				_aKeep_ + @aFacts[_i_]
			ok
		next
		_aKeep_ + [ pcS, pcP, pcO ]
		@aFacts = _aKeep_

	def _Save()
		_c_ = 'knowledge "' + @cId + '"' + char(10) + char(10) + "facts" + char(10)
		_nL_ = len(@aFacts)
		for _i_ = 1 to _nL_
			_c_ += "    " + @aFacts[_i_][1] + " | " + @aFacts[_i_][2] + " | " + @aFacts[_i_][3] + char(10)
		next
		write(This.ProgressFile(), _c_)
