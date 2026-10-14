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
#                  natural programming: describe intent, get   #
#                  the operation. Deterministic, zero hallucination.#
#   Author       : Mansour Ayouni (kalidianow@gmail.com)        #
#                                                              #
#--------------------------------------------------------------#

# StzSelfDocQ(cClassNameOrPath) -- the self-doc of a class (by name or source
# path). ONE creation function, named for its class + Q (the house rule).
func StzSelfDocQ(pcTarget)
	return new stzSelfDoc(pcTarget)

# Lets a class describe itself: it reads the methods and doc blocks from the source, then answers plain-English questions and explains each method.
#
# The knowledge already lives in the library; this indexes it. A class is read by name, with every
# method it inherits, or by the path of its source file. ExplainMethod and RecordOf say only what
# the author wrote in the doc block and what the tests show. Ask ranks the methods by meaning, a
# word match first with a loaded embedding or reranker model as a rescue, deterministic and with no
# generation. HowTo goes from an intent to a call template. Retrieval is by shared words, so check
# the answer when two methods share the question's words.
#
#   receiver   o1 = new stzSelfDoc("stzAgentSkill")
#   example    ? o1.NumberOfMethods()
#              #--> 9
#              ? o1.HasMethod("apply")
#              #--> 1
#              ? o1.DefiningClassOf("Apply")
#              #--> stzAgentSkill
#              ? o1.BestMethodFor("run the action only when the precondition holds")
#              #--> Apply
#              ? o1.RecordOf("Kind")[:returns]
#              #--> the text pi or llm
#   see        stzLibDoc, StzSelfDocQ, stzDocRecord
class stzSelfDoc from stzObject

	@cName = ""       # class name (e.g. "stzText")
	@cSource = ""     # resolved source file path
	@aMethods = []    # [ [name, description, aka, ownerClass], ... ] own + inherited
	@aVectors = []    # per-method embedding (lazy; only when a model is loaded)
	@bIndexed = 0
	@aRetTexts = []   # per-method retrieval text (query-INDEPENDENT; built once)
	@aRetHeads = []   # per-method head words (query-independent; built once)
	@bRetBuilt = 0

	# Reads a class's methods and doc blocks from its source, including the ones it inherits, so it can answer questions about them.
	#
	#   pcTarget   a class name, or the path of a .ring file for the class it names
	#   returns    nothing; the object is built
	#   note       a path harvests only that file's class, with no inherited methods
	#   warning    anything that is not a text raises an error; an unknown class name builds an
	#              object with no methods
	#   see        ClassName, Ask
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
		# Voice-sibling aka symmetry: an active form inherits its passive sibling's
		# operation synonyms (and vice versa), so imperatives find the active form.
		@aMethods = _StzFillSiblingAka(@aMethods)

	  #==========================================================#
	 #   INTROSPECTION                                          #
	#==========================================================#
	# Returns the class the object describes.
	#
	#   returns    a text
	#   see        Source
	def ClassName()
		return @cName

	# Returns the path of the source file the class was found in.
	#
	#   returns    a text; empty when the class is unknown
	#   see        ClassName
	def Source()
		return @cSource

	# Returns how many methods were harvested, own and inherited.
	#
	#   returns    a number
	#   see        MethodNames, NumberOfInheritedMethods
	def NumberOfMethods()
		return len(@aMethods)

	# Returns the names of the harvested methods, in source order.
	#
	#   returns    a list of text
	#   see        HasMethod, NumberOfMethods
	def MethodNames()
		_aMn_ = []
		_nN_ = len(@aMethods)
		for _i_ = 1 to _nN_
			_aMn_ + @aMethods[_i_][1]
		next
		return _aMn_

	# TRUE if the class has a method of that name, own or inherited; case is ignored.
	#
	#   pcName     the method name
	#   returns    TRUE or FALSE
	#   see        MethodNames, DescriptionOf
	def HasMethod(pcName)
		return This._IndexOf(pcName) > 0

	# Returns the brief written above a method.
	#
	#   pcName     the method name, in any case
	#   returns    a text; empty for an unknown method or an undocumented one
	#   see        ExplainMethod, RecordOf
	def DescriptionOf(pcName)
		_ix_ = This._IndexOf(pcName)
		if _ix_ = 0 return "" ok
		return @aMethods[_ix_][2]

	# Returns the class that defines a method: this class or an ancestor it inherits from.
	#
	#   pcName     the method name
	#   returns    a text; empty for an unknown method
	#   see        NumberOfInheritedMethods, DescriptionOf
	#@ aka  The class that actually DEFINES pcName (this class or an ancestor it inherits from). "" if the method is unknown.
	def DefiningClassOf(pcName)
		_ix_ = This._IndexOf(pcName)
		if _ix_ = 0 return "" ok
		return @aMethods[_ix_][4]

	# Returns how many harvested methods are defined by an ancestor and not by the class itself.
	#
	#   returns    a number
	#   see        DefiningClassOf, NumberOfMethods
	#@ aka  How many of the harvested methods are inherited (defined by an ancestor).
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
	# Explains a method in plain words: its brief, parameter roles, return, notes, see-also, example and the form its name implies.
	#
	#   pcName     the method name
	#   returns    a multi-line text; a sentence saying the method is absent for an unknown name
	#   note       everything is read from what the author wrote and from the tests; nothing is
	#              invented or generated
	#   see        RecordOf, DescriptionOf
	#@ aka  ExplainMethod(name) -- a plain-language explanation of one method (DATA, a string): its name + doc-comment (or a name-derived phrase if undocumented).
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
		# Teach the function FORM (active mutates / passive returns a copy / ...).
		_cFn_ = _StzFormNote(@aMethods[_ix_][1])
		if _cFn_ != ""
			_cOut_ += nl + "  (" + _cFn_ + ")"
		ok
		# For a compositionally-rich name, spell its grammar out as a sentence --
		# the name IS the meaning (functions-as-linguistic-expressions).
		_aPn_ = _StzParseName(@aMethods[_ix_][1])
		if _StzHasRichFormTag(_aPn_[2])
			_cOut_ += nl + "  reads as: " + _StzNameGloss(@aMethods[_ix_][1])
		ok
		# What the author WROTE in the method's doc block, field by field (never
		# invented here): parameters, returns, notes, see-also, example.
		_aRec_ = This._RecordFor(_ix_)
		if len(_aRec_) > 0
			_aPr_ = _aRec_[:params]
			_nPr_ = len(_aPr_)
			for _iP_ = 1 to _nPr_
				_cRole_ = _StzDocWrittenRole(_aRec_, _aPr_[_iP_])
				if _cRole_ != ""
					_cOut_ += nl + "  " + _aPr_[_iP_] + " -- " + _cRole_
				ok
			next
			if _aRec_[:returns] != ""
				_cOut_ += nl + "  returns: " + _aRec_[:returns]
			ok
			_nNt_ = len(_aRec_[:notes])
			for _iN_ = 1 to _nNt_
				_cOut_ += nl + "  note: " + _aRec_[:notes][_iN_]
			next
			if _aRec_[:see] != ""
				_cOut_ += nl + "  see: " + _aRec_[:see]
			ok
			if _aRec_[:example] != ""
				_cOut_ += nl + "  example: " + StzReplace(_aRec_[:example], char(10), nl + "           ")
			ok
		ok
		# A provably-running example from the tests: prefer a real "code #--> output"
		# snippet; else name the scenario that exercises it.
		_aEg_ = _StzExampleFor(lower(@aMethods[_ix_][1]))
		if len(_aEg_) = 3
			if _aEg_[2] != ""
				_cOut_ += nl + "  e.g. " + _aEg_[2]
			but _aEg_[1] != ""
				_cOut_ += nl + "  e.g. tested in: " + _aEg_[1]
			ok
		ok
		return _cOut_

	# Returns what the author wrote in a method's doc block, field by field.
	#
	#   pcName     the method name
	#   returns    a hash list [ :name, :brief, :params, :fields, :returns, :notes, :see, :example,
	#              :since, :status ]; an empty list for an unknown method
	#   note       the record is read from the class's own source, so an inherited method answers
	#              from its owner's
	#   see        ExplainMethod, DescriptionOf
	#@ aka  RecordOf(name) -- what the author wrote in the method's doc block (a hashlist: :brief :params :returns :notes :see :example :since :status), [ ] if none.
	def RecordOf(pcName)
		_ix_ = This._IndexOf(pcName)
		if _ix_ = 0 return [] ok
		return This._RecordFor(_ix_)

	# Prints one line with the class name and the number of methods.
	#
	#   returns    the object itself
	#   see        NumberOfMethods
	def Show()
		? "stzSelfDoc [ " + @cName + " : " + len(@aMethods) + " methods ]"
		return This

	  #==========================================================#
	 #   ASK (semantic -- embeddings/reranker or lexical)      #
	#==========================================================#
	# Returns the three methods whose meaning best matches a plain-English question, best first.
	#
	#   pcQuestion   the question in plain English
	#   returns      a list of [ name, score, description ] rows; empty when nothing shares a word
	#                with the question
	#   note         the word match runs first and a loaded embedding or reranker model rescues
	#                questions that share no word, so a model can help and never hurt
	#   see          AskFor, BestMethodFor
	#@ aka  Ask(question) -- the methods whose MEANING best matches a plain-English question, as [ [name, score, description], ... ] best first (DATA). Uses the loaded embedding model (2c) when present, else lexical similarity -- so it works with zero setup and sharpens with a model. The natural- programming entry: describe what you want, get the operation.
	def Ask(pcQuestion)
		return This.AskFor(pcQuestion, 3)

	# Returns the methods whose meaning best matches a question, up to a number asked for, best first.
	#
	#   pcQuestion   the question in plain English
	#   n            how many methods to return, 3 when below 1
	#   returns      a list of [ name, score, description ] rows
	#   note         a question about an entity of the world, such as what is X, puts a (world) row
	#                first
	#   see          Ask, BestMethodFor
	def AskFor(pcQuestion, n)
		# THE WORLD DOOR: a "what is X / who is X" question consults the
		# entity world first -- one interrogative family, two knowledge
		# sources; world answers come as "(world)" entries, like recipes
		_aWd_ = _StzWorldDoorEntry(pcQuestion)
		_aMt_ = This._AskForMethods(pcQuestion, n)
		if len(_aWd_) = 0
			return _aMt_
		ok
		_aOut_ = []
		_aOut_ + [ "(world)", 1, _aWd_[2] ]
		_nWm_ = len(_aMt_)
		for _iWm_ = 1 to _nWm_
			_aOut_ + _aMt_[_iWm_]
		next
		return _aOut_

	def _AskForMethods(pcQuestion, n)
		if NOT isString(pcQuestion) return [] ok
		_nM_ = len(@aMethods)
		if _nM_ = 0 return [] ok
		if NOT isNumber(n) or n < 1 n = 3 ok
		# No-match guard: an empty or all-stopword query has no content to match.
		_aQC_ = _StzStrictContentTokens(pcQuestion)
		if len(_aQC_) = 0 return [] ok

		# Retrieval texts + heads are query-INDEPENDENT -- build them ONCE per object
		# (was rebuilt every AskFor: ~0.77s/query on stzString's 2112 methods).
		if NOT @bRetBuilt
			@aRetTexts = []
			@aRetHeads = []
			for _i_ = 1 to _nM_
				@aRetTexts + _StzMethodRetrievalText(@aMethods[_i_])
				@aRetHeads + _StzParseName(@aMethods[_i_][1])[1]
			next
			@bRetBuilt = 1
		ok
		# Bonus IS query-dependent (form cue) -- rebuild it (cheap): own-method prior
		# + FORM preference + a tiny SHORTER-NAME nudge. All small: tip ties only.
		_aBonus_ = []
		_cCue_ = _StzQueryFormCue(pcQuestion)
		for _i_ = 1 to _nM_
			_nb_ = 0
			if lower(@aMethods[_i_][4]) = lower(@cName) _nb_ = 0.05 ok
			_nb_ += _StzFormPreferenceBonus(@aMethods[_i_][1], _cCue_)
			_nb_ -= 0.0002 * len(@aMethods[_i_][1])
			_aBonus_ + _nb_
		next
		# HYBRID (measured): the curated-aka LEXICAL path is the STRONGEST for method
		# retrieval -- a 30-intent challenge scored lexical 19/30 vs reranker 15/30 vs
		# embedding 10/30 (terse aka bags are ideal for IDF, off-domain for the neural
		# models). So run LEXICAL first; the neural models only RESCUE queries lexical
		# can't touch (zero token overlap), so loading a model can only help, never hurt.
		_aScL_ = _StzLexScoreAllIdf(pcQuestion, @aRetTexts)
		_nsL_ = len(_aScL_)
		for _i_ = 1 to _nsL_
			_aScL_[_i_][2] += _aBonus_[ _aScL_[_i_][1] ]
		next
		_aTopL_ = _StzTopNScored(_aScL_, n)
		_aOut_ = []
		_ntL_ = len(_aTopL_)
		for _i_ = 1 to _ntL_
			_ix_ = _aTopL_[_i_][1]
			# a real match must SHARE a token (bonuses must not fabricate a phantom).
			if _StzTextSharesToken(@aRetTexts[_ix_], _aQC_)
				_aOut_ + [ @aMethods[_ix_][1], _aTopL_[_i_][2], @aMethods[_ix_][2] ]
			ok
		next
		if len(_aOut_) > 0 return _aOut_ ok
		# Lexical found nothing (zero overlap) -> NEURAL rescue by meaning, if a model
		# is loaded (embedding index / reranker cross-encode).
		if StzHasNeuralModel()
			if NOT StzHasRerankerModel() This._EnsureIndex() ok
			_aTopN_ = _StzRankMethodTextsHeaded(pcQuestion, @aRetTexts, @aVectors, n, _aBonus_, @aRetHeads)
			_aOut2_ = []
			_ntN_ = len(_aTopN_)
			for _i_ = 1 to _ntN_
				_ix_ = _aTopN_[_i_][1]
				_aOut2_ + [ @aMethods[_ix_][1], _aTopN_[_i_][2], @aMethods[_ix_][2] ]
			next
			return _aOut2_
		ok
		return []

	# Returns the name of the single method that best matches a question.
	#
	#   pcQuestion   the question in plain English
	#   returns      a text; empty when nothing matches
	#   note         it can pick a method whose words overlap the question rather than the one
	#                meant, such as init for a question about a precondition
	#   see          Ask, HowTo
	#@ aka  The single best-matching method name for a question (DATA, a string).
	def BestMethodFor(pcQuestion)
		_aR_ = This._AskForMethods(pcQuestion, 1)
		if len(_aR_) = 0 return "" ok
		return _aR_[1][1]

	  #==========================================================#
	 #   GENERATE (natural programming: intent -> a call) #
	#==========================================================#
	# Turns a plain-English intent into a call template on this class, by grammar when the class has the method and by meaning otherwise.
	#
	#   pcIntent   what is wanted, in plain English
	#   returns    a text such as Q(...).Forget("...", "...", "...") followed by how it was resolved
	#   note       when nothing matches it says that no method in the class does
	#   see        MethodForIntent, Ask
	#@ aka  HowTo(intent) -- resolve a plain-English intent to a runnable method call on this class, DETERMINISTICALLY (no LLM). Two engines, unified: (1) the GRAMMAR composes a method name from the intent and grounds it against this class's real API; if the class implements it, that is the answer (highest confidence, it is derived not guessed). (2) Otherwise fall back to semantic RETRIEVAL (the ranker: reran
	def HowTo(pcIntent)
		if NOT isString(pcIntent) return "" ok
		_cComposed_ = _StzComposeName(pcIntent)
		_cMethod_ = ""
		_cHow_ = ""
		if _cComposed_ != "" and This.HasMethod(_cComposed_)
			_cMethod_ = _cComposed_
			_cHow_ = "composed by grammar"
		else
			_aR_ = This._AskForMethods(pcIntent, 1)
			if len(_aR_) > 0
				_cMethod_ = _aR_[1][1]
				_cHow_ = "retrieved by meaning"
				# surface the coverage gap when the grammar named a valid-but-absent form
				if _cComposed_ != "" and NOT This.HasMethod(_cComposed_)
					_cHow_ += " (grammar suggested " + _cComposed_ + ", not implemented here)"
				ok
			ok
		ok
		if _cMethod_ = ""
			return "No method in " + @cName + " matches: " + pcIntent
		ok
		# owner = the class that DEFINES the method (may be an ancestor) -- its source
		# is where the signature (and thus the arg types) live.
		_ix_ = This._IndexOf(_cMethod_)
		_cOwner_ = @cName
		if _ix_ > 0 _cOwner_ = @aMethods[_ix_][4] ok
		return _StzCallTemplate(@cName, _cMethod_, _cOwner_) + "   -- " + _cHow_ + " (" + _StzNameGloss(_cMethod_) + ")"

	# Returns the name of the method that an intent resolves to, by grammar first and then by retrieval.
	#
	#   pcIntent   what is wanted, in plain English
	#   returns    a text; empty when nothing matches
	#   see        HowTo, BestMethodFor
	#@ aka  The resolved method NAME only (DATA), grammar-first then retrieval.
	def MethodForIntent(pcIntent)
		_cComposed_ = _StzComposeName(pcIntent)
		if _cComposed_ != "" and This.HasMethod(_cComposed_) return _cComposed_ ok
		return This.BestMethodFor(pcIntent)

	#-- private -------------------------------------------------
	# the written doc record of method number ix, read from this object's own
	# source when the method is its own and the object was opened by path
	def _RecordFor(pnIx)
		_cSrc_ = ""
		if StzLower(@aMethods[pnIx][4]) = StzLower(@cName)
			_cSrc_ = @cSource
		ok
		return StzDocRecordOfIn(@aMethods[pnIx][4], @aMethods[pnIx][1], _cSrc_)

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
		_nN_ = len(@aMethods)
		_aTexts_ = []
		for _i_ = 1 to _nN_ _aTexts_ + _StzMethodRetrievalText(@aMethods[_i_]) next
		# Fast path: load the persisted embedding index instead of re-embedding
		# every method (~80ms each). Keyed by model dims + texts signature.
		_aV_ = _StzLoadEmbCache(@cName, _aTexts_)
		if len(_aV_) = _nN_
			@aVectors = _aV_
			@bIndexed = 1
			return
		ok
		@aVectors = []
		for _i_ = 1 to _nN_
			@aVectors + _StzEmbedInto(_aTexts_[_i_])
		next
		_StzSaveEmbCache(@cName, _aTexts_, @aVectors)
		@bIndexed = 1
