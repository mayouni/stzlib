#--------------------------------------------------------------#
#      SOFTANZA LIBRARY (V1.2) - STZLIBDOC                      #
#   An accelerative library for Ring applications, and more!    #
#--------------------------------------------------------------#
#                                                              #
#   Description  : stzLibDoc -- self-documentation across MANY    #
#                  classes at once. Harvests each class's methods  #
#                  + doc-comments from source into one index, so   #
#                  Ask() spans the whole (curated) library: "which  #
#                  Softanza method does X?" -- and the answer names  #
#                  the CLASS it lives in. Same neural brain as       #
#                  stzSelfDoc: reranker (retrieve-then-rerank) >      #
#                  embeddings > lexical, whichever model is loaded.   #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)        #
#                                                              #
#--------------------------------------------------------------#

# StzLibDocQ(aClasses) -- cross-class self-doc over the given classes (or the
# default curated set when the list is empty/omitted). ONE creation function,
# named for its class + Q (the house rule).
func StzLibDocQ(paClasses)
	if isList(paClasses) and len(paClasses) > 0
		return new stzLibDoc(paClasses)
	ok
	return new stzLibDoc(_StzDefaultDocClasses())

# The curated default set: kept LEAN so the embedding index (built lazily on the
# first Ask when an embedding model is loaded) stays fast. For a big cross-class
# corpus, prefer a reranker model -- its lexical-narrow-then-cross-encode path
# builds no index and scales to thousands of methods. Pass your own class list to
# StzLibDocQ([...]) to widen the scope.
func _StzDefaultDocClasses()
	return [ "stzText", "stzListOfTexts" ]

