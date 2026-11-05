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
# FLOOR NOTE (2026-08-20, third update -- ALL THREE RUNGS ARE BUILT).
#
#   BUILT -- the declared-structure surface (ReturnsStructure, above).
#   BUILT -- the GRAMMAR: stzOutputSchema.ToGBNF() compiles a declaration
#            into GBNF, refusing by name what it cannot express and
#            listing what a grammar structurally cannot carry
#            (engine/src/schema_gbnf.zig).
#   BUILT -- CONSTRAINED DECODING. A GBNF stack machine
#            (engine/src/gbnf_machine.zig) judges every candidate token at
#            the sampler, so a token whose bytes cannot continue the
#            grammar is never drawn. Ask oSchema.IsDecodingConstrained() --
#            it answers 1 now -- and This.IsConstrainingDecoding() for
#            whether THIS function will use it.
#
# WHAT IT WAS COSTING, and what it costs now, both measured against the
# shipped smollm2-135m on the same ten structured prompts
# (base/test/neural/_measure_structured.ring):
#
#                              checked afterwards    constrained
#     first attempt valid          2 / 10             10 / 10
#     valid within four            6 / 10             10 / 10
#     attempts per valid answer      5.0                 1.0
#     never valid at all           4 / 10              0 / 10
#
# AND THE LINE THAT MUST TRAVEL WITH THAT NUMBER: a grammar constrains
# SHAPE. It does not constrain VALUE -- no context-free rule says
# "between 0 and 130" -- and it does not constrain TRUTH. The court below
# still refuses a value outside its declared band, retries still earn
# their keep for exactly that reason, and a schema-valid lie still
# validates. UnenforcedByGrammar() lists, per field, what the grammar
# does not carry.
#
# NOT constrained, and each says so rather than pretending: a declaration
# a grammar cannot express (a nested structure), ConstrainDecoding(0), or
# a build without the sampler rung. WhyNotConstrained() names which.

