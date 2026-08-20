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
#
# DECLARED STRUCTURE, not only declared scalars. ReturnsStructure()
# raises the contract above "one word / one number" to whole records:
#
#   oF = new stzLLMFunction("read-ticket")
#   oF.SetPrompt("Read this support ticket: {input}")
#   oF.ReturnsStructure([
#           [ :field = "summary",  :type = :string ],
#           [ :field = "severity", :type = :oneof, :choices = [ "low", "high" ] ],
#           [ :field = "hours",    :type = :number, :must = [ [ ">=", 0 ] ] ],
#           [ :field = "tags",     :type = :list, :of = :string, :optional = 1 ]
#   ])
#   oF.Budget(3)
#   aTicket = oF.Call_(cText)      # the DECLARED shape, or a refusal
#
# The declaration is judged when it is DECLARED (an unknown type or a
# typo'd key raises there and then, never at call time), the reply is
# parsed (JSON or the yaml-like memo shape), validated field by field,
# retried inside the SAME Budget(n), and refused whole on exhaustion --
# citing the field and the rule that refused it. Partial credit is
# forbidden: one missing required field refuses the whole answer. The
# grammar lives in stzOutputSchema; this class only calls it.
#
# STRUCTURE KILLS MALFORMEDNESS, NOT FALSEHOOD. A schema-valid lie
# validates. What is promised here is INTEGRITY -- the answer has the
# shape it was asked for, whole, or there is no answer.
#
# FLOOR NOTE (updated): type AND STRUCTURE checking here VALIDATES the
# decoded text -- the declared-structure surface above this line now
# exists, so what remains below it is the ENGINE rung: the sampler-level
# grammar constraint (schema -> GBNF, "cannot emit a violating token"),
# which makes a malformed answer unemittable rather than caught. That
# rung is filed as an ask to the engine plane, deliberately NOT stubbed
# here: a stub would let a caller believe decoding was constrained when
# it was only checked afterwards. The ask is written down --
# prompts/42-stzlib-engine-schema-constrained-decoding.md in the
# coordination repository -- and it carries the refusal shapes that
# would close it honestly.