# Indexes the methods and doc blocks of many classes at once, so a plain-English question finds the method and the class that holds it.
#
# It harvests each named class with its inherited methods from the source, files every method under
# the class that defines it, and adds the intent recipes, small units that answer a how-do-I
# question with a runnable snippet. Ask ranks the entries by the meaning of the words: a lexical
# match first, with a loaded embedding or reranker model rescuing questions that share no word.
# Nothing is generated; the answer is always something the library already holds. Keep the class
# list short, since a large list costs index time when an embedding model is loaded.
#
#   receiver   o1 = new stzLibDoc([ "stzAgentSkill", "stzAgentMemory" ])
#   example    ? o1.NumberOfClasses()
#              #--> 2
#              ? o1.NumberOfRecipes() > 0
#              #--> 1
#              ? o1.BestMethodFor("remember a fact")
#              #--> stzAgentMemory.Fact
#              ? o1.Ask("detect the language of a text")[1][1]
#              #--> (recipe)
#   see        stzSelfDoc, StzLibDocQ
class stzLibDoc from stzObject

	@aEntries = []    # [ ownerOrKind, name, description ] (kind "(recipe)" for recipes)
	@aTexts = []      # per-entry "name-as-words + description" (built once)
	@aVectors = []    # per-entry embedding (lazy; embedding model only)
	@bIndexed = 0
	@nRecipes = 0     # how many entries are intent recipes
	@nSamples = 0     # how many entries are harvested test samples

	# Reads the methods and doc blocks of several classes, with those they inherit, into one searchable index, and adds the intent recipes.
	#
	#   paClasses   a list of class names
	#   returns     nothing; the object is built
	#   note        each method is filed under the class that defines it, so a question can tell
	#               which class has it
	#   warning     the recipes are added even for an empty list, but not when the argument is not a
	#               list
	#   see         Ask, NumberOfEntries
	def init(paClasses)
		if NOT isList(paClasses) return ok
		_nC_ = len(paClasses)
		for _c_ = 1 to _nC_
			_cClass_ = paClasses[_c_]
			if isString(_cClass_)
				# Harvest own + inherited methods; report each under the class
				# that actually DEFINES it (the owner), so "which class has X?"
				# answers truthfully across the inheritance chain.
				_aM_ = _StzHarvestChain(_cClass_)
				_aM_ = _StzFillSiblingAka(_aM_)   # voice-sibling aka symmetry
				_nM_ = len(_aM_)
				for _m_ = 1 to _nM_
					@aEntries + [ _aM_[_m_][4], _aM_[_m_][1], _aM_[_m_][2] ]
					@aTexts + _StzMethodRetrievalText([ _aM_[_m_][1], _aM_[_m_][2], _aM_[_m_][3] ])
				next
			ok
		next

		# Union in the intent RECIPES (kind "(recipe)"): atomic "one intent -> one
		# solution" units, so a conversational "how do I X" query surfaces a
		# runnable snippet, not just a method name (info-tagging strategy L4). The
		# recipe's retrieval text is its intent + tags (user-language synonyms).
		_aRec_ = _StzHarvestRecipes(_StzRecipesDir())
		_nR_ = len(_aRec_)
		for _r_ = 1 to _nR_
			@aEntries + [ "(recipe)", _aRec_[_r_][1], _aRec_[_r_][4] ]
			@aTexts + ( _aRec_[_r_][1] + " " + _StzCommasToSpaces(_aRec_[_r_][2]) )
			@nRecipes++
		next

	# Returns how many entries the index holds, methods, recipes and test samples together.
	#
	#   returns    a number
	#   see        NumberOfClasses, NumberOfRecipes, NumberOfSamples
	def NumberOfEntries()
		return len(@aEntries)

	# Returns how many distinct classes own the harvested methods, ancestors that define some included.
	#
	#   returns    a number
	#   see        NumberOfEntries
	def NumberOfClasses()
		_aSeen_ = []
		_nE_ = len(@aEntries)
		for _i_ = 1 to _nE_
			if @aEntries[_i_][1] != "(recipe)" and ring_find(_aSeen_, @aEntries[_i_][1]) = 0
				_aSeen_ + @aEntries[_i_][1]
			ok
		next
		return len(_aSeen_)

	# Adds the verified calls of the given test topics to the index, so a question can surface a call that is known to run.
	#
	#   paTopics   a list of test topic names, such as agentic
	#   returns    nothing; use AddTestSamplesQ to chain
	#   note       a topic that does not exist adds nothing; the index is rebuilt at the next
	#              question
	#   see        NumberOfSamples, Ask
	#@ aka  Union in the TEST SAMPLES of the given test topics (L3): every narrated Then("desc", code, expected) becomes an "(example)" record -- a natural query can surface a REAL verified call. Chainable; re-index on next Ask.
	def AddTestSamples(paTopics)
		if NOT isList(paTopics) return This ok
		_nT_ = len(paTopics)
		for _t_ = 1 to _nT_
			_aS_ = _StzHarvestTestSamples(paTopics[_t_])
			_nS_ = len(_aS_)
			for _s_ = 1 to _nS_
				@aEntries + [ "(example)", _aS_[_s_][1],
					_aS_[_s_][2] + "  #--> " + _aS_[_s_][3] ]
				@aTexts + (_aS_[_s_][1] + " " + _aS_[_s_][2])
				@nSamples++
			next
		next
		@bIndexed = 0

		def AddTestSamplesQ(paTopics)
			This.AddTestSamples(paTopics)
			return This

	# Returns how many test samples were added.
	#
	#   returns    a number
	#   see        AddTestSamples
	def NumberOfSamples()
		return @nSamples

	# Returns how many intent recipes are in the index.
	#
	#   returns    a number
	#   see        NumberOfEntries
	def NumberOfRecipes()
		return @nRecipes

	# Returns the five entries that best match a plain-English question across all the classes, best first.
	#
	#   pcQuestion   the question in plain English
	#   returns      a list of [ class, method, score, description ] rows; the class is (recipe),
	#                (example) or (world) for those kinds of entry
	#   note         a question with no content word, or no shared word, gives an empty list
	#   see          AskFor, BestMethodFor
	#@ aka  Ask(question) -- which methods, ACROSS the harvested classes, best match the question by MEANING: [ [class, method, score, description], ... ] best first.
	def Ask(pcQuestion)
		return This.AskFor(pcQuestion, 5)

	# Returns the entries that best match a question across all the classes, up to a number asked for, best first.
	#
	#   pcQuestion   the question in plain English
	#   n            how many entries to return, 5 when below 1
	#   returns      a list of [ class, method, score, description ] rows
	#   note         a question about an entity of the world, such as what is X, puts a (world) row
	#                first; a loaded embedding or reranker model is used when present, and otherwise
	#                the word match runs alone
	#   see          Ask, BestMethodFor
	def AskFor(pcQuestion, n)
		# THE WORLD DOOR (see stzSelfDoc.AskFor): entity-world answers
		# join the ranked results as "(world)" entries, best first
		_aWd_ = _StzWorldDoorEntry(pcQuestion)
		_aMt_ = This._AskForMethods(pcQuestion, n)
		if len(_aWd_) = 0
			return _aMt_
		ok
		_aOut_ = []
		_aOut_ + [ "(world)", _aWd_[1], 1, _aWd_[2] ]
		_nWm_ = len(_aMt_)
		for _iWm_ = 1 to _nWm_
			_aOut_ + _aMt_[_iWm_]
		next
		return _aOut_

	def _AskForMethods(pcQuestion, n)
		if NOT isString(pcQuestion) return [] ok
		_nE_ = len(@aEntries)
		if _nE_ = 0 return [] ok
		if NOT isNumber(n) or n < 1 n = 5 ok
		_aQC_ = _StzStrictContentTokens(pcQuestion)
		if len(_aQC_) = 0 return [] ok

		if StzHasNeuralModel() and NOT StzHasRerankerModel()
			This._EnsureIndex()
		ok
		# Intent RECIPES get a small prior: on an intent-shaped query they should
		# win a tie against an incidental method match (e.g. a "detect the
		# language" recipe over the SetLanguage setter), because a recipe answers
		# with a runnable snippet. Small enough to only tip genuine ties.
		_aBonus_ = []
		_aHeads_ = []
		_cCue_ = _StzQueryFormCue(pcQuestion)
		_nE2_ = len(@aEntries)
		for _iB_ = 1 to _nE2_
			if @aEntries[_iB_][1] = "(example)"
				# a verified real call: small tie-only prior
				_aBonus_ + 0.04
				_aHeads_ + ""
			but @aEntries[_iB_][1] = "(recipe)"
				# a recipe IS the imperative answer -- under a verb-
				# initial cue it keeps pace with the boosted active
				# methods (same lift); otherwise its usual small edge
				if _cCue_ = "imperative"
					_aBonus_ + 0.30
				else
					_aBonus_ + 0.05
				ok
				_aHeads_ + ""
			else
				# form preference + tiny shorter-name nudge (see stzSelfDoc.AskFor)
				_aBonus_ + ( _StzFormPreferenceBonus(@aEntries[_iB_][2], _cCue_) - 0.0002 * len(@aEntries[_iB_][2]) )
				_aHeads_ + _StzParseName(@aEntries[_iB_][2])[1]
			ok
		next
		_aTop_ = _StzRankMethodTextsHeaded(pcQuestion, @aTexts, @aVectors, n, _aBonus_, _aHeads_)

		_bLex_ = NOT StzHasNeuralModel()
		_aOut_ = []
		_nT_ = len(_aTop_)
		for _i_ = 1 to _nT_
			_ix_ = _aTop_[_i_][1]
			if _bLex_ and NOT _StzTextSharesToken(@aTexts[_ix_], _aQC_) loop ok
			_aOut_ + [ @aEntries[_ix_][1], @aEntries[_ix_][2], _aTop_[_i_][2], @aEntries[_ix_][3] ]
		next
		return _aOut_

	# Returns the single best match for a question as class.method.
	#
	#   pcQuestion   the question in plain English
	#   returns      a text such as stzAgentMemory.Fact; empty when nothing matches
	#   note         a recipe or a sample can come first, and then the text is its class kind and
	#                its title
	#   see          Ask
	#@ aka  The single best "class.method" for a question (DATA, a string).
	def BestMethodFor(pcQuestion)
		_aR_ = This._AskForMethods(pcQuestion, 1)
		if len(_aR_) = 0 return "" ok
		return _aR_[1][1] + "." + _aR_[1][2]

	# every entry whose method name is name-exact or a voice-sibling
	# (Verb/Verbed) of pcName: [ [class, method, description], ... ].
	# Deterministic sweep -- no ranking; WhatIs()'s library door.
	def _NameSites(pcName)
		_aOut_ = []
		if NOT isString(pcName)
			return _aOut_
		ok
		_cN_ = StzLower(ring_trim(pcName))
		_nE_ = len(@aEntries)
		for _i_ = 1 to _nE_
			if @aEntries[_i_][1] != "(recipe)" and
			   _StzNamesAreFormSiblings(StzLower(@aEntries[_i_][2]), _cN_)
				_aOut_ + [ @aEntries[_i_][1], @aEntries[_i_][2], @aEntries[_i_][3] ]
			ok
		next
		return _aOut_

	# Prints one line with the number of classes and entries.
	#
	#   returns    the index itself
	#   see        NumberOfEntries
	def Show()
		? "stzLibDoc [ " + This.NumberOfClasses() + " classes, " + len(@aEntries) + " methods ]"
		return This

	def _EnsureIndex()
		if @bIndexed return ok
		@aVectors = []
		_nE_ = len(@aTexts)
		for _i_ = 1 to _nE_
			@aVectors + _StzEmbedInto(@aTexts[_i_])
		next
		@bIndexed = 1
