# R4 step 6 -- stzLLMFunction: THE LLM CALL AS A PURE TYPED FUNCTION
# (the 5.7 G3 seed: "like sin(x), but for 'translate this'").
#
#   oF = new stzLLMFunction("classify-mood")
#   oF.SetPrompt("Answer with one word. Is this text positive or negative? {input}")
#   oF.ReturnsOneOf([ "positive", "negative" ])
#   oF.Budget(20)                       # MANDATORY (G9) -- no silent spend
#   ? oF.Call_("What a lovely day!")    #--> "positive"
#   ? oF.Why()
#
# THE CONTRACT:
#   - TYPED OUTPUT, or refusal: the response must validate as the
#     declared type (Number / Boolean / OneOf / String) within the
#     retry budget -- otherwise the call REFUSES (LAW 3). No garbage
#     ever escapes as a value.
#   - MEMOIZED by content hash (engine sha256): the second identical
#     call is deterministic and FREE -- determinism-by-cache.
#   - BUDGETED (G9): Budget(n) is mandatory; exhausted -> refusal.
#   - ZERO capabilities: this object only maps input text to a typed
#     value. Effects belong to pi-gates (5.7), never here.
#   - GOLDEN SETS: AddGolden/RunGoldens weave regression pinning into
#     the narrated-test culture.
# FLOOR NOTE: type checking here VALIDATES the decoded text; the
# sampler-level grammar constraint (type -> GBNF, "cannot emit a
# violating token") is the engine rung behind this same surface.

