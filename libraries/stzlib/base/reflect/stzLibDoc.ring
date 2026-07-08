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

# StzLibDoc(aClasses) -- cross-class self-doc over the given classes (or the
# default curated set when the list is empty/omitted).
func StzLibDoc(paClasses)
	if isList(paClasses) and len(paClasses) > 0
		return new stzLibDoc(paClasses)
	ok
	return new stzLibDoc(_StzDefaultDocClasses())

func StzLibDocQ(paClasses)
	return StzLibDoc(paClasses)

# The curated default set: kept LEAN so the embedding index (built lazily on the
# first Ask when an embedding model is loaded) stays fast. For a big cross-class
# corpus, prefer a reranker model -- its lexical-narrow-then-cross-encode path
# builds no index and scales to thousands of methods. Pass your own class list to
# StzLibDoc([...]) to widen the scope.
func _StzDefaultDocClasses()
	return [ "stzText", "stzListOfTexts" ]

class stzLibDoc from stzObject

	@aEntries = []    # [ ownerOrKind, name, description ] (kind "(recipe)" for recipes)
	@aTexts = []      # per-entry "name-as-words + description" (built once)
	@aVectors = []    # per-entry embedding (lazy; embedding model only)
	@bIndexed = FALSE
	@nRecipes = 0     # how many entries are intent recipes

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

	def NumberOfEntries()
		return len(@aEntries)

	def NumberOfClasses()
		_aSeen_ = []
		_nE_ = len(@aEntries)
		for _i_ = 1 to _nE_
			if @aEntries[_i_][1] != "(recipe)" and ring_find(_aSeen_, @aEntries[_i_][1]) = 0
				_aSeen_ + @aEntries[_i_][1]
			ok
		next
		return len(_aSeen_)

	def NumberOfRecipes()
		return @nRecipes

	# Ask(question) -- which methods, ACROSS the harvested classes, best match the
	# question by MEANING: [ [class, method, score, description], ... ] best first.
	def Ask(pcQuestion)
		return This.AskFor(pcQuestion, 5)

	def AskFor(pcQuestion, n)
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
			if @aEntries[_iB_][1] = "(recipe)"
				_aBonus_ + 0.05
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

	# The single best "class.method" for a question (DATA, a string).
	def BestMethodFor(pcQuestion)
		_aR_ = This.AskFor(pcQuestion, 1)
		if len(_aR_) = 0 return "" ok
		return _aR_[1][1] + "." + _aR_[1][2]

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
		@bIndexed = TRUE