# Wraps a language-model call as a typed function: the reply validates as the declared type within a budget, or the call refuses.
#
# Declare a prompt with {input}, a return type (number, boolean, one of, free text or a whole
# record) and a mandatory Budget. Call_ then answers a value of that type or raises an error: no
# unvalidated text escapes. A reply that fails is retried inside the same budget, and the first
# attempt is greedy while retries draw again. Validated answers are memoized by content hash, so the
# same input is free and deterministic the second time. For a structured return the schema also
# gives the model a prompt clause and, when the engine allows, a grammar that fixes the shape of the
# reply; a grammar never fixes a value or the truth, so the court still checks bands. UseResponder
# and SeedAnswer let it run with no model for tests, and say so in Why. The object has no capability
# beyond mapping text to a typed value.
#
#   receiver   o1 = new stzLLMFunction("classify-mood"); o1.SetPrompt("Positive or negative?
#              {input}"); o1.ReturnsOneOf([ "positive", "negative" ]) o1.Budget(5);
#              o1.SeedAnswer("What a lovely day", "positive")
#   example    ? o1.Call_("What a lovely day")
#              #--> positive
#              ? o1.CallsMade()
#              #--> 0
#              ? o1.HasSchema()
#              #--> 0
#   see        stzOutputSchema, stzNeuralModel, stzNeuralChat
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
	@nRetryTemp = 0.7          # attempt 1 is greedy; retries DRAW AGAIN
	@nRetrySeed = 1000
	@nMaxTokens = 128
	@nMaxCalls = 0
	@nCallsMade = 0
	@nRetries = 2
	@aCache = []               # sha -> validated value
	@aGoldens = []             # [ input, expected ]
	@cWhy = ""
	@bConstrain = 1            # constrain DECODING with the schema's grammar
	@cGrammar = ""             # compiled once, on first live call
	@cNoGrammarWhy = ""        # why not, when a schema cannot become a grammar
	@bLastConstrained = 0      # was the last live answer grammar-constrained?
	@cLastReason = ""          # why the last scalar reply was refused, for the error text

	# Builds a typed language-model function with a name, an empty prompt, string output and no budget.
	#
	#   pcName     the function name, which keys its memo cache
	#   returns    nothing; the object is built
	#   see        SetPrompt, Budget, Call_
	def init(pcName)
		@cName = "" + pcName

	# Returns the name the function was built with.
	#
	#   returns    a text
	#   see        SetPrompt
	def Name_()
		return @cName

	# Sets the prompt template, in which {input} marks where each call puts its input text.
	#
	#   pcTemplate   the prompt text with an optional {input} marker
	#   returns      the function itself, so calls chain
	#   note         Call_ raises an error while no template is set
	#   see          Call_, ReturnsStructure
	def SetPrompt(pcTemplate)
		@cTemplate = "" + pcTemplate
		return This

	# Declares that the answer must be one number, and refuses a reply that is anything else.
	#
	# A reply is read as a number when, with quotes, backticks, asterisks and sentence punctuation
	# ignored, it is one number written with the digits 0 to 9 -- an optional sign, whole digits, an
	# optional decimal part after a point, an optional exponent -- alone or between plain filler words
	# such as the answer is. A comma is read only as a thousands mark between digit groups of three, so
	# 1,000 is 1000. Every other reply is refused and retried, never raised from the parser: a hedge
	# such as about 42, none, a lone comma as in 1,5, 5%, NaN, inf, 0x10, digits of another script, two
	# numbers, a NUL byte, an integer of more than 15 digits and a number too large to be finite.
	#
	#   returns    the function itself, so calls chain
	#   note       1,5 is refused rather than read as 1.5: the function has no locale, and a lone comma
	#              cannot be told from a thousands mark
	#   warning    a refused reply spends one attempt of the budget; after the retries Call_ raises
	#              an error that says why the last reply was refused
	#   see        ReturnsBoolean, ReturnsOneOf, Call_
	#   example    o1.ReturnsNumber()
	#              o1.UseResponder(func cP, nT { return "The answer is 42." })
	#              ? o1.Call_("How many legs have a cat and a bird together")
	#              #--> 42
	#              o1.UseResponder(func cP, nT { return "1,000" })
	#              ? o1.Call_("How many metres in a kilometre")
	#              #--> 1000
	def ReturnsNumber()
		@cOutType = "number"
		return This

	# Declares that the answer must be yes or no, kept as 1 or 0, and refuses a reply that is neither.
	#
	# A reply is read as yes when it is the whole word yes, y, true or 1 and as no when it is the whole
	# word no, n, false or 0, in any case, with quotes and sentence punctuation ignored. A longer reply
	# is read by its first word, which must be yes, true, no or false followed by a comma, a period, a
	# dash or a line break; the rest of the reply may repeat that answer but may not contradict it, and
	# may not hedge with a word such as not, maybe, unknown, but, if or unless. Words are whole words
	# in any script, so unknown, not sure, nobody, yesterday and know are refused and never read as 0
	# or 1, and so is a reply that holds both yes and no. The answer words are English: an answer in
	# another script is refused.
	#
	#   returns    the function itself, so calls chain
	#   note       a reply with neither answer is refused
	#   warning    a refused reply spends one attempt of the budget; after the retries Call_ raises
	#              an error that says why the last reply was refused
	#   see        ReturnsNumber, ReturnsOneOf, Call_
	#   example    o1.ReturnsBoolean()
	#              o1.UseResponder(func cP, nT { return "Yes, it is." })
	#              ? o1.Call_("Is the sea salty")
	#              #--> 1
	#              o1.UseResponder(func cP, nT { return "NO." })
	#              ? o1.Call_("Is the sun cold")
	#              #--> 0
	def ReturnsBoolean()
		@cOutType = "boolean"
		return This

	# Declares that the answer is free text, trimmed of surrounding whitespace.
	#
	#   returns    the function itself, so calls chain
	#   note       this is the default type
	#   see        ReturnsNumber, ReturnsOneOf, Call_
	def ReturnsString()
		@cOutType = "string"
		return This

	# Declares that the answer must be one of a fixed set of choices, kept in lower case.
	#
	#   pacChoices   the allowed answers as a list of text, compared without regard to case
	#   returns      the function itself, so calls chain
	#   note         a reply is accepted when it equals a choice, or contains exactly one of the
	#                choices as a whole word, so reddish is not red
	#   see          ReturnsString, ReturnsStructure, Call_
	def ReturnsOneOf(pacChoices)
		@cOutType = "oneof"
		@acChoices = []
		_n_ = len(pacChoices)
		for _i_ = 1 to _n_
			@acChoices + StzLower(ring_trim("" + pacChoices[_i_]))
		next
		return This

	# Declares that the answer must be a record of the given fields, judged now, so a faulty declaration never reaches a model.
	#
	#   paFields   the stzOutputSchema declaration, a list of field hash-lists with field, type and
	#              optional must, choices, of and optional
	#   returns    the function itself, so calls chain
	#   note       ReturnsStructureQ is the same call; one missing required field refuses the whole
	#              answer
	#   warning    raises an error on the spot for an unknown field type or a mistyped key
	#   see        Schema, RefuseUnknownFields
	#@ aka  THE STRUCTURED RUNG. paFields is an stzOutputSchema declaration; it is compiled and judged HERE, so a defective declaration can never reach a model.
	def ReturnsStructure(paFields)
		_o_ = new stzOutputSchema(paFields)
		_o_.SetNameQ(@cName)
		@oSchema = _o_
		@bHasSchema = 1
		@cOutType = "structure"
		return This

		def ReturnsStructureQ(paFields)
			return This.ReturnsStructure(paFields)

	# TRUE if the function returns a declared structure.
	#
	#   returns    TRUE or FALSE
	#   see        ReturnsStructure, Schema
	def HasSchema()
		return @bHasSchema

	# Returns the stzOutputSchema of the declared structure, as a copy to read.
	#
	#   returns    the stzOutputSchema object
	#   note       changing the returned copy does not change the function; use RefuseUnknownFields
	#              for that
	#   warning    raises an error when the function returns anything but a structure
	#   see        HasSchema, RefuseUnknownFields
	#@ aka  A READ. Ring copies on assign, so configuring the returned schema configures a copy and nothing else -- use RefuseUnknownFields() below for the one knob that has to land on the stored one.
	def Schema()
		if @bHasSchema = 0
			stzraise("This function returns a " + @cOutType + ", not a structure -- " +
				"declare ReturnsStructure([...]) first.")
		ok
		return @oSchema

	# Makes the declared structure closed, so that a field the model adds refuses the answer instead of being dropped.
	#
	#   returns    the function itself, so calls chain
	#   note       an answer already memoized is still served from the cache
	#   warning    raises an error when the function returns anything but a structure
	#   see        Schema, LastFindings
	#@ aka  Closed-world: a field the schema never declared refuses the answer instead of being reported and dropped.
	def RefuseUnknownFields()
		if @bHasSchema = 0
			stzraise("RefuseUnknownFields() needs a structure -- declare ReturnsStructure([...]) first.")
		ok
		_o_ = @oSchema
		_o_.RefuseUnknownFieldsQ()
		@oSchema = _o_
		return This

	# Returns the findings of the last validation, the reasons a reply was refused or trimmed.
	#
	#   returns    a list of rule rows [ :rule, :subject, :where, :severity, :message ]; [ ] when
	#              nothing was found
	#   note       an open structure reports a dropped extra field here as a warning
	#   see        CallsMade, Why
	#@ aka  The findings the LAST validation produced, in the family's unified shape -- so a refusal can be handed to stzRuleReport.Ingest() and stand in the same CI gate as every other rule in the library.
	def LastFindings()
		return @aLastFindings

	# Sets the most model calls the function may spend; it is mandatory before the first call.
	#
	#   nMaxCalls   the number of model calls allowed in the life of the object
	#   returns     the function itself, so calls chain
	#   note        Call_ raises an error naming the budget when it is exhausted; a memo hit costs
	#               nothing
	#   see         SetRetries, CallsMade, Call_
	def Budget(nMaxCalls)
		@nMaxCalls = nMaxCalls
		return This

	# Sets how many further attempts follow a refused reply.
	#
	#   n          the number of retries
	#   returns    the function itself, so calls chain
	#   note       the default is 2, so up to 3 attempts
	#   see        Budget, SetRetrySampling
	def SetRetries(n)
		@nRetries = n
		return This

	# Puts a fake in the model place: a function that receives the prompt and the attempt number and returns raw reply text.
	#
	#   fResponder   the name of a function with two parameters, prompt text and attempt number
	#   returns      nothing; use UseResponderQ to chain
	#   note         for offline tests; it spends budget like a real call and Why says FAKE
	#                responder
	#   see          IsUsingResponder, SeedAnswer, Call_
	#@ aka  TEST / OFFLINE DOOR, named for what it is. The responder is a FAKE standing where the model stands: it receives (prompt, attempt) and returns the raw text a model would have returned. It exists so the refusal paths -- the ones that matter most and that no seeded cache can reach -- can be narrated without a GGUF. It spends budget like a real call, and Why() says "FAKE responder" on every answer it 
	def UseResponder(fResponder)
		This.UseResponderQ(fResponder)

	def UseResponderQ(fResponder)
		@fResponder = fResponder
		@bHasResponder = 1
		return This

	# TRUE if a fake responder stands in for the model.
	#
	#   returns    TRUE or FALSE
	#   see        UseResponder
	def IsUsingResponder()
		return @bHasResponder

	# Returns how many model or responder calls were spent.
	#
	#   returns    a number
	#   see        Budget, Call_
	def CallsMade()
		return @nCallsMade

	# Returns how the last answer came about: memoized, generated, or from a fake responder.
	#
	#   returns    a text; empty before the first call
	#   see        LastFindings, Call_
	def Why()
		return @cWhy

	# Maps an input text to a value of the declared type, from the memo or from the model, or refuses.
	#
	#   pcInput    the text that replaces {input} in the prompt
	#   returns    the validated value: a text, a number, 1 or 0, a choice or a list of [ field,
	#              value ] rows
	#   note       the same input gives the same answer free from the memo; of is an alias for this
	#              call
	#   warning    raises an error without a prompt, without a budget, when no generative model is
	#              loaded and nothing is memoized, when the budget is spent, and after the retries
	#              when no reply validates, naming why the last one was refused
	#   see        Of, Budget, SeedAnswer, Why
	#@ aka  -- the call ------------------------------------------------------------
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
				_cRaw_ = This._AskModel(_cPrompt_, _nTry_)
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

	# Stores a known answer for an input in the memo, so a later call returns it without a model.
	#
	#   pcInput    the input text the answer belongs to
	#   pValue     the answer, judged against the declared structure first
	#   returns    the function itself, so calls chain
	#   note       the key covers name, type and the full prompt, so declare the type and prompt
	#              before seeding
	#   warning    raises an error when the answer does not satisfy the declared structure
	#   see        Call_, UseResponder
	#@ aka  test/offline door: seed a known answer into the memo cache (the golden path for model-free environments; the seed is EXPLICIT)
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

	# A RETRY THAT CANNOT DIFFER IS NOT A RETRY, and this seam is greedy.
	#
	# MEASURED 2026-08-20 against the model this repository ships
	# (smollm2-135m-instruct-q8_0), 10 structured prompts: eight failed, and
	# on all EIGHT the second greedy attempt was BYTE-IDENTICAL to the
	# first. StzAskModel decodes at temperature 0, which is deterministic by
	# design and correct for it -- so every retry above attempt 1 was
	# spending budget to receive the same refusal again. SetRetries(n) was,
	# against this seam, a lie.
	#
	# So attempt 1 stays GREEDY -- the common path is unchanged, and its
	# answer is reproducible -- and every attempt after it DRAWS AGAIN, with
	# a temperature and a seed derived from the attempt number. Reproducible
	# per attempt (same function, same input, same attempt -> same seed),
	# and genuinely a different sample from the one that just failed.
	#
	# Determinism-by-cache is untouched: what the memo stores is the
	# VALIDATED value, so a repeated call still answers from the cache
	# without sampling at all.
	# THE ARITY THAT KEPT THE LIVE PATH FROM EVER RUNNING.
	#
	# This used to read `StzAskModel(_cPrompt_)`. StzAskModel takes TWO
	# parameters (question, maxNewTokens), and Ring raises R19 "Calling
	# function with less number of parameters" for the one-argument form
	# INSIDE A CLASS -- while tolerating it at top level, which is why it
	# reads as correct and why no reviewer caught it.
	#
	# Nothing in the suite could catch it either: every scene here seeds the
	# memo or supplies a fake responder, and the machine had no generative
	# GGUF loaded, so the live branch was never once executed. It was found
	# by MEASURING against the shipped smollm2 model, not by reading. Both
	# calls pass the token budget explicitly now.
	#
	# AND THE RUNG THAT MOVED UNDER THIS SEAM (2026-08-20). When the
	# declared structure can be expressed as a grammar and the engine
	# enforces one, the grammar goes to the SAMPLER: a token that would
	# violate the shape is never drawn. The retry policy above is
	# unchanged and still earns its keep -- a grammar constrains SHAPE,
	# so a value outside a declared band is still refused by the court
	# and still worth another attempt.
	#
	# AND A RING TRAP PAID FOR HERE, so the next reader does not pay it
	# again: the options list below is written as a LITERAL, never built
	# by appending. `aOpts + [ :Key = value ]` appends the one-element
	# WRAPPER list, so the pair ends up nested one level deeper and every
	# `len(pair) = 2` reader silently skips it. It prints identically at
	# the console -- Ring shows nested lists recursively -- so the option
	# simply had no effect, which is how a grammar was passed and not
	# applied for the length of one debugging session.
	def _AskModel(pcPrompt, pnTry)
		_cG_ = This._GrammarOrEmpty()
		if _cG_ != ""
			@bLastConstrained = 1
		else
			@bLastConstrained = 0
		ok

		# attempt 1 stays GREEDY -- reproducible, unchanged
		_nT_ = 0
		_nS_ = @nRetrySeed
		if pnTry > 1
			_nT_ = @nRetryTemp
			_nS_ = @nRetrySeed + pnTry
		else
			_nT_ = 0
			_nS_ = @nRetrySeed
		ok

		if _cG_ != ""
			return StzAskModelXT(pcPrompt, [
				:MaxTokens   = @nMaxTokens,
				:Temperature = _nT_,
				:Seed        = _nS_,
				:Grammar     = _cG_
			])
		but pnTry <= 1
			return StzAskModel(pcPrompt, @nMaxTokens)
		else
			return StzAskModelXT(pcPrompt, [
				:MaxTokens   = @nMaxTokens,
				:Temperature = _nT_,
				:Seed        = _nS_
			])
		ok

	# The grammar this function will constrain with, or "" and a reason.
	# Compiled ONCE: the declaration does not change between attempts.
	def _GrammarOrEmpty()
		@cNoGrammarWhy = ""
		if @bHasSchema = 0
			@cNoGrammarWhy = "no structure is declared -- there is nothing to constrain"
			return ""
		ok
		if @bConstrain = 0
			@cNoGrammarWhy = "ConstrainDecoding(0) was asked for"
			return ""
		ok
		if StzConstrainedDecodingSupported() = 0
			@cNoGrammarWhy = "this build does not enforce a grammar at the sampler"
			return ""
		ok
		if @cGrammar != ""
			return @cGrammar
		ok
		_c_ = ""
		try
			_c_ = @oSchema.ToGBNF()
		catch
			# A declaration a grammar cannot express (a nested structure)
			# is NOT an error here. The Ring court validates it exactly as
			# it did before -- but the fall-back is RECORDED, so nobody
			# reads an unconstrained answer as a constrained one.
			_c_ = ""
			@cNoGrammarWhy = "the declaration cannot be expressed as a grammar: " +
				StzLeft(cCatchError, 160)
		done
		@cGrammar = _c_
		return _c_

	# Switches grammar-constrained decoding on or off for a structured function.
	#
	#   pbYesNo    1 to constrain decoding with the schema grammar, 0 to leave it unconstrained
	#   returns    nothing; use ConstrainDecodingQ to chain
	#   note       it is on by default; a grammar fixes the shape, never the value or the truth
	#   see        IsConstrainingDecoding, WhyNotConstrained
	#@ aka  -- constrained decoding, asked and answered ---------------------------
	def ConstrainDecoding(pbYesNo)
		This.ConstrainDecodingQ(pbYesNo)

	def ConstrainDecodingQ(pbYesNo)
		if pbYesNo = 0 or pbYesNo = FALSE
			@bConstrain = 0
		else
			@bConstrain = 1
		ok
		return This

	# TRUE if the next live call will constrain the sampler with the schema grammar.
	#
	#   returns    TRUE or FALSE
	#   note       FALSE for a scalar type, for ConstrainDecoding(0), for a nested structure and for
	#              a build without the sampler rung
	#   see        WhyNotConstrained, ConstrainDecoding
	#@ aka  Will the NEXT live call be grammar-constrained? Ask this rather than assuming: a nested structure, an off switch, or a build without the sampler rung all answer 0, and WhyNotConstrained() says which.
	def IsConstrainingDecoding()
		if This._GrammarOrEmpty() = ""
			return 0
		ok
		return 1

	# Returns the reason the next live call will not be grammar-constrained.
	#
	#   returns    a text; empty when it will be constrained
	#   see        IsConstrainingDecoding
	def WhyNotConstrained()
		if This._GrammarOrEmpty() != ""
			return ""
		ok
		return @cNoGrammarWhy

	# The grammar text itself, for a reader who wants to see what was enforced.
	def GrammarUsed()
		return This._GrammarOrEmpty()

	# TRUE if the last live answer was drawn under a grammar.
	#
	#   returns    TRUE or FALSE
	#   note       0 for a memo hit and for a fake responder, since neither decoded anything
	#   see        IsConstrainingDecoding
	#@ aka  Was the LAST live answer grammar-constrained? (0 for a memo hit and for a fake responder -- neither of them decoded anything.)
	def WasLastAnswerConstrained()
		return @bLastConstrained

	# Sets the temperature and seed that retries sample with.
	#
	#   pnTemperature   the sampling temperature of attempts after the first
	#   pnSeed          the base seed, to which the attempt number is added
	#   returns         nothing; use SetRetrySamplingQ to chain
	#   note            the first attempt is always greedy; defaults are 0.7 and 1000
	#   see             RetryTemperature, SetRetries
	#@ aka  The sampling a RETRY uses. Attempt 1 never sees these -- it is greedy.
	def SetRetrySampling(pnTemperature, pnSeed)
		This.SetRetrySamplingQ(pnTemperature, pnSeed)

	def SetRetrySamplingQ(pnTemperature, pnSeed)
		@nRetryTemp = pnTemperature
		@nRetrySeed = pnSeed
		return This

	# Sets the most tokens a model reply may hold.
	#
	#   pnMax      the token budget of one reply
	#   returns    nothing; use SetMaxTokensQ to chain
	#   note       the default is 128
	#   see        SetRetrySampling
	def SetMaxTokens(pnMax)
		This.SetMaxTokensQ(pnMax)

	def SetMaxTokensQ(pnMax)
		@nMaxTokens = pnMax
		return This

	# Returns the temperature that retries sample with.
	#
	#   returns    a number; 0.7 by default
	#   see        SetRetrySampling
	def RetryTemperature()
		return @nRetryTemp

	def _TypeSaid()
		if @bHasSchema = 1
			return "structure(" + @oSchema.Name() + ")"
		ok
		return @cOutType

	def _Citation()
		if @bHasSchema = 1 and len(@aLastFindings) > 0
			return " WHY: " + @oSchema.CiteFindings(@aLastFindings)
		ok
		if @cLastReason != ""
			return " WHY: " + @cLastReason
		ok
		return ""

	# Adds an input with the answer it must give, for RunGoldens to check.
	#
	#   pcInput     the input text
	#   pExpected   the expected answer, a scalar or a structure
	#   returns     nothing; use AddGoldenQ to chain
	#   see         RunGoldens, Call_
	#@ aka  -- golden sets -----------------------------------------------------------
	def AddGolden(pcInput, pExpected)
		@aGoldens + [ "" + pcInput, pExpected ]

		def AddGoldenQ(pcInput, pExpected)
			This.AddGolden(pcInput, pExpected)
			return This

	# Calls the function on every golden input and compares each answer with the expected one.
	#
	#   returns    a hash-list [ :total, :passed, :failed ]; each failure is a hash-list with input,
	#              expected, got and findings
	#   note       it spends budget like any call; a structure that differs lists the fields that
	#              moved
	#   see        AddGolden, Call_
	#@ aka  Goldens hold STRUCTURES as readily as scalars now. Two things had to change for that, and both were real defects rather than gaps: Ring's own `=` answers 0 for two identical lists, so a structured golden could never have passed; and a failing structured case that reports only "expected / got" is unreadable, so the failure now carries the FIELD that moved.
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

	# Judges a raw reply against the declared type and answers [ 1, value ] or [ 0, "" ].
	#
	#   pcRaw      the raw reply text
	#   returns    a list of two items: 1 and the value when the reply validates, 0 and an empty value
	#              when it is refused
	#   note       a refused scalar reply leaves its reason for Call_ in the private reason field
	#   see        Call_
	def _Validate(pcRaw)
		@cLastReason = ""
		if @cOutType = "structure"
			_aV_ = @oSchema.ParseOutput(pcRaw)
			@aLastFindings = _aV_[:findings]
			if _aV_[:ok] = 1
				return [ 1, _aV_[:value] ]
			ok
			return [ 0, [] ]
		ok

		if @cOutType = "string"
			return [ 1, ring_trim("" + pcRaw) ]
		but @cOutType = "boolean"
			return This._ReadBoolean(pcRaw)
		but @cOutType = "number"
			return This._ReadNumber(pcRaw)
		but @cOutType = "oneof"
			return This._ReadOneOf(pcRaw)
		ok
		return [ 0, "" ]

	# Reads a reply as one number, or refuses it and keeps the reason.
	#
	#   pcRaw      the raw reply text
	#   returns    [ 1, number ] when the reply is one number between filler words only, [ 0, 0 ] otherwise
	#   see        _Tokenize, _ParseNumber, ReturnsNumber
	def _ReadNumber(pcRaw)
		_aTok_ = This._Tokenize(pcRaw)
		_nT_ = len(_aTok_)
		if _nT_ = 0
			return [ 0, 0 ]
		ok
		_cFill_ = "|the|answer|result|value|total|number|is|are|was|equals|it|its|that|so|thus|therefore|final|correct|"
		_nAt_ = 0
		for _i_ = 1 to _nT_
			_cK_ = _aTok_[_i_][2]
			if _cK_ = "number"
				if _nAt_ > 0
					@cLastReason = "the reply holds more than one number"
					return [ 0, 0 ]
				ok
				_nAt_ = _i_
			but _cK_ = "word"
				if len(StzFind("|" + _aTok_[_i_][1] + "|", _cFill_)) = 0
					@cLastReason = "the word " + _aTok_[_i_][1] + " is not a plain filler word, so the reply is not one bare number"
					return [ 0, 0 ]
				ok
			else
				@cLastReason = _aTok_[_i_][5]
				if @cLastReason = ""
					@cLastReason = "the token " + StzLeft(_aTok_[_i_][1], 30) + " is not a number written with the digits 0 to 9"
				ok
				return [ 0, 0 ]
			ok
		next
		if _nAt_ = 0
			@cLastReason = "the reply holds no number"
			return [ 0, 0 ]
		ok
		if len(StzFind("?", _aTok_[_nAt_][3])) > 0
			@cLastReason = "the number is followed by a question mark"
			return [ 0, 0 ]
		ok
		return [ 1, _aTok_[_nAt_][4] ]

	# Reads a reply as yes or no, or refuses it and keeps the reason.
	#
	#   pcRaw      the raw reply text
	#   returns    [ 1, 1 ] for yes, [ 1, 0 ] for no, [ 0, 0 ] when the reply is refused
	#   see        _Tokenize, _AnswerOf, ReturnsBoolean
	def _ReadBoolean(pcRaw)
		_aTok_ = This._Tokenize(pcRaw)
		_nT_ = len(_aTok_)
		if _nT_ = 0
			return [ 0, 0 ]
		ok
		_nLead_ = 0 - 1
		if _nT_ = 1
			_nLead_ = This._AnswerOf(_aTok_[1][1], 1)
		else
			_nLead_ = This._AnswerOf(_aTok_[1][1], 0)
		ok
		if _nLead_ < 0
			if _nT_ = 1
				@cLastReason = "the reply is not one of yes, y, true, 1, no, n, false, 0"
			else
				@cLastReason = "the reply does not begin with yes, true, no or false"
			ok
			return [ 0, 0 ]
		ok
		if len(StzFind("?", _aTok_[1][3])) > 0
			@cLastReason = "the answer is followed by a question mark"
			return [ 0, 0 ]
		ok
		if _nT_ = 1
			return [ 1, _nLead_ ]
		ok
		_cMarks_ = _aTok_[1][3]
		if len(StzFind(",", _cMarks_)) = 0 and len(StzFind(".", _cMarks_)) = 0 and
		   len(StzFind("!", _cMarks_)) = 0 and len(StzFind(";", _cMarks_)) = 0 and
		   len(StzFind(":", _cMarks_)) = 0 and len(StzFind("-", _cMarks_)) = 0
			@cLastReason = "the first word is not followed by a comma, a period, a dash or a line break"
			return [ 0, 0 ]
		ok
		_cHedge_ = "|not|never|none|nobody|nothing|neither|nor|maybe|perhaps|possibly|probably|unsure|unknown|uncertain|unclear|depends|cannot|but|however|though|although|except|unless|if|sometimes|partly|mostly|somewhat|"
		for _i_ = 2 to _nT_
			if _aTok_[_i_][2] = "word"
				_w_ = _aTok_[_i_][1]
				_nP_ = This._AnswerOf(_w_, 0)
				if _nP_ >= 0
					if _nP_ != _nLead_
						@cLastReason = "the reply holds both a yes word and a no word"
						return [ 0, 0 ]
					ok
				but len(StzFind("|" + _w_ + "|", _cHedge_)) > 0 or len(StzFind("n't", _w_)) > 0
					@cLastReason = "the word " + _w_ + " hedges the answer"
					return [ 0, 0 ]
				ok
			ok
		next
		return [ 1, _nLead_ ]

	# Reads a reply as one of the declared choices, as a whole word, or refuses it.
	#
	#   pcRaw      the raw reply text
	#   returns    [ 1, choice ] when the reply equals a choice or holds exactly one choice as a whole
	#              word, [ 0, "" ] otherwise
	#   see        ReturnsOneOf
	def _ReadOneOf(pcRaw)
		_cT_ = StzLower(ring_trim("" + pcRaw))
		_nC_ = len(@acChoices)
		# exact match first, then unique containment as a whole word
		for _i_ = 1 to _nC_
			if _cT_ = @acChoices[_i_]
				return [ 1, @acChoices[_i_] ]
			ok
		next
		_acCp_ = StzChars(_cT_)
		_nHits_ = 0
		_cHit_ = ""
		for _i_ = 1 to _nC_
			if @acChoices[_i_] != "" and This._HasWholeWord(_acCp_, _cT_, @acChoices[_i_]) = 1
				_nHits_++
				_cHit_ = @acChoices[_i_]
			ok
		next
		if _nHits_ = 1
			return [ 1, _cHit_ ]
		ok
		return [ 0, "" ]

	# Tells whether a choice stands in a reply with no letter or digit touching either end of it.
	#
	#   pacCp      the characters of the reply, as StzChars gives them
	#   pcText     the reply itself
	#   pcWord     the choice to look for
	#   returns    1 when some occurrence is a whole word, 0 otherwise
	#   see        _ReadOneOf
	def _HasWholeWord(pacCp, pcText, pcWord)
		_aPos_ = StzFind(pcWord, pcText)
		_nP_ = len(_aPos_)
		if _nP_ = 0
			return 0
		ok
		_nW_ = len(StzChars(pcWord))
		_nN_ = len(pacCp)
		for _i_ = 1 to _nP_
			_p_ = _aPos_[_i_]
			_bOk_ = 1
			if _p_ > 1
				_ch_ = pacCp[_p_ - 1]
				if StzIsAlpha(_ch_) = 1 or StzIsDigit(_ch_) = 1
					_bOk_ = 0
				ok
			ok
			if _bOk_ = 1 and (_p_ + _nW_) <= _nN_
				_ch_ = pacCp[_p_ + _nW_]
				if StzIsAlpha(_ch_) = 1 or StzIsDigit(_ch_) = 1
					_bOk_ = 0
				ok
			ok
			if _bOk_ = 1
				return 1
			ok
		next
		return 0

	# Maps an answer word to 1 for yes, 0 for no, or -1 when it is neither.
	#
	#   pcWord     a lower-case word, or the text 1 or 0
	#   pbShort    1 to accept y, n, 1 and 0 as well as yes, true, no and false
	#   returns    1, 0 or -1
	#   see        _ReadBoolean
	def _AnswerOf(pcWord, pbShort)
		if pcWord = "yes" or pcWord = "true"
			return 1
		ok
		if pcWord = "no" or pcWord = "false"
			return 0
		ok
		if pbShort = 1
			if pcWord = "y" or pcWord = "1"
				return 1
			ok
			if pcWord = "n" or pcWord = "0"
				return 0
			ok
		ok
		return 0 - 1

	# Cuts a reply into tokens, the one reading both the number rule and the boolean rule rest on.
	#
	# The reply is lower-cased, its typographic quotes, dashes and spaces are folded to plain ones and
	# each line break becomes a semicolon, so a break counts as a separator. It is cut at spaces; each
	# piece loses the quotes, brackets and asterisks on its left and the same plus sentence marks and
	# dashes on its right, and the marks removed on the right stay with the token. A piece that
	# was nothing but marks is dropped and its marks join the token before it.
	#
	#   pcRaw      the raw reply text
	#   returns    a list of tokens [ text, kind, marks, value, why ]; kind is number (value is the
	#              number), word (letters, with apostrophes inside) or other (why says what a
	#              numeric-looking token broke); [ ] for an empty reply, one holding a NUL byte or one
	#              that is not valid UTF-8, the reason being kept in the private reason field
	#   see        _ParseNumber, _ReadNumber, _ReadBoolean
	def _Tokenize(pcRaw)
		_c_ = "" + pcRaw
		if len(StzFind(char(0), _c_)) > 0
			@cLastReason = "the reply holds a NUL byte"
			return []
		ok
		_c_ = StzLower(_c_)
		_c_ = StzReplace(_c_, char(226) + char(128) + char(156), char(34))
		_c_ = StzReplace(_c_, char(226) + char(128) + char(157), char(34))
		_c_ = StzReplace(_c_, char(226) + char(128) + char(152), "'")
		_c_ = StzReplace(_c_, char(226) + char(128) + char(153), "'")
		_c_ = StzReplace(_c_, char(226) + char(128) + char(147), "-")
		_c_ = StzReplace(_c_, char(226) + char(128) + char(148), "-")
		_c_ = StzReplace(_c_, char(226) + char(136) + char(146), "-")
		_c_ = StzReplace(_c_, char(226) + char(128) + char(144), "-")
		_c_ = StzReplace(_c_, char(226) + char(128) + char(145), "-")
		_c_ = StzReplace(_c_, char(226) + char(128) + char(166), "...")
		_c_ = StzReplace(_c_, char(227) + char(128) + char(130), ".")
		_c_ = StzReplace(_c_, char(194) + char(160), " ")
		_c_ = StzReplace(_c_, char(227) + char(128) + char(128), " ")
		_c_ = StzReplace(_c_, char(226) + char(128) + char(137), " ")
		_c_ = StzReplace(_c_, char(226) + char(128) + char(175), " ")
		_c_ = StzReplace(_c_, char(13), " ")
		_c_ = StzReplace(_c_, char(9), " ")
		_c_ = StzReplace(_c_, char(11), " ")
		_c_ = StzReplace(_c_, char(12), " ")
		_c_ = StzReplace(_c_, char(10), " ; ")
		if _c_ = "" and ("" + pcRaw) != ""
			@cLastReason = "the reply is not valid UTF-8 text"
			return []
		ok

		_cLeft_ = "([{" + char(34) + "'`*"
		_cRight_ = ".,;:!?)]}" + char(34) + "'`*-"
		_aTok_ = []
		_acPiece_ = StzSplit(_c_, " ")
		_nPieces_ = len(_acPiece_)
		for _i_ = 1 to _nPieces_
			if _acPiece_[_i_] = ""
				loop
			ok
			_acCp_ = StzChars(_acPiece_[_i_])
			_nA_ = 1
			_nZ_ = len(_acCp_)
			while _nA_ <= _nZ_
				if len(StzFind(_acCp_[_nA_], _cLeft_)) = 0
					exit
				ok
				_nA_++
			end
			_cMarks_ = ""
			while _nZ_ >= _nA_
				if len(StzFind(_acCp_[_nZ_], _cRight_)) = 0
					exit
				ok
				_cMarks_ = _acCp_[_nZ_] + _cMarks_
				_nZ_--
			end
			if _nZ_ < _nA_
				_nLast_ = len(_aTok_)
				if _nLast_ > 0
					_aTok_[_nLast_][3] = _aTok_[_nLast_][3] + _cMarks_
				ok
				loop
			ok
			_cText_ = ""
			for _k_ = _nA_ to _nZ_
				_cText_ = _cText_ + _acCp_[_k_]
			next

			_aNum_ = This._ParseNumber(_cText_)
			if _aNum_[1] = 1
				_aTok_ + [ _cText_, "number", _cMarks_, _aNum_[2], "" ]
			else
				_cBare_ = StzReplace(_cText_, "'", "")
				if _cBare_ != "" and StzIsAlpha(_cBare_) = 1
					_aTok_ + [ _cText_, "word", _cMarks_, 0, "" ]
				else
					_aTok_ + [ _cText_, "other", _cMarks_, 0, _aNum_[3] ]
				ok
			ok
		next
		if len(_aTok_) = 0
			@cLastReason = "the reply is empty"
		ok
		return _aTok_

	# Reads a text as a number written with the digits 0 to 9, or says why it is not one.
	#
	# The grammar is a sign, whole digits, a point and digits, an exponent; whole digits may carry
	# commas only as groups of exactly three after a first group of one to three digits. An integer
	# of more than 15 digits, a value that is not finite and a non-zero literal that falls to zero
	# are refused, since the number held would differ from the number written.
	#
	#   pcText     one token, lower-cased
	#   returns    [ 1, number, "" ] when it is a number, [ 0, 0, why ] when it is not; why is empty
	#              for a text that is not even numeric-looking
	#   see        _Tokenize
	def _ParseNumber(pcText)
		_c_ = pcText
		_n_ = ring_len(_c_)
		if _n_ = 0
			return [ 0, 0, "" ]
		ok
		_i_ = 1
		_cSign_ = ""
		if _c_[1] = "+" or _c_[1] = "-"
			if _c_[1] = "-"
				_cSign_ = "-"
			ok
			_i_ = 2
		ok

		# whole digits, with an optional comma between groups of three
		_cInt_ = ""
		_nGrp_ = 0
		_bGroups_ = 0
		while _i_ <= _n_
			_ch_ = _c_[_i_]
			if isdigit(_ch_)
				_cInt_ = _cInt_ + _ch_
				_nGrp_++
				_i_++
			but _ch_ = ","
				if _bGroups_ = 0 and (_nGrp_ < 1 or _nGrp_ > 3)
					return [ 0, 0, "the comma in " + StzLeft(_c_, 30) + " does not stand between digit groups of three, so it cannot be read as a thousands mark or as a decimal comma" ]
				ok
				if _bGroups_ = 1 and _nGrp_ != 3
					return [ 0, 0, "the comma in " + StzLeft(_c_, 30) + " does not stand between digit groups of three, so it cannot be read as a thousands mark or as a decimal comma" ]
				ok
				_bGroups_ = 1
				_nGrp_ = 0
				_i_++
			else
				exit
			ok
		end
		if _bGroups_ = 1 and _nGrp_ != 3
			return [ 0, 0, "the comma in " + StzLeft(_c_, 30) + " does not stand between digit groups of three, so it cannot be read as a thousands mark or as a decimal comma" ]
		ok

		_cFrac_ = ""
		_bPoint_ = 0
		if _i_ <= _n_ and _c_[_i_] = "."
			_bPoint_ = 1
			_i_++
			while _i_ <= _n_
				if isdigit(_c_[_i_])
					_cFrac_ = _cFrac_ + _c_[_i_]
					_i_++
				else
					exit
				ok
			end
			if _cFrac_ = ""
				return [ 0, 0, "" ]
			ok
		ok
		if _cInt_ = "" and _bPoint_ = 0
			return [ 0, 0, "" ]
		ok

		_cExp_ = ""
		if _i_ <= _n_ and _c_[_i_] = "e"
			_i_++
			_cEs_ = ""
			if _i_ <= _n_ and (_c_[_i_] = "+" or _c_[_i_] = "-")
				if _c_[_i_] = "-"
					_cEs_ = "-"
				ok
				_i_++
			ok
			_cEd_ = ""
			while _i_ <= _n_
				if isdigit(_c_[_i_])
					_cEd_ = _cEd_ + _c_[_i_]
					_i_++
				else
					exit
				ok
			end
			if _cEd_ = ""
				return [ 0, 0, "" ]
			ok
			_cExp_ = "e" + _cEs_ + _cEd_
		ok
		if _i_ <= _n_
			return [ 0, 0, "" ]
		ok

		# the integer part without its leading zeros says how many digits an integer carries
		_cSig_ = _cInt_
		while ring_len(_cSig_) > 0 and _cSig_[1] = "0"
			_cSig_ = StzRight(_cSig_, ring_len(_cSig_) - 1)
		end
		if _bPoint_ = 0 and _cExp_ = "" and ring_len(_cSig_) > 15
			return [ 0, 0, "the integer " + StzLeft(_c_, 20) + " has more than 15 digits and cannot be held exactly" ]
		ok

		_cLit_ = _cInt_
		if _cLit_ = ""
			_cLit_ = "0"
		ok
		if _bPoint_ = 1
			_cLit_ = _cLit_ + "." + _cFrac_
		ok
		_nV_ = ring_number(_cSign_ + _cLit_ + _cExp_)
		if (_nV_ - _nV_) != 0
			return [ 0, 0, "the number " + StzLeft(_c_, 20) + " is too large to be finite" ]
		ok
		if _nV_ = 0
			_nV_ = 0
			_bNz_ = 0
			_cAll_ = _cInt_ + _cFrac_
			_nAll_ = ring_len(_cAll_)
			for _k_ = 1 to _nAll_
				if _cAll_[_k_] != "0"
					_bNz_ = 1
				ok
			next
			if _bNz_ = 1
				return [ 0, 0, "the number " + StzLeft(_c_, 20) + " is too small to be told from zero" ]
			ok
		ok
		return [ 1, _nV_, "" ]