class stzLLMFunction from stzObject

	@cName = ""
	@cTemplate = ""
	@cOutType = "string"       # string | number | boolean | oneof | structure
	@acChoices = []
	@oSchema = ""              # the stzOutputSchema, when the type is structure
	@bHasSchema = 0
	@aLastFindings = []        # why the last validation refused (unified shape)
	@fResponder = ""           # test/offline door: a FAKE in place of the model
	@bHasResponder = 0
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

	# THE STRUCTURED RUNG. paFields is an stzOutputSchema declaration; it
	# is compiled and judged HERE, so a defective declaration can never
	# reach a model.
	def ReturnsStructure(paFields)
		_o_ = new stzOutputSchema(paFields)
		_o_.SetNameQ(@cName)
		@oSchema = _o_
		@bHasSchema = 1
		@cOutType = "structure"
		return This

		def ReturnsStructureQ(paFields)
			return This.ReturnsStructure(paFields)

	def HasSchema()
		return @bHasSchema

	# A READ. Ring copies on assign, so configuring the returned schema
	# configures a copy and nothing else -- use RefuseUnknownFields()
	# below for the one knob that has to land on the stored one.
	def Schema()
		if @bHasSchema = 0
			stzraise("This function returns a " + @cOutType + ", not a structure -- " +
				"declare ReturnsStructure([...]) first.")
		ok
		return @oSchema

	# Closed-world: a field the schema never declared refuses the answer
	# instead of being reported and dropped.
	def RefuseUnknownFields()
		if @bHasSchema = 0
			stzraise("RefuseUnknownFields() needs a structure -- declare ReturnsStructure([...]) first.")
		ok
		_o_ = @oSchema
		_o_.RefuseUnknownFieldsQ()
		@oSchema = _o_
		return This

	# The findings the LAST validation produced, in the family's unified
	# shape -- so a refusal can be handed to stzRuleReport.Ingest() and
	# stand in the same CI gate as every other rule in the library.
	def LastFindings()
		return @aLastFindings

	def Budget(nMaxCalls)
		@nMaxCalls = nMaxCalls
		return This

	def SetRetries(n)
		@nRetries = n
		return This

	# TEST / OFFLINE DOOR, named for what it is. The responder is a FAKE
	# standing where the model stands: it receives (prompt, attempt) and
	# returns the raw text a model would have returned. It exists so the
	# refusal paths -- the ones that matter most and that no seeded cache
	# can reach -- can be narrated without a GGUF. It spends budget like
	# a real call, and Why() says "FAKE responder" on every answer it
	# produces, so nothing it returns can be mistaken for a live one.
	# (The name follows stzGraphRule.UseChecker(): same escape-hatch
	# shape, same word.)
	def UseResponder(fResponder)
		This.UseResponderQ(fResponder)

	def UseResponderQ(fResponder)
		@fResponder = fResponder
		@bHasResponder = 1
		return This

	def IsUsingResponder()
		return @bHasResponder

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
		_cPrompt_ = This._EffectivePrompt(pcInput)
		_cKey_ = StzEngineCryptoSha256(@cName + "|" + @cOutType + "|" + _cPrompt_)

		# memo hit: deterministic, free
		if HasKey(@aCache, _cKey_)
			@cWhy = "memoized (content hash " + StzLeft(_cKey_, 12) +
				"...) -- deterministic, zero cost"
			$cStzLastWhyB = @cWhy
			$nStzLastCertainty = 1
			return @aCache[_cKey_]
		ok

		if @bHasResponder = 0 and StzHasGenerativeModel() = 0
			stzraise("No generative model loaded (and no memo for this input). Load a GGUF or seed the cache -- refusing rather than guessing.")
		ok

		@aLastFindings = []
		_nTry_ = 0
		while _nTry_ <= @nRetries
			_nTry_++
			if @nCallsMade >= @nMaxCalls
				stzraise("Budget exhausted (" + @nMaxCalls + " call(s)) for '" + @cName + "' -- raise Budget(n) deliberately if more is wanted.")
			ok
			@nCallsMade++
			_cRaw_ = ""
			if @bHasResponder = 1
				_fR_ = @fResponder
				_cRaw_ = call _fR_(_cPrompt_, _nTry_)
			else
				_cRaw_ = StzAskModel(_cPrompt_)
			ok
			_aVal_ = This._Validate(_cRaw_)
			if _aVal_[1] = 1
				@aCache[_cKey_] = _aVal_[2]
				@cWhy = "generated (attempt " + _nTry_ + "), VALIDATED as " +
					This._TypeSaid() + ", memoized"
				if @bHasResponder = 1
					@cWhy = "FAKE responder (attempt " + _nTry_ + "), VALIDATED as " +
						This._TypeSaid() + ", memoized -- NOT a live model"
				ok
				$cStzLastWhyB = @cWhy
				return _aVal_[2]
			ok
		end
		stzraise("The model produced no valid '" + This._TypeSaid() + "' in " +
			@nRetries + " retries for '" + @cName + "' -- refusing (LAW 3: no garbage escapes as a value)." +
			This._Citation())

		def Of(pcInput)
			return This.Call_(pcInput)

	# test/offline door: seed a known answer into the memo cache (the
	# golden path for model-free environments; the seed is EXPLICIT)
	def SeedAnswer(pcInput, pValue)
		_cPrompt_ = This._EffectivePrompt(pcInput)
		_cKey_ = StzEngineCryptoSha256(@cName + "|" + @cOutType + "|" + _cPrompt_)
		_vSeed_ = pValue

		# A SEEDED structure is validated like a generated one. The door
		# is for testing, not for smuggling: LAW 3 says no garbage escapes
		# as a value, and a seed that escaped unchecked would be garbage
		# arriving through the side entrance.
		if @bHasSchema = 1
			_aV_ = []
			if isString(pValue)
				_aV_ = @oSchema.ParseOutput(pValue)
			else
				_aV_ = @oSchema.Verify(pValue)
			ok
			if _aV_[:ok] = 0
				@aLastFindings = _aV_[:findings]
				stzraise("The seed for '" + @cName + "' does not satisfy the declared " +
					"structure -- refusing to seed it." + This._Citation())
			ok
			_vSeed_ = _aV_[:value]
		ok

		@aCache[_cKey_] = _vSeed_
		return This

	# The prompt actually sent. For a structured function it carries the
	# schema's own clause, so the model is ASKED for the shape rather
	# than hoped at -- and the memo key is taken over this same text, so
	# a seed and a call agree on what the question was.
	def EffectivePrompt(pcInput)
		return This._EffectivePrompt(pcInput)

	def _EffectivePrompt(pcInput)
		_c_ = StzReplace(@cTemplate, "{input}", "" + pcInput)
		if @bHasSchema = 1
			_c_ = _c_ + char(10) + char(10) + @oSchema.PromptClause()
		ok
		return _c_

	def _TypeSaid()
		if @bHasSchema = 1
			return "structure(" + @oSchema.Name() + ")"
		ok
		return @cOutType

	def _Citation()
		if len(@aLastFindings) = 0
			return ""
		ok
		return " WHY: " + @oSchema.CiteFindings(@aLastFindings)

	#-- golden sets -----------------------------------------------------------

	def AddGolden(pcInput, pExpected)
		@aGoldens + [ "" + pcInput, pExpected ]

		def AddGoldenQ(pcInput, pExpected)
			This.AddGolden(pcInput, pExpected)
			return This

	# Goldens hold STRUCTURES as readily as scalars now. Two things had
	# to change for that, and both were real defects rather than gaps:
	# Ring's own `=` answers 0 for two identical lists, so a structured
	# golden could never have passed; and a failing structured case that
	# reports only "expected / got" is unreadable, so the failure now
	# carries the FIELD that moved.
	def RunGoldens()
		_nPass_ = 0
		_aFailed_ = []
		_n_ = len(@aGoldens)
		for _i_ = 1 to _n_
			_vExp_ = @aGoldens[_i_][2]
			_vGot_ = This.Call_(@aGoldens[_i_][1])

			_bSame_ = 0
			if isList(_vExp_) or isList(_vGot_)
				_bSame_ = StzOutputValuesAgree(_vExp_, _vGot_)
			else
				# scalars keep their exact comparison, unchanged
				if _vGot_ = _vExp_
					_bSame_ = 1
				ok
			ok

			if _bSame_ = 1
				_nPass_++
			else
				_aDiff_ = []
				if isList(_vExp_) or isList(_vGot_)
					_aDiff_ = StzOutputValueDiff(_vExp_, _vGot_, "")
				ok
				_aFailed_ + [ :input = @aGoldens[_i_][1],
					:expected = _vExp_, :got = _vGot_, :findings = _aDiff_ ]
			ok
		next
		return [ :total = _n_, :passed = _nPass_, :failed = _aFailed_ ]

	#-- validation -------------------------------------------------------------

	def _Validate(pcRaw)
		if @cOutType = "structure"
			_aV_ = @oSchema.ParseOutput(pcRaw)
			@aLastFindings = _aV_[:findings]
			if _aV_[:ok] = 1
				return [ 1, _aV_[:value] ]
			ok
			return [ 0, [] ]
		ok

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
