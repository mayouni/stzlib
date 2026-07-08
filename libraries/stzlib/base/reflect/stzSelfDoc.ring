#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZSELFDOC                     #
#   An accelerative library for Ring applications, and more!    #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzSelfDoc -- SELF-DESCRIBING objects. It      #
#                  harvests a Softanza class's methods + their    #
#                  doc-comments straight from the SOURCE, then    #
#                  lets you ASK about them in plain English and   #
#                  EXPLAIN them -- powered by the neural tier's    #
#                  embeddings (2c) + cross-encoder (2h), NOT a     #
#                  heavy LLM. The knowledge already lives in the   #
#                  library; this indexes and queries it. Enables   #
#                  near-natural programming: describe intent, get   #
#                  the operation. Deterministic, zero hallucination.#
#   Author       : Mansour Ayouni (kalidianow@gmail.com)        #
#                                                              #
#--------------------------------------------------------------#

# StzDoc(cClassNameOrPath) -- the self-doc of a class (by name or source path).
func StzDoc(pcTarget)
	return new stzSelfDoc(pcTarget)

func StzSelfDoc(pcTarget)
	return new stzSelfDoc(pcTarget)

func StzSelfDocQ(pcTarget)
	return new stzSelfDoc(pcTarget)

class stzSelfDoc from stzObject

	@cName = ""       # class name (e.g. "stzText")
	@cSource = ""     # resolved source file path
	@aMethods = []    # [ [name, description, aka, ownerClass], ... ] own + inherited
	@aVectors = []    # per-method embedding (lazy; only when a model is loaded)
	@bIndexed = FALSE

	def init(pcTarget)
		if NOT isString(pcTarget)
			StzRaise("stzSelfDoc needs a class name or a source path.")
		ok
		if _StzLooksLikePath(pcTarget)
			# By-path form: harvest only this file's named class (no chain,
			# since we resolve parents by name, not path).
			@cSource = pcTarget
			@cName = _StzNameFromPath(pcTarget)
			if @cSource != "" and fexists(@cSource)
				_aM_ = _StzHarvestClass(@cSource, @cName)
				_nM_ = len(_aM_)
				for _i_ = 1 to _nM_
					@aMethods + [ _aM_[_i_][1], _aM_[_i_][2], _aM_[_i_][3], @cName ]
				next
			ok
		else
			# By-name form: harvest the full inherited method surface (own +
			# domain ancestors), so Ask/Explain see what the object can REALLY do.
			@cName = pcTarget
			@cSource = _StzResolveSource(pcTarget)
			@aMethods = _StzHarvestChain(pcTarget)
		ok

	  #==========================================================#
	 #   INTROSPECTION                                          #
	#==========================================================#
	def ClassName()
		return @cName

	def Source()
		return @cSource

	def NumberOfMethods()
		return len(@aMethods)

	def MethodNames()
		_aMn_ = []
		_nN_ = len(@aMethods)
		for _i_ = 1 to _nN_
			_aMn_ + @aMethods[_i_][1]
		next
		return _aMn_

	def HasMethod(pcName)
		return This._IndexOf(pcName) > 0

	def DescriptionOf(pcName)
		_ix_ = This._IndexOf(pcName)
		if _ix_ = 0 return "" ok
		return @aMethods[_ix_][2]

	# The class that actually DEFINES pcName (this class or an ancestor it inherits
	# from). "" if the method is unknown.
	def DefiningClassOf(pcName)
		_ix_ = This._IndexOf(pcName)
		if _ix_ = 0 return "" ok
		return @aMethods[_ix_][4]

	# How many of the harvested methods are inherited (defined by an ancestor).
	def NumberOfInheritedMethods()
		_n_ = 0
		_nN_ = len(@aMethods)
		for _i_ = 1 to _nN_
			if lower(@aMethods[_i_][4]) != lower(@cName) _n_++ ok
		next
		return _n_

	  #==========================================================#
	 #   EXPLAIN (deterministic, templated -- no model)        #
	#==========================================================#
	# ExplainMethod(name) -- a plain-language explanation of one method (DATA,
	# a string): its name + doc-comment (or a name-derived phrase if undocumented).
	def ExplainMethod(pcName)
		_ix_ = This._IndexOf(pcName)
		if _ix_ = 0
			return "No method '" + pcName + "' in " + @cName + "."
		ok
		_cD_ = @aMethods[_ix_][2]
		if _cD_ = ""
			_cD_ = "(" + _StzSplitCamel(@aMethods[_ix_][1]) + ")"
		ok
		_cOut_ = @aMethods[_ix_][1] + " -- " + _cD_
		if lower(@aMethods[_ix_][4]) != lower(@cName)
			_cOut_ += "  [inherited from " + @aMethods[_ix_][4] + "]"
		ok
		# Point at a provably-running example from the tests, if one exercises it.
		_aEg_ = _StzExampleFor(lower(@aMethods[_ix_][1]))
		if len(_aEg_) = 3
			_cOut_ += nl + "  e.g. tested in: " + _aEg_[1]
		ok
		return _cOut_

	def Show()
		? "stzSelfDoc [ " + @cName + " : " + len(@aMethods) + " methods ]"
		return This

	  #==========================================================#
	 #   ASK (semantic -- embeddings/reranker or lexical)      #
	#==========================================================#
	# Ask(question) -- the methods whose MEANING best matches a plain-English
	# question, as [ [name, score, description], ... ] best first (DATA). Uses the
	# loaded embedding model (2c) when present, else lexical similarity -- so it
	# works with zero setup and sharpens with a model. The near-natural-
	# programming entry: describe what you want, get the operation.
	def Ask(pcQuestion)
		return This.AskFor(pcQuestion, 3)

	def AskFor(pcQuestion, n)
		if NOT isString(pcQuestion) return [] ok
		_nM_ = len(@aMethods)
		if _nM_ = 0 return [] ok
		if NOT isNumber(n) or n < 1 n = 3 ok

		_aTexts_ = []
		_aBonus_ = []
		for _i_ = 1 to _nM_
			_aTexts_ + _StzMethodRetrievalText(@aMethods[_i_])
			# Own methods get a small prior over inherited ones (see the ranker).
			if lower(@aMethods[_i_][4]) = lower(@cName)
				_aBonus_ + 0.05
			else
				_aBonus_ + 0
			ok
		next
		if StzHasNeuralModel() and NOT StzHasRerankerModel()
			This._EnsureIndex()
		ok
		_aTop_ = _StzRankMethodTextsBonus(pcQuestion, _aTexts_, @aVectors, n, _aBonus_)

		_aOut_ = []
		_nT_ = len(_aTop_)
		for _i_ = 1 to _nT_
			_ix_ = _aTop_[_i_][1]
			_aOut_ + [ @aMethods[_ix_][1], _aTop_[_i_][2], @aMethods[_ix_][2] ]
		next
		return _aOut_

	# The single best-matching method name for a question (DATA, a string).
	def BestMethodFor(pcQuestion)
		_aR_ = This.AskFor(pcQuestion, 1)
		if len(_aR_) = 0 return "" ok
		return _aR_[1][1]

	#-- private -------------------------------------------------
	def _IndexOf(pcName)
		if NOT isString(pcName) return 0 ok
		_cL_ = lower(pcName)
		_nN_ = len(@aMethods)
		for _i_ = 1 to _nN_
			if lower(@aMethods[_i_][1]) = _cL_ return _i_ ok
		next
		return 0

	def _EnsureIndex()
		if @bIndexed return ok
		@aVectors = []
		_nN_ = len(@aMethods)
		for _i_ = 1 to _nN_
			@aVectors + _StzEmbedInto(_StzMethodRetrievalText(@aMethods[_i_]))
		next
		@bIndexed = TRUE