class stzLLMFunction from stzObject

	@cName = ""
	@cTemplate = ""
	@cOutType = "string"       # string | number | boolean | oneof
	@acChoices = []
	@nMaxCalls = 0
	@nCallsMade = 0
	@nRetries = 2
	@aCache = []               # sha -> validated value
	@aGoldens = []             # [ input, expected ]
	@cWhy = ""

	def init(pcName)
		@cName = "" + pcName

	def Name_()
		return @cName

	def SetPrompt(pcTemplate)
		@cTemplate = "" + pcTemplate
		return This

	def ReturnsNumber()
		@cOutType = "number"
		return This

	def ReturnsBoolean()
		@cOutType = "boolean"
		return This

	def ReturnsString()
		@cOutType = "string"
		return This

	def ReturnsOneOf(pacChoices)
		@cOutType = "oneof"
		@acChoices = []
		_n_ = len(pacChoices)
		for _i_ = 1 to _n_
			@acChoices + StzLower(ring_trim("" + pacChoices[_i_]))
		next
		return This

	def Budget(nMaxCalls)
		@nMaxCalls = nMaxCalls
		return This

	def SetRetries(n)
		@nRetries = n
		return This

	def CallsMade()
		return @nCallsMade

	def Why()
		return @cWhy

	#-- the call ------------------------------------------------------------

	def Call_(pcInput)
		if @cTemplate = ""
			stzraise("Declare the Prompt() template first.")
		ok
		if @nMaxCalls = 0
			stzraise("Budget(n) is MANDATORY before calling (G9: no silent spend).")
		ok
		_cPrompt_ = StzReplace(@cTemplate, "{input}", "" + pcInput)
		_cKey_ = StzEngineCryptoSha256(@cName + "|" + @cOutType + "|" + _cPrompt_)

		# memo hit: deterministic, free
		if HasKey(@aCache, _cKey_)
			@cWhy = "memoized (content hash " + StzLeft(_cKey_, 12) +
				"...) -- deterministic, zero cost"
			$cStzLastWhyB = @cWhy
			$nStzLastCertainty = 1
			return @aCache[_cKey_]
		ok

		if StzHasGenerativeModel() = 0
			stzraise("No generative model loaded (and no memo for this input). Load a GGUF or seed the cache -- refusing rather than guessing.")
		ok

		_nTry_ = 0
		while _nTry_ <= @nRetries
			_nTry_++
			if @nCallsMade >= @nMaxCalls
				stzraise("Budget exhausted (" + @nMaxCalls + " call(s)) for '" + @cName + "' -- raise Budget(n) deliberately if more is wanted.")
			ok
			@nCallsMade++
			_cRaw_ = StzAskModel(_cPrompt_)
			_aVal_ = This._Validate(_cRaw_)
			if _aVal_[1] = 1
				@aCache[_cKey_] = _aVal_[2]
				@cWhy = "generated (attempt " + _nTry_ + "), VALIDATED as " +
					@cOutType + ", memoized"
				$cStzLastWhyB = @cWhy
				return _aVal_[2]
			ok
		end
		stzraise("The model produced no valid '" + @cOutType + "' in " +
			@nRetries + " retries for '" + @cName + "' -- refusing (LAW 3: no garbage escapes as a value).")

		def Of(pcInput)
			return This.Call_(pcInput)

	# test/offline door: seed a known answer into the memo cache (the
	# golden path for model-free environments; the seed is EXPLICIT)
	def SeedAnswer(pcInput, pValue)
		_cPrompt_ = StzReplace(@cTemplate, "{input}", "" + pcInput)
		_cKey_ = StzEngineCryptoSha256(@cName + "|" + @cOutType + "|" + _cPrompt_)
		@aCache[_cKey_] = pValue
		return This

	#-- golden sets -----------------------------------------------------------

	def AddGolden(pcInput, pExpected)
		@aGoldens + [ "" + pcInput, pExpected ]
		return This

	def RunGoldens()
		_nPass_ = 0
		_aFailed_ = []
		_n_ = len(@aGoldens)
		for _i_ = 1 to _n_
			_vGot_ = This.Call_(@aGoldens[_i_][1])
			if _vGot_ = @aGoldens[_i_][2]
				_nPass_++
			else
				_aFailed_ + [ :input = @aGoldens[_i_][1],
					:expected = @aGoldens[_i_][2], :got = _vGot_ ]
			ok
		next
		return [ :total = _n_, :passed = _nPass_, :failed = _aFailed_ ]

	#-- validation -------------------------------------------------------------

	def _Validate(pcRaw)
		_cT_ = StzLower(ring_trim("" + pcRaw))
		if @cOutType = "string"
			return [ 1, ring_trim("" + pcRaw) ]
		but @cOutType = "boolean"
			if len(StzFind("yes", _cT_)) > 0 or len(StzFind("true", _cT_)) > 0
				return [ 1, 1 ]
			ok
			if len(StzFind("no", _cT_)) > 0 or len(StzFind("false", _cT_)) > 0
				return [ 1, 0 ]
			ok
			return [ 0, 0 ]
		but @cOutType = "number"
			_acW_ = StzSplit(StzReplace(StzReplace(_cT_, char(10), " "), ",", " "), " ")
			_nW_ = len(_acW_)
			for _i_ = 1 to _nW_
				_cW_ = ring_trim(_acW_[_i_])
				if _cW_ != ""
					_nV_ = ring_number(_cW_)
					if _nV_ != 0 or _cW_ = "0" or StzLeft(_cW_, 2) = "0."
						return [ 1, _nV_ ]
					ok
				ok
			next
			return [ 0, 0 ]
		but @cOutType = "oneof"
			_nC_ = len(@acChoices)
			# exact match first, then unique containment
			for _i_ = 1 to _nC_
				if _cT_ = @acChoices[_i_]
					return [ 1, @acChoices[_i_] ]
				ok
			next
			_nHits_ = 0
			_cHit_ = ""
			for _i_ = 1 to _nC_
				if len(StzFind(@acChoices[_i_], _cT_)) > 0
					_nHits_++
					_cHit_ = @acChoices[_i_]
				ok
			next
			if _nHits_ = 1
				return [ 1, _cHit_ ]
			ok
			return [ 0, "" ]
		ok
		return [ 0, "" ]
