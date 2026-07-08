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

	@aEntries = []    # [ className, methodName, description ]
	@aTexts = []      # per-entry "name-as-words + description" (built once)
	@aVectors = []    # per-entry embedding (lazy; embedding model only)
	@bIndexed = FALSE

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
				_nM_ = len(_aM_)
				for _m_ = 1 to _nM_
					@aEntries + [ _aM_[_m_][3], _aM_[_m_][1], _aM_[_m_][2] ]
					@aTexts + _StzMethodText([ _aM_[_m_][1], _aM_[_m_][2] ])
				next
			ok
		next

	def NumberOfEntries()
		return len(@aEntries)

	def NumberOfClasses()
		_aSeen_ = []
		_nE_ = len(@aEntries)
		for _i_ = 1 to _nE_
			if ring_find(_aSeen_, @aEntries[_i_][1]) = 0
				_aSeen_ + @aEntries[_i_][1]
			ok
		next
		return len(_aSeen_)

	# Ask(question) -- which methods, ACROSS the harvested classes, best match the
	# question by MEANING: [ [class, method, score, description], ... ] best first.
	def Ask(pcQuestion)
		return This.AskFor(pcQuestion, 5)

	def AskFor(pcQuestion, n)
		if NOT isString(pcQuestion) return [] ok
		_nE_ = len(@aEntries)
		if _nE_ = 0 return [] ok
		if NOT isNumber(n) or n < 1 n = 5 ok

		if StzHasNeuralModel() and NOT StzHasRerankerModel()
			This._EnsureIndex()
		ok
		_aTop_ = _StzRankMethodTexts(pcQuestion, @aTexts, @aVectors, n)

		_aOut_ = []
		_nT_ = len(_aTop_)
		for _i_ = 1 to _nT_
			_ix_ = _aTop_[_i_][1]
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
